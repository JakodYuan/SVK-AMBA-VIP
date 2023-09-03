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
`include "vip/src/axi/svk_axi_define.sv"
`include "vip/src/axi/svk_axi_if.sv"
`include "vip/src/axi/svk_axi_ifs.sv"
`include "svk_pkg.sv"
package svk_axi_pkg;

    import uvm_pkg::*;
    import svk_pkg::*;

    `include "vip/src/axi/svk_axi_dec.sv"
    `include "vip/src/axi/svk_axi_delay.sv"
    `include "vip/src/axi/svk_axi_linedata.sv"
    `include "vip/src/axi/svk_axi_transaction.sv"
    `include "vip/src/axi/svk_axi_transaction_wrap.sv"
    `include "vip/src/axi/svk_axi_scheduler.sv"
    `include "vip/src/axi/svk_axi_database.sv"
    `include "vip/src/axi/svk_axi_driver.sv"
    `include "vip/src/axi/svk_axi_sequencer.sv"
    `include "vip/src/axi/svk_axi_global.sv"
    `include "vip/src/axi/svk_axi_reg_extension.sv"
    `include "vip/src/axi/svk_axi_reg_adapter.sv"
    `include "vip/src/axi/svk_axi_agent_cfg.sv"

    `include "vip/src/axi/svk_axi_master_database.sv"
    `include "vip/src/axi/svk_axi_master_callback.sv"
    `include "vip/src/axi/svk_axi_master_driver.sv"

    `include "vip/src/axi/svk_axi_slave_database.sv"
    `include "vip/src/axi/svk_axi_slave_callback.sv"
    `include "vip/src/axi/svk_axi_slave_driver.sv"

    `include "vip/src/axi/svk_axi_monitor_database.sv"
    `include "vip/src/axi/svk_axi_monitor_callback.sv"
    `include "vip/src/axi/svk_axi_monitor.sv"

    `include "vip/src/axi/svk_axi_agent.sv"

    `include "vip/src/axi/svk_axi_sys_env_cfg.sv"
    `include "vip/src/axi/svk_axi_sys_env.sv"
    `include "vip/src/axi/svk_axi_sequence.sv"
    `include "vip/src/axi/svk_axi_default_master_sequence.sv"
    `include "vip/src/axi/svk_axi_default_slave_sequence.sv"


endpackage
