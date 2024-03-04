import BRAM::*;
import FIFO::*;
import FIFOF::*;
import SpecialFIFOs::*;
import MemTypes::*;
import Ehr::*;

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

    method Action putFromProc(MainMemReq e);
        noAction;
    endmethod

    method ActionValue#(MainMemResp) getToProc();
        return unpack(0);
    endmethod

    method ActionValue#(MainMemReq) getToMem();
        return unpack(0);
    endmethod

    method Action putFromMem(MainMemResp e);
        noAction;
    endmethod

endmodule
