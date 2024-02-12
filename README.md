# Matrix Multiplication Lab

## The Scenario

Tim the Beaver has fallen into the craze of computer vision and machine learning after borrowing his friend's brand new augmented reality headset
over the weekend. Once he's done trying it out, his friend tells him about the high tech hardware specifications of the headset. He then learns that the
developers of the headset designed a custom spatial computing chip for the device. He then questions his friend about why they put the time and
effort into designing a new custom chip instead of using a general x86 processor. His friend suggests that maybe spatial computing is easier to
do in hardware than software. Let's find out!

## Hardware Specification

To find out if hardware design is easier than software for spatial computing, you decide to design a hardware module that can compute 16x16 matrix 
multiplication ($C = A * B$) with 32-bit integer elements.

***Ignore integer overflow in your design!\*\*\*

You decide on the following interface for a simple matrix multiplication design.

```
interface MM;
    method Action write_row_a(Vector#(16, Bit#(32)) row, Bit#(4) row_idx);
    method Action write_row_b(Vector#(16, Bit#(32)) row, Bit#(4) row_idx);
    method Action start();
    method ActionValue#(Vector#(16, Bit#(32))) resp_row_c();
endinterface
```

- Method `write_row_a` must write each element of the 16 elements of size 32 bits Vector `row` into row specified by `row_idx` within BRAM A.
  - For example, if `write_row_a` is called with arguments `row` = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15] and `row_idx` = 5, then all of the
elements of `row` should be written to BRAM A. All of the address(es) should correspond to the 6th row of the matrix.
Note: There is more than one way to design and address the BRAMs  (More on this later).
- Method `load_row_b` must do the same for BRAM B.
- Method `start()` should start the matrix multiplication calculation. The guard of `load_row_a`, `load_row_b`, and `resp_row_c` should be false 
while calculating matrix C.
- Method `resp_row_c` should return 1 row of matrix C. On the first call it should return the first row and on the second call it should return
the second row. On the 17th call it should return the first row again.

For this sequential design, we recommend using 3 different BRAMs. 2 to hold the two input matrices, A & B, and 1 for the output matrix, C. We also recommend
calculating matrix C by iterating over the elements of A & B. In other words, each cycle of your C matrix calculation rule should compute the value: $$c_{ij,f}
= a_{ik} * b_{kj} + c_{ij,i}$$ **INSTEAD OF:** $$c_{ij} =\sum_{k=1}^n a_{ik} * b_{kj}$$

How many cycles would this take for an NxN matrix and why do we suggest taking this approach?

The following diagram summarizes the specification of the hardware design:
<img src="DesignBlueprint.png" alt="Matrix Multiply Design" width=600>

## BRAM Design & Usage

There is more than one correct way to design the BRAM to store the values elements of the matrices. First, consider how large the BRAM must be to store all
of the elements of a 16x16 32-bit element matrix. How might you design the layout of the BRAM (input/output size vs address size)? What are the pros and cons of each design? 


How to initialize a BRAM module:

```
BRAM_Configure cfg = defaultValue;
BRAM1Port#(Bit#(addrSize), Bit#(dataSize)) a <- mkBRAM1Server(cfg);
```

How to send a request to a BRAM:

```
a.portA.request.put(BRAMRequest{write: True, // False for read
                         responseOnWrite: False,
                         address: _,
                         datain: _});
```

How to read a response from a BRAM:

```
let resp <- a.portA.response.get();
```

## Design Verification

To verify your design call `make` on your command line. It should automatically re-compile your design if there are updates and
save the testbench output to the file `output.log`.

There are 4 tests performed in sequence:
- test0: Multiply the identity matrix with itself
- test1: Again multiply the identity matrix with itself
- test2: Multiply two random matrices
- test3: Multiply two other random matrices


## Reflection

Do you think matrix multiplication is easier in software or hardware?

What are some of the advantages of your design over software?

Why do you think companies produce custom hardware instead of using mass-produced chips?

## Submission

To submit your completed lab we ask that you stage, commit, and push your changes to your repo. Please include your entire repo including the output
files in your submission. For more guidance on how to do this please see our piazza post: https://piazza.com/class/lrgt0dgrtpz590/post/27.
