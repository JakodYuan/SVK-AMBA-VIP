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

`ifndef SVK_APB_MASTER_DRIVER__SV
`define SVK_APB_MASTER_DRIVER__SV

`define MST vif.mst_mp.mst_cb

class svk_apb_master_driver extends uvm_driver;
    `uvm_component_utils(svk_apb_master_driver)

    svk_apb_agent_cfg                       cfg;
    virtual svk_apb_if                      vif;

    extern function new(string name, uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task reset_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern task drive_write(svk_apb_transaction tr);
    extern task drive_read(svk_apb_transaction tr);
    extern task drive_idle();

endclass

function svk_apb_master_driver::new(string name, uvm_component parent);
    super.new(name, parent);
endfunction


function void svk_apb_master_driver::build_phase(uvm_phase phase);
    if(cfg == null)
        cfg = svk_apb_agent_cfg::type_id::create("svk_apb_master_driver_cfg");
endfunction


function void svk_apb_master_driver::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction


task svk_apb_master_driver::reset_phase(uvm_phase phase);
    `MST.paddr   <= 0;
    `MST.puser   <= 0;
    `MST.psel    <= 0;
    `MST.pwdata  <= 0;
    `MST.penable <= 0;
    `MST.pwrite  <= 0;
    `MST.pstrb   <= 0;
    `MST.pprot   <= 0;
endtask

task svk_apb_master_driver::run_phase(uvm_phase phase);
    svk_apb_transaction  tr;

    while(1)begin
        #0;
        if(seq_item_port.has_do_available())begin
            seq_item_port.get_next_item(this.req);
            $cast(tr, req);
            if(tr.addr % (cfg.data_width/8) != 0)begin
                `uvm_warning(get_type_name(), $sformatf("addr=%0h is not align %0d bytes", tr.addr, cfg.data_width/8))
            end
            case(tr.dir)
                svk_apb_dec::WRITE: drive_write(tr);
                svk_apb_dec::READ : drive_read(tr);
            endcase

            if(tr.need_resp == 1)begin
                seq_item_port.put_response(tr);
            end
            end_tr(tr);
            seq_item_port.item_done();
        end
        else begin
            drive_idle();
        end
    end
endtask


task svk_apb_master_driver::drive_read(svk_apb_transaction tr);
    int wait_cnt = 0;

    `MST.paddr       <= tr.addr;
    `MST.puser       <= tr.user;
    `MST.psel        <= 1'b1;
    `MST.pwrite      <= 1'b0;
    `MST.penable     <= 1'b0;
    `MST.pprot       <= tr.prot;
    @(`MST);
    `MST.penable     <= 1'b1;
    @(`MST);
    while(`MST.pready !== 1'b1)begin
        ++wait_cnt;
        if(wait_cnt >= cfg.pready_time_out)begin
            `uvm_error(get_type_name(), $sformatf("pready not set after %0d cycles", wait_cnt))
            break;
        end
        @(`MST);
    end
    `MST.psel        <= 1'b0;
    `MST.penable     <= 1'b0;
    tr.data = `MST.prdata;
    tr.resp = `MST.pslverr;
endtask



task svk_apb_master_driver::drive_write(svk_apb_transaction tr);
    int wait_cnt = 0;

    `MST.paddr       <= tr.addr;
    `MST.puser       <= tr.user;
    `MST.pwdata      <= tr.data;
    `MST.pstrb       <= tr.strb;
    `MST.psel        <= 1'b1;
    `MST.pwrite      <= 1'b1;
    `MST.penable     <= 1'b0;
    `MST.pprot       <= tr.prot;
    @(`MST);
    `MST.penable     <= 1'b1;
    @(`MST);
    while(`MST.pready !== 1'b1)begin
        ++wait_cnt;
        if(wait_cnt >= cfg.pready_time_out)begin
            `uvm_error(get_type_name(), $sformatf("pready not set after %0d cycles", wait_cnt))
            break;
        end
        @(`MST);
    end
    `MST.psel        <= 1'b0;
    `MST.penable     <= 1'b0;
    tr.resp = `MST.pslverr;
endtask:drive_write


task svk_apb_master_driver::drive_idle();
    if(cfg.idle_value == svk_dec::IDLE_ZERO)begin
        `MST.paddr       <= 0;
        `MST.puser       <= 0;
        `MST.psel        <= 0;
        `MST.pwdata      <= 0;
        `MST.penable     <= 0;
        `MST.pwrite      <= 0;
        `MST.pstrb       <= 0;
        `MST.pprot       <= 0;
        @(`MST);
    end
    else if(cfg.idle_value == svk_dec::IDLE_RAND)begin
        `MST.paddr       <= $random;
        `MST.puser       <= $random;
        `MST.psel        <= 0;
        `MST.pwdata      <= $random;
        `MST.penable     <= 0;
        `MST.pwrite      <= $random;
        `MST.pstrb       <= $random;
        `MST.pprot       <= $random;
        @(`MST);
    end
    else if(cfg.idle_value == svk_dec::IDLE_STABLE)begin
        `MST.psel        <= 0;
        `MST.penable     <= 0;
        @(`MST);
    end
endtask:drive_idle

`undef MST

`endif
