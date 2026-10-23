module tb_regfile;

    logic        clk = 0;
    logic        we;
    logic [4:0]  waddr, raddr1, raddr2;
    logic [31:0] wdata, rdata1, rdata2;

    int errors = 0;

    regfile dut (
        .clk(clk), .we(we), .waddr(waddr), .wdata(wdata),
        .raddr1(raddr1), .raddr2(raddr2),
        .rdata1(rdata1), .rdata2(rdata2)
    );

    // Clock: flips every 5 time units → period of 10
    always #5 clk = ~clk;

    // Write one register (takes one clock edge)
    task automatic write_reg(input logic [4:0] addr, input logic [31:0] data);
        we = 1; waddr = addr; wdata = data;
        @(posedge clk);
        #1;
        we = 0;
    endtask

    // Read through port 1 and check
    task automatic check_read(input logic [4:0] addr, input logic [31:0] expected);
        raddr1 = addr;
        #1;
        if (rdata1 !== expected) begin
            $display("ERROR read x%0d: got %h, expected %h", addr, rdata1, expected);
            errors++;
        end
    endtask

    initial begin
        we = 0; waddr = 0; wdata = 0; raddr1 = 0; raddr2 = 0;

        // 1. Write then read back
        write_reg(5'd5, 32'hDEADBEEF);
        check_read(5'd5, 32'hDEADBEEF);

        // 2. x0 must always read 0, even after a write
        write_reg(5'd0, 32'hFFFFFFFF);
        check_read(5'd0, 32'd0);

        // 3. we = 0 must not change anything
        we = 0; waddr = 5'd5; wdata = 32'h12345678;
        @(posedge clk); #1;
        check_read(5'd5, 32'hDEADBEEF);

        // 4. Two reads at the same time
        write_reg(5'd10, 32'hAAAA0000);
        raddr1 = 5'd5; raddr2 = 5'd10;
        #1;
        if (rdata1 !== 32'hDEADBEEF || rdata2 !== 32'hAAAA0000) begin
            $display("ERROR dual read: got %h and %h", rdata1, rdata2);
            errors++;
        end

        // 5. Write every register 1..31, then read them all back
        for (int i = 1; i < 32; i++) write_reg(i[4:0], 32'h1000 + i);
        for (int i = 1; i < 32; i++) check_read(i[4:0], 32'h1000 + i);
	// 6. Read must use the READ address, not the write address 
	waddr = 5'd0;
	check_read(5'd5, 32'h1005);
	waddr = 5'd7;
	check_read(5'd0, 32'd0);


        if (errors == 0) $display("TEST tb_regfile PASS");
        else             $display("TEST tb_regfile FAIL (%0d errors)", errors);
        $finish;
    end

endmodule
