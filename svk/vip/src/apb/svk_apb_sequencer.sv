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
