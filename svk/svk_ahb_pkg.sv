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

`ifndef SVK_AHB_PKG__SV
`define SVK_AHB_PKG__SV

`include "vip/src/ahb/svk_ahb_define.sv"
`include "vip/src/ahb/svk_ahb_if.sv"
`include "vip/src/ahb/svk_ahb_ifs.sv"

package svk_ahb_pkg;

    import uvm_pkg::*;
    import svk_pkg::*;

    `include "vip/src/ahb/svk_ahb_dec.sv"

    `include "vip/src/ahb/svk_ahb_agent_cfg.sv"
    `include "vip/src/ahb/svk_ahb_transaction.sv"
    `include "vip/src/ahb/svk_ahb_global.sv"
    `include "vip/src/ahb/svk_ahb_sequencer.sv"

    `include "vip/src/ahb/svk_ahb_master_driver.sv"
    `include "vip/src/ahb/svk_ahb_slave_driver.sv"
    `include "vip/src/ahb/svk_ahb_monitor.sv"

    `include "vip/src/ahb/svk_ahb_reg_extension.sv"
    `include "vip/src/ahb/svk_ahb_reg_adapter.sv"
    `include "vip/src/ahb/svk_ahb_agent.sv"

    `include "vip/src/ahb/svk_ahb_sequence.sv"
    `include "vip/src/ahb/svk_ahb_sys_env_cfg.sv"
    `include "vip/src/ahb/svk_ahb_sys_env.sv"
    `include "vip/src/ahb/svk_ahb_default_master_sequence.sv"
    `include "vip/src/ahb/svk_ahb_default_slave_sequence.sv"
endpackage

`endif

