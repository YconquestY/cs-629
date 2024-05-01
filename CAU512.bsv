import BRAM::*;
import Vector::*;
import FIFO::*;
import Ehr::*;
import MemTypes::*;


interface CAU512;
    method Action req(MainMemReq r);
    method ActionValue#(CAUResp2) resp();
    method Action update(LineIndex2 index, CacheLine2 line);
endinterface

(* synthesize *)
module mkCAU512(CAU512);
    BRAM_Configure cfg = defaultValue;
    cfg.loadFormat = tagged Binary "zero512.vmh";  // zero out for you

    Vector#(256, Reg#(LineState)) stateArray <- replicateM(mkReg(Invalid));
    Vector#(256, Reg#(LineTag2)) tagArray <- replicateM(mkReg(0));
    // use 1-port BRAM, see https://piazza.com/class/lrgt0dgrtpz590/post/113
    BRAM1Port#(LineIndex2, MainMemResp) dataArray <- mkBRAM1Server(cfg);
    
    Reg#(CAUStatus) status <- mkReg(Ready);
    FIFO#(MainMemReq) currReqQ <- mkFIFO;

    method Action req(MainMemReq r) if (status == Ready);
        status <= WaitResp;

        let index = parseAddress2(r.addr).index;
        dataArray.portA.request.put(BRAMRequest{write: False,
                                                responseOnWrite: False,
                                                address: index,
                                                datain: ?});
        // Reading `stateArray` and `tagArray` is done in `resp()`.
        currReqQ.enq(r);
    endmethod

    method ActionValue#(CAUResp2) resp() if (status == WaitResp);
        let data <- dataArray.portA.response.get;
        let currReq = currReqQ.first; currReqQ.deq;

        let parsedAddr = parseAddress2(currReq.addr);
        let index = parsedAddr.index;

        let state = stateArray[index];
        let reqTag = parsedAddr.tag;
        let oldTag = tagArray[index];
        let hit = reqTag == oldTag;
        if (state != Invalid && hit) begin
            status <= Ready;

            if (!unpack(currReq.write)) begin // load hit
                return CAUResp2{hitMiss: LdHit,
                                line: CacheLine2{state: ?,
                                                 tag: ?,
                                                 data: data}};
            end
            else begin // store hit
                dataArray.portA.request.put(BRAMRequest{write: True,
                                                        responseOnWrite: False,
                                                        address: index,
                                                        datain: currReq.data});
                stateArray[index] <= Dirty;
                return CAUResp2{hitMiss: StHit, line: ?};
            end
        end
        else begin // miss
            status <= WaitUpdate;
            let dirty = state == Dirty;
            return CAUResp2{hitMiss: Miss,
                            line: CacheLine2{state: state,
                                             tag: dirty ? oldTag : ?,
                                             data: dirty ? data : ?}};
        end
    endmethod

    method Action update(LineIndex2 index, CacheLine2 line) if (status == WaitUpdate);
        status <= Ready;

        stateArray[index] <= line.state;
        tagArray[index] <= line.tag;
        dataArray.portA.request.put(BRAMRequest{write: True,
                                                responseOnWrite: False,
                                                address: index,
                                                datain: line.data});
    endmethod
endmodule