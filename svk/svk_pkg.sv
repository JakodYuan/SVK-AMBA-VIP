/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/

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