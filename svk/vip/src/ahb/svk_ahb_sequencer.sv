/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_AHB_SEQUENCER
`define SVK_AHB_SEQUENCER


class svk_ahb_sequencer extends svk_sequencer;
    `uvm_component_utils(svk_ahb_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    extern virtual function void write_data_to_mem(uvm_sequence_item tr);
    extern virtual function void read_data_from_mem(uvm_sequence_item tr);
endclass

function void svk_ahb_sequencer::read_data_from_mem(uvm_sequence_item tr);
    bit [`SVK_AHB_ADDR_WIDTH-1:0]   addr;
    int                             lower_byte;
    int                             upper_byte;
    int                             bus_bytes;
    int                             data_idx;
    svk_ahb_transaction             ahb_tr;
    svk_ahb_agent_cfg               ahb_cfg;

    $cast(ahb_tr, tr);
    $cast(ahb_cfg, cfg);

    bus_bytes = ahb_tr.cfg.data_width/8;
    for(int i=0; i<ahb_tr.get_len(); ++i)begin
        get_lanes(ahb_tr, i, lower_byte, upper_byte);
        for(int j=0; j<bus_bytes; ++j)begin
            if(j<=upper_byte - lower_byte)begin
                addr = ahb_tr.addr + data_idx++;
                ahb_tr.data[i][j*8 +: 8] = mem.get(addr);
            end
            else begin
                ahb_tr.data[i][j*8 +:8] = 8'hxx;
            end
        end
    end
endfunction

function void svk_ahb_sequencer::write_data_to_mem(uvm_sequence_item tr);
    bit [`SVK_AHB_ADDR_WIDTH-1:0]   addr;
    int                             lower_byte;
    int                             upper_byte;
    int                             bus_bytes;
    int                             data_idx;
    svk_ahb_transaction             ahb_tr;
    svk_ahb_agent_cfg               ahb_cfg;

    $cast(ahb_tr, tr);
    $cast(ahb_cfg, cfg);

    if(ahb_tr.get_len() != ahb_tr.rsp_idx)
        return;

    bus_bytes = ahb_tr.cfg.data_width/8;

    for(int i=0; i<ahb_tr.get_len(); ++i)begin
        get_lanes(ahb_tr, i, lower_byte, upper_byte);
        for(int j=0; j<=upper_byte-lower_byte; ++j)begin
            if(!ahb_tr.cfg.enable_strb || (ahb_tr.cfg.enable_strb && ahb_tr.strb[i][j+lower_byte] == 1'b1))begin
                addr = ahb_tr.addr + data_idx;
                mem.set(addr, ahb_tr.data[i][j*8 +: 8]);
            end
            data_idx++;
        end
    end
endfunction

`endif

