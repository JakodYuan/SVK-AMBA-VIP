/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_ENV_CFG__SV
`define SVK_ENV_CFG__SV


class svk_env_cfg extends uvm_object;



    function new(string name="svk_env_cfg");
        super.new(name);

        uvm_default_comparer.sev = UVM_ERROR;
    endfunction

    `uvm_object_utils_begin(svk_env_cfg)
    `uvm_object_utils_end

endclass
`endif
