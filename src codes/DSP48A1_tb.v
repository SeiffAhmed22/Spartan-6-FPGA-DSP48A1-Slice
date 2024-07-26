module DSP48A1_tb;
    reg [17:0] A_tb, B_tb, D_tb;
    reg [47:0] C_tb;
    reg CLK_tb;
    reg CARRYIN_tb;
    reg [7:0] OPMODE_tb;
    reg RSTA_tb, RSTB_tb, RSTM_tb, RSTP_tb, RSTC_tb, RSTD_tb, RSTCARRYIN_tb, RSTOPMODE_tb;
    reg CEA_tb, CEB_tb, CEM_tb, CEP_tb, CEC_tb, CED_tb, CECARRYIN_tb, CEOPMODE_tb;
    reg [47:0] PCIN_tb;
    
endmodule