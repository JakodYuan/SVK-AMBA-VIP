/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_APB_AGENT_CFG__SV
`define SVK_APB_AGENT_CFG__SV


class svk_apb_agent_cfg extends svk_agent_cfg;

    svk_dec::default_value_enum            mem_default_value    = svk_dec::DEFAULT_ZERO;
    svk_dec::idle_value_enum               idle_value           = svk_dec::IDLE_ZERO;
    svk_apb_dec::version_enum              version              = svk_apb_dec::APB3;

    int unsigned                           addr_width           = `SVK_APB_ADDR_WIDTH;
    int unsigned                           data_width           = `SVK_APB_DATA_WIDTH;
    int unsigned                           pready_time_out      = 500;



    `uvm_object_utils_begin(svk_apb_agent_cfg)
        `uvm_field_int(data_width                    , UVM_ALL_ON)
        `uvm_field_int(pready_time_out               , UVM_ALL_ON)
        `uvm_field_enum(svk_dec::default_value_enum  , mem_default_value, UVM_ALL_ON)
        `uvm_field_enum(svk_dec::idle_value_enum     , idle_value   , UVM_ALL_ON)
        `uvm_field_enum(svk_dec::agent_work_mode_enum, work_mode    , UVM_ALL_ON)
        `uvm_field_enum(svk_apb_dec::version_enum    , version      , UVM_ALL_ON)
    `uvm_object_utils_end


    function new(string name="svk_apb_agent_cfg");
        super.new(name);
    endfunction


    function void check_cfg();
        if(data_width%8 != 0)
            `uvm_error(get_type_name(), $sformatf("data_width=%0d not a mutiple of 8", data_width))
    endfunction


endclass


`endif
