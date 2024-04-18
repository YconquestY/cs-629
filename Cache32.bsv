// SINGLE CORE ASSOIATED CACHE -- stores words

import BRAM::*;
import FIFO::*;
import FIFOF::*;
import SpecialFIFOs::*;
import MemTypes::*;
import Ehr::*;
import Vector :: * ;
import CAU32::*;

// TODO: copy over from 3_a

interface Cache32;
    method Action putFromProc(CacheReq e);
    method ActionValue#(Word) getToProc();
    method ActionValue#(MainMemReq) getToMem();
    method Action putFromMem(MainMemResp e);
endinterface

(* synthesize *)
module mkCache32(Cache32);
    // TODO copy over from 3_a
    CAU32 cau <- mkCAU32;

    FIFO#(Word) hitQ <- mkBypassFIFO;

    FIFO#(CacheReq) currReqQ <- mkFIFO;
    Reg#(ReqStatus) state <- mkReg(WaitCAUResp);
    // L2$-side queues
    FIFO#(MainMemReq)  lineReqQ  <- mkFIFO;
    FIFO#(MainMemResp) lineRespQ <- mkFIFO;
    // process CAU response
    rule waitCAUResponse (state == WaitCAUResp);
        let tmp <- cau.resp;
        let currReq = currReqQ.first;
        case (tmp.hitMiss)
            LdHit: begin
                hitQ.enq(tmp.ldValue);
                currReqQ.deq;
            end
            StHit: begin
                currReqQ.deq;
            end
            Miss: begin
                let old = tmp.line;

                let oldState = old.state;
                if (oldState == Dirty) begin // writeback
                    let parsedAddr = parseAddress(currReq.addr);
                    lineReqQ.enq(MainMemReq{write: 1,
                                            addr : {old.tag, parsedAddr.index},
                                            data : pack(old.data)});
                    state <= SendReq;
                end
                else begin
                    lineReqQ.enq(MainMemReq{write: 0,
                                            addr : currReq.addr[31:6], // Why 26b address?
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
                                addr : currReq.addr[31:6], // Why 26b address?
                                data : ?});
        state <= WaitMemResp;
    endrule
    // process response from L2$
    rule waitL2Resp (state == WaitMemResp);
        let line = lineRespQ.first; lineRespQ.deq;
        let currReq = currReqQ.first; currReqQ.deq;
        let parsedAddr = parseAddress(currReq.addr);
        if (currReq.word_byte == 4'h0) begin // load
            LineData data = unpack(line);
            hitQ.enq(data[parsedAddr.woffset]);
            cau.update(parsedAddr.index, CacheLine{state: Clean,
                                                   tag: parsedAddr.tag,
                                                   data: data});
        end
        else begin // store
            LineData data = unpack(line);

            Vector#(4, Bit#(8)) from = unpack(data[parsedAddr.woffset]);
            Vector#(4, Bit#(8)) to   = unpack(currReq.data);
            for (Bit#(3) bo = 0; bo < 4; bo = bo + 1) begin
                if (currReq.word_byte[bo] == 1) begin
                    from[bo] = to[bo];
                end
            end

            data[parsedAddr.woffset] = pack(from);
            cau.update(parsedAddr.index, CacheLine{state: Dirty,
                                                   tag: parsedAddr.tag,
                                                   data: data});
        end
        state <= WaitCAUResp;
    endrule
    
    method Action putFromProc(CacheReq e) if (state != WaitMemResp); // 1-port BRAM!
        cau.req(e);
        currReqQ.enq(e);
    endmethod

    method ActionValue#(Word) getToProc();
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
