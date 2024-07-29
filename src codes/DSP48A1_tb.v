module DSP48A1_tb;
    reg [17:0] A_tb, B_tb, D_tb;
    reg [47:0] C_tb;
    reg CLK_tb;
    reg CARRYIN_tb;
    reg [7:0] OPMODE_tb;
    reg RSTA_tb, RSTB_tb, RSTM_tb, RSTP_tb, RSTC_tb, RSTD_tb, RSTCARRYIN_tb, RSTOPMODE_tb;
    reg CEA_tb, CEB_tb, CEM_tb, CEP_tb, CEC_tb, CED_tb, CECARRYIN_tb, CEOPMODE_tb;
    reg [47:0] PCIN_tb;
    wire [17:0] BCOUT_dut;
    wire [47:0] PCOUT_dut, P_dut;
    wire [35:0] M_dut;
    wire CARRYOUT_dut;
    wire CARRYOUTF_dut;

    DSP48A1 DUT(
        .A(A_tb), .B(B_tb), .D(D_tb), .C(C_tb), .CLK(CLK_tb),
        .CARRYIN(CARRYIN_tb), .OPMODE(OPMODE_tb),
        .RSTA(RSTA_tb), .RSTB(RSTB_tb), .RSTM(RSTM_tb), .RSTP(RSTP_tb),
        .RSTC(RSTC_tb), .RSTD(RSTD_tb), .RSTCARRYIN(RSTCARRYIN_tb),
        .RSTOPMODE(RSTOPMODE_tb),
        .CEA(CEA_tb), .CEB(CEB_tb), .CEM(CEM_tb), .CEP(CEP_tb),
        .CEC(CEC_tb), .CED(CED_tb), .CECARRYIN(CECARRYIN_tb),
        .CEOPMODE(CEOPMODE_tb),
        .PCIN(PCIN_tb), .BCOUT(BCOUT_dut), .PCOUT(PCOUT_dut),
        .P(P_dut), .M(M_dut), .CARRYOUT(CARRYOUT_dut),
        .CARRYOUTF(CARRYOUTF_dut)
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
        @(negedge CLK_tb);
        @(negedge CLK_tb);
        $stop;
    end
endmodule