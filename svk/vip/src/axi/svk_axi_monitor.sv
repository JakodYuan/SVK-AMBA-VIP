/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_AXI_MONITOR__SV 
`define SVK_AXI_MONITOR__SV 

`define MON vif.mon_mp.mon_cb
class svk_axi_monitor extends uvm_monitor;
    `uvm_component_utils(svk_axi_monitor)
    `uvm_register_cb(svk_axi_monitor, svk_axi_monitor_callback)

    svk_axi_monitor_database                    db;
    svk_axi_agent_cfg                           cfg;
    virtual svk_axi_if                          vif;
    uvm_analysis_port#(uvm_sequence_item)       port;



    svk_aw_linedata                             aw_line;
    svk_w_linedata                              w_line;
    svk_ar_linedata                             ar_line;
    svk_r_linedata                              r_line;
    svk_b_linedata                              b_line;


    extern function new(string name, uvm_component parent);
    extern function void connect_phase(uvm_phase phase);
    extern function void build_phase(uvm_phase phase);
    extern task reset_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern function void monitor_aw();
    extern function void monitor_ar();
    extern function void monitor_w();
    extern function void monitor_r();
    extern function void monitor_b();
    extern function int get_wr_osd();
    extern function int get_rd_osd();
    extern function void pre_monitor();
    extern function void monitor();
    extern function void post_monitor();
endclass

function svk_axi_monitor::new(string name, uvm_component parent);
    super.new(name, parent);
endfunction

function void svk_axi_monitor::build_phase(uvm_phase phase);
    super.build_phase(phase);
    port = new("port", this);
    if(this.cfg == null)
        cfg = svk_axi_agent_cfg::type_id::create("svk_axi_agent_cfg");
endfunction

function void svk_axi_monitor::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction

task svk_axi_monitor::reset_phase(uvm_phase phase);
    super.reset_phase(phase);

    db = new(cfg);  
endtask

task svk_axi_monitor::run_phase(uvm_phase phase);
    super.run_phase(phase);

    while(1)begin
        @(`MON);
        pre_monitor();
        monitor();
        post_monitor();     
    end
endtask

function void svk_axi_monitor::monitor_aw();

    if(`MON.awvalid === 1'b1 && `MON.awready === 1'b1)begin
        aw_line        = new();
        aw_line.id     = `MON.awid & cfg.ID_MASK;
        aw_line.addr   = `MON.awaddr & cfg.ADDR_MASK;
        aw_line.len    = `MON.awlen;
        aw_line.size   = `MON.awsize;
        aw_line.burst  = `MON.awburst;
        aw_line.lock   = `MON.awlock;
        aw_line.cache  = `MON.awcache;
        aw_line.prot   = `MON.awprot;
        aw_line.region = `MON.awregion;
        aw_line.user   = `MON.awuser & cfg.ADDR_USER_MASK;
        aw_line.qos    = `MON.awqos;
        db.put_aw_linedata(aw_line);
    end
endfunction

function void svk_axi_monitor::monitor_w();

    if(`MON.wvalid === 1'b1 && `MON.wready === 1'b1)begin
        w_line      = new();
        w_line.id   = `MON.wid & cfg.ID_MASK;
        w_line.data = `MON.wdata & cfg.DATA_MASK;
        w_line.strb = `MON.wstrb;
        w_line.user = `MON.wuser & cfg.DATA_USER_MASK;
        w_line.last = `MON.wlast;
        db.put_w_linedata(w_line);
    end

endfunction

function void svk_axi_monitor::monitor_ar();

    if(`MON.arvalid === 1'b1 && `MON.arready === 1'b1)begin
        ar_line        = new();
        ar_line.id     = `MON.arid & cfg.ID_MASK;
        ar_line.addr   = `MON.araddr & cfg.ADDR_MASK;
        ar_line.len    = `MON.arlen;
        ar_line.size   = `MON.arsize;
        ar_line.burst  = `MON.arburst;
        ar_line.lock   = `MON.arlock;
        ar_line.cache  = `MON.arcache;
        ar_line.prot   = `MON.arprot;
        ar_line.region = `MON.awregion;
        ar_line.user   = `MON.awuser & cfg.ADDR_USER_MASK;
        ar_line.qos    = `MON.awqos;
        db.put_ar_linedata(ar_line);
    end
endfunction

function void svk_axi_monitor::monitor_r();

    if(`MON.rvalid === 1'b1 && `MON.rready === 1'b1)begin
        r_line      = new();
        r_line.id   = `MON.rid & cfg.ID_MASK;
        r_line.data = `MON.rdata & cfg.DATA_MASK;
        r_line.resp = `MON.rresp;
        r_line.last = `MON.rlast;
        r_line.user = `MON.ruser & cfg.RESP_USER_MASK;
        db.put_r_linedata(r_line);
    end
endfunction

function void svk_axi_monitor::monitor_b();

    if(`MON.bvalid === 1'b1 && `MON.bready === 1'b1)begin
        b_line      = new();
        b_line.id   = `MON.bid & cfg.ID_MASK;
        b_line.resp = `MON.bresp;
        b_line.user = `MON.buser & cfg.RESP_USER_MASK;
        db.put_b_linedata(b_line);
    end
endfunction

function int svk_axi_monitor::get_wr_osd();
    return db.get_wr_osd();
endfunction

function int svk_axi_monitor::get_rd_osd();
    return db.get_rd_osd();
endfunction

function void svk_axi_monitor::pre_monitor();

endfunction

function void svk_axi_monitor::monitor();
    monitor_aw();
    monitor_ar();
    monitor_w();
    monitor_r();
    monitor_b();
endfunction

function void svk_axi_monitor::post_monitor();
    svk_axi_transaction  tr;

    tr = db.get_wr_tr();
    if(tr != null)begin
        `uvm_do_callbacks(svk_axi_monitor, svk_axi_monitor_callback, run(tr))
        tr.randomize(null);



        port.write(tr);
    end

    tr = db.get_rd_tr();
    if(tr != null)begin
        `uvm_do_callbacks(svk_axi_monitor, svk_axi_monitor_callback, run(tr))
        tr.randomize(null);



        port.write(tr);
    end



endfunction

`undef MON

`endif


