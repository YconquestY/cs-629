# Lab 4a -- Basic multithreaidng	

Start by copying in `pipelined.bsv` from lab2b, `Cache32.bsv` and `Cache512.bsv` from lab3a, and `CacheInterface.bsv` from lab3b, replacing the templates in this repository. You may need to add in any other dependencies you added, as well, such as `*.hex` files.

## Two-threads machine

In this lab, you are first asked to build a simple processor that hosts two hardware threads.


For this initial version of part a, you can use a simplified implementation where both threads fly through a single queue per stage of the processor, resulting in both threads potentially stalling each-other. 

As a hint we suggest you use the following updated datastructure accross stages:

```
typedef struct { 
                 Bit#(32) pc;
                 Bit#(32) ppc;
                 Bit#(1) epoch; 
                 KonataId k_id; 
                 Bit#(1) thread_id; // NEW
             } F2D deriving (Eq, FShow, Bits);

typedef struct { 
    DecodedInst dinst;
    Bit#(32) pc;
    Bit#(32) ppc;
    Bit#(1) epoch;
    Bit#(32) rv1; 
    Bit#(32) rv2; 
    Bit#(1) thread_id; // <- NEW
    KonataId k_id;
} D2E deriving (Eq, FShow, Bits);

typedef struct { 
    MemBusiness mem_business;
    Bit#(32) data;
    Bit#(32) pc;
    DecodedInst dinst;
    Bit#(1) thread_id; // <- NEW
    KonataId k_id;
} E2W deriving (Eq, FShow, Bits);
```

Your machine will also necessitate 2 register file, two scoreboards and two epochs.
To be able to distinguish the two threads, we do not start the two threads in the same exact state.
We decide to follow the following convention: both threads should start at the
same pc, but one should start with register x10 (a0) initialized to 0, while the other one to
should start with register x10 initialized to 1.
Considering that a0 is the argument passed to main, it will allow us to write software in C:
```
int main(int tid) {
  if (tid ==0) {
    // code that should be run by hwthread0
  } else {
    // code that should be run by hwthread1
  }
}
```

Notice that if no argument is used in main, then both thread will run the same code.

Despite its simplicity, your machine is likely to go a bit faster than the baseline pipelined processor.
What are the reasons that make the processor a bit goes faster?  (Show a
Konata screenshot of a situation in your pipelined processor, and why it will
flies better in the 2-threads processor)

If/in cases where it does not go faster, why does it not go faster? (Show a Konata screenshot of a situation in your 2-thread core, where there is an opportunity of speedup if threads could overtake each other)

### Understanding the software running

Compare  `test/init.S` with the `test/init.S` of the previous lab, notice the main difference and explain what it does.


### Write a baremetal multicore "consumer-producer" software queue (a software ring buffer). 

Thread0 should iterate over the elements of an array, an push them into a queue.
Thread1 should pull from that queue and sum all the elements.

You should add this to `testMultiCore/src/buffer.c`. 

Please install `gcc-riscv64-unknown-elf` on your machine (`sudo apt-get install gcc-riscv64-unknown-elf` for Debian/WSL). Mac users will need to do `brew tap riscv-software-src/riscv; brew install riscv-tools`. Mac users will also need to do `cd elf2hex; make clean; make` before running any of their own programs.

Then you can make your test by doing `cd testMultiCore; make`. You run it using `./run_threaded.sh buffer32`.

Please see the matrix multiply and multicore tests for inspiration. Similar to multicore, print success or failure if it has the right result.

## Konata update

Konata supports displaying instruction from different threads. For that, one simply needs to specify at fetch time which thread we are fetching from.

```
// When fetching from thread 0:
	let iid <- fetch1Konata(lfh, fresh_id, 0);
	
// When fetching from thread 1:
  let iid <- fetch1Konata(lfh, fresh_id, 1);
```

Note that we only need to specify the thread of the instruction at fetch time (when calling fetch1Konata).

## Running tests

Run `make all` first. then....

We have a collection of a few tests:
  add32, and32, or32, hello32, thelie32, mul32, ... (see the full list in test/build/)

To run one of those tests specifically you can do:

```
./run_pipelined.sh add32
```

And for some multithreading tests...(multicore32, matmulmulti32)
```
./run_threaded.sh multicore32
```


Those will generate a trace `pipelined.log` that can be opened in Konata.


You can also run all the tests with:
```
./test_all_pipelined.sh
```
(We removed matmul32 as it would require a little adaptation to run in this 2 threads version)

Notice that now, it reports that two thread ran, with the number of cycle for each of them.
Right now, for all those benchmarks, both thread run the same benchmark in parallel.


We provided the (ungraded) RISC-V unit tests from 6.004 for convenience. See the `risc_v_tests` folder for a list of test types and included tests.
```
./run_6004 <test_type>/<test>
```


# Submitting
`make submit` will do it all for you :)

In part b, you will be asked to improve on this machine by using parallel queues to allow a thread to sometime overtake another thread, as outlined in the lecture. You will also explore instruction-choice policy.
