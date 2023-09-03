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

`ifndef SVK_svk_axi_DRIVER__SV
`define SVK_svk_axi_DRIVER__SV

`define MON vif.mon_mp.mon_cb
class svk_axi_driver extends uvm_driver;
    svk_axi_database                            db;
    virtual svk_axi_if                          vif;
    uvm_analysis_port#(uvm_sequence_item)       port;
    svk_axi_agent_cfg                           cfg;

    bit                                         aw_first_valid = 1;
    bit                                         ar_first_valid = 1;
    bit                                         w_first_valid  = 1;
    bit                                         r_first_valid  = 1;
    bit                                         b_first_valid  = 1;

    bit                                         r_first_transfer = 1;
    bit                                         w_first_transfer = 1;

    extern function new(string name = "", uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);

    extern function void get_wr_events(ref svk_axi_dec::wr_event_struct events[$]);
    extern function void get_rd_events(ref svk_axi_dec::rd_event_struct events[$]);

    extern function void get_aw_events(ref svk_axi_dec::wr_event_struct events[$]);
    extern function void get_w_events(ref svk_axi_dec::wr_event_struct events[$]);
    extern function void get_ar_events(ref svk_axi_dec::rd_event_struct events[$]);
    extern function void get_b_events(ref svk_axi_dec::wr_event_struct events[$]);
    extern function void get_r_events(ref svk_axi_dec::rd_event_struct events[$]);

    extern function int get_rand_delay();

endclass

function svk_axi_driver::new(string name = "", uvm_component parent);
    super.new(name, parent);
endfunction

function void svk_axi_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
    port = new("port", this);
endfunction

function void svk_axi_driver::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction


function void svk_axi_driver::get_wr_events(ref svk_axi_dec::wr_event_struct events[$]);
    get_aw_events(events);
    get_w_events(events);
    get_b_events(events);
endfunction


function void svk_axi_driver::get_rd_events(ref svk_axi_dec::rd_event_struct events[$]);
    get_ar_events(events);
    get_r_events(events);
endfunction



function void svk_axi_driver::get_aw_events(ref svk_axi_dec::wr_event_struct events[$]);

    if(`MON.awvalid === 1'b1 && aw_first_valid == 1'b1)begin
        svk_axi_dec::wr_event_struct tmp;
        tmp.wr_event    = svk_axi_dec::WT_AWVALID_EVENT;
        tmp.id          = `MON.awid;
        aw_first_valid  = 0;
        events.push_back(tmp);
    end

    if(`MON.awvalid === 1'b1 & `MON.awready === 1'b1)begin
        svk_axi_dec::wr_event_struct tmp;
        tmp.wr_event    = svk_axi_dec::WT_AW_HANDSHAKE_EVENT;
        tmp.id          = `MON.awid;
        aw_first_valid  = 1;
        events.push_back(tmp);
    end

endfunction

function void svk_axi_driver::get_w_events(ref svk_axi_dec::wr_event_struct events[$]);
    svk_axi_dec::wr_delay_event_enum               wr_event;         
    bit                                            first_first_valid;
    bit                                            first_handshake;  

    first_first_valid = w_first_transfer  & w_first_valid;
    if(w_first_transfer & `MON.wvalid === 1'b1 & `MON.wready === 1'b1)begin
        first_handshake = 1;
        w_first_transfer = 0;
    end
    else
        first_handshake = 0;

    if(`MON.wvalid === 1'b1 && w_first_valid == 1'b1)begin
        svk_axi_dec::wr_event_struct tmp;
        tmp.wr_event    = svk_axi_dec::WT_WVALID_EVENT;
        tmp.id          = `MON.wid;
        w_first_valid   = 0;
        events.push_back(tmp);
    end

    if(`MON.wvalid === 1'b1 & `MON.wready === 1'b1)begin
        svk_axi_dec::wr_event_struct tmp;
        tmp.wr_event    = svk_axi_dec::WT_W_HANDSHAKE_EVENT;
        tmp.id          = `MON.wid;
        w_first_valid   = 1;
        events.push_back(tmp);
    end

    if(first_first_valid & `MON.wvalid === 1'b1)begin
        svk_axi_dec::wr_event_struct tmp;
        tmp.wr_event    = svk_axi_dec::WT_FIRST_WVALID_EVENT;
        tmp.id          = `MON.wid;
        events.push_back(tmp);
    end

    if(first_handshake)begin
        svk_axi_dec::wr_event_struct tmp;
        tmp.wr_event    = svk_axi_dec::WT_FIRST_W_HANDSHAKE_EVENT;
        tmp.id          = `MON.wid;
        events.push_back(tmp);
    end

    if(`MON.wvalid === 1'b1 && `MON.wlast === 1'b1 && `MON.wready === 1'b1)begin
        svk_axi_dec::wr_event_struct tmp;
        tmp.wr_event    = svk_axi_dec::WT_LAST_W_HANDSHAKE_EVENT;
        tmp.id          = `MON.wid;
        events.push_back(tmp);
    end

    w_first_transfer = `MON.wvalid & `MON.wready & `MON.wlast;
endfunction

function void svk_axi_driver::get_ar_events(ref svk_axi_dec::rd_event_struct events[$]);
    svk_axi_dec::rd_delay_event_enum               rd_event;

    if(`MON.arvalid === 1'b1 && ar_first_valid == 1'b1)begin
        svk_axi_dec::rd_event_struct tmp;
        tmp.rd_event    = svk_axi_dec::RD_ARVALID_EVENT;
        tmp.id          = `MON.arid;
        ar_first_valid  = 0;
        events.push_back(tmp);
    end

    if(`MON.arvalid === 1'b1 & `MON.arready === 1'b1)begin
        svk_axi_dec::rd_event_struct tmp;
        tmp.rd_event    = svk_axi_dec::RD_AR_HANDSHAKE_EVENT;
        tmp.id          = `MON.arid;
        ar_first_valid  = 1;
        events.push_back(tmp);
    end

endfunction

function void svk_axi_driver::get_b_events(ref svk_axi_dec::wr_event_struct events[$]);
    svk_axi_dec::wr_delay_event_enum               wr_event;

    if(`MON.bvalid === 1'b1 && b_first_valid == 1'b1)begin
        svk_axi_dec::wr_event_struct tmp;
        tmp.wr_event    = svk_axi_dec::WT_BVALID_EVENT;
        tmp.id          = `MON.bid;
        b_first_valid   = 0;
        events.push_back(tmp);
    end

    if(`MON.bvalid === 1'b1 & `MON.bready === 1'b1)begin
        svk_axi_dec::wr_event_struct tmp;
        tmp.wr_event    = svk_axi_dec::WT_B_HANDSHAKE_EVENT;
        tmp.id          = `MON.bid;
        b_first_valid   = 1;
        events.push_back(tmp);
    end

endfunction

function void svk_axi_driver::get_r_events(ref svk_axi_dec::rd_event_struct events[$]);
    svk_axi_dec::rd_delay_event_enum                     rd_event;         
    bit                                     first_first_valid;
    bit                                     first_handshake;  


    first_first_valid = r_first_transfer  & r_first_valid;
    if(r_first_transfer & `MON.rvalid & `MON.rready)begin
        first_handshake = 1;
        r_first_transfer = 0;
    end
    else
        first_handshake = 0;

    if(`MON.rvalid === 1'b1 && r_first_valid == 1'b1)begin
        svk_axi_dec::rd_event_struct tmp;
        tmp.rd_event    = svk_axi_dec::RD_RVALID_EVENT;
        tmp.id          = `MON.rid;
        r_first_valid   = 0;
        events.push_back(tmp);
    end

    if(`MON.rvalid === 1'b1 & `MON.rready === 1'b1)begin
        svk_axi_dec::rd_event_struct tmp;
        tmp.rd_event    = svk_axi_dec::RD_R_HANDSHAKE_EVENT;
        tmp.id          = `MON.rid;
        r_first_valid   = 1;
        events.push_back(tmp);
    end

    if(first_first_valid & `MON.rvalid === 1'b1)begin
        svk_axi_dec::rd_event_struct tmp;
        tmp.rd_event    = svk_axi_dec::RD_RVALID_EVENT;
        tmp.id          = `MON.rid;
        events.push_back(tmp);
    end

    if(first_handshake)begin
        svk_axi_dec::rd_event_struct tmp;
        tmp.rd_event    = svk_axi_dec::RD_FIRST_R_HANDSHAKE_EVENT;
        tmp.id          = `MON.rid;
        events.push_back(tmp);
    end

    if(`MON.rvalid === 1'b1 && `MON.rlast === 1'b1 && `MON.rready === 1'b1)begin
        svk_axi_dec::rd_event_struct tmp;
        tmp.rd_event    = svk_axi_dec::RD_LAST_R_HANDSHAKE_EVENT;
        tmp.id          = `MON.rid;
        events.push_back(tmp);
    end

    r_first_transfer = `MON.rvalid & `MON.rready & `MON.rlast;
endfunction


function int svk_axi_driver::get_rand_delay();
    int delay;
    svk_axi_transaction tr;

    tr = svk_axi_transaction::type_id::create("tr");

    std::randomize(delay) with {
        delay dist {
            0:/ tr.zero_delay_wt,
            [tr.short_delay_min:tr.short_delay_max]:/ tr.short_delay_wt,
            [tr.long_delay_min:tr.long_delay_max]:/ tr.long_delay_wt
        };
    };

    return delay;
endfunction

`endif
