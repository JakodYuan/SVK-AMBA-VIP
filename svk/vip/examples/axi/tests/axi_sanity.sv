/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


class axi_sanity extends axi_base_test;
    `uvm_component_utils(axi_sanity)

    function new(string name="axi_sanity", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

		uvm_config_db#(uvm_object_wrapper)::set(null, "*axi_sys_env.master[0].sqr.main_phase", "default_sequence", svk_axi_default_master_sequence::type_id::get());
		uvm_config_db#(uvm_object_wrapper)::set(null, "*axi_sys_env.slave[0].sqr.main_phase", "default_sequence", svk_axi_default_slave_sequence::type_id::get());

    endfunction


endclass