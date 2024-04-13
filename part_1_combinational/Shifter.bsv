import Vector::*;

typedef Bit#(16) Word;

function Vector#(16, Word) naiveShfl(Vector#(16, Word) in, Bit#(4) shftAmnt);
    Vector#(16, Word) resultVector = in; 
    for (Integer i = 0; i < 16; i = i + 1) begin
        Bit#(4) idx = fromInteger(i);
        resultVector[i] = in[shftAmnt+idx];
    end
    return resultVector;
endfunction


function Vector#(16, Word) barrelLeft(Vector#(16, Word) in, Bit#(4) shftAmnt);
    Vector#(5, Vector#(16, Word)) barrel = replicate(in);
    for (Integer i = 3; i >= 0; i = i - 1) begin
        Bit#(4) mask = 0;
        mask[i] = 1;
        //Bit#(4) maskedAmnt = shftAmnt & mask;
        //barrel[4-i] = naiveShfl(barrel[3-i], maskedAmnt);
        barrel[4-i] = unpack(pack(shftAmnt[i])) ? naiveShfl(barrel[3-i], mask) : barrel[3-i];
    end
    return barrel[4];
endfunction
