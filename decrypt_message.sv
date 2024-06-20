module Decrypt_Message(
    input wire clk,
    input logic start,
    input wire [7:0] q, // to read from s[i] or s[j]
	 input wire [7:0] q_rom, // to read from encrypted_input[k]
	 input wire [7:0] q_ram,
    output logic [7:0] address, // address for the sram
	 output logic [4:0] address_rom, // address for the encrypted rom
	 output logic [4:0] address_ram, // address for the decrypted ram
	 output logic [7:0] data, // for the sram
    output logic [7:0] data_ram, // for the decrypted ram
    output logic wren, // to enable writing to the sram
	 output logic wren_ram, // to enable writing to the decrypted ram
    output logic finish,
	 output logic [7:0] LED
);

    // State machine states for Task 2
    typedef enum logic [4:0] {
        INIT,
		  ADD_I,
		  ADD_I_WAIT,
		  GET_ADDRESS_I,
		  GET_ADDRESS_I_WAIT,
		  GET_S_J,
		  ADD_J,
		  ADD_J_WAIT,
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
		  PRE_GET_F,
		  GET_F,
		  SET_ROM_ADDRESS,
		  SET_ROM_ADDRESS_WAIT,
		  DECRYPT,
		  DECRYPT_ADDRESS_WAIT,
		  DECRYPT_WAIT_WAIT,
		  DECRYPT_PRE_WAIT,
		  DECRYPT_WAIT,
		  DECRYPT_DONE
	} state_type;

    state_type state;
	 
	 reg [7:0] i, j, f, i_element, j_element, decrypted;
	 reg [4:0] k;
	 reg [8:0] temp_address, j_f, i_f;

    always_ff @(posedge clk) begin
        if (!start) begin
				state <= INIT;
				i <= 8'b0;
				j <= 8'b0;
				k <= 5'b0;
				f <= 8'b0;
				i_element <= 8'b0;
				j_element <= 8'b0;
				temp_address <= 9'b0;
				j_f <= 9'b0;
				address <= 8'b0; // set the address of sram to 0
				address_rom <= 5'b0; // set the address of the encrypted rom to 0
				address_ram <= 5'b0; // set the address of the decrypted ram to 0
				wren <= 1'b0; 
            wren_ram <= 1'b0;
				finish <= 8'b0;
        end else begin
            case (state)
					INIT: begin
						i <= 8'b0;
						j <= 8'b0;
						k <= 4'b0;
						state <= ADD_I;
					end
					ADD_I: begin
						i_f <= i + 8'd1;
						state <= ADD_I_WAIT;
					end
					ADD_I_WAIT: begin
						state <= GET_ADDRESS_I;
					end
					GET_ADDRESS_I: begin
						address <= i_f;
						state <= GET_ADDRESS_I_WAIT;
					end
					GET_ADDRESS_I_WAIT: begin
						state <= GET_S_J;
					end
					GET_S_J: begin
						i_element <= q;
						
						state <= ADD_J;
					end
					ADD_J: begin
						j_f <= (j + i_element);
						state <= ADD_J_WAIT;
					end
					ADD_J_WAIT: begin
						state <= GET_ADDRESS_J;
					end
					GET_ADDRESS_J: begin
						
						address <= j_f[7:0];	
						state <= GET_ADDRESS_J_WAIT;
					end
					GET_ADDRESS_J_WAIT: begin
						state <= GET_J_ELEMENT;
					end
					GET_J_ELEMENT: begin // s[j]
						j_element <= q;
						state <= SWAP_J_TO_I;
					end
					SWAP_J_TO_I: begin
						data <= i_element; // s[j] = s[i]
						state <= ENABLE_WRITE;
					end
					ENABLE_WRITE: begin
						wren <= 1'b1;
						state <= DISABLE_WRITE;
					end
					DISABLE_WRITE: begin // s[j] has s[i] written to it
						wren <= 1'b0;
						state <= SWAP_I_TO_J;
					end
					SWAP_I_TO_J: begin
						address <= i_f;
						data <= j_element;
						state <= SWAP_I_TO_J_WAIT;
					end
					SWAP_I_TO_J_WAIT: begin
						state <= ENABLE_WRITE_2;
					end
					ENABLE_WRITE_2: begin
						wren <= 1'b1;
						state <= DISABLE_WRITE_2;
					end
					DISABLE_WRITE_2: begin
						wren <= 1'b0;
						state <= CHANGE_ADDRESS;
					end
					CHANGE_ADDRESS: begin
						temp_address <= (i_element + j_element);
						
						state <= CHANGE_ADDRESS_WAIT;
					end
			
					CHANGE_ADDRESS_WAIT: begin
						address <= temp_address[7:0];
						state <= PRE_GET_F;
					end
					PRE_GET_F: begin
						state <= GET_F;
					end
					GET_F: begin
						f <= q;	// f = s[ (s[i) + s[j]) ]
						address_rom <= k;
						state <= SET_ROM_ADDRESS;
					end
					SET_ROM_ADDRESS: begin
						state <= SET_ROM_ADDRESS_WAIT;
					end
					SET_ROM_ADDRESS_WAIT: begin
						state <= DECRYPT;
					end
					DECRYPT: begin
//						LED[0] <= q_rom[0];
//						LED[1] <= q_rom[1];
//						LED[2] <= q_rom[2];
//						LED[3] <= q_rom[3];
//						LED[4] <= q_rom[4];
//						LED[5] <= q_rom[5];
//						LED[6] <= q_rom[6];
//						LED[7] <= q_rom[7];
						address_ram <= k;
						decrypted <= (f ^ q_rom);
						state <= DECRYPT_ADDRESS_WAIT;
					end
					
					DECRYPT_ADDRESS_WAIT: begin
						state <= DECRYPT_WAIT_WAIT;
						data_ram <= decrypted;
					end
					
					DECRYPT_WAIT_WAIT: begin
						state <= DECRYPT_PRE_WAIT;
						wren_ram <= 1'b1;
					end
		
					DECRYPT_PRE_WAIT: begin
						i <= i_f[7:0];
						wren_ram <= 1'b0;
						
						state <= DECRYPT_WAIT;
					end
					DECRYPT_WAIT: begin
						j <= j_f[7:0]; // set j to the updated j
						k <= k + 8'd1;
						
						if (k == 8'd31) begin
                        state <= DECRYPT_DONE;
                    end else begin
                        state <= ADD_I;
                    end
					end
					DECRYPT_DONE: begin
                  finish <= 1'b1;
					end
					default: begin
						state <= INIT;
					end
					
            endcase
        end
    end
endmodule
