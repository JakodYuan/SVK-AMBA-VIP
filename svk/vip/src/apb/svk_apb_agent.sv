/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_APB_AGENT__SV
`define SVK_APB_AGENT__SV

class svk_apb_agent extends svk_agent;
    `uvm_component_utils(svk_apb_agent)

    svk_apb_master_driver       mst_drv;
    svk_apb_slave_driver        slv_drv;
    svk_apb_monitor             mon;
    svk_apb_agent_cfg           cfg;
    svk_apb_sequencer           sqr;
    svk_apb_reg_adapter         adp;
    virtual svk_apb_if          vif;


    extern function new(string name, uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern function svk_agent_cfg get_cfg();
    extern function svk_sequencer get_sequencer();
    extern function svk_dec::agent_work_mode_enum get_work_mode();
    extern function uvm_reg_adapter get_adapter();
    extern function uvm_analysis_port#(uvm_sequence_item) get_observed_port();
endclass


function svk_apb_agent::new(string name, uvm_component parent);
    super.new(name, parent);
endfunction:new


function void svk_apb_agent::build_phase(uvm_phase phase);
    super.build_phase(phase);

    uvm_config_db#(svk_apb_agent_cfg)::get(this, "", "cfg", cfg);
    if(cfg == null)begin
        `uvm_info(get_type_name(), "create randomize apb configeration !", UVM_NONE)
        cfg = svk_apb_agent_cfg::type_id::create("svk_apb_agent_cfg");
        cfg.randomize();
    end
    cfg.check_cfg();
    `uvm_info(get_type_name(), $sformatf("cfg=\n%0s", cfg.sprint()), UVM_NONE)

    if(!uvm_config_db#(virtual svk_apb_if)::get(this, "", "vif", this.vif))
        `uvm_fatal("apb_master_driver", "get interface is error!")

    case(cfg.work_mode)
        svk_dec::MASTER:begin
            mst_drv     = svk_apb_master_driver::type_id::create("drv", this);
            sqr         = svk_apb_sequencer::type_id::create("sqr", this);
            adp         = svk_apb_reg_adapter::type_id::create("adp");
            mon         = svk_apb_monitor::type_id::create("mon", this);
            mon.cfg     = cfg;
            mst_drv.cfg = cfg;
            mst_drv.vif = vif;
            mon.vif     = vif;
            sqr.cfg     = cfg;
        end
        svk_dec::SLAVE:begin
            slv_drv     = svk_apb_slave_driver::type_id::create("slv_drv", this);
            sqr         = svk_apb_sequencer::type_id::create("sqr", this);
            mon         = svk_apb_monitor::type_id::create("mon", this);
            mon.cfg     = cfg;
            slv_drv.cfg = cfg;
            slv_drv.vif = vif;
            mon.vif     = vif;
            sqr.cfg     = cfg;
            sqr.build_response_request_port();
        end
        svk_dec::ONLY_MONITOR:begin
            mon         = svk_apb_monitor::type_id::create("mon", this);
            mon.cfg     = cfg;
            mon.vif     = vif;
        end
    endcase


endfunction:build_phase


function void svk_apb_agent::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if(!uvm_config_db#(svk_memory)::get(this, "*", "mem", mem))
        mem = new(cfg.mem_default_value);

    if(cfg.work_mode == svk_dec::MASTER)begin
        mst_drv.seq_item_port.connect(sqr.seq_item_export);
        sqr.mem = mem;
    end

    if(cfg.work_mode == svk_dec::SLAVE)begin
        slv_drv.seq_item_port.connect(sqr.seq_item_export);
        sqr.response_request_port.connect(slv_drv.response_request_imp);
        sqr.mem = mem;
    end
endfunction:connect_phase


function svk_agent_cfg svk_apb_agent::get_cfg();
    return cfg;
endfunction

function svk_sequencer svk_apb_agent::get_sequencer();
    return sqr;
endfunction

function svk_dec::agent_work_mode_enum svk_apb_agent::get_work_mode();
    return cfg.work_mode;
endfunction

function uvm_reg_adapter svk_apb_agent::get_adapter();
    return adp;
endfunction

function uvm_analysis_port#(uvm_sequence_item) svk_apb_agent::get_observed_port();
    return mon.port;
endfunction


`endif
