module tb_Initialize_Array;

  // Declare testbench signals
  reg clk;
  reg reset;
  wire finish;
  wire [7:0] address;
  wire [7:0] data;
  wire wren;
  wire [1:0] current_state;

  // Instantiate the DUT (Device Under Test)
  Initialize_Array uut (
    .clk(clk),
    .reset(reset),
    .finish(finish),
    .address(address),
    .data(data),
    .wren(wren)
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
    reset = 1;
    #10;
    reset = 0;

    // Check the initial state
    #10;
    if (current_state != uut.S_INIT_TASK1) begin
      //$stop;
    end

    // Check the state after reset
    #10;
    if (current_state != uut.S_INCREMENT) begin
      //$stop;
    end

    // Wait for the operation to complete
    wait(finish);

    // Check the final state
    #10000;
    if (current_state != uut.S_DONE) begin
      //$stop;
    end

   

    // End simulation
    $stop;
  end

endmodule
