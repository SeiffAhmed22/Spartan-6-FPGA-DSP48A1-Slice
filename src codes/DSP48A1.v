module DSP48A1 #(
    parameter A0REG = 0, // If equal (0) --> No register, else --> Registered 
    parameter A1REG = 1, // If equal (0) --> No register, else --> Registered 
    parameter B0REG = 0, // If equal (0) --> No register, else --> Registered 
    parameter B1REG = 1, // If equal (0) --> No register, else --> Registered 
    parameter CREG = 1, // If equal (0) --> No register, else --> Registered 
    parameter DREG = 1, // If equal (0) --> No register, else --> Registered 
    parameter MREG = 1, // If equal (0) --> No register, else --> Registered 
    parameter PREG = 1, // If equal (0) --> No register, else --> Registered 
    parameter CARRYINREG = 1, // If equal (0) --> No register, else --> Registered 
    parameter CARRYOUTREG = 1, // If equal (0) --> No register, else --> Registered 
    parameter OPMODEREG = 1, // If equal (0) --> No register, else --> Registered 
    parameter CARRYINSEL = "OPMODE5", // Selects between CARRYIN and opcode[5]
    parameter B_INPUT = "DIRECT", // Selects between direct (B) input and cascaded input (BCIN)
    parameter RSTTYPE = "SYNC" // Selects whether all registers have a synchronous or asynchronous reset capability
    ) (
    input [17:0] A, B, D,
    input [47:0] C,
    input CLK, // DSP clock 
    input CARRYIN, // carry input to the post-adder/subtracter
    input [7:0] OPMODE, // Control input to select the arithmetic operations
    input RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCARRYIN, RSTOPMODE, // Reset Input Ports (Active High)
    input CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CEOPMODE, // Clock Enable Input Ports
    input [47:0] PCIN, // Cascade input for Port P
    output [17:0] BCOUT, // Cascade output for Port B
    output [47:0] PCOUT, // Cascade output for Port P
    output [47:0] P, // Primary data output from the post-adder/subtracter
    output [35:0] M, // 36-bit buffered multiplier data output, routable to the FPGA logic
    output CARRYOUT, // Cascade carry out signal from post-adder/subtracter. This output is to be connected only to CARRYIN of adjacent DSP48A1 if multiple DSP blocks are used
    output CARRYOUTF // Carry out signal from post-adder/subtracter for use in the FPGA logic. It is a copy of the CARRYOUT signal that can be routed to the user logic
    );
    wire [7:0] OPMODE_REG;
    wire [17:0] BCIN; // The BCIN input is the direct cascade from the adjacent DSP48A1 BCOUT
    wire [17:0] B_Mux, A0_REG, A1_REG, B0_REG, B1_REG, D_REG, Pre_Add_Sub, B_add_sub_mux;
    wire [35:0] Mult, M_REG;
    wire [47:0] C_REG, D_A_B, X_Mux, Z_Mux, Post_Add_Sub;
    wire Carry_Cascade, Carry_In_REG, Carry_Out_Post;

    assign B_Mux = (B_INPUT == "DIRECT") ? B : (B_INPUT == "CASCADE") ? BCIN : 0; // B input MUX, either direct (B) input or cascaded input (BCIN)
    ff_mux #(.RSTTYPE(RSTTYPE), .WIDTH(18), .XREG(DREG)) D_ff_mux (.clk(CLK), .rst(RSTD), .clk_en(CED), .d(D), .q(D_REG)); // D register
    ff_mux #(.RSTTYPE(RSTTYPE), .WIDTH(18), .XREG(B0REG)) B0_ff_mux (.clk(CLK), .rst(RSTB), .clk_en(CEB), .d(B_Mux), .q(B0_REG)); // B0 register
    ff_mux #(.RSTTYPE(RSTTYPE), .WIDTH(18), .XREG(A0REG)) A0_ff_mux (.clk(CLK), .rst(RSTA), .clk_en(CEA), .d(A), .q(A0_REG)); // A0 register
    ff_mux #(.RSTTYPE(RSTTYPE), .WIDTH(48), .XREG(CREG)) C_ff_mux (.clk(CLK), .rst(RSTC), .clk_en(CEC), .d(C), .q(C_REG)); // C register
    ff_mux #(.RSTTYPE(RSTTYPE), .WIDTH(8), .XREG(OPMODEREG)) OPMODE_ff_mux (.clk(CLK), .rst(RSTOPMODE), .clk_en(CEOPMODE), .d(OPMODE), .q(OPMODE_REG)); // OPMODE register
    assign Pre_Add_Sub = (OPMODE_REG[6] == 1) ? (D_REG - B0_REG) : (D_REG + B0_REG); // Choose between addition or subtraction in pre-adder/subtracter
    assign B_add_sub_mux = (OPMODE_REG[4] == 1) ? Pre_Add_Sub : B0_REG; // Mux for either output of Pre-Adder/Subtractor or B0 register
    ff_mux #(.RSTTYPE(RSTTYPE), .WIDTH(18), .XREG(B1REG)) B1_ff_mux (.clk(CLK), .rst(RSTB), .clk_en(CEB), .d(B_add_sub_mux), .q(B1_REG)); // B1 register
    assign BCOUT = B1_REG;
    ff_mux #(.RSTTYPE(RSTTYPE), .WIDTH(18), .XREG(A1REG)) A1_ff_mux (.clk(CLK), .rst(RSTA), .clk_en(CEA), .d(A0_REG), .q(A1_REG)); // A1 register
    assign Mult = A1_REG * B1_REG; // Multiply operation
    ff_mux #(.RSTTYPE(RSTTYPE), .WIDTH(36), .XREG(MREG)) M_ff_mux (.clk(CLK), .rst(RSTM), .clk_en(CEM), .d(Mult), .q(M_REG)); // M register
    ff_mux #(.RSTTYPE(RSTTYPE), .WIDTH(36), .XREG(1)) M_buffer_ff_mux (.clk(CLK), .rst(0), .clk_en(1), .d(M_REG), .q(M)); // Buffered M register
    assign Carry_Cascade = (CARRYINSEL == "OPMODE5") ? OPMODE_REG[5] : (CARRYINSEL == "CARRYIN") ? CARRYIN : 0; // Carry MUX, either CARRYIN or opcode[5]
    ff_mux #(.RSTTYPE(RSTTYPE), .WIDTH(1), .XREG(CARRYINREG)) CYI_ff_mux (.clk(CLK), .rst(RSTCARRYIN), .clk_en(CECARRYIN), .d(Carry_Cascade), .q(Carry_In_REG)); // CARRYIN register
    assign D_A_B = {D_REG[11:0], A1_REG[17:0], B1_REG[17:0]};
    mux_4to1 #(.WIDTH(48)) X_4x1_MUX (.in0({48{1'b0}}), .in1({{12{1'b0}}, M_REG}), .in2(P), .in3(D_A_B), .sel(OPMODE_REG[1:0]), .out(X_Mux)); // X 4x1 MUX
    mux_4to1 #(.WIDTH(48)) Z_4x1_MUX (.in0({48{1'b0}}), .in1(PCIN), .in2(P), .in3(C_REG), .sel(OPMODE_REG[3:2]), .out(Z_Mux)); // Z 4x1 MUX
    assign {Carry_Out_Post, Post_Add_Sub} = (OPMODE_REG[7] == 1) ? (Z_Mux - (X_Mux + Carry_In_REG)) : (Z_Mux + X_Mux + Carry_In_REG); // Choose between addition or subtraction in post-adder/subtracter
    ff_mux #(.RSTTYPE(RSTTYPE), .WIDTH(1), .XREG(CARRYOUTREG)) CYO_ff_mux (.clk(CLK), .rst(RSTCARRYIN), .clk_en(CECARRYIN), .d(Carry_Out_Post), .q(CARRYOUT)); // CARRYOUT register
    assign CARRYOUTF = CARRYOUT;
    ff_mux #(.RSTTYPE(RSTTYPE), .WIDTH(48), .XREG(PREG)) P_ff_mux (.clk(CLK), .rst(RSTP), .clk_en(CEP), .d(Post_Add_Sub), .q(P)); // P register
    assign PCOUT = P;
endmodule