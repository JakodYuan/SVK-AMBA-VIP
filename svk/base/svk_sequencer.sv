/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/

`ifndef SVK_SEQUENCER__SV
`define SVK_SEQUENCER__SV

class svk_sequencer extends uvm_sequencer;
    `uvm_component_utils(svk_sequencer)

    uvm_blocking_peek_port#(uvm_sequence_item)  response_request_port;
    svk_memory                                  mem;
    svk_agent_cfg                               cfg;

    extern function new(string name, uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void build_response_request_port();
    extern function void connect_phase(uvm_phase phase);
    extern virtual function void write_data_to_mem(uvm_sequence_item tr);
    extern virtual function void read_data_from_mem(uvm_sequence_item tr);
    extern virtual function svk_agent_cfg get_cfg();

endclass

function svk_sequencer::new(string name, uvm_component parent);
    super.new(name, parent);
endfunction

function void svk_sequencer::build_phase(uvm_phase phase);
    super.build_phase(phase);
endfunction

function void svk_sequencer::build_response_request_port();
    response_request_port = new("port", this);
endfunction

function void svk_sequencer::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction

function void svk_sequencer::write_data_to_mem(uvm_sequence_item tr);
    `uvm_fatal(get_type_name(), "must override write_data_to_mem() function")
endfunction

function void svk_sequencer::read_data_from_mem(uvm_sequence_item tr);
    `uvm_fatal(get_type_name(), "must override read_data_from_mem() function")
endfunction

function svk_agent_cfg svk_sequencer::get_cfg();
    return cfg;
endfunction


`endif