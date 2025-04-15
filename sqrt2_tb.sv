`include "sqrt2.sv"

module sqrt2_tb;
    reg CLK = 0;
    reg ENABLE;
    reg [15:0] IO_DATA;
    wire IS_NAN;
    wire IS_PINF;
    wire IS_NINF;
    wire RESULT;

    wire[15:0] io_data_wire;


    integer fd;
    integer i;
    integer errors = 0;
    assign io_data_wire = IO_DATA;

    sqrt2 uut (
        .IO_DATA(io_data_wire),
        .IS_NAN(IS_NAN),
        .IS_PINF(IS_PINF),
        .IS_NINF(IS_NINF),
        .RESULT(RESULT),
        .CLK(CLK),
        .ENABLE(ENABLE)
    );

	always #1 CLK = ~CLK;
    
    initial begin
        fd = $fopen("sqrt2_log.csv", "w");

		#0
		ENABLE = 0;
		$fwrite(fd, "Test #1.1 (normal number) \n");
		IO_DATA = 16'h1234;
		ENABLE = 1;
		#2
		IO_DATA = 16'bzzzzzzzzzzzzzzzz;
        #22;

		#0
		ENABLE = 0;
		$fwrite(fd, "\nTest #1.2 (normal number) \n");
		IO_DATA = 16'h10c7;
		ENABLE = 1;
		#2
		IO_DATA = 16'bzzzzzzzzzzzzzzzz;
        #22;


		#0
		ENABLE = 0;
		$fwrite(fd, "\nTest #1.3 (normal number) \n");
		IO_DATA = 16'h6066;
		ENABLE = 1;
		#2
		IO_DATA = 16'bzzzzzzzzzzzzzzzz;
        #22;

		#0
		ENABLE = 0;
		$fwrite(fd, "\nTest #1.4 (normal number) \n");
		IO_DATA = 16'h20ba;
		ENABLE = 1;
		#2
		IO_DATA = 16'bzzzzzzzzzzzzzzzz;
        #22;

		#0
		ENABLE = 0;
		$fwrite(fd, "\nTest #1.5 (normal number) \n");
		IO_DATA = 16'h3604;
		ENABLE = 1;
		#2
		IO_DATA = 16'bzzzzzzzzzzzzzzzz;
        #22;


		#0
		ENABLE = 0;
		$fwrite(fd, "\nTest #1.6 (normal number) \n");
		IO_DATA = 16'h7777;
		ENABLE = 1;
		#2
		IO_DATA = 16'bzzzzzzzzzzzzzzzz;
        #22;

		#0
		ENABLE = 0;
 		$fwrite(fd, "\nTest #2 (pos zero) \n");
		IO_DATA = 16'h0000;
		ENABLE = 1;
		#2
		IO_DATA = 16'bzzzzzzzzzzzzzzzz;
        #22;

		#0
		ENABLE = 0;
 		$fwrite(fd, "\nTest #3 (neg zero) \n");
		IO_DATA = 16'h8000;
		ENABLE = 1;
		#2
		IO_DATA = 16'bzzzzzzzzzzzzzzzz;
        #2;

		#0
		ENABLE = 0;
 		$fwrite(fd, "\nTest #4 (not quite nan)\n");
		IO_DATA = 16'h7d30;
		ENABLE = 1;
		#2
		IO_DATA = 16'bzzzzzzzzzzzzzzzz;
        #2;

		#0
		ENABLE = 0;
 		$fwrite(fd, "\nTest #5 (quite nan)\n");
		IO_DATA = 16'h7f30;
		ENABLE = 1;
		#2
		IO_DATA = 16'bzzzzzzzzzzzzzzzz;
        #2;

		#0
		ENABLE = 0;
 		$fwrite(fd, "\nTest #5 (pinf)\n");
		IO_DATA = 16'h7c00;
		ENABLE = 1;
		#2
		IO_DATA = 16'bzzzzzzzzzzzzzzzz;
        #2;

		#0
		ENABLE = 0;
 		$fwrite(fd, "\nTest #6.1 (denorm number)\n");
		IO_DATA = 16'h000a;
		ENABLE = 1;
		#2
		IO_DATA = 16'bzzzzzzzzzzzzzzzz;
        #22;

		#0
		ENABLE = 0;
 		$fwrite(fd, "\nTest #6.2 (denorm number)\n");
		IO_DATA = 16'h0049;
		ENABLE = 1;
		#2
		IO_DATA = 16'bzzzzzzzzzzzzzzzz;
        #22;

		#0
		ENABLE = 0;
 		$fwrite(fd, "\nTest #6.3 (denorm number)\n");
		IO_DATA = 16'h0001;
		ENABLE = 1;
		#2
		IO_DATA = 16'bzzzzzzzzzzzzzzzz;
        #22;

        $finish;
    end
    
	always @(negedge CLK) begin
		$fwrite(fd, "timw: %d, num = %h, res %h, is_nan %h, is_ninf %h, is_pinf %h,   \n", $time , io_data_wire, RESULT, IS_NAN, IS_NINF, IS_PINF);
	end
    
endmodule