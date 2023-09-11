/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_APB_DEFINE__SV
`define SVK_APB_DEFINE__SV


`ifndef SVK_APB_ADDR_WIDTH
`define SVK_APB_ADDR_WIDTH 32
`endif

`ifndef SVK_APB_DATA_WIDTH
`define SVK_APB_DATA_WIDTH 32
`endif

`ifndef SVK_APB_USER_WIDTH
`define SVK_APB_USER_WIDTH 8
`endif

`ifndef SVK_APB_STRB_WIDTH
`define SVK_APB_STRB_WIDTH `SVK_APB_DATA_WIDTH/8
`endif

`ifndef SVK_APB_MAX_NUM_MASTER
`define SVK_APB_MAX_NUM_MASTER 16
`endif

`ifndef SVK_APB_MAX_NUM_SLAVE
`define SVK_APB_MAX_NUM_SLAVE 16
`endif


`endif

