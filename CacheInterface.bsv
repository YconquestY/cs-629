// SINGLE CORE CACHE INTERFACE WITH NO PPP
import MainMem::*;
import MemTypes::*;
import Cache32::*;
import Cache512::*;
// import FIFOF::*;


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

    method Action sendReqData(CacheReq req);
        noAction;
    endmethod

    method ActionValue#(Word) getRespData() ;
        return unpack(0);
    endmethod


    method Action sendReqInstr(CacheReq req);
        noAction;
    endmethod

    method ActionValue#(Word) getRespInstr();
        return unpack(0);
    endmethod
endmodule
