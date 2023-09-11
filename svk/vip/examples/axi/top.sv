/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


module harness;
    import uvm_pkg::*;
    import svk_pkg::*;
    import svk_axi_pkg::*;
    import axi_env_pkg::*;

    `include "axi_tests.sv"

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
        $fsdbDumpfile("axi_test.fsdb");
        $fsdbDumpvars(harness, 0, "+all");
        $fsdbDumpon();
    end

    always #5 clk = ~clk;

    svk_axi_ifs u_if();
    assign u_if.master[0].aclk = clk;
    assign u_if.master[0].aresetn = rstn;
    assign u_if.slave[0].aclk = clk;
    assign u_if.slave[0].aresetn = rstn;

    initial begin
        force u_if.slave[0].awvalid  = u_if.master[0].awvalid;
        force u_if.master[0].awready = u_if.slave[0].awready;
        force u_if.slave[0].awid     = u_if.master[0].awid;
        force u_if.slave[0].awaddr   = u_if.master[0].awaddr;
        force u_if.slave[0].awlen    = u_if.master[0].awlen;
        force u_if.slave[0].awsize   = u_if.master[0].awsize;
        force u_if.slave[0].awburst  = u_if.master[0].awburst;
        force u_if.slave[0].awlock   = u_if.master[0].awlock;
        force u_if.slave[0].awcache  = u_if.master[0].awcache;
        force u_if.slave[0].awprot   = u_if.master[0].awprot;
        force u_if.slave[0].awregion = u_if.master[0].awregion;
        force u_if.slave[0].awuser   = u_if.master[0].awuser;
        force u_if.slave[0].awqos    = u_if.master[0].awqos;
        force u_if.slave[0].arvalid  = u_if.master[0].arvalid;
        force u_if.master[0].arready = u_if.slave[0].arready;
        force u_if.slave[0].arid     = u_if.master[0].arid;
        force u_if.slave[0].araddr   = u_if.master[0].araddr;
        force u_if.slave[0].arlen    = u_if.master[0].arlen;
        force u_if.slave[0].arsize   = u_if.master[0].arsize;
        force u_if.slave[0].arburst  = u_if.master[0].arburst;
        force u_if.slave[0].arlock   = u_if.master[0].arlock;
        force u_if.slave[0].arcache  = u_if.master[0].arcache;
        force u_if.slave[0].arprot   = u_if.master[0].arprot;
        force u_if.slave[0].arregion = u_if.master[0].arregion;
        force u_if.slave[0].aruser   = u_if.master[0].aruser;
        force u_if.slave[0].arqos    = u_if.master[0].arqos;
        force u_if.master[0].rvalid  = u_if.slave[0].rvalid;
        force u_if.slave[0].rready   = u_if.master[0].rready;
        force u_if.master[0].rlast   = u_if.slave[0].rlast;
        force u_if.master[0].rid     = u_if.slave[0].rid;
        force u_if.master[0].rdata   = u_if.slave[0].rdata;
        force u_if.master[0].rresp   = u_if.slave[0].rresp;
        force u_if.master[0].ruser   = u_if.slave[0].ruser;
        force u_if.slave[0].wvalid   = u_if.master[0].wvalid;
        force u_if.master[0].wready  = u_if.slave[0].wready;
        force u_if.slave[0].wlast    = u_if.master[0].wlast;
        force u_if.slave[0].wid      = u_if.master[0].wid;
        force u_if.slave[0].wdata    = u_if.master[0].wdata;
        force u_if.slave[0].wstrb    = u_if.master[0].wstrb;
        force u_if.slave[0].wuser    = u_if.master[0].wuser;
        force u_if.master[0].bvalid  = u_if.slave[0].bvalid;
        force u_if.slave[0].bready   = u_if.master[0].bready;
        force u_if.master[0].bid     = u_if.slave[0].bid;
        force u_if.master[0].bresp   = u_if.slave[0].bresp;
        force u_if.master[0].buser   = u_if.slave[0].buser;
    end

    initial begin
        uvm_config_db#(virtual svk_axi_ifs)::set(null, "*axi_sys_env*", "vif", u_if);
    end

endmodule
