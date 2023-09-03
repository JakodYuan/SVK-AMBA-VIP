/**
 *  Copyright (C) 2023-2024 JakodYuan. ( JakodYuan@outlook.com )
 *
 *  Licensed under the GNU LESSER GENERAL PUBLIC LICENSE, Version 3.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *          http://www.gnu.org/licenses/lgpl.html
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
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