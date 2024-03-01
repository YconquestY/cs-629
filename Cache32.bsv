// SINGLE CORE ASSOIATED CACHE -- stores words

import BRAM::*;
import FIFO::*;
import FIFOF::*;
import SpecialFIFOs::*;
import MemTypes::*;
import Ehr::*;
import Vector :: * ;

typedef Bit#(7) IndexAddr;



typedef struct { 
  Bit#(2) valid;
  Bit#(19) tag;
} CacheReqLine deriving (Eq, Bits);



typedef struct { 
  Bit#(32) addr;
  Bit#(32) data;
  Bit#(4) byte_en;
} StbReq deriving (Eq, Bits);

interface Cache32;
    method Action putFromProc(CacheReq e);
    method ActionValue#(Word) getToProc();
    method ActionValue#(MainMemReq) getToMem();
    method Action putFromMem(MainMemResp e);
endinterface

module mkCache32(Cache32);
  BRAM_Configure cfg = defaultValue;
  cfg.loadFormat = tagged Binary "zero.vmh";
  BRAM1Port#(IndexAddr, CacheReqLine) bram1 <- mkBRAM1Server(cfg);
  BRAM1PortBE#(IndexAddr, Vector#(16, Word), 64) bram2 <- mkBRAM1ServerBE(cfg);




  // TODO Write a Cache
  method Action putFromProc(CacheReq e);
  endmethod

  method ActionValue#(Word) getToProc();
  endmethod

  method ActionValue#(MainMemReq) getToMem();
  endmethod

  method Action putFromMem(MainMemResp e) if(!start_fill);
  endmethod


endmodule