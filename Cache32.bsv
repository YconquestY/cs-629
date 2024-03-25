// SINGLE CORE ASSOIATED CACHE -- stores words

import BRAM::*;
import FIFO::*;
import FIFOF::*;
import SpecialFIFOs::*;
import MemTypes::*;
import Ehr::*;
import Vector :: * ;

// The types live in MemTypes.bsv

// Notice the asymmetry in this interface, as mentioned in lecture.
// The processor thinks in 32 bits, but the other side thinks in 512 bits.
interface Cache32;
    method Action putFromProc(CacheReq e);
    method ActionValue#(Word) getToProc();
    method ActionValue#(MainMemReq) getToMem();
    method Action putFromMem(MainMemResp e);
endinterface

// delete when you're done with it
typedef Bit#(1) PLACEHOLDER;

(* synthesize *)
module mkCache32(Cache32);
    BRAM_Configure cfg = defaultValue;
    cfg.loadFormat = tagged Binary "zero.vmh";  // zero out for you

    // Did you make sure to define your data types in MemTypes.bsv? It will help you debug if you use types.

    // Hint 1: one way is to have one BRAM for data, vector of registers for the rest of the state
    // Hint 2: The index to those memories should be the same (number of line in the cache).
    // Hint 3: Define additional types and structs as necessary.
    
    // Reminder to instantiate a BRAM with byte enable:
    // BRAM1PortBE#(PLACEHOLDER, Bit#(512), 64) example_bram2 <- mkBRAM1ServerBE(cfg);  // also a placeholder

    // You may instead find it useful to use the CacheArrayUnit abstraction presented
    // in lecture. In that case, most of your logic would be in that module, which you 
    // can instantiate within this one.

    // Hint: Refer back to the slides for implementation details.
    // Hint: You may find it helpful to outline the necessary states and rules you'll need for your cache
    // Hint: Don't forget about $display
    // Hint: If you want to add in a store buffer, do it after getting it working without one.

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
