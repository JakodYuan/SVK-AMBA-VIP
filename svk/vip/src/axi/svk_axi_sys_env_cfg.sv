/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/

`ifndef SVK_AXI_SYS_ENV_CFG__SV
`define SVK_AXI_SYS_ENV_CFG__SV

class svk_axi_sys_env_cfg extends uvm_object;
    `uvm_object_utils(svk_axi_sys_env_cfg)

    int master_num;
    int slave_num;

    svk_axi_agent_cfg master_cfg[`SVK_AXI_MAX_NUM_MASTER-1:0];
    svk_axi_agent_cfg slave_cfg[`SVK_AXI_MAX_NUM_SLAVE-1:0];

    function new(string name="svk_axi_sys_env_cfg");
        super.new(name);
    endfunction

    function void create_sub_cfg(int master_num, int slave_num);
        this.master_num = master_num;
        this.slave_num  = slave_num;

        for(int i=0; i<master_num; ++i)begin
            master_cfg[i] = svk_axi_agent_cfg::type_id::create($sformatf("master_cfg[%0d]",i));
        end
        for(int i=0; i<slave_num; ++i)begin
            slave_cfg[i] = svk_axi_agent_cfg::type_id::create($sformatf("slave_cfg[%0d]",i));
        end

    endfunction

endclass

`endif