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
