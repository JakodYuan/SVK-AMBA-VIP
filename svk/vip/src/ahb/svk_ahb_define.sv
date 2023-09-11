/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef AHB_DEC__SV
`define AHB_DEC__SV

`ifndef SVK_AHB_DATA_WIDTH     
`define SVK_AHB_DATA_WIDTH   32  
`endif
                        
`ifndef SVK_AHB_RESP_WIDTH     
`define SVK_AHB_RESP_WIDTH   2 
`endif

`ifndef SVK_AHB_ADDR_WIDTH     
`define SVK_AHB_ADDR_WIDTH   32
`endif

`ifndef SVK_AHB_BURST_WIDTH    
`define SVK_AHB_BURST_WIDTH   3
`endif
                        
`ifndef SVK_AHB_PROT_WIDTH     
`define SVK_AHB_PROT_WIDTH    4
`endif
                        
`ifndef SVK_AHB_SIZE_WIDTH     
`define SVK_AHB_SIZE_WIDTH   3 
`endif

`ifndef SVK_AHB_TRANS_WIDTH    
`define SVK_AHB_TRANS_WIDTH   2
`endif

`ifndef SVK_AHB_CTRL_USER_WIDTH
`define SVK_AHB_CTRL_USER_WIDTH 32
`endif

`ifndef SVK_AHB_DATA_USER_WIDTH
`define SVK_AHB_DATA_USER_WIDTH 32
`endif

`ifndef SVK_AHB_SEL_WIDTH      
`define SVK_AHB_SEL_WIDTH     1
`endif
                        
`ifndef SVK_AHB_MASTER_WIDTH   
`define SVK_AHB_MASTER_WIDTH  7 
`endif
                        
`ifndef SVK_AHB_STRB_WIDTH
`define SVK_AHB_STRB_WIDTH `SVK_AHB_DATA_WIDTH/8
`endif

`ifndef SVK_AHB_MAX_INCR_LEN
`define SVK_AHB_MAX_INCR_LEN 16
`endif


`ifndef SVK_AHB_MAX_NUM_MASTER
`define SVK_AHB_MAX_NUM_MASTER 16
`endif

`ifndef SVK_AHB_MAX_NUM_SLAVE
`define SVK_AHB_MAX_NUM_SLAVE 16
`endif

`endif

