module ksa (
  input CLOCK_50,
  input [3:0] KEY,
  input [9:0] SW,
  output [9:0] LEDR,
  output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0
);

  // Internal signals
  wire [7:0] address, data;
  wire wren;
  wire reset;

  // Memory instance
  s_memory s_mem_inst (
    .address(address),
    .clock(CLOCK_50),
    .data(data),
    .wren(wren),
    .q()
  );

  // Reset signal
  assign reset = ~KEY[3];

  // Seven Segment Display (SSD) decoder instances (currently not used, placeholder)
  SevenSegmentDisplayDecoder h0(HEX0, 4'b0);
  SevenSegmentDisplayDecoder h1(HEX1, 4'b0);
  SevenSegmentDisplayDecoder h2(HEX2, 4'b0);
  SevenSegmentDisplayDecoder h3(HEX3, 4'b0);
  SevenSegmentDisplayDecoder h4(HEX4, 4'b0);
  SevenSegmentDisplayDecoder h5(HEX5, 4'b0);
  
  // Initialize s Array FSM
  Initialize_Array initialize_s_array(
	.clk(CLOCK_50),
	.reset(reset),
	.address(address),
	.data(data),
	.wren(wren)
  );

endmodule