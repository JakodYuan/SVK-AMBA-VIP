/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_AHB_IFS__SV
`define SVK_AHB_IFS__SV

interface svk_ahb_ifs;
    svk_ahb_if      master[`SVK_AHB_MAX_NUM_MASTER-1:0]();
    svk_ahb_if      slave[`SVK_AHB_MAX_NUM_SLAVE-1:0]();

    virtual svk_ahb_if master_vif[`SVK_AHB_MAX_NUM_MASTER-1:0];
    virtual svk_ahb_if slave_vif[`SVK_AHB_MAX_NUM_SLAVE-1:0];
    genvar i;
    generate;
        for(i =0; i<`SVK_AHB_MAX_NUM_MASTER; i=i+1)begin:gen_master
            initial begin
                master_vif[i] = master[i];
            end
        end
    endgenerate
    generate;
        for(i =0; i<`SVK_AHB_MAX_NUM_SLAVE; i=i+1)begin:gen_slave
            initial begin
                slave_vif[i] = slave[i];
            end
        end
    endgenerate


endinterface

`endif
