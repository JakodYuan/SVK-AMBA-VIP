/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


class axi_base_test extends uvm_test;
    `uvm_component_utils(axi_base_test)

    axi_env env;

    function new(string name="axi_base_test", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = axi_env::type_id::create("env", this);
    endfunction
endclass