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
`ifndef SVK_AHB_DEFAULT_SLAVE_SEQUENCE__SV
`define SVK_AHB_DEFAULT_SLAVE_SEQUENCE__SV

class svk_ahb_default_slave_sequence extends svk_ahb_sequence;
    `uvm_object_utils(svk_ahb_default_slave_sequence)

    function new(string name="svk_ahb_default_slave_sequence");
        super.new(name);
    endfunction


    task body();
        svk_ahb_transaction tr;
        svk_ahb_agent_cfg   ahb_cfg;
        svk_agent_cfg       get_cfg;


        get_cfg = p_sequencer.get_cfg();
        if(!$cast(ahb_cfg, get_cfg))
            `uvm_error(get_type_name(), "config type is not svk_ahb_agent_cfg")
        
        while(1)begin
            p_sequencer.response_request_port.peek(req);
            $cast(tr, req);

            foreach(tr.resp[i])begin
                tr.resp[i] = 0;
            end
            foreach(tr.num_wait_cycles[i])begin
                tr.num_wait_cycles[i] = 2;
            end

            if(tr.dir == svk_ahb_dec::WRITE)begin
                p_sequencer.write_data_to_mem(tr);
            end
            else if(tr.dir == svk_ahb_dec::READ)begin
                p_sequencer.read_data_from_mem(tr);
            end


            `uvm_send(tr)
        end

    endtask

endclass


`endif
