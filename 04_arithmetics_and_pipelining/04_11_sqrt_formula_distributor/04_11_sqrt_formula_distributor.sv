module sqrt_formula_distributor
# (
    parameter formula = 1,
              impl    = 1
)
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output logic        res_vld,
    output logic [31:0] res
);

    // Task:
    //
    // Implement a module that will calculate formula 1 or formula 2
    // based on the parameter values. The module must be pipelined.
    // It should be able to accept new triple of arguments a, b, c arriving
    // at every clock cycle.
    //
    // The idea of the task is to implement hardware task distributor,
    // that will accept triplet of the arguments and assign the task
    // of the calculation formula 1 or formula 2 with these arguments
    // to the free FSM-based internal module.
    //
    // The first step to solve the task is to fill 03_04 and 03_05 files.
    //
    // Note 1:
    // Latency of the module "formula_1_isqrt" should be clarified from the corresponding waveform
    // or simply assumed to be equal 50 clock cycles.
    //
    // Note 2:
    // The task assumes idealized distributor (with 50 internal computational blocks),
    // because in practice engineers rarely use more than 10 modules at ones.
    // Usually people use 3-5 blocks and utilize stall in case of high load.
    //
    // Hint:
    // Instantiate sufficient number of "formula_1_impl_1_top", "formula_1_impl_2_top",
    // or "formula_2_top" modules to achieve desired performance.

    localparam N = (formula == 1) ? 13 : 13;
    
    logic [31:0] in_a   [N];
    logic [31:0] in_b   [N];
    logic [31:0] in_c   [N];
    logic        in_vld [N];

    logic [31:0] out_res [N];
    logic        out_vld [N];

    logic [7:0] cnt;

    always_ff @ (posedge clk) begin
        if (rst) begin
            cnt <= '0;
        end

        if(cnt ==  N - 1)
            cnt <= 0;
        else
            cnt++;
    end
    
    always_comb begin
        for (int i = 0; i < N; i++)
            in_vld[i] = '0;

        in_a  [cnt] = a;
        in_b  [cnt] = b;
        in_c  [cnt] = c;
        in_vld[cnt] = arg_vld;   

        res     = out_res[cnt];
        res_vld = out_vld[cnt];
    end


    generate
        genvar i;
        if (formula == 1)
            for (i = 0; i < N; i++)
                formula_1_impl_1_top f1(
                    .clk(clk),
                    .rst(rst),
                    .a(in_a[i]),
                    .b(in_b[i]),
                    .c(in_c[i]),
                    .arg_vld(in_vld[i]),
                    .res_vld(out_vld[i]),
                    .res(out_res[i]));

        else if (formula == 2)
            for (i = 0; i < N; i++)
                formula_2_top f2(
                    .clk(clk),
                    .rst(rst),
                    .a(in_a[i]),
                    .b(in_b[i]),
                    .c(in_c[i]),
                    .arg_vld(in_vld[i]),
                    .res_vld(out_vld[i]),
                    .res(out_res[i]));

    endgenerate

endmodule
