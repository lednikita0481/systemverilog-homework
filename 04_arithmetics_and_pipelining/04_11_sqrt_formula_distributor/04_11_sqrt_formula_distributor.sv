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


    localparam N = 50;

    logic [31:0]            in_a   [N];
    logic [31:0]            in_b   [N];
    logic [31:0]            in_c   [N];
    logic                   in_vld [N];
    logic [N-1:0]           busy;

    logic [31:0]            out_res [N];
    logic                   out_vld [N];

    logic [$clog2(N)-1:0]   cnt;

    always_ff @(posedge clk) begin
        if (rst) begin
            cnt <= '0;
        end 
        else if (arg_vld) begin
            for (int i = 0; i < N; i++) begin
                logic [$clog2(N)-1:0] next_cnt = (cnt + i) % N;
                if (!busy[next_cnt]) begin
                    cnt <= next_cnt;
                    break;
                end
            end
        end
    end

    always_comb begin
        for (int i = 0; i < N; i++) begin
            in_vld[i] = '0;
            in_a[i] = '0;
            in_b[i] = '0;
            in_c[i] = '0;
        end

        if (arg_vld && !busy[cnt]) begin
            in_a[cnt] = a;
            in_b[cnt] = b;
            in_c[cnt] = c;
            in_vld[cnt] = arg_vld;
        end
    end

    always_comb begin
        res_vld = out_vld[cnt];
        res = out_res[cnt];
    end

    generate
        genvar i;
        for (i = 0; i < N; i++) begin

            if (formula == 1 && impl == 1) begin
                formula_1_impl_1_top f1_i1 (
                    .clk(clk),
                    .rst(rst),
                    .arg_vld(in_vld[i]),
                    .a(in_a[i]),
                    .b(in_b[i]),
                    .c(in_c[i]),
                    .res_vld(out_vld[i]),
                    .res(out_res[i])
                );

            end 
            else if (formula == 1 && impl == 2) begin
                formula_1_impl_2_top f1_i2 (
                    .clk(clk),
                    .rst(rst),
                    .arg_vld(in_vld[i]),
                    .a(in_a[i]),
                    .b(in_b[i]),
                    .c(in_c[i]),
                    .res_vld(out_vld[i]),
                    .res(out_res[i])
                );
            end 
            else begin
                formula_2_top f2 (
                    .clk(clk),
                    .rst(rst),
                    .arg_vld(in_vld[i]),
                    .a(in_a[i]),
                    .b(in_b[i]),
                    .c(in_c[i]),
                    .res_vld(out_vld[i]),
                    .res(out_res[i])
                );
            end

            always_ff @(posedge clk) begin
                if (rst) begin
                    busy[i] <= '0;
                end else if (in_vld[i]) begin
                    busy[i] <= '1;
                end else if (out_vld[i]) begin
                    busy[i] <= '0;
                end
            end
        end
    endgenerate

endmodule