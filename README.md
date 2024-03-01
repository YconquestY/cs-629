# Lab 3a -- Caches

This lab is split into two parts that consist of designing realistic memory interfaces for a processor. (part 3b will have you actually connect this to a processor)

Some definitions:
* word = 32 bits
* line = 512 bits, or 16 words as a vector
* L1 cache = directly connected to processor and requests word response
* L2 cache = connected to the L1 cache and below main memory, stores lines just like main memory.

## Part 1 -- L1 Cache

In the file `Cache32.bsv`, you should implement the `mkCache32` module. Your cache should have the following characteristics:
- It has 128 cache lines, each line is 512-bits long, made up of 32 bit words.
- It uses a writeback miss-allocate policy
- It uses a store-buffer
- You are free to design either a k-way associative (k=2,4,8) or a direct-mapped cache. If you choose a k-way associative you can pick any replacement policy you want
- You should use a BRAM to hold the content of the cache and the associated tags. A placeholder bram is in the code for you.

Note that a BE (byte enable) bram is used to store data. This is important for processor use since RISC-V specifications allow byte based (`lb, sb, etc.`) instructions. A byte enable string looks something like `1100` for a four byte write. This means only the upper two bytes will be written to the bram, ignoring the lower two bytes. This applies for lines as well. A 64 byte line (512 bits at 8 bits per byte) would consist of a series of 64 bits (one hot encoding) for the byte enable request. The data in value would be the same, but the zeroed bytes are ignored. Please see the Bluespec specifications for usage. `BramRequestBE` types include this byte enable value in the `writeen` field.
```
typedef struct {Bit#(n) writeen;
    Bool responseOnWrite;
    addr address;
    data datain;
} BRAMRequestBE#(type addr, type data, numeric type n) deriving (Bits, Eq)
```
Please see the bluespec reference for more details on usage. Note that reads are always `writeen=0`. You will still always want to return words for any read. Your processor will always give a `CacheReq` type with the fields `CacheReq{word_byte: req.byte_en, addr: req.addr, data: req.data}`. The `word_byte` field will be the associated byte enable field for a given word. You will need to modify that to write to lines in your cache. Hint: n-dim vectors of m-bits in bluespec are the same as `n*m` bits in bluespec (in bram or otherwise).


In the file `MemTypes.bsv` we defined a few basic types.
You will also have to define new types for the tags and the indexes.



```verilog
interface Cache32;
    method Action putFromProc(CacheReq e);
    method ActionValue#(Word) getToProc();
    method ActionValue#(MainMemReq) getToMem();
    method Action putFromMem(MainMemResp e);
endinterface
```

Here we see four methods. `putFromProc` delivers a cache request from your processor to your cache. `getToProc` should return the associated data that is for that memory address that was requested. `getToMem` will deliver any requests from your cache to L2 cache. `putFromMem` will respond with the data you requested from L2. These are connected in the test bench for you already.


## Part 2 -- L2 Cache

In the file `Cache512.bsv`, you should implement the `mkCache` module. Your cache should have the following characteristics:
- It has 256 cache lines, each line is 512-bits long, with all data requested and returned being 512 bits long
- It uses a writeback miss-allocate policy
- It uses a store-buffer
- You are free to design either a k-way associative (k=2,4,8) or a direct-mapped cache. If you choose a k-way associative you can pick any replacement policy you want
- You should use a BRAM to hold the content of the cache and the associated tags. A placeholder bram is in the code for you with these specifications.

In the file `MemTypes.bsv` we defined a few basic types.
You will also have to define new types for the tags and the indexes. Make sure these do not conflict with types defined in Cache32

Here, you do not need to worry about byte enable flags at all, so please feel free to store everything in a single bram as given. You are free to split it up instead if you so desire.

```verilog
interface Cache512;
    method Action putFromProc(MainMemReq e);
    method ActionValue#(MainMemResp) getToProc();
    method ActionValue#(MainMemReq) getToMem();
    method Action putFromMem(MainMemResp e);
endinterface
```

Here we see four methods. `putFromProc` delivers a cache request from your L1 cache to your L2 cache. `getToProc` should return the associated data that is for that memory address that was requested from L1. `getToMem` will deliver any requests from your cache to main memory (or a higher level cache). `putFromMem` will respond with the data you requested from main memory. These are connected in the test bench for you already.


## Suggestions

We recommend using the types given in the lab which are there to help you easily label data in bram, etc. You can also add your own types that will simplify the process.

For instance, you might find the following type useful:
`typedef enum { Invalid, Clean, Dirty} LineState`

# Running tests

To test the cache in isolation, we have made one randomized test. It only tests functional correctness. The test does not check the sizes/kind of cache chosen, etc... all those things will be discussed during checkoffs.

The test is simply sending random requests both to your design, and to an ideal memory. The test make sure that the response obtained from your system are the same as the one returned by the ideal memory.

To run the test, you can do:

```bash
make
./Beveren # tests only L1 cache
./Beveren_nested # tests L1 and L2 cache
```

# Submitting
Run `make submit` in the main folder.
