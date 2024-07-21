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
    wire [17:0] BCIN; // The BCIN input is the direct cascade from the adjacent DSP48A1 BCOUT
    wire [17:0] B_mux, A0_REG, A1_REG, B0_REG, B1_REG, D_REG, pre_add_sub, B_add_sub_mux;
    wire [47:0] C_REG, D_A_B;
    wire [35:0] mult;
    wire Carry_Cascade;

    assign B_mux = (B_INPUT == "DIRECT") ? B : (B_INPUT == "CASCADE") ? BCIN : 0; // B input MUX, either direct (B) input or cascaded input (BCIN)
    ff_mux #(.RSTTYPE(RSTTYPE), .WIDTH(18), .REG(DREG)) D_ff_mux (.clk(CLK), .rst(RSTD), .clk_en(CED), .d(D), .q(D_REG)); // D register
    ff_mux #(.RSTTYPE(RSTTYPE), .WIDTH(18), .REG(B0REG)) B0_ff_mux (.clk(CLK), .rst(RSTB), .clk_en(CEB), .d(B_mux), .q(B0_REG)); // B0 register
    ff_mux #(.RSTTYPE(RSTTYPE), .WIDTH(18), .REG(A0REG)) A0_ff_mux (.clk(CLK), .rst(RSTA), .clk_en(CEA), .d(A), .q(A0_REG)); // A0 register
    ff_mux #(.RSTTYPE(RSTTYPE), .WIDTH(48), .REG(CREG)) C_ff_mux (.clk(CLK), .rst(RSTC), .clk_en(CEC), .d(C), .q(C_REG)); // C register
    assign pre_add_sub = (OPMODE[6] == 1) ? (D_REG - B0_REG) : (D_REG + B0_REG); // MUX for either addition or subtraction
    assign B_add_sub_mux = (OPMODE[4] == 1) ? pre_add_sub : B0_REG; // Mux for either output of Pre-Adder/Subtractor or B0 register
    ff_mux #(.RSTTYPE(RSTTYPE), .WIDTH(18), .REG(B1REG)) B1_ff_mux (.clk(CLK), .rst(RSTB), .clk_en(CEB), .d(B_add_sub_mux), .q(B1_REG)); // B1 register
    assign BCOUT = B1_REG;
    ff_mux #(.RSTTYPE(RSTTYPE), .WIDTH(18), .REG(A1REG)) A1_ff_mux (.clk(CLK), .rst(RSTA), .clk_en(CEA), .d(A0_REG), .q(A1_REG)); // A1 register
    assign mult = A1_REG * B1_REG; // Multiply operation
    ff_mux #(.RSTTYPE(RSTTYPE), .WIDTH(36), .REG(MREG)) M_ff_mux (.clk(CLK), .rst(RSTM), .clk_en(CEM), .d(mult), .q(M)); // M register
    assign Carry_Cascade = (CARRYINSEL == "OPMODE5") ? OPMODE[5] : (CARRYINSEL == "CARRYIN") ? CARRYIN : 0; // Carry MUX, either CARRYIN or opcode[5]
    assign D_A_B = {D_REG[11:0], A1_REG[17:0], B1_REG[17:0]};
endmodule