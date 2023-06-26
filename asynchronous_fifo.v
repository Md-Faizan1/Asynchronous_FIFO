// Asynchronous memory with gray code pointer exchange

module myAsyncFIFO #(
  parameter MyDepthSize = 8,
  parameter MyArraySize = 4
) (
  input   myWreq, myWclk, myWrst_n,
  input   myRreq, myRclk, myRrst_n,
  input   [MyDepthSize-1:0] myWdata,
  output  [MyDepthSize-1:0] myRdata,
  output  reg myWfull,
  output  reg myRempty
);

reg     [MyArraySize:0]   myWd2Rptr, myWd1Rptr, myRptr;
reg     [MyArraySize:0]   myRd2Wptr, myRd1Wptr, myWptr;
wire    myRemptyVal;
wire    [MyArraySize:0] myRptrNxt;
wire    [MyArraySize-1:0] myRaddr;
reg     [MyArraySize:0] myRbin;
wire    [MyArraySize:0] myRbinNxt;
wire    [MyArraySize-1:0] myWaddr;
reg     [MyArraySize:0] myWbin;
wire    [MyArraySize:0] myWbinNxt;
wire    [MyArraySize:0] myWptrNxt;

// Synchronizing rptr to wclk
always @(posedge myWclk or negedge myWrst_n) begin
  if (!myWrst_n)
    {myWd2Rptr, myWd1Rptr} <= 2'b0;
  else
    {myWd2Rptr, myWd1Rptr} <= {myWd1Rptr, myRptr};
end

// Synchronizing wptr to rclk
always @(posedge myRclk or negedge myRrst_n) begin
  if (!myRrst_n)
    {myRd2Wptr, myRd1Wptr} <= 2'b0;
  else
    {myRd2Wptr, myRd1Wptr} <= {myRd1Wptr, myWptr};
end

// Generating myRempty condition
assign myRemptyVal = (myRptrNxt == myRd2Wptr); 

always @(posedge myRclk or negedge myRrst_n) begin
  if (!myRrst_n)
    myRempty <= 1'b0;
  else
    myRempty <= myRemptyVal;
end

// Generating read address for myFifoMem
assign myRbinNxt = myRbin + (myRreq & ~myRempty);

always @(posedge myRclk or negedge myRrst_n) begin
  if (!myRrst_n)
    myRbin <= 0;
  else
    myRbin <= myRbinNxt;
end

assign myRaddr = myRbin[MyArraySize-1:0]; 

// Generating myRptr to send to myWclk domain
// Convert from binary to gray
assign myRptrNxt = myRbinNxt ^ (myRbinNxt >> 1);

always @(posedge myRclk or negedge myRrst_n) begin
  if (!myRrst_n)
    myRptr <= 0;
  else
    myRptr <= myRptrNxt;
end

// Generating write address for myFifoMem
assign myWbinNxt = myWbin + (myWreq & !myWfull);

always @(posedge myWclk or negedge myWrst_n) begin
  if (!myWrst_n)
    myWbin <= 0;
  else
    myWbin <= myWbinNxt;
end

assign myWaddr = myWbin [MyArraySize-1:0];

// Generating myWptr to send to myRclk domain
// Convert from binary to gray
assign myWptrNxt = (myWbinNxt >> 1) ^ myWbinNxt; 

always @(posedge myWclk or negedge myWrst_n) begin
  if (!myWrst_n)
    myWptr <= 0;
  else
    myWptr <= myWptrNxt;
end

// Generate myWfull condition
wire myWfullVal;
assign myWfullVal = (myWd2Rptr == {~myWptr[MyArraySize : MyArraySize-1], myWptr[MyArraySize-2 : 0]});

always @(posedge myWclk or negedge myWrst_n) begin
  if (!myWrst_n)
    myWfull <= 0;
  else
    myWfull <= myWfullVal;
end

// myFifoMem
// Using Verilog memory model
localparam MyDepth = (1 << (MyArraySize));
reg [MyDepthSize-1 : 0] myMem [0: MyDepth -1];

assign myRdata = myMem[myRaddr];

always @(posedge myWclk) begin
  if (myWreq & !myWfull)
    myMem[myWaddr] <= myWdata;
end

endmodule
