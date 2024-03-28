import Vector::*;
import Ehr::*;

import Types::*;
import MessageTypes::*;
import SwitchAllocTypes::*;
import RoutingTypes::*;

import CrossbarBuffer::*;

interface CrossbarPort;
  method Action putFlit(Flit traverseFlit, DirIdx destDirn);
  method ActionValue#(Flit) getFlit; 
endinterface

interface CrossbarSwitch;
  interface Vector#(NumPorts, CrossbarPort) crossbarPorts;
endinterface

(* synthesize *)
module mkCrossbarSwitch(CrossbarSwitch);
  /*
    lab 5a
    @student, please implement the crossbar logic 
  */


endmodule
