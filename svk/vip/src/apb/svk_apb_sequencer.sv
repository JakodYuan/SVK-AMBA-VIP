/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_APB_SEQUENCER
`define SVK_APB_SEQUENCER


class svk_apb_sequencer extends svk_sequencer;
    `uvm_component_utils(svk_apb_sequencer)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    extern virtual function void write_data_to_mem(uvm_sequence_item tr);
    extern virtual function void read_data_from_mem(uvm_sequence_item tr);
endclass

function void svk_apb_sequencer::read_data_from_mem(uvm_sequence_item tr);
    svk_apb_transaction apb_tr;
    svk_apb_agent_cfg   apb_cfg;
    $cast(apb_tr, tr);
    $cast(apb_cfg, cfg);
    for(int n=0; n<(apb_cfg.data_width/8); ++n)begin
        apb_tr.data[n*8 +: 8] = mem.get(apb_tr.addr + n);
    end
endfunction

function void svk_apb_sequencer::write_data_to_mem(uvm_sequence_item tr);
    svk_apb_transaction apb_tr;
    svk_apb_agent_cfg   apb_cfg;
    $cast(apb_tr, tr);
    $cast(apb_cfg, cfg);
    for(int n=0; n<(apb_cfg.data_width/8); ++n)begin
        if(apb_cfg.version == svk_apb_dec::APB4)begin
            if(apb_tr.strb[n] == 1'b1)begin
                mem.set(apb_tr.addr + n, apb_tr.data[n*8 +: 8]);
            end
        end
        else begin
            mem.set(apb_tr.addr + n, apb_tr.data[n*8 +: 8]);
        end
    end
endfunction


`endif
