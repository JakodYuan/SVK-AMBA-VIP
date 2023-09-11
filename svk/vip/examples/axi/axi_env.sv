/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


class axi_env extends uvm_env;
    `uvm_component_utils(axi_env)
    svk_axi_sys_env         axi_sys_env;
    svk_axi_sys_env_cfg     axi_sys_env_cfg;

    function new(string name="axi_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        axi_sys_env_cfg = cust_axi_sys_env_cfg::type_id::create("axi_sys_env_cfg");
        uvm_config_db#(svk_axi_sys_env_cfg)::set(this, "axi_sys_env", "cfg", axi_sys_env_cfg);
        axi_sys_env = svk_axi_sys_env::type_id::create("axi_sys_env", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        for(bit [31:0] addr='h8000_0000; addr<'h8000_00ff; ++addr)begin
            axi_sys_env.slave[0].mem.set(addr, addr[7:0]);
        end
    endfunction

endclass
