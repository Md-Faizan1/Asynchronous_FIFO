// Asynchronous memory with gray code pointer exchange

module AsyncFIFO #(
  parameter DepthSize = 8,
  parameter ArraySize = 4
) (
  input   wreq, wclk, wrst_n,
  input   rreq, rclk, rrst_n,
  input   [DepthSize-1:0] wdata,
  output  [DepthSize-1:0] rdata,
  output  reg wfull,
  output  reg rempty
);

  reg     [ArraySize:0]   wd2rptr, wd1rptr, rptr;
  reg     [ArraySize:0]   rd2wptr, rd1wptr, wptr;
  wire    rempty_val;
  wire    [ArraySize:0] rptr_nxt;
  wire    [ArraySize-1:0] raddr;
  reg     [ArraySize:0] rbin;
  wire    [ArraySize:0] rbin_nxt;
  wire    [ArraySize-1:0] waddr;
  reg     [ArraySize:0] wbin;
  wire    [ArraySize:0] wbin_nxt;
  wire    [ArraySize:0] wptr_nxt;

  // Synchronizing rptr to wclk
  always @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n)
      {wd2rptr, wd1rptr} <= 2'b0;
    else
      {wd2rptr, wd1rptr} <= {wd1rptr, rptr};
  end

  // Synchronizing wptr to rclk
  always @(posedge rclk or negedge rrst_n) begin
    if (!rrst_n)
      {rd2wptr, rd1wptr} <= 2'b0;
    else
      {rd2wptr, rd1wptr} <= {rd1wptr, wptr};
  end

  // Generating rempty condition
  assign rempty_val = (rptr_nxt == rd2wptr); 

  always @(posedge rclk or negedge rrst_n) begin
    if (!rrst_n)
      rempty <= 1'b0;
    else
      rempty <= rempty_val;
  end

  // Generating read address for FifoMem
  assign rbin_nxt = rbin + (rreq & ~rempty);

  always @(posedge rclk or negedge rrst_n) begin
    if (!rrst_n)
      rbin <= 0;
    else
      rbin <= rbin_nxt;
  end

  assign raddr = rbin[ArraySize-1:0]; 

  // Generating rptr to send to wclk domain
  // Convert from binary to gray
  assign rptr_nxt = rbin_nxt ^ (rbin_nxt >> 1);

  always @(posedge rclk or negedge rrst_n) begin
    if (!rrst_n)
      rptr <= 0;
    else
      rptr <= rptr_nxt;
  end

  // Generating write address for FifoMem
  assign wbin_nxt = wbin + (wreq & !wfull);

  always @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n)
      wbin <= 0;
    else
      wbin <= wbin_nxt;
  end

  assign waddr = wbin [ArraySize-1:0];

  // Generating wptr to send to rclk domain
  // Convert from binary to gray
  assign wptr_nxt = (wbin_nxt >> 1) ^ wbin_nxt; 

  always @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n)
      wptr <= 0;
    else
      wptr <= wptr_nxt;
  end

  // Generate wfull condition
  wire wfull_val;
  assign wfull_val = (wd2rptr == {~wptr[ArraySize : ArraySize-1], wptr[ArraySize-2 : 0]});

  always @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n)
      wfull <= 0;
    else
      wfull <= wfull_val;
  end

  // FifoMem
  // Using Verilog memory model
  localparam Depth = (1 << (ArraySize));
  reg [DepthSize-1 : 0] mem [0: Depth -1];

  assign rdata = mem[raddr];

  always @(posedge wclk) begin
    if (wreq & !wfull)
      mem[waddr] <= wdata;
  end

endmodule
