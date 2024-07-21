module ff_mux #(
    parameter RSTTYPE = "SYNC",
    parameter WIDTH = 1,
    parameter XREG = 1
    )(
    input clk, rst, clk_en,
    input [WIDTH - 1:0] d,
    output reg [WIDTH - 1:0] q
    );
    reg [WIDTH - 1:0] q_sync, q_async;
    // wire [WIDTH - 1:0] q_reg;

    always @(posedge clk) begin // D Flip Flop with Active High Synchronous Reset
        if(rst)
            q_sync <= 0;
        else if(clk_en)
            q_sync <= d;
    end
    always @(posedge clk, posedge rst) begin // D Flip Flop with Active High Asynchronous Reset
        if(rst)
            q_async <= 0;
        else if(clk_en)
            q_async <= d;
    end
    always @(*) begin
        if (XREG) // MUX for the pipline stages
            q = (RSTTYPE == "SYNC") ? q_sync : q_async; // MUX for Synchronous D Flip Flop or the Asynchronous D Flip Flop
        else
            q = d;
    end
    // assign q_reg = (RSTTYPE == "SYNC") ? q_sync : q_async; // MUX for Synchronous D Flip Flop or the Asynchronous D Flip Flop
    // assign q = (XREG == 1) ? q_reg : d; // MUX for the pipline stages
endmodule