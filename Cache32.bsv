// SINGLE CORE ASSOIATED CACHE -- stores words

import BRAM::*;
import FIFO::*;
import FIFOF::*;
import SpecialFIFOs::*;
import MemTypes::*;
import Ehr::*;
import Vector :: * ;
import CAU32::*;

// The types live in MemTypes.bsv

// Notice the asymmetry in this interface, as mentioned in lecture.
// The processor thinks in 32 bits, but the other side thinks in 512 bits.
interface Cache32;
    // processor-side methods
    method Action putFromProc(CacheReq e);
    method ActionValue#(Word) getToProc();
    // L2$-side methods
    method ActionValue#(MainMemReq) getToMem();
    method Action putFromMem(MainMemResp e); // A.k.a. `LineData`
endinterface

(* synthesize *)
module mkCache32(Cache32);
    // Did you make sure to define your data types in MemTypes.bsv? It will help you debug if you use types.

    // Hint 1: one way is to have one BRAM for data, vector of registers for the rest of the state
    // Hint 2: The index to those memories should be the same (number of line in the cache).
    // Hint 3: Define additional types and structs as necessary.
    CAU32 cau <- mkCAU32;

    FIFO#(Word) hitQ <- mkBypassFIFO;

    FIFO#(CacheReq) currReqQ <- mkFIFO;
    Reg#(ReqStatus) state <- mkReg(WaitCAUResp);
    // L2$-side queues
    FIFO#(MainMemReq)  lineReqQ  <- mkFIFO;
    FIFO#(MainMemResp) lineRespQ <- mkFIFO;
    // Reminder to instantiate a BRAM with byte enable:
    // BRAM1PortBE#(PLACEHOLDER, Bit#(512), 64) example_bram2 <- mkBRAM1ServerBE(cfg);  // also a placeholder

    // You may instead find it useful to use the CacheArrayUnit abstraction presented
    // in lecture. In that case, most of your logic would be in that module, which you 
    // can instantiate within this one.

    // Hint: Refer back to the slides for implementation details.
    // Hint: You may find it helpful to outline the necessary states and rules you'll need for your cache
    // Hint: Don't forget about $display
    // Hint: If you want to add in a store buffer, do it after getting it working without one.

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
