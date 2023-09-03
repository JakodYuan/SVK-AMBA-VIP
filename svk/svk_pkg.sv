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
`ifndef SVK_PKG__SV
`define SVK_PKG__SV

package svk_pkg;
    import uvm_pkg::*;

    `include "uvm_macros.svh"


    `include "base/svk_define.sv"
    `include "base/svk_dec.sv"
    `include "base/svk_global.sv"
    `include "base/svk_extension.sv"
    `include "base/svk_extension_wrapper.sv"

    `include "base/svk_rm_cfg.sv"
    `include "base/svk_checker_cfg.sv"
    `include "base/svk_agent_cfg.sv"
    `include "base/svk_env_cfg.sv"

    `include "base/svk_memory.sv"
    `include "base/svk_sequencer.sv"
    `include "base/svk_virtual_sequencer.sv"
    `include "base/svk_rm.sv"
    `include "base/svk_checker.sv"
    `include "base/svk_agent.sv"
    `include "base/svk_env.sv"
    `include "base/svk_sequence.sv"
    `include "base/svk_access_sequence.sv"
    `include "base/svk_tc.sv"
    `include "base/svk_bind.sv"

endpackage

`endif