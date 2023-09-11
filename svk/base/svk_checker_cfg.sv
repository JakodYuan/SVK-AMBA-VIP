/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_CHECKER_CFG__SV
`define SVK_CHECKER_CFG__SV


class svk_checker_cfg extends uvm_object;
    svk_dec::switch_enum     check_en = svk_dec::ON;

    function new(string name="");
        super.new(name);
    endfunction

    `uvm_object_utils_begin(svk_checker_cfg)
        `uvm_field_enum(svk_dec::switch_enum, check_en , UVM_ALL_ON)
    `uvm_object_utils_end
endclass
`endif
