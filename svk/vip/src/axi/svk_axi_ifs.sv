/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/

`ifndef SVK_AXI_IFS__SV
`define SVK_AXI_IFS__SV


interface svk_axi_ifs;

    svk_axi_if      master[`SVK_AXI_MAX_NUM_MASTER-1:0]();
    svk_axi_if      slave[`SVK_AXI_MAX_NUM_SLAVE-1:0]();

    virtual svk_axi_if master_vif[`SVK_AXI_MAX_NUM_MASTER-1:0];
    virtual svk_axi_if slave_vif[`SVK_AXI_MAX_NUM_SLAVE-1:0];
    genvar i;
    generate;
        for(i =0; i<`SVK_AXI_MAX_NUM_MASTER; i=i+1)begin:gen_master
            initial begin
                master_vif[i] = master[i];
            end
        end
    endgenerate
    generate;
        for(i =0; i<`SVK_AXI_MAX_NUM_SLAVE; i=i+1)begin:gen_slave
            initial begin
                slave_vif[i] = slave[i];
            end
        end
    endgenerate

endinterface

`endif
