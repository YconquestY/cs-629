import Vector::*;
import BRAM::*;

interface MM;
    method Action write_row_a(Vector#(16, Bit#(32)) row, Bit#(4) row_idx);
    method Action write_row_b(Vector#(16, Bit#(32)) row, Bit#(4) row_idx);
    method Action start();
    method ActionValue#(Vector#(16, Bit#(32))) resp_row_c();
endinterface

module mkMatrixMultiplyFolded(MM);
        // TODO Implement the interface according to design specification
endmodule



