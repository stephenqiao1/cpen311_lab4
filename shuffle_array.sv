module Shuffle_Array(
	input wire clk,
	input logic start,
	input logic [9:0] SW,
	input logic [7:0] q,
	output logic [7:0] address,
	output logic [7:0] data,
	output logic wren,
	output logic finish,
	output logic [9:0] LED
);

	// State machine states for Task 2
  typedef enum logic [3:0] {
    S_INIT_TASK2A,
	 S_PRE_SUM_J,
    S_SUM_J,
    S_READ_ARRAY_I,
    S_READ_ARRAY_I_WAIT,
    S_READ_ARRAY_J,
    S_READ_ARRAY_J_WAIT,
    S_READING_FINISHED,
    S_SWAP_I_TO_J,
    S_SWAP_J_TO_I,
    S_WRITING_DONE,
    S_WAIT,
    S_CHANGE_ADDRESS,
    S_DONE
  } state_type;

  state_type state;
  
  reg [7:0] adjusted_key, i, j, i_element, j_element;
  reg [23:0] secret_key;
  
  always_ff @(posedge clk) begin
	if (!start) begin
		state <= S_INIT_TASK2A;
		finish <= 1'b0;
		wren <= 1'b0; // Ensure wren is reset when not starting
	end else begin
		case (state)
			S_INIT_TASK2A: begin
				i <= 8'd0;
				j <= 8'd0;
				wren <= 1'b0;
				secret_key <= {14'd0, SW[9:0]}; //lower 10bits are the switches state
				state <= S_PRE_SUM_J;
			end
			
			S_PRE_SUM_J: begin
				address <= i;
				
				if ((i % 3) == 8'd0) begin
					adjusted_key <= secret_key[23:16];
				end else if ((i % 3) == 8'd1) begin
					adjusted_key <= secret_key[15:8];
				end else begin
					adjusted_key <= secret_key[7:0];
				end
				
				state <= S_SUM_J;
			end
			
			S_SUM_J: begin
				j <= (j + q + adjusted_key); // algorithm formula for j value update
				
				state <= S_READ_ARRAY_I;
			end
			
			S_READ_ARRAY_I: begin
				address <= i;
//				wren <= 1'b0;
				state <= S_READ_ARRAY_I_WAIT;
			end
			
			S_READ_ARRAY_I_WAIT: begin
				i_element <= q; // save i value into i_element
				state <= S_READ_ARRAY_J;
			end
			
			S_READ_ARRAY_J: begin
				// reading at J starts here
				address <= j; // go to address j in the memory
				state <= S_READ_ARRAY_J_WAIT;
			end
			
			S_READ_ARRAY_J_WAIT: begin
				j_element <= q; // save j value in j_element
				state <= S_READING_FINISHED;
			end
			
			S_READING_FINISHED: begin
				wren <= 1'b1; // since we are writing in next states, wren = 1
				state <= S_SWAP_I_TO_J;
			end
			
			S_SWAP_I_TO_J: begin
				data <= i_element; // at address j, write i to the memory
				// wren <= 1'b1; // since we are writing, wren = 1
				state <= S_CHANGE_ADDRESS; // we do the same swapping method for J to I
			end
			
			S_CHANGE_ADDRESS: begin
				address <= i;
				state <= S_SWAP_J_TO_I;
			end
			
			S_SWAP_J_TO_I: begin
				data <= j_element;
				state <= S_WAIT;
			end
			
			S_WAIT: begin
				i <= i + 8'd1;
				
				if (i == 255) begin
					state <= S_DONE;
				end else begin
					state <= S_WRITING_DONE;
				end
			end
			
			S_WRITING_DONE: begin
				wren <= 1'b0;
				state <= S_PRE_SUM_J;
			end
			
			S_DONE: begin
				wren <= 1'b0;
				finish <= 1'b1;
			end
			
			default: begin
				state <= S_INIT_TASK2A;
			end
		endcase
	end
  end
endmodule