/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/

`ifndef SVK_AHB_SYS_ENV__SV
`define SVK_AHB_SYS_ENV__SV

class svk_ahb_sys_env extends uvm_env;
    `uvm_component_utils(svk_ahb_sys_env)

    svk_ahb_agent           master[`SVK_AHB_MAX_NUM_MASTER-1:0];
    svk_ahb_agent           slave[`SVK_AHB_MAX_NUM_SLAVE-1:0];
    svk_ahb_sys_env_cfg     cfg;
    virtual svk_ahb_ifs     vif;

    function new(string name="svk_ahb_sys_env", uvm_component parent=null);
       super.new(name, parent); 
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(svk_ahb_sys_env_cfg)::get(this, "", "cfg", cfg))begin
            `uvm_fatal(get_type_name(), "can't get svk_ahb_sys_env_cfg!")
        end
        if(!uvm_config_db#(virtual svk_ahb_ifs)::get(this, "", "vif", vif))begin
            `uvm_fatal(get_type_name(), "can't get svk_ahb_ifs!")
        end


        for(int i=0; i<cfg.master_num; ++i)begin
            uvm_config_db#(virtual svk_ahb_if)::set(this, $sformatf("master[%0d]", i), "vif", vif.master_vif[i]);
            uvm_config_db#(svk_ahb_agent_cfg)::set(this, $sformatf("master[%0d]", i), "cfg", cfg.master_cfg[i]);
            master[i] = svk_ahb_agent::type_id::create($sformatf("master[%0d]", i), this);
        end
        for(int i=0; i<cfg.slave_num; ++i)begin
            uvm_config_db#(virtual svk_ahb_if)::set(this, $sformatf("slave[%0d]", i), "vif", vif.slave_vif[i]);
            uvm_config_db#(svk_ahb_agent_cfg)::set(this, $sformatf("slave[%0d]", i), "cfg", cfg.slave_cfg[i]);
            slave[i] = svk_ahb_agent::type_id::create($sformatf("slave[%0d]", i), this);
        end

    endfunction

endclass

`endif
