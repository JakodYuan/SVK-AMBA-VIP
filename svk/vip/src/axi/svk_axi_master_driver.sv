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


`ifndef SVK_svk_axi_MASTER_DRIVER__SV
`define SVK_svk_axi_MASTER_DRIVER__SV

`define MST vif.mst_mp.mst_cb
`define MON vif.mon_mp.mon_cb
class svk_axi_master_driver extends svk_axi_driver;
    `uvm_component_utils(svk_axi_master_driver)
    `uvm_register_cb(svk_axi_master_driver, svk_axi_master_callback)

    svk_axi_master_database     db;



    svk_aw_linedata             aw_line;
    svk_ar_linedata             ar_line;
    svk_w_linedata              w_line;
    svk_r_linedata              r_line;
    svk_b_linedata              b_line;
    bit                         r_first_valid = 1; 
    bit                         b_first_valid = 1; 



    extern function new(string name, uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task reset_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern task get_trans();
    extern function void drive_aw_linedata();
    extern function void drive_ar_linedata();
    extern function void drive_w_linedata();
    extern function void sample_r_linedata();
    extern function void sample_b_linedata();




    extern function int  get_wr_osd();
    extern function int  get_rd_osd();
    extern function void pre_drive();
    extern function void drive();
    extern function void post_drive();
    extern function svk_aw_linedata get_idle_aw_linedata();
    extern function svk_ar_linedata get_idle_ar_linedata();
    extern function svk_w_linedata  get_idle_w_linedata();
endclass

function svk_axi_master_driver::new(string name, uvm_component parent);
    super.new(name, parent);
endfunction

function void svk_axi_master_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(this.cfg == null)
        cfg = svk_axi_agent_cfg::type_id::create("svk_axi_mst_driver_cfg");

    db = new(cfg);
    super.db = db;

endfunction

function void svk_axi_master_driver::connect_phase(uvm_phase phase);
    uvm_pool#(string, svk_axi_master_callback) pool;
    string key;
    super.connect_phase(phase);

    pool = uvm_pool#(string, svk_axi_master_callback)::get_global_pool();
    pool.first(key);
    do
        if(key != "" && uvm_is_match(key, get_full_name()))begin
            uvm_callbacks#(svk_axi_master_driver, svk_axi_master_callback)::add(this, pool.get(key));
        end
    while(pool.next(key));
endfunction

task svk_axi_master_driver::run_phase(uvm_phase phase);
    realtime                pre_get_trans_time;
    realtime                post_get_trans_time;

    super.run_phase(phase);
    fork
        while(1)begin
            @(`MST);

            pre_get_trans_time = $realtime;
            get_trans();
            post_get_trans_time = $realtime;
            if(pre_get_trans_time != post_get_trans_time)
                `uvm_fatal(get_type_name(), "get_trans has delay !")

            pre_drive();
            drive();
            post_drive();     
        end


    join
endtask

function void svk_axi_master_driver::drive();
    drive_aw_linedata();
    drive_ar_linedata();
    drive_w_linedata();
endfunction


function void svk_axi_master_driver::drive_aw_linedata();

    if((`MST.awready === 1'b1 && `MON.awvalid === 1'b1) || (aw_line != null && aw_line.vld == 0))begin
        aw_line = null;
    end

    if(aw_line == null)begin
        aw_line = db.get_aw_linedata();
    end
    if(aw_line == null)begin
        aw_line = get_idle_aw_linedata();
    end

    `MST.awvalid  <= aw_line.vld;
    `MST.awid     <= aw_line.id & cfg.ID_MASK;
    `MST.awaddr   <= aw_line.addr & cfg.ADDR_MASK;
    `MST.awlen    <= aw_line.len;
    `MST.awsize   <= aw_line.size;
    `MST.awburst  <= aw_line.burst;
    `MST.awlock   <= aw_line.lock;
    `MST.awcache  <= aw_line.cache;
    `MST.awprot   <= aw_line.prot;
    `MST.awregion <= aw_line.region;
    `MST.awuser   <= aw_line.user & cfg.ADDR_USER_MASK;
    `MST.awqos    <= aw_line.qos;

endfunction

function void svk_axi_master_driver::drive_w_linedata();

    if((`MST.wready === 1'b1 && `MON.wvalid === 1'b1) || (w_line != null && w_line.vld == 0))begin
        w_line = null;
    end

    if(w_line == null)begin
        w_line = db.get_w_linedata();
    end
    if(w_line == null)begin
        w_line = get_idle_w_linedata();
    end

    `MST.wvalid <= w_line.vld;
    `MST.wdata  <= w_line.data & cfg.DATA_MASK;
    `MST.wstrb  <= w_line.strb & cfg.WSTRB_MASK;
    `MST.wuser  <= w_line.user & cfg.DATA_USER_MASK;
    `MST.wlast  <= w_line.last;
    if(cfg.version == svk_axi_dec::AXI3)
        `MST.wid    <= w_line.id & cfg.ID_MASK;
    else
        `MST.wid    <= 1'bz;

endfunction

function void svk_axi_master_driver::drive_ar_linedata();

    if((`MST.arready === 1'b1 && `MON.arvalid === 1'b1) || (ar_line != null && ar_line.vld == 0))begin
        ar_line = null;
    end

    if(ar_line == null)begin
        ar_line = db.get_ar_linedata();
    end
    if(ar_line == null)begin
        ar_line = get_idle_ar_linedata();
    end

    `MST.arvalid  <= ar_line.vld;
    `MST.arid     <= ar_line.id & cfg.ID_MASK;
    `MST.araddr   <= ar_line.addr & cfg.ADDR_MASK;
    `MST.arlen    <= ar_line.len;
    `MST.arsize   <= ar_line.size;
    `MST.arburst  <= ar_line.burst;
    `MST.arlock   <= ar_line.lock;
    `MST.arcache  <= ar_line.cache;
    `MST.arprot   <= ar_line.prot;
    `MST.arregion <= ar_line.region;
    `MST.aruser   <= ar_line.user & cfg.ADDR_USER_MASK;
    `MST.arqos    <= ar_line.qos;

endfunction

function void svk_axi_master_driver::sample_r_linedata();
    static bit can_load_delay = 1'b0;
    static bit has_send_ready = 1'b1;
    static int idx = 0;

    if(`MST.rvalid === 1'b1 && r_first_valid)begin
        r_line      = new();
        r_line.id   = `MST.rid & cfg.ID_MASK;
        r_line.data = `MST.rdata & cfg.DATA_MASK;
        r_line.resp = `MST.rresp;
        r_line.last = `MST.rlast;
        r_line.user = `MST.ruser & cfg.RESP_USER_MASK;
        db.put_r_linedata(r_line);
    end


    if(`MST.rvalid === 1'b1 && r_first_valid == 1'b1)begin
        r_first_valid = 0;
    end

    if(`MST.rvalid === 1'b1 & `MON.rready === 1'b1)begin
        r_first_valid = 1;
    end

    if(cfg.rd_interleave_en == 1'b0)begin
        if(cfg.default_rready == 1'b0)begin

            if(`MON.rvalid === 1'b1 & `MON.rready == 1'b0)
                can_load_delay = 1'b1;

            if(`MON.rvalid === 1'b1 & `MON.rready == 1'b1 & `MON.rlast == 1'b1)begin
                can_load_delay = 1'b0;
                idx = 0;
            end

            if(`MON.rvalid === 1'b1 & `MON.rready == 1'b1)
                has_send_ready = 1'b1;

            if(`MON.rvalid === 1'b1 & can_load_delay & has_send_ready == 1'b1)begin
                db.load_rready_delay(`MON.rid, idx++);
                has_send_ready = 1'b0;
            end

            if(`MON.rvalid === 1'b1 & db.rready_delay == 0 & can_load_delay)begin
                `MST.rready <= 1'b1;

            end
            else 
                `MST.rready <= 1'b0;

            if(`MON.rvalid === 1'b1 && db.rready_delay != 0)begin
                --db.rready_delay;
            end
        end
        else begin


            if(db.rready_delay != 0)
                --db.rready_delay;
            else if(`MON.rvalid === 1'b1 && `MON.rready === 1'b1)
                db.load_rready_delay(`MON.rid, idx++);

            if(db.rready_delay == 0)
                `MST.rready <= 1'b1;
            else
                `MST.rready <= 1'b0;


            if(`MON.rvalid === 1'b1 & `MON.rready == 1'b1 & `MON.rlast == 1'b1)begin
                idx = 0;
            end
        end
    end
    else begin
        static int delay = 0;
        static bit has_send_ready = 1'b1;

        if(cfg.default_rready == 1'b0)begin
            if(delay == 0 && `MON.rvalid === 1'b1 && has_send_ready==1'b1)begin
                delay = get_rand_delay();
                has_send_ready = 0;
            end

            if(delay > 0)
                delay--;

            if(`MON.rvalid === 1'b1 && delay == 0 && has_send_ready==1'b0)begin
                `MST.rready <= 1'b1;
                has_send_ready = 1;
            end
            else
                `MST.rready <= 1'b0;
            
        end
        else begin
            if(`MON.rvalid === 1'b1 && `MON.rready === 1'b1)
                delay = get_rand_delay();

            if(delay > 0)
                delay--;

            if(delay == 0)
                `MST.rready <= 1'b1;
            else
                `MST.rready <= 1'b0;
        end
    end

endfunction

function void svk_axi_master_driver::sample_b_linedata();
    static bit has_send_ready = 1'b1;

    if(`MST.bvalid === 1'b1 && b_first_valid)begin
        b_line      = new();
        b_line.id   = `MST.bid & cfg.ID_MASK;
        b_line.resp = `MST.bresp;
        b_line.user = `MST.buser & cfg.RESP_USER_MASK;
        db.put_b_linedata(b_line);
    end


    if(`MST.bvalid === 1'b1 && b_first_valid == 1'b1)begin
        b_first_valid = 0;
    end

    if(`MST.bvalid === 1'b1 & `MON.bready === 1'b1)begin
        b_first_valid = 1;
    end


    if(cfg.default_bready == 1'b0)begin

        if(`MON.bvalid & !`MON.bready & has_send_ready)begin
            db.load_bready_delay(`MON.bid);
            has_send_ready = 1'b0;
        end

        if(`MON.bvalid === 1'b1 & db.bready_delay == 0 & has_send_ready == 0)begin
            `MST.bready <= 1'b1;
            has_send_ready = 1;
        end
        else begin
            `MST.bready <= 1'b0;
        end


        if(`MON.bvalid === 1'b1 && db.bready_delay != 0)begin
            --db.bready_delay;
        end
    end
    else begin
        if(db.bready_delay != 0)
            --db.bready_delay;
        else if(`MON.bvalid === 1'b1 && `MON.bready === 1'b1)
            db.load_bready_delay(`MON.bid);

        if(db.bready_delay == 0)
            `MST.bready <= 1'b1;
        else
            `MST.bready <= 1'b0;
    end

endfunction

function int svk_axi_master_driver::get_wr_osd();
    return db.get_wr_osd();
endfunction

function int svk_axi_master_driver::get_rd_osd();
    return db.get_rd_osd();
endfunction

function void svk_axi_master_driver::pre_drive();
    svk_axi_dec::wr_event_struct         wr_events[$];
    svk_axi_dec::rd_event_struct         rd_events[$];

    sample_r_linedata();
    sample_b_linedata();

    get_wr_events(wr_events);
    get_rd_events(rd_events);

    foreach(wr_events[i])
        db.update_wr_status(wr_events[i]);
    foreach(rd_events[i])
        db.update_rd_status(rd_events[i]);
endfunction

task svk_axi_master_driver::get_trans();
    static svk_axi_transaction tr;
    static bit      has_data = 1'b0;
    bit             has_data_and_osd;











    if(has_data == 0)begin
        seq_item_port.try_next_item(req);
        if(req != null)begin
            if($cast(tr, req))begin
                has_data = 1;
            end
            else begin
                `uvm_fatal(get_type_name(), $sformatf("get transaction type=%s from sequencer, not type of svk_axi_transaction", req.get_type_name()))
            end
        end
    end

    if(has_data && ((tr.dir == svk_axi_dec::WRITE && get_wr_osd() > 0) ||
                    (tr.dir == svk_axi_dec::READ && get_rd_osd() > 0)))begin

        has_data_and_osd = 1;

        seq_item_port.item_done();
    end

    if(has_data_and_osd)begin
        has_data = 0;

        tr.randomize(null);




        if(tr.cfg == null)
            `uvm_fatal(get_type_name(), "cfg is null in svk_axi_transaction")

        case(tr.dir)
            svk_axi_dec::WRITE: db.put_wr_tr(tr);
            svk_axi_dec::READ:  db.put_rd_tr(tr);
        endcase
    end

endtask

function void svk_axi_master_driver::post_drive();
    svk_axi_transaction  tr;

    tr = db.get_wr_tr();
    if(tr != null)begin
        `uvm_do_callbacks(svk_axi_master_driver, svk_axi_master_callback, run(tr))
        tr.randomize(null);




        port.write(tr);
        if(tr.need_resp)
            seq_item_port.put_response(tr);
    end

    tr = db.get_rd_tr();
    if(tr != null)begin
        `uvm_do_callbacks(svk_axi_master_driver, svk_axi_master_callback, run(tr))
        tr.randomize(null);



        port.write(tr);
        if(tr.need_resp)
            seq_item_port.put_response(tr);
    end

    db.tick();
endfunction

function svk_aw_linedata svk_axi_master_driver::get_idle_aw_linedata();
    svk_aw_linedata    line;

    line = new();
    line.vld = 0;
    case(cfg.idle_value)
        svk_dec::IDLE_STABLE:begin
            line.id     = `MON.awid;
            line.addr   = `MON.awaddr;
            line.len    = `MON.awlen;
            line.size   = `MON.awsize;
            line.burst  = `MON.awburst;
            line.lock   = `MON.awlock;
            line.cache  = `MON.awcache;
            line.prot   = `MON.awprot;
            line.region = `MON.awregion;
            line.user   = `MON.awuser;
            line.qos    = `MON.awqos;
        end
        svk_dec::IDLE_ZERO:begin
            line.max_cons.constraint_mode(0);
            line.zero_cons.constraint_mode(1);
            line.randomize();
        end
        svk_dec::IDLE_MAX:begin
            line.max_cons.constraint_mode(1);
            line.zero_cons.constraint_mode(0);
            line.randomize();
        end
        svk_dec::IDLE_RAND:begin
            line.max_cons.constraint_mode(0);
            line.zero_cons.constraint_mode(0);
            line.randomize();
        end
    endcase

    return line;
endfunction


function svk_w_linedata svk_axi_master_driver::get_idle_w_linedata();
    svk_w_linedata    line;

    line = new();
    line.vld = 0;
    case(cfg.idle_value)
        svk_dec::IDLE_STABLE:begin
            line.id   = `MON.wid;
            line.data = `MON.wdata;
            line.strb = `MON.wstrb;
            line.user = `MON.wuser;
            line.last = `MON.wlast;
        end
        svk_dec::IDLE_ZERO:begin
            line.max_cons.constraint_mode(0);
            line.zero_cons.constraint_mode(1);
            line.randomize();
        end
        svk_dec::IDLE_MAX:begin
            line.max_cons.constraint_mode(2);
            line.zero_cons.constraint_mode(0);
            line.randomize();
        end
        svk_dec::IDLE_RAND:begin
            line.max_cons.constraint_mode(0);
            line.zero_cons.constraint_mode(0);
            line.randomize();
        end
    endcase

    return line;
endfunction



function svk_ar_linedata svk_axi_master_driver::get_idle_ar_linedata();
    svk_ar_linedata    line;

    line = new();
    line.vld = 0;
    case(cfg.idle_value)
        svk_dec::IDLE_STABLE:begin
            line.id     = `MON.arid;
            line.addr   = `MON.araddr;
            line.len    = `MON.arlen;
            line.size   = `MON.arsize;
            line.burst  = `MON.arburst;
            line.lock   = `MON.arlock;
            line.cache  = `MON.arcache;
            line.prot   = `MON.arprot;
            line.region = `MON.arregion;
            line.user   = `MON.aruser;
            line.qos    = `MON.arqos;
        end
        svk_dec::IDLE_ZERO:begin
            line.max_cons.constraint_mode(0);
            line.zero_cons.constraint_mode(1);
            line.randomize();
        end
        svk_dec::IDLE_MAX:begin
            line.max_cons.constraint_mode(1);
            line.zero_cons.constraint_mode(0);
            line.randomize();
        end
        svk_dec::IDLE_RAND:begin
            line.max_cons.constraint_mode(0);
            line.zero_cons.constraint_mode(0);
            line.randomize();
        end
    endcase

    return line;
endfunction

task svk_axi_master_driver::reset_phase(uvm_phase phase);
    super.reset_phase(phase);


    `MST.bready   <= cfg.default_bready;
    `MST.rready   <= cfg.default_rready;
    `MST.awvalid  <= 0;
    `MST.awid     <= 0;
    `MST.awaddr   <= 0;
    `MST.awlen    <= 0;
    `MST.awsize   <= 0;
    `MST.awburst  <= 0;
    `MST.awlock   <= 0;
    `MST.awcache  <= 0;
    `MST.awprot   <= 0;
    `MST.awuser   <= 0;
    `MST.awqos    <= 0;
    `MST.arvalid  <= 0;
    `MST.arid     <= 0;
    `MST.araddr   <= 0;
    `MST.arlen    <= 0;
    `MST.arsize   <= 0;
    `MST.arburst  <= 0;
    `MST.arlock   <= 0;
    `MST.arcache  <= 0;
    `MST.arprot   <= 0;
    `MST.arregion <= 0;
    `MST.aruser   <= 0;
    `MST.arqos    <= 0;
    `MST.wvalid   <= 0;
    `MST.wlast    <= 0;
    `MST.wid      <= 0;
    `MST.wdata    <= 0;
    `MST.wstrb    <= 0;
    `MST.wuser    <= 0;
endtask

`undef  MST
`undef  MON
`endif


