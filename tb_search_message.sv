module tb_search_message();

    reg clk;
    reg start;
    reg [7:0] read_byte;
    wire [7:0] address;
    wire [23:0] key;
    wire [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
    wire [9:0] LEDR;
    wire [3:0] state; 

    
    search_message dut (
        .clk(clk), 
        .start(start), 
        .read_byte(read_byte),
        .address(address),
        .key(key),
        .HEX5(HEX5),
        .HEX4(HEX4),
        .HEX3(HEX3),
        .HEX2(HEX2),
        .HEX1(HEX1),
        .HEX0(HEX0),
        .LEDR(LEDR)
    );

    assign state = dut.state;

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    // Test sequence
    initial begin
        // Initialize inputs
        start = 0;
        read_byte = 8'd0;

        // Reset the design
        #10;
        start = 1;

        #10 read_byte = 8'h61; // ASCII 'a'
        #10 read_byte = 8'h62; // ASCII 'b'
        #10 read_byte = 8'h63; // ASCII 'c'
        #10 read_byte = 8'h64; // ASCII 'd'
        #10 read_byte = 8'h20; // ASCII ' ' (space)
        #10 read_byte = 8'h65; // ASCII 'e'
        #10 read_byte = 8'h66; // ASCII 'f'
        #10 read_byte = 8'h67; // ASCII 'g'
        #10 read_byte = 8'h68; // ASCII 'h'
        #10 read_byte = 8'h7E; 
        
        // Allow some time for the state machine to process the bytes
        #100;
        
        // Stop the simulation
        $stop;
    end

   

endmodule
