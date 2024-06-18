module tb_Shuffle_Array;

  // Declare testbench signals
  reg clk;
  reg start;
  reg [9:0] SW;
  reg [7:0] q;
  wire [7:0] address;
  wire [7:0] data;
  wire wren;
  wire finish;
  wire [9:0] LED;
  wire [4:0] current_state;

  Shuffle_Array uut (
    .clk(clk),
    .start(start),
    .SW(SW),
    .q(q),
    .address(address),
    .data(data),
    .wren(wren),
    .finish(finish),
    .LED(LED)
  );

  assign current_state = uut.state;

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;  // Clock period of 10 time units
  end

  // Test sequence
  initial begin
    // Initialize signals
    start = 0;
    SW = 10'b1010101010;  // Arbitrary switch pattern
    q = 8'b0;

    // Apply reset
    #10;
    start = 1;
    #10;
    start = 1;

    // Apply inputs to go through all states
    // The state transitions will be observed in the waveform
    // Let's assume q is set to 0 initially

    #10;  // Wait for state to initialize
    q = 8'h05;  // Set q to a specific value to simulate memory read
    #10;  // Wait for state to change to S_PRE_SUM_J

    #10;  // Wait for state to change to S_SUM_J
    q = 8'h10;  // Update q to simulate memory read for i_element

    #10;  // Wait for state to change to S_READ_ARRAY_I
    q = 8'h20;  // Update q to simulate memory read for j_element

    #10;  // Wait for state to change to S_READ_ARRAY_J
    q = 8'h30;  // Update q to simulate memory read completion

    #10;  // Wait for state to change to S_READING_FINISHED
    q = 8'h40;  // Update q to simulate memory write for i_element

    #10;  // Wait for state to change to S_PRE_SWAP_I_TO_J
    q = 8'h50;  // Update q to simulate memory write for j_element

    #10;  // Wait for state to change to S_SWAP_I_TO_J
    q = 8'h60;  // Update q to simulate memory write completion

    #10;  // Wait for state to change to S_PRE_SWAP_J_TO_I
    q = 8'h70;  // Update q to simulate final memory write

    #10;  // Wait for state to change to S_SWAP_J_TO_I
    q = 8'h80;  // Update q to simulate final write completion

    #10;  // Wait for state to change to S_WRITING_DONE
    q = 8'h90;  // Update q to simulate writing done

    #10;  // Wait for state to change to S_WAIT

    // Increment i until it reaches 255
    repeat (256) begin
      #10;
      q = q + 1;  // Increment q to simulate new memory values
    end

    // Wait for state to change to S_DONE
    #10;
 

    // End simulation
    $stop;
  end


endmodule
