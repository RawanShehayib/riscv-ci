module tb_alu;

    // 1. Signals to connect to the ALU
    logic [31:0] a, b, result;
    logic [3:0]  op;
    logic        zero;

    int errors = 0;

    // 2. The design under test (DUT)
    alu dut (
        .a(a), .b(b), .op(op),
        .result(result), .zero(zero)
    );

    // 3. A helper that applies inputs and checks the result
    task automatic check(input logic [3:0] op_i,
                         input logic [31:0] a_i, b_i, expected);
        a = a_i; b = b_i; op = op_i;
        #1;   // let the combinational logic settle
        if (result !== expected) begin
            $display("ERROR op=%b a=%h b=%h: got %h, expected %h",
                     op_i, a_i, b_i, result, expected);
            errors++;
        end
    endtask

    // 4. The tests
    initial begin
        // Directed tests: check(op, a, b, expected)
        check(4'b0000, 32'd5,  32'd3,  32'd8);     // ADD: 5 + 3
        check(4'b0001, 32'd5,  32'd3,  32'd2);     // SUB: 5 - 3
        check(4'b0010, 32'hF0, 32'h3C, 32'h30);    // AND

        check(4'b0011, 32'hF0, 32'h3C, 32'hFC);
        check(4'b0100, 32'hF0, 32'h3C, 32'hCC);
        check(4'b0101, 32'd1, 32'd4, 32'd16);              
        check(4'b0110, 32'h80000000, 32'd4, 32'h08000000);       
        check(4'b0111, 32'h80000000, 32'd4, 32'hF8000000);       
        check(4'b1000, 32'hFFFFFFFF, 32'd1, 32'd1);       
        check(4'b1001, 32'hFFFFFFFF, 32'd1, 32'd0);     

        // Random tests against a reference model
        repeat (1000) begin
            logic [31:0] ra, rb;
            ra = $urandom; rb = $urandom;
            check(4'b0000, ra, rb, ra + rb);
            check(4'b0001, ra, rb, ra - rb);
        end

        // 5. Exactly one final line for scripts to read
        if (errors == 0) $display("TEST tb_alu PASS");
        else             $display("TEST tb_alu FAIL (%0d errors)", errors);
        $finish;
    end

endmodule

