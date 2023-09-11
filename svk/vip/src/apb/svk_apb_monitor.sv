/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_APB_MONITOR__SV
`define SVK_APB_MONITOR__SV

`define MON vif.mon_mp.mon_cb

class svk_apb_monitor extends uvm_monitor;
    `uvm_component_utils(svk_apb_monitor)

    svk_apb_agent_cfg                       cfg;
    virtual svk_apb_if                      vif;
    uvm_analysis_port#(uvm_sequence_item)   port;

    extern function new(string name, uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern task main_thread();

endclass


function svk_apb_monitor::new(string name, uvm_component parent);
    super.new(name, parent);
endfunction


function void svk_apb_monitor::build_phase(uvm_phase phase);
    if(cfg == null)
        cfg = svk_apb_agent_cfg::type_id::create("apb_monitor_cfg");
    port = new("mon_port", this);
endfunction


function void svk_apb_monitor::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction


task svk_apb_monitor::run_phase(uvm_phase phase);
    super.run_phase(phase);
    main_thread();
endtask


task svk_apb_monitor::main_thread();
    svk_apb_transaction tr;
    int             wait_cnt;

    while(1)begin
        tr = svk_apb_transaction::type_id::create("tr");
        wait_cnt = 0;
        do
            @(`MON);
        while(`MON.psel !== 1'b1);

        tr.addr = `MON.paddr;
        tr.prot = `MON.pprot;
        tr.user = `MON.puser;
        tr.resp = `MON.pslverr;
        tr.strb = `MON.pstrb;
        $cast(tr.dir, `MON.pwrite);
        case(tr.dir)
            svk_apb_dec::WRITE : tr.data = `MON.pwdata;
            svk_apb_dec::READ  : tr.data = `MON.prdata;
        endcase

        if(tr.addr % (cfg.data_width/8) != 0)begin
            `uvm_warning(get_type_name(), $sformatf("addr=%0h is not align %0d bytes", tr.addr, cfg.data_width/8))
        end

        @(`MON);
        while(`MON.pready !== 1'b1)begin
            ++wait_cnt;
            if(wait_cnt >= cfg.pready_time_out)begin
                `uvm_error(get_type_name(), $sformatf("pready not set after %0d cycles", wait_cnt))
                break;
            end
            @(`MON);
        end

        port.write(tr);
    end
endtask

`undef MON

`endif
