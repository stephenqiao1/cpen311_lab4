module Initialize_Array(
	input wire clk,
	input logic reset,
	output logic finish,
	output logic [7:0] address,
	output logic [7:0] data,
	output logic wren
);

// State machine states for Task 1
  typedef enum logic [1:0] {
    S_INIT_TASK1,
    S_INCREMENT,
    S_DONE
  } state_type;

  state_type state;
  
  reg [7:0] i;

  // State machine for Task 1
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= S_INIT_TASK1;
      i <= 8'b0;
		  finish <= 1'b0;
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
          i <= i + 8'd1;
          if (i == 8'd255) begin
            state <= S_DONE;
          end else begin
				state <= S_INCREMENT;
			end
        end

        S_DONE: begin
          wren <= 1'b0;
			 finish <= 1'b1;
        end

      endcase
    end
  end

endmodule