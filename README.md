# Lab 3b -- Caches + Processor

This section of the lab will involve connecting your caches into your processor from labs 2b and 3a.

Start by copying `pipelined.bsv` from lab2b into this lab. Then copy `Cache32.bsv` and `Cache512.bsv` from lab 3a into this lab. Note: if you did not finish lab 2b, you can copy the contents of `multicycle.bsv` into `pipelined.bsv` instead.

## Your goal

You will need to populate `CacheInterface.bsv` with proper instruction and data caches that connect to a shared cache, which in turn connects to main memory.

This should look like:
```
      MAIN MEM
          |
         L2
     -----|-----
    |           |
  IMEM L1    DMEM L1
    |           |
    -----||------
         ||    
      Processor
```

You want two L1 (32 bit) caches -- one for data and one for instructions. L2 (512 bit) is shared and main memory is connected to L2.

We provide an interface that replaces the Harvard architechture style pseudo-magic memory interface we had before. This looks like the following:
```verilog
interface CacheInterface;
    method Action sendReqData(CacheReq req);
    method ActionValue#(Word) getRespData();
    method Action sendReqInstr(CacheReq req);
    method ActionValue#(Word) getRespInstr();
endinterface
```
The processor will send a request for data or for an instruction and you should return a result for each as needed.

In real RISC-V computers, data memory and instruction memory are shared (Princeton architechture), so you will address a single main memory.

Specifically, you should keep a L2 cache that can store instructions and data. To a cache, these both look the same (i.e. words or lines of data). In fact you can address data and instructions the same way in main memory and your compiler determines these addresses for you.

So how do we merge data and instructions to the same interface.....
You need to maintain a FIFO queue that will keep track of the order in which your L1 caches requested misses. The responses from misses from L2 should return to their respective L1 cache depending on what order value you put in the FIFO. 

L2 cache should connect directly to main memory, which uses the following interface:
```verilog
interface MainMem;
    method Action put(MainMemReq req);
    method ActionValue#(MainMemResp) get();
endinterface
```
Put sends a request (address) to memory, get returns the resulting line of data. See the MemTypes file for information on the types.

## Running tests

Run `make all` first. then....

We have a collection of a few tests:
  add32, and32, or32, hello32, thelie32, mul32, ... (see the full list in test/build/)

To run one of those tests specifically you can do:

```
./run_pipelined add32
```

Those will generate a trace `multicycle.log` or `pipelined.log` that can be opened in Konata (see below).

You can also run all the tests with:
```
./test_all_multicycle.sh
./test_all_pipelined.sh
```

All tests but `matmul32` typically take less than 2s to finish. `matmul32` is much slower (30s to 1mn).

Note: The testbench has been modified from lab 2b to use a cache instead. Please do not overwrite these with copies from 2b.

### How does testing work?
(For enrichment)

Your processor gets its instructions from its memory, and its memory is loaded from the `mem.vmh` file. Our test script moves a prebuilt RISC-V hex file from the `test/build` directory into `mem.vmh` and then calls the simulator that runs the `top` file that corresponds with whichever processor you're testing. If you're using the `run_<something>.sh` scripts, they also convert the intermediate Konata logs into a human-readable Konata log, which is how you see things like `li a0 0` in the Konata visualization.

If you want to produce your own tests, you can do two things:
- Write your own RISC-V assembly and compile it into an `elf`
- Write your own C code and compile it into RISC-V `elf`

then convert that `elf` into a `hex` file, hence the `elf2hex` tool we have in the directory.  (Note: run `make clean; make` in the `elf2hex` directory before use if not on Linux amd64). We don't expect you'll need to produce any tests yourself, but they are here if you want them.

If you *do* make your own tests, feel free to share the `hex` files on the Piazza. We have a rather boring and minimal set of tests, and I'm sure your peers would be delighted to see whatever fun tests you cook up! But it is not necessary for the lab.

# Submitting
`make submit` will do it all for you :)
