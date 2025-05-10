module put_in_order
# (
    parameter width    = 16,
              n_inputs = 4
)
(
    input                       clk,
    input                       rst,

    input  [ n_inputs - 1 : 0 ] up_vlds,
    input  [ n_inputs - 1 : 0 ]
           [ width    - 1 : 0 ] up_data,

    output                      down_vld,
    output [ width   - 1 : 0 ]  down_data
);

    // Task:
    //
    // Implement a module that accepts many outputs of the computational blocks
    // and outputs them one by one in order. Input signals "up_vlds" and "up_data"
    // are coming from an array of non-pipelined computational blocks.
    // These external computational blocks have a variable latency.
    //
    // The order of incoming "up_vlds" is not determent, and the task is to
    // output "down_vld" and corresponding data in a round-robin manner,
    // one after another, in order.
    //
    // Comment:
    // The idea of the block is kinda similar to the "parallel_to_serial" block
    // from Homework 2, but here block should also preserve the output order.


    logic [width-1:0]  data_buffer [n_inputs-1:0];
    logic [n_inputs-1:0] valid_buffer; 

    logic [$clog2(n_inputs)-1:0] current_idx;

    logic [n_inputs-1:0] next_valid_buffer;
    assign next_valid_buffer = valid_buffer & ~(1 << current_idx);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            current_idx   <= '0;
            valid_buffer  <= '0;
        end else begin
            if (valid_buffer[current_idx]) begin
                if (current_idx == n_inputs-1)
                    current_idx <= 0;
                else
                    current_idx <= current_idx + 1;
            end

            valid_buffer <= (valid_buffer & ~(1 << current_idx)) 
                          | (next_valid_buffer & up_vlds) 
                          | up_vlds;

            for (int i = 0; i < n_inputs; i++) begin
                if (!next_valid_buffer[i] && up_vlds[i]) begin
                    data_buffer[i] <= up_data[i];
                end
            end
        end
    end

    assign down_vld  = valid_buffer[current_idx];
    assign down_data = data_buffer[current_idx];
endmodule
