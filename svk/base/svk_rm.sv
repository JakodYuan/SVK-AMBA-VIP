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


`ifndef SVK_RM__SV
`define SVK_RM__SV

class svk_rm extends uvm_component;
    `uvm_analysis_imp_decl(_mon)
    `uvm_analysis_imp_decl(_chk)

    uvm_analysis_export#(uvm_sequence_item) svk_export;
    uvm_analysis_port#(uvm_sequence_item)   svk_port;
    svk_dec::switch_enum                    work_en = svk_dec::ON;



    `uvm_component_utils_begin(svk_rm)
        `uvm_field_enum(svk_dec::switch_enum, work_en , UVM_ALL_ON)
    `uvm_component_utils_end


    function new(string name="svk_rm", uvm_component parent);
        super.new(name, parent);


        svk_export = new("svk_mon_export", this);
        svk_port   = new("svk_chk_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);


    endfunction

endclass
`endif

