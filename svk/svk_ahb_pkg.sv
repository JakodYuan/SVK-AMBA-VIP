/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


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

