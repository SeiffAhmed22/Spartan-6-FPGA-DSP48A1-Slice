module DSP48A1_tb;
    reg [17:0] A_tb, B_tb, D_tb;
    reg [47:0] C_tb;
    reg CLK_tb;
    reg CARRYIN_tb;
    reg [7:0] OPMODE_tb;
    reg RSTA_tb, RSTB_tb, RSTM_tb, RSTP_tb, RSTC_tb, RSTD_tb, RSTCARRYIN_tb, RSTOPMODE_tb;
    reg CEA_tb, CEB_tb, CEM_tb, CEP_tb, CEC_tb, CED_tb, CECARRYIN_tb, CEOPMODE_tb;
    reg [47:0] PCIN_tb;
    wire [17:0] BCOUT_dut_def;
    wire [47:0] PCOUT_dut_def, P_dut_def;
    wire [35:0] M_dut_def;
    wire CARRYOUT_dut_def;
    wire CARRYOUTF_dut_def;

    // Instantiation with Default Paramters
    DSP48A1 DUT(
        .A(A_tb), .B(B_tb), .D(D_tb), .C(C_tb), .CLK(CLK_tb),
        .CARRYIN(CARRYIN_tb), .OPMODE(OPMODE_tb),
        .RSTA(RSTA_tb), .RSTB(RSTB_tb), .RSTM(RSTM_tb), .RSTP(RSTP_tb),
        .RSTC(RSTC_tb), .RSTD(RSTD_tb), .RSTCARRYIN(RSTCARRYIN_tb),
        .RSTOPMODE(RSTOPMODE_tb),
        .CEA(CEA_tb), .CEB(CEB_tb), .CEM(CEM_tb), .CEP(CEP_tb),
        .CEC(CEC_tb), .CED(CED_tb), .CECARRYIN(CECARRYIN_tb),
        .CEOPMODE(CEOPMODE_tb),
        .PCIN(PCIN_tb), .BCOUT(BCOUT_dut_def), .PCOUT(PCOUT_dut_def),
        .P(P_dut_def), .M(M_dut_def), .CARRYOUT(CARRYOUT_dut_def),
        .CARRYOUTF(CARRYOUTF_dut_def)
    );

    // Clock Generation
    initial begin
        CLK_tb = 0;
        forever #5 CLK_tb = ~CLK_tb;
    end

    initial begin
        // Initialization
        {RSTA_tb, RSTB_tb, RSTM_tb, RSTP_tb, RSTC_tb, RSTD_tb, RSTCARRYIN_tb, RSTOPMODE_tb} = 8'b1111_1111;
        {CEA_tb, CEB_tb, CEM_tb, CEP_tb, CEC_tb, CED_tb, CECARRYIN_tb, CEOPMODE_tb} = 8'b1111_1111;
        {A_tb, B_tb, D_tb, C_tb, CARRYIN_tb, OPMODE_tb, PCIN_tb} = 0;
        repeat (2) @(negedge CLK_tb);

        {RSTA_tb, RSTB_tb, RSTM_tb, RSTP_tb, RSTC_tb, RSTD_tb, RSTCARRYIN_tb, RSTOPMODE_tb} = 0;

        // Test Case 1: Pre-Adder, Pre-Adder output, Post-Adder, Multiplier output from MUX X, C Input from MUX X
        A_tb = 'd5;
        B_tb = 'd4;
        C_tb = 'd7;
        D_tb = 'd10;
        OPMODE_tb = 8'b0011_1101;
        CARRYIN_tb = 1'b1;
        repeat (4) @(negedge CLK_tb);

        // Test Case 2: Pre-Subtractor, Pre-Subtractor output, Post-Subtractor, D:A:B Concatenated from MUX X, PCIN Input from MUX X
        A_tb = 'd2;
        B_tb = 'd5;
        C_tb = 'd7;
        D_tb = 'd15;
        OPMODE_tb = 8'b1101_0111;
        PCIN_tb = 48'h00f0000f0000;
        repeat (4) @(negedge CLK_tb);

        // Test Case 3: Pre-Subtractor, B input from MUX, Post-Adder, P from MUX X, P from MUX X
        A_tb = 'd10;
        B_tb = 'd5;
        C_tb = 'd7;
        D_tb = 'd15;
        OPMODE_tb = 8'b0100_1010;
        repeat (4) @(negedge CLK_tb);
        
        // Test Case 4: Pre-Adder, B input from MUX, Post-Adder, (Zeros from MUX X & Zeros from MUX X) Reset P
        A_tb = 'd15;
        B_tb = 'd30;
        C_tb = 'd7;
        D_tb = 'd15;
        OPMODE_tb = 8'b1000_0000;
        repeat (4) @(negedge CLK_tb);

        $stop;
    end
endmodule