module search_message(
    input wire logic clk, 
    input wire logic start, 
    input wire logic [7:0] read_byte,
    output reg [7:0] address,
    output reg [23:0] key,
    output reg [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0, 
    output reg [9:0] LEDR
);

    typedef enum logic [3:0] {
        S_INIT,
        S_READ_BYTE,
        S_READ_WAIT,
        S_CHECK_IF_CHAR,
        S_INC_ADDR,
        S_INC_KEY,
        S_GO_TO_ADDR,
        S_ADDR_WAIT,
        S_GO_TO_TASK2,
        S_DONE
        
    } state_type;

    state_type state;

    reg [7:0] read_data_temp;
    reg key_DNE_flag;


    wire [6:0] hex5, hex4, hex3, hex2, hex1, hex0;
    SevenSegmentDisplayDecoder decoder5 (.ssOut(hex5), .nIn(key[23:20]));
    SevenSegmentDisplayDecoder decoder4 (.ssOut(hex4), .nIn(key[19:16]));
    SevenSegmentDisplayDecoder decoder3 (.ssOut(hex3), .nIn(key[15:12]));
    SevenSegmentDisplayDecoder decoder2 (.ssOut(hex2), .nIn(key[11:8]));
    SevenSegmentDisplayDecoder decoder1 (.ssOut(hex1), .nIn(key[7:4]));
    SevenSegmentDisplayDecoder decoder0 (.ssOut(hex0), .nIn(key[3:0]));

    always_ff@(posedge clk or negedge start) begin
        if(!start) begin
            state <= S_INIT;
        end else begin
            case(state)
                S_INIT: begin
                    state <= S_GO_TO_ADDR;
                    address <= 8'd0;
                    key <= 24'd0;
                    key_DNE_flag <= 1'b0;
                    LEDR <= 10'd0;

                    // Update HEX displays
                    HEX5 <= hex5;
                    HEX4 <= hex4;
                    HEX3 <= hex3;
                    HEX2 <= hex2;
                    HEX1 <= hex1;
                    HEX0 <= hex0;

                end

                S_GO_TO_ADDR: begin
                    state <= S_ADDR_WAIT;
                end

                S_ADDR_WAIT: begin
                    state <= S_READ_BYTE;
                end

                S_READ_BYTE: begin
                    read_data_temp <= read_byte;
                    state <= S_READ_WAIT;
                end

                S_READ_WAIT: begin
                    state <= S_CHECK_IF_CHAR;
                end

                S_CHECK_IF_CHAR: begin
                    if(read_data_temp >= 8'd97 && read_data_temp <= 8'd122 || read_data_temp == 8'd32) begin
                        state <= S_INC_ADDR;
                    end else begin
                        state <= S_INC_KEY;
                    end
                end

                S_INC_KEY: begin
                    key <= key + 24'd1;

                    if(key <= 24'h3FFFFF) begin
                        state <= S_GO_TO_TASK2;
                    end else begin
                        state <= S_DONE;
                    end

                    // Update HEX displays
                    HEX5 <= hex5;
                    HEX4 <= hex4;
                    HEX3 <= hex3;
                    HEX2 <= hex2;
                    HEX1 <= hex1;
                    HEX0 <= hex0;
                end

                S_GO_TO_TASK2: begin
                    state <= S_INIT;
                end

                S_INC_ADDR: begin
                    address <= address + 8'd1;

                    if(address == 8'd32) begin
                        state <= S_DONE;
                    end else begin
                        state <= S_GO_TO_ADDR;
                    end
                end

                S_DONE: begin
                    if(!key_DNE_flag) begin
                        key <= key;
                        LEDR[0] <= 1'b1;
                    end else begin
                        key <= 24'd0;
                        LEDR[1] <= 1'b1;
                    end
                    state <= S_DONE;
                end

                default: begin
                    state <= S_INIT;
                end
            endcase
        end
    end



endmodule