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
`ifndef SVK_AHB_DEFAULT_MASTER_SEQUENCE__SV
`define SVK_AHB_DEFAULT_MASTER_SEQUENCE__SV

class svk_ahb_default_master_sequence extends svk_ahb_sequence;
    `uvm_object_utils(svk_ahb_default_master_sequence)

    function new(string name="svk_ahb_default_master_sequence");
        super.new(name);
    endfunction

    extern task pre_body(); 
    extern task post_body(); 
    extern task body(); 


endclass



task svk_ahb_default_master_sequence::body();
    svk_ahb_transaction tr;
    svk_ahb_agent_cfg   ahb_cfg;
    svk_agent_cfg       get_cfg;


    get_cfg = p_sequencer.get_cfg();
    if(!$cast(ahb_cfg, get_cfg))
        `uvm_error(get_type_name(), "config type is not svk_ahb_agent_cfg")
    


    repeat(10)begin
        tr = svk_ahb_transaction::type_id::create("tr");
        tr.cfg = ahb_cfg;
        tr.randomize() with {
            addr >= 'h8000_0000;
            addr <  'h8000_00ff;
            foreach(addr[i]) {
                if(i<size) {
                    addr[i] == 0;
                }
            }
            dir == svk_ahb_dec::READ;
            need_resp == 1;
            foreach(num_busy_cycles[i]) {
                num_busy_cycles[i] < 5;
            }
            num_incr_beats < 5;
            num_idle_cycles < 5;
        };
        `uvm_send(tr)
        if(tr.need_resp)
            get_response(rsp, tr.get_transaction_id());
    end



    repeat(10)begin
        bit [31:0] send_addr;
        svk_ahb_transaction wr;

        tr = svk_ahb_transaction::type_id::create("tr");
        tr.cfg = ahb_cfg;
        std::randomize(send_addr) with {
            send_addr >= 'h8000_0000;
            send_addr <'h8000_00ff;
            foreach(send_addr[i]) {
                if(i<tr.size) {
                    send_addr[i] == 0;
                }
            }
        };
        tr.randomize() with {
            addr == send_addr;
            dir == svk_ahb_dec::WRITE;
            need_resp == 1;
            foreach(num_busy_cycles[i]) {
                num_busy_cycles[i] < 5;
            }
            num_incr_beats < 5;
            num_idle_cycles < 5;
        };
        `uvm_send(tr)
        if(tr.need_resp)
            get_response(rsp, tr.get_transaction_id());


        wr = svk_ahb_transaction::type_id::create("tr");
        wr.copy(tr);
        wr.cmd_idx = 0;
        wr.dat_idx = 0;
        wr.rsp_idx = 0;
        wr.dir = svk_ahb_dec::READ;
        `uvm_send(wr)
        if(wr.need_resp)
            get_response(rsp, wr.get_transaction_id());
    end


    for(int i=0; i<10; ++i)begin
        tr = svk_ahb_transaction::type_id::create("tr");
        tr.cfg = ahb_cfg;
        tr.randomize() with {
            foreach(addr[i]) {
                if(i<size) {
                    addr[i] == 0;
                }
            }
            need_resp == 1;
            foreach(num_busy_cycles[i]) {
                num_busy_cycles[i] < 5;
            }
            num_incr_beats < 5;
            num_idle_cycles < 5;
        };
        `uvm_send(tr)
        if(tr.need_resp)
            get_response(rsp, tr.get_transaction_id());
    end



endtask



task svk_ahb_default_master_sequence::pre_body();
    super.pre_body();

    `ifdef UVM_MINOR_REV_2
    if(get_starting_phase() != null)
        get_starting_phase().raise_objection(this);
        `uvm_info(get_type_name(), "raise objection .............", UVM_NONE)
    `else
    if(starting_phase != null)
        starting_phase.raise_objection(this);    
        `uvm_info(get_type_name(), "raise objection .............", UVM_NONE)
    `endif

endtask


task svk_ahb_default_master_sequence::post_body();
    super.post_body();

    `ifdef UVM_MINOR_REV_2
    if(get_starting_phase() != null)begin
        get_starting_phase().phase_done.set_drain_time(this, 100ns);
        get_starting_phase().drop_objection(this);
        `uvm_info(get_type_name(), "drop objection .............", UVM_NONE)
    end
    `else
    if(starting_phase != null)begin
        starting_phase.phase_done.set_drain_time(this, 100ns);
        starting_phase.drop_objection(this);    
        `uvm_info(get_type_name(), "drop objection .............", UVM_NONE)
    end
    `endif
endtask
`endif
