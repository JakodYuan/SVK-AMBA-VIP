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

`ifndef SVK_AHB_MONITOR__SV
`define SVK_AHB_MONITOR__SV

`define MON vif.mon_mp.mon_cb

class svk_ahb_monitor extends uvm_monitor;
    `uvm_component_utils(svk_ahb_monitor)

    svk_ahb_agent_cfg                       cfg;
    virtual svk_ahb_if                      vif;
    uvm_analysis_port#(uvm_sequence_item)   port;

    svk_ahb_dec::trans_enum                 pre_trans = svk_ahb_dec::IDLE;
    svk_ahb_dec::dir_enum                   pre_dir = svk_ahb_dec::READ;
    svk_ahb_transaction                     trans_q[$];
    int                                     wait_cnt;

    extern function new(string name, uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern function svk_ahb_transaction get_wtr();
    extern function svk_ahb_transaction get_rtr();
    extern function svk_ahb_transaction get_tr();
    extern task update();
    extern task monitor_ctrl();
    extern task monitor_wdata();
    extern task monitor_rdata_rsp();
    extern function void set_rand_mode(svk_ahb_transaction tr);
endclass


function svk_ahb_monitor::new(string name, uvm_component parent);
    super.new(name, parent);
endfunction


function void svk_ahb_monitor::build_phase(uvm_phase phase);
    if(cfg == null)
        cfg = svk_ahb_agent_cfg::type_id::create("svk_ahb_agent_cfg");
    port = new("mon_port", this);
endfunction


function void svk_ahb_monitor::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction


task svk_ahb_monitor::run_phase(uvm_phase phase);
    super.run_phase(phase);

    while(1)begin
        update();
        monitor_ctrl();
        monitor_wdata();
        monitor_rdata_rsp();
        if(`MON.hready === 1'b1)begin
            pre_trans = svk_ahb_dec::trans_enum'(`MON.htrans);
            pre_dir   = svk_ahb_dec::dir_enum'(`MON.hwrite);
        end;
        @(`MON);
    end

endtask



function svk_ahb_transaction svk_ahb_monitor::get_wtr();
    svk_ahb_transaction tr;
    foreach(trans_q[i])begin
        if(trans_q[i].dir == svk_ahb_dec::WRITE)begin
            tr = trans_q[i];
            break;
        end
    end
    return tr;
endfunction

function svk_ahb_transaction svk_ahb_monitor::get_rtr();
    svk_ahb_transaction tr;
    foreach(trans_q[i])begin
        if(trans_q[i].dir == svk_ahb_dec::READ)begin
            tr = trans_q[i];
            break;
        end
    end
    return tr;
endfunction

function svk_ahb_transaction svk_ahb_monitor::get_tr();
    if(trans_q.size != 0)
        return trans_q[0];
endfunction

task svk_ahb_monitor::update();
    if(trans_q.size != 0 && `MON.hready === 1'b0)
        wait_cnt++;
    else
        wait_cnt = 0;

    if(wait_cnt > cfg.hready_time_out)
        `uvm_error(get_type_name(), $sformatf("wait_cnt=%0d > hready_time_out=%0d", wait_cnt, cfg.hready_time_out))
endtask

task svk_ahb_monitor::monitor_ctrl();
    static bit wait_ready = 0;
    svk_ahb_transaction tr;

    if(`MON.htrans == svk_ahb_dec::NSEQ && !wait_ready)begin
        tr = svk_ahb_transaction::type_id::create("tr");
        tr.cfg = cfg;

        tr.addr      = `MON.haddr;
        tr.burst     = svk_ahb_dec::burst_enum'(`MON.hburst);
        tr.prot[0]   = svk_ahb_dec::prot0_enum'(`MON.hprot[0]);
        tr.prot[1]   = svk_ahb_dec::prot1_enum'(`MON.hprot[1]);
        tr.prot[2]   = svk_ahb_dec::prot2_enum'(`MON.hprot[2]);
        tr.prot[3]   = svk_ahb_dec::prot3_enum'(`MON.hprot[3]);
        tr.size      = svk_ahb_dec::size_enum'(`MON.hsize);
        tr.nonsec    = svk_ahb_dec::nonsec_enum'(`MON.hnonsec);
        tr.lock      = `MON.hlock;
        tr.ctrl_user = `MON.control_huser;
        $cast(tr.dir, `MON.hwrite);

        if(tr.addr % (1<<tr.size) != 0)begin
            `uvm_warning(get_type_name(), $sformatf("addr=%0h is not align %0d bytes", tr.addr, 1<<tr.size))
        end
        if(tr.burst == svk_ahb_dec::INCR)
            tr.num_incr_beats = `SVK_AHB_MAX_INCR_LEN;

        set_rand_mode(tr);
        tr.randomize(num_wait_cycles, resp, length, data, data_user, strb) with {
            foreach(data[i])
                data[i] == 0;
            foreach(data_user[i])
                data_user[i] == 0;
            foreach(strb[i])
                strb[i] == 0;
        };
        trans_q.push_back(tr);

        if(`MON.hready === 1'b0 && `MON.htrans == svk_ahb_dec::SEQ)begin
            wait_ready = 1;
        end
    end

    if(`MON.hready === 1'b1 && `MON.htrans == svk_ahb_dec::SEQ)begin
        wait_ready = 0;
    end

endtask

task svk_ahb_monitor::monitor_wdata();
    svk_ahb_transaction             tr;
    int                             lower_byte;
    int                             upper_byte;

    if((pre_trans == svk_ahb_dec::SEQ || pre_trans == svk_ahb_dec::NSEQ) && pre_dir == svk_ahb_dec::WRITE && `MON.hready)begin
        tr = get_wtr();
        get_lanes(tr, tr.dat_idx, lower_byte, upper_byte);
        for(int i=0; i<=upper_byte-lower_byte; ++i)begin
            tr.data[tr.dat_idx][i*8 +:8] = `MON.hwdata[(i+lower_byte)*8 +:8];
        end
        tr.strb[tr.dat_idx]      = `MON.hstrb;
        tr.data_user[tr.dat_idx] = `MON.hwdata_huser;
        tr.dat_idx++;
    end
endtask

task svk_ahb_monitor::monitor_rdata_rsp();
    svk_ahb_transaction             tr;
    int                             lower_byte;
    int                             upper_byte;
    logic [`SVK_AHB_DATA_WIDTH-1:0] tmp_data;


    if((pre_trans == svk_ahb_dec::SEQ || pre_trans == svk_ahb_dec::NSEQ) && `MON.hready)begin
        tr = get_tr();
        if(tr.dir == svk_ahb_dec::READ)begin
            get_lanes(tr, tr.dat_idx, lower_byte, upper_byte);
            for(int i=0; i<=upper_byte-lower_byte; ++i)begin
                tr.data[tr.dat_idx][i*8 +:8] = `MON.hrdata[(i+lower_byte)*8 +:8];
            end
            tr.dat_idx++;
        end
        tr.resp[tr.rsp_idx] = svk_ahb_dec::resp_enum'(`MON.hresp);
        tr.data_user[tr.rsp_idx] = `MON.hrdata_huser;
        tr.rsp_idx++;

        if(tr.burst == svk_ahb_dec::INCR)begin
            if(`MON.htrans == svk_ahb_dec::IDLE)begin
                tr.num_incr_beats = tr.rsp_idx;
                trans_q.pop_front();
                port.write(tr);
                `uvm_info("", $sformatf("%s", tr.sprint()), UVM_NONE)
            end
        end
        else if(tr.get_len() == tr.rsp_idx)begin
            trans_q.pop_front();
            port.write(tr);
            `uvm_info("", $sformatf("%s", tr.sprint()), UVM_NONE)
        end
        else if(`MON.htrans == svk_ahb_dec::IDLE)begin
            trans_q.pop_front();
            port.write(tr);
            `uvm_info("", $sformatf("%s", tr.sprint()), UVM_NONE)
        end
    end

endtask


function void svk_ahb_monitor::set_rand_mode(svk_ahb_transaction tr);
    tr.con_dir.constraint_mode(0);
    tr.con_addr.constraint_mode(0);


    tr.con_ctrl_user.constraint_mode(0);

    tr.con_burst.constraint_mode(0);
    tr.con_num_busy_cycles.constraint_mode(0);
    tr.con_size.constraint_mode(0);
    tr.con_lock.constraint_mode(0);
    tr.con_need_resp.constraint_mode(0);
endfunction

`undef MON

`endif

