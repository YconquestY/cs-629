import Vector::*;
import BRAM::*;
import FIFO::*;

// Time Spent:

interface MM;
    method Action write_row_a(Vector#(16, Bit#(32)) row, Bit#(4) row_idx);
    method Action write_row_b(Vector#(16, Bit#(32)) row, Bit#(4) row_idx);
    method Action start();
    method ActionValue#(Vector#(16, Bit#(32))) resp_row_c();
endinterface

typedef enum {
    Idle, // waiting for load
    Busy, // loading row
    Done  // row fully loaded
} RowState deriving (Bits, Eq, FShow);

module mkMatrixMultiplyFolded(MM);
    BRAM1Port#(Bit#(4), Vector#(16, Bit#(32))) m_a <- mkBRAM1Server(defaultValue);
    BRAM1Port#(Bit#(4), Vector#(16, Bit#(32))) m_b <- mkBRAM1Server(defaultValue);
    FIFO#(Vector#(16, Bit#(32))) m_c <- mkSizedFIFO(16); 

    Reg#(Vector#(16, Bit#(32))) row_a <- mkReg(unpack(0));
    Reg#(Vector#(16, Bit#(32))) row_b <- mkReg(unpack(0));
    Reg#(Vector#(16, Bit#(32))) row_c <- mkReg(unpack(0));

    Reg#(Bool) busy <- mkReg(False); // whether multiplier is busy
    Reg#(RowState) row_a_state <- mkReg(Idle);
    Reg#(RowState) row_b_state <- mkReg(Idle);

    Reg#(Bit#(5)) row_a_idx <- mkReg(0); // index of row read from A
    Reg#(Bit#(4)) row_b_idx <- mkReg(0); // index of row read from B; deliberate overflow!
    Reg#(Bit#(4)) col_idx   <- mkReg(0); // index of entry being computed; deliberate overflow!

    (* conflict_free = "load_row_a_store_row_c, store_row_c_patch, compute" *)

    // load new row from A and store result to C
    //     when the entire B has been computed
    rule load_row_a_store_row_c (busy && row_a_state == Idle);
        m_a.portA.request.put(
            BRAMRequest{
                write: False,
                responseOnWrite: False,
                address: truncate(row_a_idx),
                datain: ?
            }
        );
        row_a_state <= Busy;

        if (row_a_idx >= 1) begin
            m_c.enq(row_c);
            row_c <= unpack(0);
        end
        // `row_ac_idx` incremented elsewhere
    endrule

    rule store_row_c_patch (row_a_idx == 16);
        m_c.enq(row_c);
        row_a_idx <= 0;
    endrule

    rule cache_row_a (busy && row_a_state == Busy);
        let resp <- m_a.portA.response.get;
        row_a <= resp;
        row_a_state <= Done;
    endrule

    // load new row from B whenever the previous row has been computed
    rule load_row_b (busy && row_b_state == Idle);
        // end
        m_b.portA.request.put(
            BRAMRequest{
                write: False,
                responseOnWrite: False,
                address: row_b_idx,
                datain: ?
            }
        );
        row_b_state <= Busy;
        // `row_b_idx` incremented elsewhere
    endrule

    rule cache_row_b (busy && row_b_state == Busy);
        let resp <- m_b.portA.response.get;
        row_b <= resp;
        row_b_state <= Done;
    endrule

    rule compute (busy && row_a_state == Done
                       && row_b_state == Done);
        let a = row_a[row_b_idx];
        let b = row_b[col_idx];
        row_c[col_idx] <= row_c[col_idx] + a * b;

        col_idx <= col_idx + 1; // if already 15, overflow to 0
        if (col_idx == 15) begin
            row_b_state <= Idle;
            row_b_idx <= row_b_idx + 1; // if already 15, overflow to 0
            if (row_b_idx == 15) begin
                row_a_state <= Idle;
                row_a_idx <= row_a_idx + 1;
                if (row_a_idx == 15) begin
                    busy <= False;
                end
            end
        end
    endrule

    method Action write_row_a(Vector#(16, Bit#(32)) row, Bit#(4) row_idx) if (!busy);
        m_a.portA.request.put(
            BRAMRequest{
                write: True,
                responseOnWrite: False,
                address: row_idx,
                datain: row
            }
        );
    endmethod

    method Action write_row_b(Vector#(16, Bit#(32)) row, Bit#(4) row_idx) if (!busy);
        m_b.portA.request.put(
            BRAMRequest{
                write: True,
                responseOnWrite: False,
                address: row_idx,
                datain: row
            }
        );
    endmethod

    method Action start() if (!busy);
        row_c <= unpack(0);

        busy <= True;
        row_a_state <= Idle;
        row_b_state <= Idle;

        row_a_idx <= 0;
        row_b_idx <= 0;
        col_idx   <= 0;
    endmethod

    method ActionValue#(Vector#(16, Bit#(32))) resp_row_c();
        let resp = m_c.first(); m_c.deq();
        return resp;
    endmethod
endmodule
