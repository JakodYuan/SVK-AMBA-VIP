/**
 *  Copyright (C) 2023-2024 JakodYuan. ( JakodYuan@outlook.com )
 *
 *  Licensed under the GNU LESSER GENERAL PUBLIC LICENSE, Version 3.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *          http://www.gnu.org/licenses/lgpl.html
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

`ifndef SVK_AHB_AGENT_CFG__SV
`define SVK_AHB_AGENT_CFG__SV


class svk_ahb_agent_cfg extends svk_agent_cfg;

    svk_dec::default_value_enum           mem_default_value    = svk_dec::DEFAULT_ZERO;
    svk_dec::default_value_enum           default_value   = svk_dec::DEFAULT_ZERO;
    svk_dec::idle_value_enum              idle_value      = svk_dec::IDLE_STABLE;

    int unsigned                          ctrl_user_width = `SVK_AHB_CTRL_USER_WIDTH;
    int unsigned                          data_user_width = `SVK_AHB_DATA_USER_WIDTH;
    int unsigned                          addr_width      = `SVK_AHB_ADDR_WIDTH;
    int unsigned                          data_width      = `SVK_AHB_DATA_WIDTH;
    int unsigned                          hready_time_out = 500;

    bit                                   enable_strb;
    bit                                   cancle_after_error;



    `uvm_object_utils_begin(svk_ahb_agent_cfg)
        `uvm_field_int(addr_width                    , UVM_ALL_ON)
        `uvm_field_int(ctrl_user_width                    , UVM_ALL_ON)
        `uvm_field_int(data_user_width                    , UVM_ALL_ON)
        `uvm_field_int(hready_time_out               , UVM_ALL_ON)
        `uvm_field_int(cancle_after_error               , UVM_ALL_ON)
        `uvm_field_int(enable_strb               , UVM_ALL_ON)
        `uvm_field_enum(svk_dec::default_value_enum  , default_value, UVM_ALL_ON)
        `uvm_field_enum(svk_dec::default_value_enum  , mem_default_value, UVM_ALL_ON)
        `uvm_field_enum(svk_dec::idle_value_enum     , idle_value  , UVM_ALL_ON)
        `uvm_field_enum(svk_dec::agent_work_mode_enum, work_mode   , UVM_ALL_ON)
    `uvm_object_utils_end


    function new(string name="svk_ahb_agent_cfg");
        super.new(name);
    endfunction


    function void check_cfg();
        if(data_width%8 != 0)
            `uvm_error(get_type_name(), $sformatf("data_width=%0d not a mutiple of 8", data_width))
    endfunction


endclass


`endif

