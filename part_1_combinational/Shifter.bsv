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
    return unpack(0);
    // Implementation of a left barrel shifter, presented in recitation
endfunction


function Vector#(16, Word) naiveButterfly(Vector#(16, Word) in, Bit#(4) param);
    Vector#(16, Word) resultVector = in; 
    for (Integer i = 0; i < 16; i = i + 1) begin
        Bit#(4) idx = fromInteger(i);
        resultVector[i] = in[param^idx];
    end
    return resultVector;
endfunction
function Vector#(16, Word) barrelButterfly(Vector#(16, Word) in, Bit#(4) param);
    return unpack(0);
    // Adapt the technique used in the barrel shifter to build a more efficient butterfly permutation.
endfunction
