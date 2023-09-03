/**
 *  Copyright (C) 2023-2024 JakodYuan. ( JakodYuan@outlook.com )
 *
 *  Licensed under the GNU LESSER GENERAL PUBLIC LICENSE, Version 3.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *          http://www.gnu.org/licenses/lgpl.html
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

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

