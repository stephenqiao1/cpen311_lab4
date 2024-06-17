module Shuffle_Array(
    input wire clk,
    input logic start,
    input logic [9:0] SW,
    input wire [7:0] q,
    output logic [7:0] address,
    output logic [7:0] data,
    output logic wren,
    output logic finish,
    output logic [9:0] LED
);

    // State machine states for Task 2
    typedef enum logic [4:0] {
        S_INIT_TASK2A,
        S_PRE_SUM_J,
        S_SUM_J,
        S_READ_ARRAY_I,
        S_READ_ARRAY_I_WAIT,
        S_READ_ARRAY_J,
        S_READ_ARRAY_J_WAIT,
        S_READING_FINISHED,
        S_PRE_SWAP_I_TO_J,
        S_SWAP_I_TO_J,
        S_PRE_SWAP_J_TO_I,
        S_SWAP_J_TO_I,
        S_WRITING_DONE,
        S_WAIT,
        S_DONE,
		  S_READ_ARRAY_I_FINISH,
		  S_READ_ARRAY_J_FINISH
    } state_type;

    state_type state;
    
    reg [7:0] adjusted_key, i, j, i_element, j_element;
    reg [23:0] secret_key;

    always_ff @(posedge clk or negedge start) begin
        if (!start) begin
            state <= S_INIT_TASK2A;
            finish <= 1'b0;
            wren <= 1'b0;
            address <= 8'b0;
            data <= 8'b0;
            i <= 8'b0;
            j <= 8'b0;
            secret_key <= 24'b0;
        end else begin
            case (state)
                S_INIT_TASK2A: begin
                    i <= 8'd0;
                    j <= 8'd0;
                    wren <= 1'b0;
                    secret_key <= {14'd0, SW}; // Lower 10 bits are the switches state
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
                    state <= S_READ_ARRAY_I;
                end

                S_READ_ARRAY_I: begin
						j <= (j + q + adjusted_key); // Algorithm formula for j value update
                    address <= i;
                    state <= S_READ_ARRAY_I_WAIT;
                end
					 
					 S_READ_ARRAY_I_WAIT: begin
						state <= S_READ_ARRAY_I_FINISH;
					 end
					 

                S_READ_ARRAY_I_FINISH: begin
                    i_element <= q; // Save i value into i_element
                    state <= S_READ_ARRAY_J;
                end

                S_READ_ARRAY_J: begin 
                    address <= j; // Go to address j in the memory
                    state <= S_READ_ARRAY_J_WAIT;
                end

                S_READ_ARRAY_J_WAIT: begin
                    j_element <= q; // Save j value in j_element
                    state <= S_READ_ARRAY_J_FINISH;
                end
					 
					 S_READ_ARRAY_J_FINISH: begin
						j_element <= q; // Save j value in j_element
						state <= S_READING_FINISHED;
					 end

                S_READING_FINISHED: begin
                    state <= S_PRE_SWAP_I_TO_J;
                end

                S_PRE_SWAP_I_TO_J: begin
                    address <= j; // Set address for i_element
                    data <= i_element; // Set data to be written
                    state <= S_SWAP_I_TO_J;
                end

                S_SWAP_I_TO_J: begin
                    wren <= 1'b1; // Enable write
                    state <= S_PRE_SWAP_J_TO_I;
                end

                S_PRE_SWAP_J_TO_I: begin
                    wren <= 1'b0; // Disable write
                    address <= i; // Set address for j_element
                    data <= j_element; // Set data to be written
                    state <= S_SWAP_J_TO_I;
                end

                S_SWAP_J_TO_I: begin
					 
                    wren <= 1'b1; // Enable write
                    state <= S_WRITING_DONE;
                end

                S_WRITING_DONE: begin
                    wren <= 1'b0; // Disable write
                    state <= S_WAIT;
                end

                S_WAIT: begin
                    if (i == 8'd255) begin
                        state <= S_DONE;
                    end else begin
                        state <= S_PRE_SUM_J;
                    end
                    i <= i + 8'd1;
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
