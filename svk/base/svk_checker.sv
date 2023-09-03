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

`ifndef SVK_CHECKER__SV
`define SVK_CHECKER__SV

class svk_checker extends uvm_component;

    uvm_analysis_port#(uvm_sequence_item)   svk_export0;
    uvm_analysis_port#(uvm_sequence_item)   svk_export1;
    svk_dec::switch_enum                    check_en = svk_dec::ON;

    `uvm_component_utils_begin(svk_checker)
        `uvm_field_enum(svk_dec::switch_enum, check_en , UVM_ALL_ON)
    `uvm_component_utils_end


    function new(string name="svk_checker", uvm_component parent);
        super.new(name, parent);
        svk_export0 = new("svk_export0", this);
        svk_export1 = new("svk_export1", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        uvm_config_db#(svk_dec::switch_enum)::get(this, "", "check_en", check_en);
        `uvm_info(get_type_name(), $sformatf("%s : check_en=%s", get_full_name(), check_en.name), UVM_NONE)
    endfunction




endclass

`endif
