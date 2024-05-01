// SINGLE CORE CACHE INTERFACE WITH NO PPP
import MainMem::*;
import MemTypes::*;
import Cache32::*;
import Cache512::*;
import FIFO::*;
import SpecialFIFOs::*;
import Ehr::*;


typedef enum { Ready, Busy } L2State deriving (Bits, Eq, FShow);
typedef enum { L1D, L1I } L2RespDest deriving (Bits, Eq, FShow);

interface CacheInterface;
    method Action sendReqData(CacheReq req);
    method ActionValue#(Word) getRespData();
    method Action sendReqInstr(CacheReq req);
    method ActionValue#(Word) getRespInstr();
endinterface


module mkCacheInterface(CacheInterface);
    let verbose = True;
    MainMem mainMem <- mkMainMem(); 
    Cache512 cacheL2 <- mkCache;
    Cache32 cacheI <- mkCache32;
    Cache32 cacheD <- mkCache32;

    // You need to add rules and/or state elements.
    FIFO#(CacheReq) toInstrCache   <- mkBypassFIFO;
    FIFO#(Word)     fromInstrCache <- mkBypassFIFO;
    FIFO#(CacheReq) toDataCache    <- mkBypassFIFO;
    FIFO#(Word)     fromDataCache  <- mkBypassFIFO;

    FIFO#(MainMemReq) instrCacheToL2 <- mkBypassFIFO;
    FIFO#(MainMemReq) dataCacheToL2  <- mkBypassFIFO;

    Ehr#(2, Bool) dReq <- mkEhr(False);
    Ehr#(2, Bool) iReq <- mkEhr(False);
    Reg#(L2State) l2State <- mkReg(Ready);

    FIFO#(L2RespDest) l2RespDest <- mkFIFO; // larger size?
    // connect processor and L1D
    rule proc2l1d;
        let l1Req = toDataCache.first; toDataCache.deq;
        cacheD.putFromProc(l1Req);
    endrule

    rule l1d2proc;
        let l1Resp <- cacheD.getToProc;
        fromDataCache.enq(l1Resp);
    endrule
    // connect processor and L1I
    rule proc2l1i;
        let l1Req = toInstrCache.first; toInstrCache.deq;
        cacheI.putFromProc(l1Req);
    endrule

    rule l1i2proc;
        let l1Resp <- cacheI.getToProc;
        fromInstrCache.enq(l1Resp);
    endrule
    // connect L1$ and L2$
    rule l1dPropose (l2State == Ready);
        let l2Req <- cacheD.getToMem;
        dataCacheToL2.enq(l2Req);
        dReq[0] <= True;
    endrule

    rule l1iPropose (l2State == Ready);
        let l2Req <- cacheI.getToMem;
        instrCacheToL2.enq(l2Req);
        iReq[0] <= True;
    endrule
    /* In an in-order pipeline, it is assumed that data are more frequently
     * requested than instructions. This may be different for an OoO pipeline.
     */
    rule l2Decide (l2State == Ready && (dReq[1] || iReq[1]));
        if (dReq[1]) begin // handle L1D request first
            l2RespDest.enq(L1D);

            let l2Req = dataCacheToL2.first; dataCacheToL2.deq;
            cacheL2.putFromProc(l2Req);

            if (iReq[1]) begin   // If both L1D and L1I report a miss in the
                l2State <= Busy; // same cycle, handle I$ miss in next cycle,
            end                  // and stop accepting requests.
        end
        else if (iReq[1]) begin // handle L1I request
            l2RespDest.enq(L1I);

            let l2Req = instrCacheToL2.first; instrCacheToL2.deq;
            cacheL2.putFromProc(l2Req);
        end
        // reset proposal
        dReq[1] <= False;
        iReq[1] <= False;
    endrule

    rule l2Outstanding (l2State == Busy);
        l2RespDest.enq(L1I);

        let l2Req = instrCacheToL2.first; instrCacheToL2.deq;
        cacheL2.putFromProc(l2Req);

        l2State <= Ready;
    endrule

    rule l22l1;
        let l2Resp <- cacheL2.getToProc;
        let dest = l2RespDest.first; l2RespDest.deq;
        if (dest == L1D) begin
            cacheD.putFromMem(l2Resp);
        end
        else begin // L1I
            cacheI.putFromMem(l2Resp);
        end
    endrule
    // connect L2$ and memory
    rule l22mem;
        let memReq <- cacheL2.getToMem;
        mainMem.put(memReq);
    endrule

    rule mem2l2;
        let memResp <- mainMem.get;
        cacheL2.putFromMem(memResp);
    endrule
    // connect processor and L1D
    method Action sendReqData(CacheReq req);
        toDataCache.enq(req);
    endmethod

    method ActionValue#(Word) getRespData() ;
        fromDataCache.deq();
        return fromDataCache.first();
    endmethod
    // connect processor and L1I
    method Action sendReqInstr(CacheReq req);
        toInstrCache.enq(req);
    endmethod

    method ActionValue#(Word) getRespInstr();
        fromInstrCache.deq();
        return fromInstrCache.first();
    endmethod
endmodule
