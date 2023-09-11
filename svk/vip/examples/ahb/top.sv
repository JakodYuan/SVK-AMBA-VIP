/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


module harness;
    import uvm_pkg::*;
    import svk_pkg::*;
    import svk_ahb_pkg::*;
    import ahb_env_pkg::*;

    `include "ahb_tests.sv"

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
        $fsdbDumpfile("ahb_test.fsdb");
        $fsdbDumpvars(harness, 0, "+all");
        $fsdbDumpon();
    end

    always #5 clk = ~clk;

    svk_ahb_ifs u_if();
    assign u_if.master[0].hclk = clk;
    assign u_if.master[0].hresetn = rstn;
    assign u_if.slave[0].hclk = clk;
    assign u_if.slave[0].hresetn = rstn;

    initial begin
        force u_if.master[0].hgrant                 = u_if.slave[0].hgrant;
        force u_if.master[0].hrdata                 = u_if.slave[0].hrdata;
        force u_if.master[0].hready                 = u_if.slave[0].hready;
        force u_if.master[0].hresp                  = u_if.slave[0].hresp;
        force u_if.master[0].hrdata_huser           = u_if.slave[0].hrdata_huser;

        force u_if.slave[0].haddr                 = u_if.master[0].haddr;
        force u_if.slave[0].hburst                = u_if.master[0].hburst;
        force u_if.slave[0].hbusreq               = u_if.master[0].hbusreq;
        force u_if.slave[0].hlock                 = u_if.master[0].hlock;
        force u_if.slave[0].hprot                 = u_if.master[0].hprot;
        force u_if.slave[0].hnonsec               = u_if.master[0].hnonsec;
        force u_if.slave[0].hsize                 = u_if.master[0].hsize;
        force u_if.slave[0].htrans                = u_if.master[0].htrans;
        force u_if.slave[0].hwdata                = u_if.master[0].hwdata;
        force u_if.slave[0].hwrite                = u_if.master[0].hwrite;
        force u_if.slave[0].hstrb                 = u_if.master[0].hstrb;

        force u_if.slave[0].control_huser         = u_if.master[0].control_huser;
        force u_if.slave[0].hwdata_huser          = u_if.master[0].hwdata_huser;
    end

    initial begin
        uvm_config_db#(virtual svk_ahb_ifs)::set(null, "*ahb_sys_env*", "vif", u_if);
    end

endmodule
