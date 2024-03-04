// Types used in L1 interface
typedef struct { Bit#(1) write; Bit#(26) addr; Bit#(512) data; } MainMemReq deriving (Eq, FShow, Bits, Bounded);
typedef struct { Bit#(4) word_byte; Bit#(32) addr; Bit#(32) data; } CacheReq deriving (Eq, FShow, Bits, Bounded);
typedef Bit#(512) MainMemResp;
typedef Bit#(32) Word;

// Helper types for implementation (L1 cache):
typedef enum {
    Invalid,
    Clean,
    Dirty
} LineState deriving (Eq, Bits, FShow);

// TODO Copy over from 3_a

// Helper types for implementation (L2 cache):