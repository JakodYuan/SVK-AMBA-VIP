/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_AXI_MASTER_CALLBACK__SV
`define SVK_AXI_MASTER_CALLBACK__SV

class svk_axi_master_callback extends uvm_callback;

    virtual function void run(svk_axi_transaction tr);
    endfunction

endclass

`endif

