/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_AGENT__SV
`define SVK_AGENT__SV


virtual class svk_agent extends uvm_agent;


    svk_memory  mem;

    function new(string name="svk_agent", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction


    pure virtual function svk_agent_cfg get_cfg();
    pure virtual function svk_sequencer get_sequencer();
    pure virtual function svk_dec::agent_work_mode_enum get_work_mode();
    pure virtual function uvm_reg_adapter get_adapter();
    pure virtual function uvm_analysis_port#(uvm_sequence_item) get_observed_port();

endclass
`endif
