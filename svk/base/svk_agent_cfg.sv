/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_AGENT_CFG__SV
`define SVK_AGENT_CFG__SV

class svk_agent_cfg extends uvm_object;

    svk_dec::agent_work_mode_enum                work_mode = svk_dec::ONLY_MONITOR;

    `uvm_object_utils_begin(svk_agent_cfg)
        `uvm_field_enum(svk_dec::agent_work_mode_enum, work_mode, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name="");
        super.new(name);
    endfunction


    virtual function void distrubute_cfg();
    endfunction

endclass

`endif
