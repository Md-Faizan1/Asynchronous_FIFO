`default_nettype none
`timescale 1ps/1ps

module myAsyncFIFO_TB();

parameter MyDSIZE = 8;
parameter MyASIZE = 4;
parameter MyWCLK_PERIOD = 10;
parameter MyRCLK_PERIOD = 40;

reg myWreq, myWclk, myWrst_n, myRreq, myRclk, myRrst_n;
reg [MyDSIZE-1:0] myWdata;
wire [MyDSIZE-1:0] myRdata;
wire myWfull, myRempty;

// Instance
myAsyncFIFO
#(     
    .MyDepthSize(MyDSIZE),
    .MyArraySize(MyASIZE)
)
u_myAsyncFIFO
(
    .myWreq(myWreq), .myWrst_n(myWrst_n), .myWclk(myWclk),
    .myRreq(myRreq), .myRclk(myRclk), .myRrst_n(myRrst_n),
    .myWdata(myWdata), .myRdata(myRdata), .myWfull(myWfull), .myRempty(myRempty)
);

initial begin
    myWrst_n = 0;
    myWclk = 0;
    myWreq = 0;
    myWdata = 0;
    repeat (2) #(MyWCLK_PERIOD/2) myWclk = ~myWclk;
    myWrst_n = 1;
    forever #(MyWCLK_PERIOD/2) myWclk = ~myWclk;
end

initial begin
    myRrst_n = 0;
    myRclk = 0;
    myRreq = 0;
    repeat (2) #(MyRCLK_PERIOD/2) myRclk = ~myRclk;
    myRrst_n = 1;
    forever  #(MyRCLK_PERIOD/2) myRclk = ~myRclk;
end

initial 
begin
    $dumpfile("dump.vcd"); 
    $dumpvars;
end  


initial begin
    repeat (4) @ (posedge myWclk);
     @(negedge myWclk); myWreq = 1; myWdata = 8'd1;
     @(negedge myWclk); myWreq = 1; myWdata = 8'd2;
     @(negedge myWclk); myWreq = 1; myWdata = 8'd3;
     @(negedge myWclk); myWreq = 1; myWdata = 8'd4;
     @(negedge myWclk); myWreq = 1; myWdata = 8'd5;
     @(negedge myWclk); myWreq = 1; myWdata = 8'd6;
     @(negedge myWclk); myWreq = 1; myWdata = 8'd7;
     @(negedge myWclk); myWreq = 1; myWdata = 8'd8;
     @(negedge myWclk); myWreq = 1; myWdata = 8'd9;
     @(negedge myWclk); myWreq = 1; myWdata = 8'd10;
     @(negedge myWclk); myWreq = 1; myWdata = 8'd11;
     @(negedge myWclk); myWreq = 1; myWdata = 8'd12;
     @(negedge myWclk); myWreq = 1; myWdata = 8'd13;
     @(negedge myWclk); myWreq = 1; myWdata = 8'd14;
     @(negedge myWclk); myWreq = 1; myWdata = 8'd15;
     @(negedge myWclk); myWreq = 1; myWdata = 8'd16;
     @(negedge myWclk); myWreq = 0;

     @(negedge myRclk); myRreq = 1;
     repeat (17) @(posedge myRclk);
     myRreq = 0;

     #100;
     $finish;
end

endmodule
