// SINGLE CORE CACHE INTERFACE WITH NO PPP
import ClientServer::*;
import GetPut::*;
import Randomizable::*;
import MainMem::*;
import MemTypes::*;
import Cache32::*;
import Cache::*;
import FIFOF::*;


interface CacheInterface;
    method Action sendReqData(CacheReq req);
    method ActionValue#(Word) getRespData();
    method Action sendReqInstr(CacheReq req);
    method ActionValue#(Word) getRespInstr();
endinterface


module mkCacheInterface(CacheInterface);
    let verbose = True;
    MainMem mainMem <- mkMainMem(); 
    Cache32 cacheD <- mkCache32;
    Cache512 cacheL2 <- mkCache;
    Cache32 cacheI <- mkCache32;



    method Action sendReqData(CacheReq req);
    endmethod

    method ActionValue#(Word) getRespData() ;
    endmethod


    method Action sendReqInstr(CacheReq req);
    endmethod

    method ActionValue#(Word) getRespInstr();
    endmethod
endmodule
