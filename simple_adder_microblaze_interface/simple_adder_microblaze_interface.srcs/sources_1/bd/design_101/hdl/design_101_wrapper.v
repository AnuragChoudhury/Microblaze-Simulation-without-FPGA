//Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2018.3 (win64) Build 2405991 Thu Dec  6 23:38:27 MST 2018
//Date        : Tue Jun 30 20:04:16 2020
//Host        : ANURAGCHOUDAFBF running 64-bit major release  (build 9200)
//Command     : generate_target design_101_wrapper.bd
//Design      : design_101_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module design_101_wrapper
   (clk_in1_0,
    reset,
    uart2_pl_rxd,
    uart2_pl_txd);
  input clk_in1_0;
  input reset;
  input uart2_pl_rxd;
  output uart2_pl_txd;

  wire clk_in1_0;
  wire reset;
  wire uart2_pl_rxd;
  wire uart2_pl_txd;

  design_101 design_101_i
       (.clk_in1_0(clk_in1_0),
        .reset(reset),
        .uart2_pl_rxd(uart2_pl_rxd),
        .uart2_pl_txd(uart2_pl_txd));
endmodule
