import Vector::*;
import FIFO::*;
import FIFOF::*;
import SpecialFIFOs::*;

import Ehr::*;
import Types::*;
import MessageTypes::*;
import RoutingTypes::*;

import CrossbarSwitch::*;
import MatrixArbiter::*;

(* synthesize *)
module mkOutPortArbiter(NtkArbiter#(NumPorts));
    // We provide an implementation of a priority arbiter,
    // it gives you the following method: 
    // method ActionValue#(Bit#(numRequesters)) getArbit(Bit#(numRequesters) reqBit);
    // you send a bitvector of all the client that would like to access a resource,
    // and it selects one clients among all of them (returned in one-hot
    // encoding) You can look at the implementation in MatrixArbiter if you are
    // curious, but you could also use a more naive implementation that does not
    // record previous requests
    
    Integer n = valueOf(NumPorts);
    NtkArbiter#(NumPorts)	matrixArbiter <- mkMatrixArbiter(n);
    return matrixArbiter;
endmodule

typedef Vector#(NumPorts, Direction)  ArbReq;
typedef Vector#(NumPorts, Direction)  ArbReqBits;
typedef Bit#(NumPorts)                ArbRes;

interface DataLink;
    method ActionValue#(Flit)         getFlit;
    method Action                     putFlit(Flit flit);
endinterface

interface Router;
    method Bool isInited;
    interface Vector#(NumPorts, DataLink)    dataLinks;
endinterface

(* synthesize *)
module mkRouter(Router);

    /********************************* States *************************************/
    Reg#(Bool)                                inited         <- mkReg(False);
  
    FIFO#(ArbRes)                             arbResBuf      <- mkBypassFIFO;
    Vector#(NumPorts, FIFOF#(Flit))           inputBuffer    <- replicateM(mkSizedBypassFIFOF(4));
    Vector#(NumPorts, NtkArbiter#(NumPorts))  outPortArbiter <- replicateM(mkOutPortArbiter);
    CrossbarSwitch                            cbSwitch       <- mkCrossbarSwitch;
    Vector#(NumPorts, FIFOF#(Flit))           outputLatch   <- replicateM(mkSizedBypassFIFOF(1));
    
    rule doInitialize(!inited);
        // Some initialization for the priority arbiters
        for(Integer outPort = 0; outPort < valueOf(NumPorts); outPort = outPort+1) begin
            outPortArbiter[outPort].initialize;
        end
        inited <= True;
    endrule 


    rule rl_Switch_Arbitration(inited);
      
        /*
            Please implement the Switch Arbitration stage here
            push into arbResBuf
        */ 
        
    endrule

    rule rl_Switch_Traversal(inited);
        /*
           deq arbResBuf
           Read the input winners, and push them to the crossbar
        */ 

    endrule
    
    for(Integer outPort=0; outPort<valueOf(NumPorts); outPort = outPort+1)
    begin
        rule rl_enqOutLatch(inited);
            // Use several rules to dequeue from the cross bar output and push into the output ports queues 
        endrule
    end

    /***************************** Router Interface ******************************/

    Vector#(NumPorts, DataLink) dataLinksDummy;
    for(DirIdx prt = 0; prt < fromInteger(valueOf(NumPorts)); prt = prt+1)
    begin
        dataLinksDummy[prt] =

        interface DataLink
            method ActionValue#(Flit) getFlit if(outputLatch[prt].notEmpty);
                Flit retFlit = outputLatch[prt].first();
                outputLatch[prt].deq();
                return retFlit;
            endmethod

            method Action putFlit(Flit flit) if(inputBuffer[prt].notFull);
                inputBuffer[prt].enq(flit);
            endmethod
        endinterface;
    end 

    interface dataLinks = dataLinksDummy;

    method Bool isInited;
        return inited; 
    endmethod

endmodule
