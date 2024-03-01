import BRAM::*;
import FIFO::*;
import FIFOF::*;
import SpecialFIFOs::*;
import MemTypes::*;
import Ehr::*;

typedef Bit#(8) IndexAddr;


typedef struct { 
  Bit#(18) tag; 
  IndexAddr idx; 
  MainMemReq memReq;
} CacheReq512 deriving (Eq, Bits);


typedef struct { 
  Bit#(2) valid;
  Bit#(18) tag;
  Bit#(512) data;
} CacheReq512Line deriving (Eq, Bits);



interface Cache512;
    method Action putFromProc(MainMemReq e);
    method ActionValue#(MainMemResp) getToProc();
    method ActionValue#(MainMemReq) getToMem();
    method Action putFromMem(MainMemResp e);
endinterface

module mkCache(Cache512);
  BRAM_Configure cfg = defaultValue;
  BRAM1Port#(IndexAddr, CacheReq512Line) bram <- mkBRAM1Server(cfg);
  cfg.loadFormat = tagged Binary "zero512.vmh";


  // TODO Write a Cache
  method Action putFromProc(MainMemReq e);
  endmethod

  method ActionValue#(MainMemResp) getToProc() ;
  endmethod

  method ActionValue#(MainMemReq) getToMem();
  endmethod

  method Action putFromMem(MainMemResp e);
  endmethod


endmodule
