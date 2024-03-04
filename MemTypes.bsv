// Types used in L1 interface
typedef struct { Bit#(1) write; Bit#(26) addr; Bit#(512) data; } MainMemReq deriving (Eq, FShow, Bits, Bounded);
typedef struct { Bit#(4) word_byte; Bit#(32) addr; Bit#(32) data; } CacheReq deriving (Eq, FShow, Bits, Bounded);
typedef Bit#(512) MainMemResp;
typedef Bit#(32) Word;

// (Curiosity Question: CacheReq address doesn't actually need to be 32 bits. Why?)

// Helper types for implementation (L1 cache):
typedef enum {
    Invalid,
    Clean,
    Dirty
} LineState deriving (Eq, Bits, FShow);

// You should also define a type for LineTag, LineIndex. Calculate the appropriate number of bits for your design.
// typedef ??????? LineTag
// typedef ??????? LineIndex
// You may also want to define a type for WordOffset, since multiple Words can live in a line.

// You can translate between Vector#(16, Word) and Bit#(512) using the pack/unpack builtin functions.
// typedef Vector#(16, Word) LineData  (optional)

// Optional: You may find it helpful to make a function to parse an address into its parts.
// e.g.,
// typedef struct {
    //     LineTag tag;
    //     LineIndex index;
    //     WordOffset offset;
    // } ParsedAddress deriving (Bits, Eq);
    //
typedef Bit#(1) ParsedAddress;  // placeholder

function ParsedAddress parseAddress(Bit#(32) address);
    return unpack(0);
endfunction

// and define whatever other types you may find helpful.


// Helper types for implementation (L2 cache):