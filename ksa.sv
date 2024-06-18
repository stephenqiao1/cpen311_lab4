module ksa (
  input CLOCK_50,
  input [3:0] KEY,
  input [9:0] SW,
  output [9:0] LEDR,
  output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0
);

  // Internal signals
  wire [7:0] address_init, address_shuffle, address_decrypt, data_init, data_shuffle, data_decrypt, q, q_rom;
  wire [7:0] address, data, data_ram, address_rom, address_ram;
  wire wren_init, wren_shuffle, wren_decrypt, reset, finish_init, finish_shuffle, finish_decrypt;
  wire wren, wren_ram;

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
      .address(address_rom),
      .clock(CLOCK_50),
      .q(q_rom)
   );
	
	// RAM memory
	decrypted_memory u_decrypted_memory (
        .address(address_ram),
        .clock(CLOCK_50),
        .data(data_ram),
        .wren(wren_ram),
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
	.finish(finish_shuffle)
  );
  
  // Decrypt Message FSM
  Decrypt_Message decrypt(
	.clk(CLOCK_50),
	.start(finish_shuffle),
	.q(q),
	.q_rom(q_rom),
	.address(address_decrypt),
	.address_rom(address_rom),
	.address_ram(address_ram),
	.data(data_decrypt),
	.data_ram(data_ram),
	.wren(wren_decrypt),
	.wren_ram(wren_ram),
	.finish(finish_decrypt),
	.LED(LEDR)
  );
  
  // Control logic for address, data, and wren signals
  assign address = finish_init ? (finish_shuffle ? address_decrypt : address_shuffle) : address_init;
  assign data = finish_init ? (finish_shuffle ? data_decrypt : data_shuffle) : data_init;
  assign wren = finish_init ? (finish_shuffle ? wren_decrypt : wren_shuffle) : wren_init;

endmodule