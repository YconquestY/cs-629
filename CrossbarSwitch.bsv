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
  Vector#(NumPorts, Ehr#(TAdd#(NumPorts, 1), Bool)) valid
    <- replicateM(mkEhr(False));
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
          //$display("data=%d into port %d", traverseFlit.flitData, destDirn);
          crossbar[destDirn][ports] <= traverseFlit;
          valid[destDirn][ports] <= True;
        endmethod
        method ActionValue#(Flit) getFlit if (valid[ports][valueOf(NumPorts)]);
          //  body for your method getFlit[ports]
          valid[ports][valueOf(NumPorts)] <= False;
          return crossbar[ports][valueOf(NumPorts)];
        endmethod
      endinterface;
  end
  interface crossbarPorts = crossbarPortsConstruct;
endmodule
