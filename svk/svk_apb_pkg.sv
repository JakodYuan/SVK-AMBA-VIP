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

`ifndef SVK_APB_PKG__SV
`define SVK_APB_PKG__SV

`include "vip/src/apb/svk_apb_define.sv"
`include "vip/src/apb/svk_apb_if.sv"
`include "vip/src/apb/svk_apb_ifs.sv"

package svk_apb_pkg;

    import uvm_pkg::*;
    import svk_pkg::*;

    `include "vip/src/apb/svk_apb_dec.sv"

    `include "vip/src/apb/svk_apb_agent_cfg.sv"
    `include "vip/src/apb/svk_apb_transaction.sv"
    `include "vip/src/apb/svk_apb_sequencer.sv"

    `include "vip/src/apb/svk_apb_master_driver.sv"
    `include "vip/src/apb/svk_apb_slave_driver.sv"
    `include "vip/src/apb/svk_apb_monitor.sv"

    `include "vip/src/apb/svk_apb_reg_extension.sv"
    `include "vip/src/apb/svk_apb_reg_adapter.sv"
    `include "vip/src/apb/svk_apb_agent.sv"


    `include "vip/src/apb/svk_apb_sequence.sv"
    `include "vip/src/apb/svk_apb_sys_env_cfg.sv"
    `include "vip/src/apb/svk_apb_sys_env.sv"
    `include "vip/src/apb/svk_apb_default_master_sequence.sv"
    `include "vip/src/apb/svk_apb_default_slave_sequence.sv"

endpackage

`endif

