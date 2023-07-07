`timescale 1ns / 1ps
/* 
The first version without softmax 
noted in order to make output dimension match
make w_parallelism = w_size
    w_num_parallelism = in_depth
    but the dimension constraint, shown in the testbench part but not here
    data_in [IN_PARALLELISM * IN_NUM_PARALLELISM][IN_SIZE * IN_DEPTH]
    weight_q[W_PARALLELISM * W_NUM_PARALLELISM][W_SIZE * IN_DEPTH]
    weight_k[W_PARALLELISM * W_NUM_PARALLELISM][W_SIZE * IN_DEPTH]
    weight_v[W_PARALLELISM * W_NUM_PARALLELISM][W_SIZE * IN_DEPTH]

    data_q  [W_PARALLELISM * W_NUM_PARALLELISM][IN_PARALLELISM * IN_NUM_PARALLELISM]
    data_k  [W_PARALLELISM * W_NUM_PARALLELISM][IN_PARALLELISM * IN_NUM_PARALLELISM]

    data_v_t[IN_PARALLELISM * IN_NUM_PARALLELISM][W_PARALLELISM * W_NUM_PARALLELISM]

    data_s  [W_PARALLELISM * W_NUM_PARALLELISM][W_PARALLELISM * W_NUM_PARALLELISM]
    
    data_z  [W_PARALLELISM * W_NUM_PARALLELISM][IN_PARALLELISM * IN_NUM_PARALLELISM]
    data_out[IN_PARALLELISM][W_PARALLELISM]

    realize the function
    data_z = att(data_in)
*/
module fixed_att #(
    parameter DATA_WIDTH = 8,
    parameter DATA_FRAC_WIDTH = 1,
    parameter WEIGHT_WIDTH = 8,
    parameter W_FRAC_WIDTH = 1,


    parameter IN_PARALLELISM = 3,
    parameter IN_NUM_PARALLELISM = 2,

    parameter IN_SIZE  = 3,
    //define for matrix multilication
    parameter IN_DEPTH = 3,

    parameter W_PARALLELISM = 2,
    parameter W_NUM_PARALLELISM = 3,
    parameter W_SIZE = IN_SIZE,


    parameter OUT_PARALLELISM = IN_PARALLELISM,
    parameter OUT_SIZE = W_PARALLELISM
) (
    input clk,
    input rst,

    input [WEIGHT_WIDTH - 1:0] weight_q[W_PARALLELISM * W_SIZE -1 : 0],
    input weight_q_valid,
    output weight_q_ready,

    input [WEIGHT_WIDTH - 1:0] weight_k[W_PARALLELISM * W_SIZE -1 : 0],
    input weight_k_valid,
    output weight_k_ready,

    input [WEIGHT_WIDTH - 1:0] weight_v[W_PARALLELISM * W_SIZE -1 : 0],
    input weight_v_valid,
    output weight_v_ready,

    input [DATA_WIDTH -1:0] data_in_q[IN_PARALLELISM * IN_SIZE - 1 : 0],
    input data_in_q_valid,
    output data_in_q_ready,

    input [DATA_WIDTH -1:0] data_in_k[IN_PARALLELISM * IN_SIZE - 1 : 0],
    input data_in_k_valid,
    output data_in_k_ready,

    input [DATA_WIDTH -1:0] data_in_v[IN_PARALLELISM * IN_SIZE - 1 : 0],
    input data_in_v_valid,
    output data_in_v_ready,

    output [DATA_WIDTH -1:0] data_out[OUT_PARALLELISM * OUT_SIZE - 1:0],
    output data_out_valid,
    input data_out_ready
);

  logic [DATA_WIDTH-1:0] ff_data_in_q[IN_PARALLELISM * IN_SIZE - 1:0];
  logic [DATA_WIDTH-1:0] ff_data_in_k[IN_PARALLELISM * IN_SIZE - 1:0];
  logic ff_data_in_q_valid, ff_data_in_k_valid;
  logic ff_data_in_q_ready, ff_data_in_k_ready;
  //   assign ff_data_in_qk_ready = ff_data_in_q_ready&&ff_data_in_k_ready;
  // fifo for qk
  fifo #(
      .DEPTH(IN_DEPTH * IN_NUM_PARALLELISM),
      .DATA_WIDTH(DATA_WIDTH),
      .IN_NUM(IN_PARALLELISM * IN_SIZE)
  ) fifo_q (
      .clk(clk),
      .rst(rst),
      .data_in(data_in_q),
      .data_in_valid(data_in_q_valid),
      .data_in_ready(data_in_q_ready),
      .data_out(ff_data_in_q),
      .data_out_valid(ff_data_in_q_valid),
      .data_out_ready(ff_data_in_q_ready)
  );

  fifo #(
      .DEPTH(IN_DEPTH * IN_NUM_PARALLELISM),
      .DATA_WIDTH(DATA_WIDTH),
      .IN_NUM(IN_PARALLELISM * IN_SIZE)
  ) fifo_k (
      .clk(clk),
      .rst(rst),
      .data_in(data_in_k),
      .data_in_valid(data_in_k_valid),
      .data_in_ready(data_in_k_ready),
      .data_out(ff_data_in_k),
      .data_out_valid(ff_data_in_k_valid),
      .data_out_ready(ff_data_in_k_ready)
  );

  logic [DATA_WIDTH - 1 : 0] data_q[IN_PARALLELISM * W_PARALLELISM - 1:0];
  logic data_q_valid, data_q_ready;
  logic [DATA_WIDTH - 1 : 0] data_k[IN_PARALLELISM * W_PARALLELISM - 1:0];
  logic data_k_valid, data_k_ready;
  //matmul qk
  fixed_matmul #(
      .IN1_WIDTH(DATA_WIDTH),
      .IN1_FRAC_WIDTH(DATA_FRAC_WIDTH),
      .IN2_WIDTH(WEIGHT_WIDTH),
      .IN2_FRAC_WIDTH(W_FRAC_WIDTH),
      .OUT_WIDTH(DATA_WIDTH),
      .OUT_FRAC_WIDTH(DATA_FRAC_WIDTH),
      .IN1_PARALLELISM(IN_PARALLELISM),
      .IN1_NUM_PARALLELISM(IN_NUM_PARALLELISM),
      .IN_SIZE(IN_SIZE),
      .IN2_PARALLELISM(W_PARALLELISM),
      .IN2_NUM_PARALLELISM(W_NUM_PARALLELISM),
      .IN_DEPTH(IN_DEPTH)
  ) inst_fmmc_q (
      .clk(clk),
      .rst(rst),
      .data_in1(ff_data_in_q),
      .data_in1_valid(ff_data_in_q_valid),
      .data_in1_ready(ff_data_in_q_ready),
      .data_in2(weight_q),
      .data_in2_valid(weight_q_valid),
      .data_in2_ready(weight_q_ready),
      .data_out(data_q),
      .data_out_valid(data_q_valid),
      .data_out_ready(data_q_ready)
  );

  fixed_matmul #(
      .IN1_WIDTH(DATA_WIDTH),
      .IN1_FRAC_WIDTH(DATA_FRAC_WIDTH),
      .IN2_WIDTH(WEIGHT_WIDTH),
      .IN2_FRAC_WIDTH(W_FRAC_WIDTH),
      .OUT_WIDTH(DATA_WIDTH),
      .OUT_FRAC_WIDTH(DATA_FRAC_WIDTH),
      .IN1_PARALLELISM(IN_PARALLELISM),
      .IN1_NUM_PARALLELISM(IN_NUM_PARALLELISM),
      .IN_SIZE(IN_SIZE),
      .IN2_PARALLELISM(W_PARALLELISM),
      .IN2_NUM_PARALLELISM(W_NUM_PARALLELISM),
      .IN_DEPTH(IN_DEPTH)
  ) inst_fmmc_k (
      .clk(clk),
      .rst(rst),
      .data_in1(ff_data_in_k),
      .data_in1_valid(ff_data_in_k_valid),
      .data_in1_ready(ff_data_in_k_ready),
      .data_in2(weight_k),
      .data_in2_valid(weight_k_valid),
      .data_in2_ready(weight_k_ready),
      .data_out(data_k),
      .data_out_valid(data_k_valid),
      .data_out_ready(data_k_ready)
  );
  logic [DATA_WIDTH - 1 : 0] data_s[IN_PARALLELISM * IN_PARALLELISM - 1:0];
  logic data_s_valid, data_s_ready;
  // matmul s
  fixed_matmul #(
      .IN1_WIDTH(DATA_WIDTH),
      .IN1_FRAC_WIDTH(DATA_FRAC_WIDTH),
      .IN2_WIDTH(DATA_WIDTH),
      .IN2_FRAC_WIDTH(DATA_FRAC_WIDTH),
      .OUT_WIDTH(DATA_WIDTH),
      .OUT_FRAC_WIDTH(DATA_FRAC_WIDTH),
      .IN1_PARALLELISM(IN_PARALLELISM),
      .IN1_NUM_PARALLELISM(IN_NUM_PARALLELISM),
      .IN_SIZE(W_PARALLELISM),
      .IN2_PARALLELISM(IN_PARALLELISM),
      .IN2_NUM_PARALLELISM(IN_NUM_PARALLELISM),
      .IN_DEPTH(IN_DEPTH)
  ) inst_fmmc_s (
      .clk(clk),
      .rst(rst),
      .data_in1(data_q),
      .data_in1_valid(data_q_valid),
      .data_in1_ready(data_q_ready),
      .data_in2(data_k),
      .data_in2_valid(data_k_valid),
      .data_in2_ready(data_k_ready),
      .data_out(data_s),
      .data_out_valid(data_s_valid),
      .data_out_ready(data_s_ready)
  );

  /*
    should be softmax here
*/
  //matmul_v
  logic [DATA_WIDTH - 1 : 0] data_v_t[W_PARALLELISM * IN_PARALLELISM - 1:0];
  logic data_v_t_valid, data_v_t_ready;
  fixed_matmul #(
      .IN1_WIDTH(WEIGHT_WIDTH),
      .IN1_FRAC_WIDTH(W_FRAC_WIDTH),
      .IN2_WIDTH(DATA_WIDTH),
      .IN2_FRAC_WIDTH(DATA_FRAC_WIDTH),
      .OUT_WIDTH(DATA_WIDTH),
      .OUT_FRAC_WIDTH(DATA_FRAC_WIDTH),
      .IN1_PARALLELISM(W_PARALLELISM),
      .IN1_NUM_PARALLELISM(W_NUM_PARALLELISM),
      .IN_SIZE(IN_SIZE),
      .IN2_PARALLELISM(IN_PARALLELISM),
      .IN2_NUM_PARALLELISM(IN_NUM_PARALLELISM),
      .IN_DEPTH(IN_DEPTH)
  ) inst_fmmc_v (
      .clk(clk),
      .rst(rst),
      .data_in1(weight_v),
      .data_in1_valid(weight_v_valid),
      .data_in1_ready(weight_v_ready),
      .data_in2(data_in_v),
      .data_in2_valid(data_in_v_valid),
      .data_in2_ready(data_in_v_ready),
      .data_out(data_v_t),
      .data_out_valid(data_v_t_valid),
      .data_out_ready(data_v_t_ready)
  );

  logic [DATA_WIDTH - 1:0] data_z[IN_PARALLELISM * W_PARALLELISM - 1:0];
  logic data_z_valid, data_z_ready;
  //z = s*v_t
  fixed_matmul #(
      .IN1_WIDTH(DATA_WIDTH),
      .IN1_FRAC_WIDTH(DATA_FRAC_WIDTH),
      .IN2_WIDTH(DATA_WIDTH),
      .IN2_FRAC_WIDTH(DATA_FRAC_WIDTH),
      .OUT_WIDTH(DATA_WIDTH),
      .OUT_FRAC_WIDTH(DATA_FRAC_WIDTH),

      .IN1_PARALLELISM(IN_PARALLELISM),
      .IN1_NUM_PARALLELISM(IN_NUM_PARALLELISM),
      .IN2_PARALLELISM(W_PARALLELISM),
      .IN2_NUM_PARALLELISM(W_NUM_PARALLELISM),

      .IN_SIZE (IN_PARALLELISM),
      .IN_DEPTH(IN_NUM_PARALLELISM)
  ) inst_fmmc_z (
      .clk(clk),
      .rst(rst),
      .data_in1(data_s),
      .data_in1_valid(data_s_valid),
      .data_in1_ready(data_s_ready),
      .data_in2(data_v_t),
      .data_in2_valid(data_v_t_valid),
      .data_in2_ready(data_v_t_ready),
      .data_out(data_z),
      .data_out_valid(data_z_valid),
      .data_out_ready(data_z_ready)
  );
  assign data_out = data_z;
  assign data_out_valid = data_z_valid;
  assign data_z_ready = data_out_ready;
endmodule