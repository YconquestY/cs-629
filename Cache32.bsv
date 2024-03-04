// SINGLE CORE ASSOIATED CACHE -- stores words

import BRAM::*;
import FIFO::*;
import FIFOF::*;
import SpecialFIFOs::*;
import MemTypes::*;
import Ehr::*;
import Vector :: * ;

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
    
    method Action putFromProc(CacheReq e);
        noAction;
    endmethod

    method ActionValue#(Word) getToProc();
        return unpack(0);
    endmethod

    method ActionValue#(MainMemReq) getToMem();
        return unpack(0);
    endmethod

    method Action putFromMem(MainMemResp e);
        noAction;
    endmethod

endmodule
