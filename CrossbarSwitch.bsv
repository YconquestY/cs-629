import Vector::*;
import Ehr::*;

import Types::*;
import MessageTypes::*;
import SwitchAllocTypes::*;
import RoutingTypes::*;


interface CrossbarPort;
  method Action putFlit(Flit traverseFlit, DirIdx destDirn);
  method ActionValue#(Flit) getFlit; 
endinterface

interface CrossbarSwitch;
  interface Vector#(NumPorts, CrossbarPort) crossbarPorts; // nested `interface`
endinterface

(* synthesize *)
module mkCrossbarSwitch(CrossbarSwitch);
  Vector#(NumPorts, Ehr#(TAdd#(NumPorts, 1), Flit)) crossbar
    <- replicateM(mkEhr(Flit{nextDir: null_,
                             flitData: 0}));
/*
  implement the crossbar

  To define a vector of methods (with NumPorts*2 methods) you can use the following syntax:
*/
  Vector#(NumPorts, CrossbarPort) crossbarPortsConstruct;
  for (Integer ports=0; ports < valueOf(NumPorts); ports = ports+1) begin
    crossbarPortsConstruct[ports] =
      interface CrossbarPort
        method Action putFlit(Flit traverseFlit, DirIdx destDirn);
          //  body for your method putFlit[ports]
          crossbar[destDirn][ports] <= traverseFlit;
        endmethod
        method ActionValue#(Flit) getFlit;
          //  body for your method getFlit[ports]
          return crossbar[ports][valueOf(NumPorts)];
        endmethod
      endinterface;
  end
  interface crossbarPorts = crossbarPortsConstruct;
endmodule
