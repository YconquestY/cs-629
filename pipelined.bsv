import FIFO::*;
import SpecialFIFOs::*;
import RegFile::*;
import RVUtil::*;
import Vector::*;
import KonataHelper::*;
import Printf::*;
import Ehr::*;

import CacheInterface::*;

typedef struct { Bit#(4) byte_en; Bit#(32) addr; Bit#(32) data; } Mem deriving (Eq, FShow, Bits);

interface RVIfc;
    method ActionValue#(Mem) getIReq();
    method Action getIResp(Mem a);
    method ActionValue#(Mem) getDReq();
    method Action getDResp(Mem a);
    method ActionValue#(Mem) getMMIOReq();
    method Action getMMIOResp(Mem a);
endinterface

(* synthesize *)
module mkpipelined(RVIfc);
    // Interface with memory and devices (don't touch)
    FIFO#(Mem) toImem <- mkBypassFIFO;
    FIFO#(Mem) fromImem <- mkBypassFIFO;
    FIFO#(Mem) toDmem <- mkBypassFIFO;
    FIFO#(Mem) fromDmem <- mkBypassFIFO;
    FIFO#(Mem) toMMIO <- mkBypassFIFO;
    FIFO#(Mem) fromMMIO <- mkBypassFIFO;

    // TODO copy over your whole implementation.
  
    method ActionValue#(Mem) getIReq();
		toImem.deq();
		return toImem.first();
    endmethod
    method Action getIResp(Mem a);
    	fromImem.enq(a);
    endmethod
    method ActionValue#(Mem) getDReq();
		toDmem.deq();
		return toDmem.first();
    endmethod
    method Action getDResp(Mem a);
		fromDmem.enq(a);
    endmethod
    method ActionValue#(Mem) getMMIOReq();
		toMMIO.deq();
		return toMMIO.first();
    endmethod
    method Action getMMIOResp(Mem a);
		fromMMIO.enq(a);
    endmethod
endmodule
