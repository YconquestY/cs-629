import BRAM::*;
import FIFO::*;
import FIFOF::*;
import SpecialFIFOs::*;
import MemTypes::*;
import Ehr::*;

// Note that this interface *is* symmetric. 
interface Cache512;
    method Action putFromProc(MainMemReq e);
    method ActionValue#(MainMemResp) getToProc();
    method ActionValue#(MainMemReq) getToMem();
    method Action putFromMem(MainMemResp e);
endinterface

// delete when you're done with it
typedef Bit#(1) PLACEHOLDER;

module mkCache(Cache512);
    BRAM_Configure cfg = defaultValue;
    cfg.loadFormat = tagged Binary "zero512.vmh";  // zero out for you

    // Rename this to a meaningful name if you're keeping it, or adding more.
    BRAM1Port#(PLACEHOLDER, PLACEHOLDER) example_bram <- mkBRAM1Server(cfg);

    // Remember the previous hints when applicable, especially defining useful types.

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
