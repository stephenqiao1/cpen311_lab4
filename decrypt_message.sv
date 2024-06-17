module Decrypt_Message(
    input wire clk,
    input logic start,
    input wire [7:0] q,
	 input wire [7:0] q_rom,
    output logic [7:0] address,
	 output logic [7:0] address_rom,
	 output logic [7:0] address_ram,
	 output logic [7:0] data,
    output logic [7:0] data_ram,
    output logic wren,
	 output logic wren_ram,
    output logic finish,
	 output logic [7:0] LED
);

    // State machine states for Task 2
    typedef enum logic [4:0] {
        INIT,
		  ADD_I,
		  GET_ADDRESS_I,
		  GET_ADDRESS_I_WAIT,
		  ADD_J,
		  GET_I_ELEMENT,
		  GET_ADDRESS_J,
		  GET_ADDRESS_J_WAIT,
		  GET_J_ELEMENT,
		  SWAP_J_TO_I,
		  ENABLE_WRITE,
		  DISABLE_WRITE,
		  SWAP_I_TO_J,
		  SWAP_I_TO_J_WAIT,
		  ENABLE_WRITE_2,
		  DISABLE_WRITE_2,
		  CHANGE_ADDRESS,
		  CHANGE_ADDRESS_WAIT,
		  GET_F,
		  SET_ROM_ADDRESS,
		  DECRYPT,
		  ENABLE_RAM_WRITE,
		  DISABLE_RAM_WRITE,
		  DECRYPT_WAIT,
		  DECRYPT_DONE
    } state_type;

    state_type state;
	 
	 reg [7:0] i, j, k, f, i_element, j_element;

    always_ff @(posedge clk or negedge start) begin
        if (!start) begin
				state <= INIT;
				i <= 8'b0;
				j <= 8'b0;
				k <= 8'b0;
				f <= 8'b0;
				address <= 8'b0;
				address_rom <= 8'b0;
				address_ram <= 8'b0;
        end else begin
            case (state)
					INIT: begin
						i <= 8'b0;
						j <= 8'b0;
						k <= 8'b0;
						state <= ADD_I;
					end
					ADD_I: begin
						i <= i + 8'd1;
						state <= GET_ADDRESS_I;
					end
					GET_ADDRESS_I: begin
						address <= i;
						state <= GET_ADDRESS_I_WAIT;
					end
					GET_ADDRESS_I_WAIT: begin
						state <= ADD_J;
					end
					ADD_J: begin
						j <= j + q;
						state <= GET_I_ELEMENT;
					end
					GET_I_ELEMENT: begin
						LED[0] <= q[0];
						LED[1] <= q[1];
						LED[2] <= q[2];
						LED[3] <= q[3];
						LED[4] <= q[4];
						LED[5] <= q[5];
						LED[6] <= q[6];
						LED[7] <= q[7];
					
						i_element <= q;
						state <= GET_ADDRESS_J;
					end
					GET_ADDRESS_J: begin
						address <= j;
						state <= GET_ADDRESS_J_WAIT;
					end
//					GET_ADDRESS_J_WAIT: begin
//						state <= GET_J_ELEMENT;
//					end
//					GET_J_ELEMENT: begin
//						j_element <= q;
//						state <= SWAP_J_TO_I;
//					end
//					SWAP_J_TO_I: begin
//						data <= i_element;
//						state <= ENABLE_WRITE;
//					end
//					ENABLE_WRITE: begin
//						wren <= 1'b1;
//						state <= DISABLE_WRITE;
//					end
//					DISABLE_WRITE: begin
//						wren <= 1'b0;
//						state <= SWAP_I_TO_J;
//					end
//					SWAP_I_TO_J: begin
//						address <= i;
//						data <= j_element;
//						state <= SWAP_I_TO_J_WAIT;
//					end
//					SWAP_I_TO_J_WAIT: begin
//						state <= ENABLE_WRITE_2;
//					end
//					ENABLE_WRITE_2: begin
//						wren <= 1'b1;
//						state <= DISABLE_WRITE_2;
//					end
//					DISABLE_WRITE_2: begin
//						wren <= 1'b0;
//						state <= CHANGE_ADDRESS;
//					end
//					CHANGE_ADDRESS: begin
//						address <= i_element + j_element;
//						state <= CHANGE_ADDRESS_WAIT;
//					end
//					CHANGE_ADDRESS_WAIT: begin
//						state <= GET_F;
//					end
//					GET_F: begin
//						f <= q;
//						address_rom <= k;
//						address_ram <= k;
//						state <= SET_ROM_ADDRESS;
//					end
//					SET_ROM_ADDRESS: begin
//						state <= DECRYPT;
//					end
//					DECRYPT: begin
//						data_ram <= f ^ q_rom;
//						state <= ENABLE_RAM_WRITE;
//					end
//					ENABLE_RAM_WRITE: begin
//						wren_ram <= 1'b1;
//						state <= DISABLE_RAM_WRITE;
//					end
//					DISABLE_RAM_WRITE: begin
//						wren_ram <= 1'b0;
//						state <= DECRYPT_WAIT;
//					end
//					DECRYPT_WAIT: begin
//						if (k == 8'd31) begin
//                        state <= DECRYPT_DONE;
//                    end else begin
//								k <= k + 8'd1;
//                        state <= ADD_I;
//                    end
//					end
//					DECRYPT_DONE: begin
//                  finish <= 1'b1;
//					end
					default: begin
						state <= INIT;
					end
					
            endcase
        end
    end
endmodule
