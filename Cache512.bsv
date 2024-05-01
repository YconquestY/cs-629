import BRAM::*;
import FIFO::*;
import FIFOF::*;
import SpecialFIFOs::*;
import MemTypes::*;
import Ehr::*;
import CAU512::*;

// TODO: copy over from 3_a

interface Cache512;
    method Action putFromProc(MainMemReq e);
    method ActionValue#(MainMemResp) getToProc();
    method ActionValue#(MainMemReq) getToMem();
    method Action putFromMem(MainMemResp e);
endinterface

(* synthesize *)
module mkCache(Cache512);
    // TODO copy over from 3_a
    CAU512 cau <- mkCAU512;

    FIFO#(MainMemResp) hitQ <- mkBypassFIFO;

    FIFO#(MainMemReq) currReqQ <- mkFIFO;
    Reg#(ReqStatus) state <- mkReg(WaitCAUResp);
    // DRAM-side queues
    FIFO#(MainMemReq)  lineReqQ  <- mkFIFO;
    FIFO#(MainMemResp) lineRespQ <- mkFIFO;
    // process CAU response
    rule waitCAUResponse (state == WaitCAUResp);
        let tmp <- cau.resp;
        let currReq = currReqQ.first;
        case (tmp.hitMiss)
            LdHit: begin
                hitQ.enq(tmp.line.data);
                currReqQ.deq;
            end
            StHit: begin
                currReqQ.deq;
            end
            Miss: begin
                let old = tmp.line;

                let oldState = old.state;
                if (oldState == Dirty) begin // writeback
                    let parsedAddr = parseAddress2(currReq.addr);
                    lineReqQ.enq(MainMemReq{write: 1,
                                            addr : {old.tag, parsedAddr.index},
                                            data : old.data});
                    state <= SendReq;
                end
                else begin
                    lineReqQ.enq(MainMemReq{write: 0,
                                            addr : currReq.addr, // Why 26b address?
                                            data : ?});
                    state <= WaitMemResp;
                end
            end
        endcase
    endrule
    // send request to L2$
    rule sendL2Req (state == SendReq);
        let currReq = currReqQ.first;
        lineReqQ.enq(MainMemReq{write: 0,
                                addr : currReq.addr, // Why 26b address?
                                data : ?});
        state <= WaitMemResp;
    endrule
    // process response from L2$
    rule waitL2Resp (state == WaitMemResp);
        let line = lineRespQ.first; lineRespQ.deq;
        let currReq = currReqQ.first; currReqQ.deq;
        let parsedAddr = parseAddress2(currReq.addr);

        if (!unpack(currReq.write)) begin // load
            hitQ.enq(line);
            cau.update(parsedAddr.index, CacheLine2{state: Clean,
                                                    tag: parsedAddr.tag,
                                                    data: line});
        end
        else begin // store
            cau.update(parsedAddr.index, CacheLine2{state: Dirty,
                                                    tag: parsedAddr.tag,
                                                    data: line});
        end
        state <= WaitCAUResp;
    endrule

    method Action putFromProc(MainMemReq e) if (state != WaitMemResp); // 1-port BRAM!
        cau.req(e);
        currReqQ.enq(e);
    endmethod

    method ActionValue#(MainMemResp) getToProc();
        hitQ.deq;
        return hitQ.first;
    endmethod

    method ActionValue#(MainMemReq) getToMem();
        lineReqQ.deq;
        return lineReqQ.first;
    endmethod

    method Action putFromMem(MainMemResp e);
        lineRespQ.enq(e);
    endmethod

endmodule
