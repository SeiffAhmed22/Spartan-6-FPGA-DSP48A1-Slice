module mux_4to1 #(parameter WIDTH = 48) (
    input [WIDTH - 1:0] in0, in1, in2, in3,
    input [1:0] sel,
    output [WIDTH - 1:0] out
    );
    assign out =    (sel == 2'b11) ? in3 :
                    (sel == 2'b10) ? in2 :
                    (sel == 2'b01) ? in1 : in0;
endmodule