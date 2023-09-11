/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/



`ifndef SVK_AXI_SEQUENCER__SV
`define SVK_AXI_SEQUENCER__SV

typedef class svk_axi_agent_cfg;

class svk_axi_sequencer extends svk_sequencer;
    `uvm_component_utils(svk_axi_sequencer)

    extern function new(string name, uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern function void write_data_to_mem(uvm_sequence_item tr);
    extern function void read_data_from_mem(uvm_sequence_item tr);
    extern function svk_agent_cfg get_cfg();


endclass

function svk_axi_sequencer::new(string name, uvm_component parent);
    super.new(name, parent);
endfunction


function void svk_axi_sequencer::build_phase(uvm_phase phase);
    super.build_phase(phase);

endfunction

function void svk_axi_sequencer::connect_phase(uvm_phase phase);
    super.connect_phase(phase);

endfunction

function void svk_axi_sequencer::read_data_from_mem(uvm_sequence_item tr);
    int                 lower_byte_lane;
    int                 upper_byte_lane;
    int                 byte_idx = 0;
    svk_axi_transaction axi_tr;
    svk_axi_agent_cfg   axi_cfg;
    int unsigned        data_bus_bytes;

    $cast(axi_tr, tr);
    $cast(axi_cfg, cfg);
    if(!axi_tr.dir == svk_axi_dec::READ)
        return;

    data_bus_bytes = axi_cfg.data_width / 8;


    for(int beat=0; beat<=axi_tr.length; ++beat)begin
        get_lanes(axi_tr, beat, lower_byte_lane, upper_byte_lane, data_bus_bytes);
        axi_tr.data[beat] = 0;
        for(int i=0; i<=upper_byte_lane - lower_byte_lane; ++i)begin
            axi_tr.data[beat][i*8 +: 8] = mem.get(axi_tr.addr+byte_idx);
            byte_idx++;
        end
    end
endfunction

function void svk_axi_sequencer::write_data_to_mem(uvm_sequence_item tr);
    byte unsigned       bytes[];
    byte unsigned       bytes_enable[];
    int                 lower_byte_lane;
    int                 upper_byte_lane;
    svk_axi_transaction axi_tr;
    svk_axi_agent_cfg   axi_cfg;
    int unsigned        data_bus_bytes;

    $cast(axi_tr, tr);
    $cast(axi_cfg, cfg);
    if(!(axi_tr.dir == svk_axi_dec::WRITE & axi_tr.write_finish == 1'b1))
        return;

    data_bus_bytes = axi_cfg.data_width / 8;
    for(int beat=0; beat<= axi_tr.length; ++beat)begin
        get_lanes(axi_tr, beat, lower_byte_lane, upper_byte_lane, data_bus_bytes);
        for(int i=0; i<=upper_byte_lane - lower_byte_lane; ++i)begin
            bytes = {bytes, axi_tr.data[beat][(i*8) +:8]};
            bytes_enable = {bytes_enable, axi_tr.wstrb[beat][i+lower_byte_lane]};
        end
    end

    foreach(bytes[i])begin
        if(bytes_enable[i])begin
            mem.set(axi_tr.addr + i, bytes[i]);
        end
    end
endfunction

function svk_agent_cfg svk_axi_sequencer::get_cfg();
    return cfg;
endfunction

`endif

