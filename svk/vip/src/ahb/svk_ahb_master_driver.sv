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

`ifndef SVK_AHB_MASTER_DRIVER__SV
`define SVK_AHB_MASTER_DRIVER__SV

`define MST vif.mst_mp.mst_cb
`define MON vif.mon_mp.mon_cb

class svk_ahb_master_driver extends uvm_driver;
    `uvm_component_utils(svk_ahb_master_driver)

    svk_ahb_agent_cfg                       cfg;
    virtual svk_ahb_if                      vif;

    int idle_cnt;
    int busy_cnt;

 
    svk_ahb_transaction                     send_q[$];

    svk_ahb_dec::trans_enum                 pre_trans;

    extern function new(string name, uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task reset_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern task drive_data_idle();
    extern task drive_ctrl_idle();

    extern function svk_ahb_transaction get_cmd_tr();
    extern function svk_ahb_transaction get_wdata_tr();
    extern function svk_ahb_transaction get_resp_tr();
    extern task get_trans();
    extern task update();
    extern task drive_cmd();
    extern task drive_wdata();
    extern task drive_rdata_rsp();

endclass

function svk_ahb_master_driver::new(string name, uvm_component parent);
    super.new(name, parent);
endfunction


function void svk_ahb_master_driver::build_phase(uvm_phase phase);
    if(cfg == null)
        cfg = svk_ahb_agent_cfg::type_id::create("svk_ahb_master_driver_cfg");
endfunction


function void svk_ahb_master_driver::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction


task svk_ahb_master_driver::reset_phase(uvm_phase phase);
    drive_data_idle();
    drive_ctrl_idle();
endtask

task svk_ahb_master_driver::run_phase(uvm_phase phase);






    while(1)begin
        update();
        repeat(10) #0;
        get_trans();
        drive_cmd();
        drive_wdata();
        drive_rdata_rsp();
        @(`MST);
    end

endtask







function svk_ahb_transaction svk_ahb_master_driver::get_cmd_tr();
    svk_ahb_transaction tr;

    foreach(send_q[i])begin
        if(send_q[i].get_len() > send_q[i].cmd_idx)begin
            tr = send_q[i];
            break;
        end
    end

    return tr; 
endfunction

function svk_ahb_transaction svk_ahb_master_driver::get_wdata_tr();
    svk_ahb_transaction tr;

    foreach(send_q[i])begin
        if(send_q[i].cmd_idx > 0 && send_q[i].get_len() > send_q[i].dat_idx && send_q[i].dir == svk_ahb_dec::WRITE)begin
            tr = send_q[i];
            break;
        end
    end

    return tr; 
endfunction

function svk_ahb_transaction svk_ahb_master_driver::get_resp_tr();
    svk_ahb_transaction tr;

    foreach(send_q[i])begin
        if(send_q[i].cmd_idx > 0 && send_q[i].get_len() > send_q[i].rsp_idx)begin
            tr = send_q[i];
            break;
        end
    end

    return tr; 
endfunction

task svk_ahb_master_driver::get_trans();

    svk_ahb_transaction tr;
    tr = get_cmd_tr();
    if(tr == null)begin
        if(seq_item_port.has_do_available())begin
            seq_item_port.get_next_item(this.req);
            $cast(tr, req);
            if(tr.rsp_idx != 0 || tr.cmd_idx != 0 || tr.dat_idx != 0)
                `uvm_fatal(get_type_name(), $sformatf("cmd_idx=%0d, dat_idx=%0d, rsp_idx=%0d", tr.cmd_idx, tr.dat_idx, tr.rsp_idx))
            if(tr.addr % (1<<tr.size) != 0)begin
                `uvm_fatal(get_type_name(), $sformatf("addr=%0h is not align %0d bytes", tr.addr, 1<<tr.size))
            end
            send_q.push_back(tr);
        end
    end
endtask

task svk_ahb_master_driver::update();
endtask

task svk_ahb_master_driver::drive_cmd();
    svk_ahb_transaction tr;
    static bit wait_ready = 0;


    if(`MST.hready)begin
        wait_ready = 0;
        tr = get_cmd_tr();
        if((`MON.htrans == svk_ahb_dec::NSEQ || `MON.htrans == svk_ahb_dec::SEQ) && tr != null)begin
            tr.cmd_idx++;
            if(tr.get_len() == tr.cmd_idx)begin
                idle_cnt = tr.num_idle_cycles;
            end
            else begin
                busy_cnt = tr.num_busy_cycles[tr.cmd_idx-1];
            end
        end
    end

    if(`MON.htrans == svk_ahb_dec::BUSY)begin
        busy_cnt--;
        if(busy_cnt < 0)
            `uvm_error("", "busy_cnt < 0")
    end if(`MON.htrans == svk_ahb_dec::IDLE)begin
        if(idle_cnt > 0)
            idle_cnt--;
    end

    if(`MST.hresp != 0 && `MON.htrans != svk_ahb_dec::IDLE && cfg.cancle_after_error)begin
        tr = get_cmd_tr();
        if(`MST.hresp == svk_ahb_dec::ERROR || `MST.hresp == svk_ahb_dec::SPLIT)begin
            tr.resp[tr.rsp_idx] = `MST.hresp;
            if(tr.need_resp)begin
                seq_item_port.put_response(tr);
            end
            end_tr(tr);
            seq_item_port.item_done();
            send_q.pop_front();
        end
        else if(`MST.hresp == svk_ahb_dec::RETRY)begin
            tr.cmd_idx = 0;
            tr.dat_idx = 0;
            tr.rsp_idx = 0;
        end
        wait_ready = 0;
        idle_cnt = 1;
    end

    if(!wait_ready)begin
        tr = get_cmd_tr();
        if(`MST.hresp == 0 && idle_cnt == 0 &&  tr != null)begin
            `MST.haddr          <= tr.addr + (1<<tr.size) * tr.cmd_idx; 
            `MST.hwrite         <= (tr.dir == svk_ahb_dec::WRITE);
            `MST.htrans         <= (tr.cmd_idx == 0) ? svk_ahb_dec::NSEQ : busy_cnt > 0 ? svk_ahb_dec::BUSY : svk_ahb_dec::SEQ;
            `MST.hsize          <= tr.size;
            `MST.hburst         <= tr.burst;
            `MST.hprot          <= tr.prot;
            `MST.hlock          <= tr.lock;
            `MST.hnonsec        <= tr.nonsec;
            `MST.hbusreq        <= 1'b1;
            `MST.control_huser  <= tr.ctrl_user;

            wait_ready = busy_cnt > 0 ? 1'b0 : 1'b1;
        end
        else begin
            drive_ctrl_idle();
        end

    end
endtask

task svk_ahb_master_driver::drive_wdata();
    svk_ahb_transaction             tr;
    int                             lower_byte;
    int                             upper_byte;
    logic [`SVK_AHB_DATA_WIDTH-1:0] tmp_data;
    static bit                      wait_ready = 0;

    tr = get_wdata_tr();
    if((`MON.htrans == svk_ahb_dec::SEQ || `MON.htrans == svk_ahb_dec::NSEQ) && `MON.hwrite && `MON.hready)begin
        get_lanes(tr, tr.dat_idx, lower_byte, upper_byte);
        for(int i=0; i<=upper_byte-lower_byte; ++i)begin
            tmp_data[(i+lower_byte)*8 +:8] = tr.data[tr.dat_idx][i*8 +:8];
        end
        `MST.hwdata        <= tmp_data;
        `MST.hstrb         <= tr.strb[tr.dat_idx];
        `MST.hwdata_huser  <= tr.data_user[tr.dat_idx];
        tr.dat_idx++;
        wait_ready = 1;
    end
    else if(wait_ready==1)begin
        if(`MON.hready)
            wait_ready = 0;
    end
    else begin
        drive_data_idle();
    end
endtask

task svk_ahb_master_driver::drive_rdata_rsp();
    svk_ahb_transaction             tr;
    int                             lower_byte;
    int                             upper_byte;

    tr = get_resp_tr();
    if((pre_trans == svk_ahb_dec::SEQ || pre_trans == svk_ahb_dec::NSEQ) && `MON.hready === 1'b1 && tr != null)begin
        if(tr.dir == svk_ahb_dec::READ)begin
            get_lanes(tr, tr.rsp_idx, lower_byte, upper_byte);
            for(int i=0; i<=upper_byte-lower_byte; ++i)begin
                tr.data[tr.rsp_idx][i*8 +:8] = `MST.hrdata[(i+lower_byte)*8 +:8];
            end
        end
        tr.resp[tr.rsp_idx] = svk_ahb_dec::resp_enum'(`MST.hresp);
        tr.data_user[tr.rsp_idx] = `MST.hrdata_huser;
        tr.rsp_idx++;


        if(tr.get_len() == tr.rsp_idx)begin
            if(tr.need_resp)begin
                seq_item_port.put_response(tr);
            end
            end_tr(tr);
            seq_item_port.item_done();
            send_q.pop_front();
        end

    end

    if(`MON.hready === 1'b1)begin
        pre_trans = svk_ahb_dec::trans_enum'(`MON.htrans);
    end

endtask


task svk_ahb_master_driver::drive_ctrl_idle();
    if(cfg.idle_value == svk_dec::IDLE_ZERO)begin
        `MST.haddr         <= 0;
        `MST.htrans        <= svk_ahb_dec::IDLE;
        `MST.hburst        <= 0;
        `MST.hsize         <= 0;
        `MST.hprot         <= 0;
        `MST.hlock         <= 0;
        `MST.hnonsec       <= 0;
        `MST.hbusreq       <= 0;
        `MST.control_huser <= 0;
        `MST.hwrite        <= 0;
    end
    else if(cfg.idle_value == svk_dec::IDLE_RAND)begin
        `MST.haddr         <= $urandom;
        `MST.htrans        <=  svk_ahb_dec::IDLE;
        `MST.hburst        <= $urandom;
        `MST.hsize         <= $urandom;
        `MST.hprot         <= $urandom;
        `MST.hlock         <= $urandom;
        `MST.hnonsec       <= $urandom;
        `MST.hbusreq       <= $urandom;
        `MST.control_huser <= $urandom;
        `MST.hwrite        <= $urandom;
    end
    else if(cfg.idle_value == svk_dec::IDLE_STABLE)begin
        `MST.htrans        <= svk_ahb_dec::IDLE;
    end
endtask

task svk_ahb_master_driver::drive_data_idle();
    if(cfg.idle_value == svk_dec::IDLE_ZERO)begin
        `MST.hwdata        <= 0;
        `MST.hstrb         <= 0;
        `MST.hwdata_huser  <= 0;
    end
    else if(cfg.idle_value == svk_dec::IDLE_RAND)begin
        `MST.hwdata        <= $urandom;
        `MST.hstrb         <= $urandom;
        `MST.hwdata_huser  <= $urandom;
    end
    else if(cfg.idle_value == svk_dec::IDLE_STABLE)begin
    end
endtask

`undef MST
`undef MON

`endif

