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
`ifndef SVK_AXI_DEFAULT_SLAVA_SEQUENCE__SV
`define SVK_AXI_DEFAULT_SLAVA_SEQUENCE__SV

class svk_axi_default_slave_sequence extends svk_axi_sequence;
    `uvm_object_utils(svk_axi_default_slave_sequence)

    function new(string name="default_slave_seq");
        super.new(name);
    endfunction

    task body();
        svk_axi_transaction tr;



        forever begin
            p_sequencer.response_request_port.peek(req);
            $cast(tr, req);

            tr.randomize();

            tr.awready_delay = 2;
            tr.arready_delay = 0;
            foreach(tr.wready_delay[i])
                tr.wready_delay[i] = i;

            tr.bvalid_delay = 1;
            foreach(tr.rvalid_delay[i])
                tr.rvalid_delay[i] = i;

            if(tr.dir == svk_axi_dec::WRITE)begin
                p_sequencer.write_data_to_mem(tr);
            end
            else if(tr.dir == svk_axi_dec::READ)begin
                p_sequencer.read_data_from_mem(tr);
            end


            `uvm_send(tr)
        end

    endtask

endclass

`endif
