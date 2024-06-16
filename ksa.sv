module ksa (
  input CLOCK_50,
  input [3:0] KEY,
  input [9:0] SW,
  output [9:0] LEDR,
  output [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0
);

  // Internal signals
  reg [7:0] address, data;
  reg wren;
  reg [7:0] i;
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

  // State machine states for Task 1
  typedef enum logic [1:0] {
    S_INIT_TASK1,
    S_INCREMENT,
    S_DONE
  } state_type;

  state_type state;

  // State machine for Task 1
  always_ff @(posedge CLOCK_50 or posedge reset) begin
    if (reset) begin
      state <= S_INIT_TASK1;
      i <= 8'b0;
    end else begin
      case (state)
        S_INIT_TASK1: begin
          i <= 8'b0;
          state <= S_INCREMENT;
          wren <= 1'b1;
        end
        
        S_INCREMENT: begin
          address <= i;
          data <= i;
          wren <= 1'b1;
          i <= i + 1;
          if (i == 8'd255) begin
            state <= S_DONE;
          end
        end

        S_DONE: begin
          wren <= 1'b0;
        end

      endcase
    end
  end

  assign LEDR[9:2] = i;
  assign LEDR[1:0] = 2'b00;

endmodule