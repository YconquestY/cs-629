import Vector::*;

typedef struct {
 Bool valid;
 Bit#(31) data;
 Bit#(4) index;
} ResultArbiter deriving (Bits, Eq, FShow);

typeclass CanArbitrate#(numeric type m);
	function ResultArbiter arbitrate(Vector#(m, Bit#(1)) ready, Vector#(m, Bit#(31)) data);
endtypeclass

instance CanArbitrate#(1);
	function ResultArbiter arbitrate(Vector#(1, Bit#(1)) ready, Vector#(1, Bit#(31)) data);
			return ResultArbiter{valid: unpack(ready[0]), data: data[0], index: 0};
	endfunction
endinstance

instance CanArbitrate#(n) provisos (Div#(n,2,n2), CanArbitrate#(n2));
	function ResultArbiter arbitrate(Vector#(n, Bit#(1)) ready, Vector#(n, Bit#(31)) data);
		// Cut the vector in two:
		Vector#(n2, Bit#(1)) ready_l;
		Vector#(n2, Bit#(1)) ready_r;
		Vector#(n2, Bit#(31)) data_l;
		Vector#(n2, Bit#(31)) data_r;
		Integer vn2 = valueOf(n2);
		for (Integer i=0; i < vn2; i = i + 1) begin
			ready_l[i] = ready[i];
			ready_r[i] = ready[i+vn2];
			data_l[i] = data[i];
			data_r[i] = data[i+vn2];
		end
		// Find another instance in the typeclass, for n2:
		ResultArbiter l = arbitrate(ready_l, data_l);
		ResultArbiter r = arbitrate(ready_r, data_r);
		if (l.valid) return l;
		else return r;

	endfunction
endinstance

(* noinline *)
function ResultArbiter arbitrate16(Vector#(16, Bit#(1)) ready, Vector#(16, Bit#(31)) data)=arbitrate(ready,data);


