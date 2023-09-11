/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


module harness;
    import uvm_pkg::*;
    import svk_pkg::*;
    import svk_apb_pkg::*;
    import apb_env_pkg::*;

    `include "apb_tests.sv"

    reg clk  = 0;
    reg rstn = 0;

    initial begin
        rstn = 0;
        #20ns;
        rstn = 1;
    end

    initial begin
        run_test();
    end

    initial begin
        $fsdbDumpfile("apb_test.fsdb");
        $fsdbDumpvars(harness, 0, "+all");
        $fsdbDumpon();
    end

    always #5 clk = ~clk;

    svk_apb_ifs u_if();
    assign u_if.master[0].pclk = clk;
    assign u_if.master[0].presetn = rstn;
    assign u_if.slave[0].pclk = clk;
    assign u_if.slave[0].presetn = rstn;

    initial begin
        force u_if.slave[0].psel     = u_if.master[0].psel;
        force u_if.slave[0].penable  = u_if.master[0].penable;
        force u_if.slave[0].pwrite   = u_if.master[0].pwrite;
        force u_if.slave[0].paddr    = u_if.master[0].paddr;
        force u_if.slave[0].pwdata   = u_if.master[0].pwdata;
        force u_if.slave[0].pstrb    = u_if.master[0].pstrb;
        force u_if.slave[0].pprot    = u_if.master[0].pprot;
        force u_if.slave[0].puser    = u_if.master[0].puser;
        force u_if.master[0].prdata  = u_if.slave[0].prdata;
        force u_if.master[0].pready  = u_if.slave[0].pready;
        force u_if.master[0].pslverr = u_if.slave[0].pslverr;
    end


    initial begin
        uvm_config_db#(virtual svk_apb_ifs)::set(null, "*apb_sys_env*", "vif", u_if);
    end

endmodule
