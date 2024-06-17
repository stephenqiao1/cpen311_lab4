module ksa (
  input CLOCK_50,
  input [3:0] KEY,
  input [9:0] SW,
  output [9:0] LEDR,
  output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0
);

  // Internal signals
  wire [7:0] address_init, address_shuffle, data_init, data_shuffle, q, q_rom;
  wire wren_init, wren_shuffle, reset, finish_init, finish_shuffle;
  wire [7:0] address, data;
  wire wren;

  // Memory instance
  s_memory s_mem_inst (
    .address(address),
    .clock(CLOCK_50),
    .data(data),
    .wren(wren),
    .q(q)
  );
  
  // Instantiate the ROM
   message u_message (
      .address(address),
      .clock(clock),
      .q(q_rom)
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
	.finish(finish_init),
	.address(address_init),
	.data(data_init),
	.wren(wren_init)
  );
  
  // Shuffle Array FSM
  Shuffle_Array shuffle_array(
	.clk(CLOCK_50),
	.start(finish_init),
	.SW(SW),
	.q(q),
	.address(address_shuffle),
	.data(data_shuffle),
	.wren(wren_shuffle),
	.finish(finish_shuffle),
	.LED(LEDR)
  );
  
  // Control logic for address, data, and wren signals
  assign address = finish_init ? address_shuffle : address_init;
  assign data = finish_init ? data_shuffle : data_init;
  assign wren = finish_init ? wren_shuffle : wren_init;

endmodule