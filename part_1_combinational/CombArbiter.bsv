import Vector::*;

typedef struct {
 Bool valid;
 Bit#(31) data;
 Bit#(4) index;
} ResultArbiter deriving (Eq, FShow);

function ResultArbiter arbitrate(Vector#(16, Bit#(1)) ready, Vector#(16, Bit#(31)) data);
	//let result = ResultArbiter{
	ResultArbiter result = ResultArbiter{
		valid: False,
		data : 0,
		index: 0
	};
	for (Integer i = 0; i < 16; i = i + 1) begin
		if (ready[i] == 1) begin
			result.valid = True;
			result.data = data[i];
			result.index = fromInteger(i);
		end
	end
	return result;
endfunction

