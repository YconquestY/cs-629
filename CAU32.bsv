import BRAM::*;
import Vector::*;
import FIFO::*;
import Ehr::*;
import MemTypes::*;


interface CAU;
    method Action req(CacheReq r);
    method ActionValue#(CAUResp) resp();
    method Action update(LineIndex index, CacheLine line);
endinterface

(* synthesize *)
module mkCAU(CAU);
    BRAM_Configure cfg = defaultValue;
    cfg.loadFormat = tagged Binary "zero.vmh";  // zero out for you

    Vector#(128, Reg#(LineState)) stateArray <- replicateM(mkReg(Invalid));
    Vector#(128, Reg#(LineTag)) tagArray <- replicateM(mkReg(0));
    // use 1-port BRAM, see https://piazza.com/class/lrgt0dgrtpz590/post/113
    BRAM1Port#(LineIndex, LineData) dataArray <- mkBRAM1Server(cfg);
    
    Reg#(Bool) ready <- mkReg(False);
    FIFO#(CacheReq) currReqQ <- mkFIFO;

    method Action req(CacheReq r) if (!ready);
        ready <= True;

        let index = parseAddress(r.addr).index;
        dataArray.portA.request.put(BRAMRequest{write: False,
                                                responseOnWrite: False,
                                                address: index,
                                                datain: ?});
        // Reading `stateArray` and `tagArray` is done in `resp()`.
        currReqQ.enq(r);
    endmethod

    method ActionValue#(CAUResp) resp() if (ready);
        ready <= False;

        let data <- dataArray.portA.response.get;
        let currReq = currReqQ.first; currReqQ.deq;

        let parsedAddr = parseAddress(currReq.addr);
        let index = parsedAddr.index;

        let state = stateArray[index];
        let reqTag = parsedAddr.tag;
        let oldTag = tagArray[index];
        let hit = reqTag == oldTag;
        let write = currReq.word_byte != 4'h0;
        if (state != Invalid && hit) begin
            if (!write) begin // load hit
                return CAUResp{hitMiss: LdHit,
                               ldValue: data[parsedAddr.woffset],
                               line: ?};
            end
            else begin // store hit
                Vector#(4, Bit#(8)) from = unpack(data[parsedAddr.woffset]);
                Vector#(4, Bit#(8)) to   = unpack(currReq.data);
                for (Bit#(3) bo = 0; bo < 4; bo = bo + 1) begin
                    if (currReq.word_byte[bo] == 1) begin
                        from[bo] = to[bo];
                    end
                end
                data[parsedAddr.woffset] = pack(from);
                dataArray.portA.request.put(BRAMRequest{write: True,
                                                        responseOnWrite: False,
                                                        address: index,
                                                        datain: data});
                stateArray[index] <= Dirty;
                return CAUResp{hitMiss: StHit, ldValue: ?, line: ?};
            end
        end
        else begin // miss
            let dirty = state == Dirty;
            return CAUResp{hitMiss: Miss,
                           ldValue: ?,
                           line: CacheLine{state: state,
                                           tag: dirty ? oldTag : ?,
                                           data: dirty ? data : ?}};
        end
    endmethod

    method Action update(LineIndex index, CacheLine line);
        stateArray[index] <= line.state;
        tagArray[index] <= line.tag;
        dataArray.portA.request.put(BRAMRequest{write: True,
                                                responseOnWrite: False,
                                                address: index,
                                                datain: line.data});
    endmethod
endmodule