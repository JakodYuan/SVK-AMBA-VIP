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
