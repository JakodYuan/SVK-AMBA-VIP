/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


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

