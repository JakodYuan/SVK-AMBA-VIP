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


`ifndef SVK_AXI_SLAVE_DRIVER__SV
`define SVK_AXI_SLAVE_DRIVER__SV

`define SLV vif.slv_mp.slv_cb
`define MON vif.mon_mp.mon_cb
class svk_axi_slave_driver extends svk_axi_driver;
    `uvm_component_utils(svk_axi_slave_driver)
    `uvm_register_cb(svk_axi_slave_driver, svk_axi_slave_callback)

    uvm_blocking_peek_imp#(uvm_sequence_item, svk_axi_slave_driver)   response_request_imp;
    svk_axi_slave_database      db;
    event                       has_peek_data;
    uvm_sequence_item           peek_data;
    bit                         peek_done;




    svk_aw_linedata             aw_line;
    svk_ar_linedata             ar_line;
    svk_w_linedata              w_line;
    svk_r_linedata              r_line;
    svk_b_linedata              b_line;
    bit                         aw_first_valid = 1;
    bit                         ar_first_valid = 1;
    bit                         w_first_valid = 1;

    int unsigned            slave_sequence_get_num;
    int unsigned            slave_sequence_put_num;
    extern function new(string name, uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task peek(output uvm_sequence_item data);
    extern task reset_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);





    extern task sample_aw_linedata();
    extern task sample_ar_linedata();
    extern task sample_w_linedata();
    extern task drive_r_linedata();
    extern task drive_b_linedata();

    extern function int get_wr_osd();
    extern function int get_rd_osd();

    extern task pre_drive();
    extern task drive();
    extern task post_drive();

    extern function svk_r_linedata get_idle_r_linedata();
    extern function svk_b_linedata get_idle_b_linedata();
endclass

function svk_axi_slave_driver::new(string name, uvm_component parent);
    super.new(name, parent);
endfunction

function void svk_axi_slave_driver::build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(this.cfg == null)
        cfg = svk_axi_agent_cfg::type_id::create("svk_axi_slave_driver_cfg");

    db = new(cfg);  
    super.db = db; 

    response_request_imp = new("pesponse_port", this);
endfunction


function void svk_axi_slave_driver::connect_phase(uvm_phase phase);
    uvm_pool#(string, svk_axi_slave_callback) pool;
    string key;
    super.connect_phase(phase);

    pool = uvm_pool#(string, svk_axi_slave_callback)::get_global_pool();
    pool.first(key);
    do
        if(key != "" && uvm_is_match(key, get_full_name()))begin
            uvm_callbacks#(svk_axi_slave_driver, svk_axi_master_callback)::add(this, pool.get(key));
        end
    while(pool.next(key));
endfunction

task svk_axi_slave_driver::peek(output uvm_sequence_item data);
    @has_peek_data;
    data = peek_data;
    peek_done = 1;
    slave_sequence_get_num++;
endtask


task svk_axi_slave_driver::run_phase(uvm_phase phase);
    realtime pre_time;
    realtime post_time;

    super.run_phase(phase);

    fork
        while(1)begin
            @(`SLV);
            pre_time = $realtime;
            pre_drive();
            drive();
            post_drive();     
            post_time = $realtime;
            if(pre_time != post_time)
                `uvm_fatal(get_type_name(), "drive has delay !")
        end



    join
endtask

task svk_axi_slave_driver::sample_aw_linedata();
    static bit has_send_ready = 1'b1;
    svk_axi_transaction tmp;
    int cid;

    if(`SLV.awvalid === 1'b1 && aw_first_valid)begin
        aw_line        = new();
        aw_line.id     = `SLV.awid & cfg.ID_MASK;
        aw_line.addr   = `SLV.awaddr & cfg.ADDR_MASK;
        aw_line.len    = `SLV.awlen;
        aw_line.size   = `SLV.awsize;
        aw_line.burst  = `SLV.awburst;
        aw_line.lock   = `SLV.awlock;
        aw_line.cache  = `SLV.awcache;
        aw_line.prot   = `SLV.awprot;
        aw_line.region = `SLV.awregion;
        aw_line.user   = `SLV.awuser & cfg.ADDR_USER_MASK;
        aw_line.qos    = `SLV.awqos;

        cid = db.put_aw_linedata(aw_line);



        if(db.wr_tr[cid].w_vld == 1'b0)begin
            tmp = svk_axi_transaction::type_id::create("tr");
            tmp.copy(db.wr_tr[cid].tr);
            tmp.cfg = cfg;
            db.set_aw_rand_mode(tmp);





            peek_data = tmp;
            #0;
            ->has_peek_data;
            #0;
            fork
                begin
                    if(peek_done)begin
                        seq_item_port.get_next_item(req);
                        $cast(tmp, req);
                        seq_item_port.item_done();
                        peek_done = 0;
                        ++slave_sequence_put_num;
                    end
                end
                begin
                    #0.1;
                end
            join_any

            if(slave_sequence_get_num != slave_sequence_put_num)
                `uvm_fatal(get_type_name(), $sformatf("slave_sequence_get_num=%0d,slave_sequence_put_num=%0d, slave_response_sequence has delay!", slave_sequence_get_num, slave_sequence_put_num))

            db.wr_tr[cid].tr.resp         = tmp.resp;
            db.wr_tr[cid].tr.buser        = tmp.buser;
            db.wr_tr[cid].tr.awready_delay = tmp.awready_delay;
            db.wr_tr[cid].tr.wready_delay = tmp.wready_delay;
            db.wr_tr[cid].tr.bvalid_delay = tmp.bvalid_delay;
        end

        if(db.wr_tr[cid].last_finish && db.wr_tr[cid].w_vld && db.wr_tr[cid].aw_vld)begin
            tmp = svk_axi_transaction::type_id::create("tr");
            tmp.copy(db.wr_tr[cid].tr);
            tmp.cfg = cfg;
            tmp.write_finish = 1'b1;
            db.set_aw_rand_mode(tmp);



            peek_data = tmp;
            #0;
            ->has_peek_data;
            #0;
            fork
                begin
                    if(peek_done)begin
                        seq_item_port.get_next_item(req);
                        $cast(tmp, req);
                        seq_item_port.item_done();
                        peek_done = 0;
                        ++slave_sequence_put_num;
                    end
                end
                begin
                    #0.1;
                end
            join_any

            if(slave_sequence_get_num != slave_sequence_put_num)
                `uvm_fatal(get_type_name(), $sformatf("slave_sequence_get_num=%0d,slave_sequence_put_num=%0d, slave_response_sequence has delay!", slave_sequence_get_num, slave_sequence_put_num))



        end

    end

    if(`SLV.awvalid === 1'b1 && aw_first_valid == 1)
        aw_first_valid = 0;

    if(`SLV.awvalid === 1'b1 && `MON.awready === 1'b1)
        aw_first_valid = 1;


   if(cfg.default_awready == 1'b0)begin

        if(`MON.awvalid & !`MON.awready & has_send_ready)begin
            db.load_awready_delay(`MON.awid);
            has_send_ready = 1'b0;
        end

        if(`MON.awvalid === 1'b1 & db.awready_delay == 0 & has_send_ready == 0)begin
            `SLV.awready <= 1'b1;
            has_send_ready = 1;
        end
        else begin
            `SLV.awready <= 1'b0;
        end


        if(`MON.awvalid === 1'b1 && db.awready_delay != 0)begin
            --db.awready_delay;
        end
    end
    else begin
        if(db.awready_delay != 0)
            --db.awready_delay;
        else if(`MON.awvalid === 1'b1 && `MON.awready === 1'b1)
            db.load_awready_delay(`MON.awid);

        if(db.awready_delay == 0)
            `SLV.awready <= 1'b1;
        else
            `SLV.awready <= 1'b0;
    end


endtask

task svk_axi_slave_driver::sample_ar_linedata();
    static bit has_send_ready = 1'b1;
    svk_axi_transaction tmp;
    int cid;

    if(`SLV.arvalid === 1'b1 && ar_first_valid)begin
        ar_line         = new();
        ar_line.id      = `SLV.arid & cfg.ID_MASK;
        ar_line.addr    = `SLV.araddr & cfg.ADDR_MASK;
        ar_line.len     = `SLV.arlen;
        ar_line.size    = `SLV.arsize;
        ar_line.burst   = `SLV.arburst;
        ar_line.lock    = `SLV.arlock;
        ar_line.cache   = `SLV.arcache;
        ar_line.prot    = `SLV.arprot;
        ar_line.region  = `SLV.awregion;
        ar_line.user    = `SLV.awuser & cfg.ADDR_USER_MASK;
        ar_line.qos     = `SLV.awqos;

        cid = db.put_ar_linedata(ar_line);


        tmp = svk_axi_transaction::type_id::create("tr");
        tmp.copy(db.rd_tr[cid].tr);
        tmp.cfg = cfg;


        db.set_ar_rand_mode(tmp);




        peek_data = tmp;
        #0;
        ->has_peek_data;
        #0;
        fork
            begin
                if(peek_done)begin
                    seq_item_port.get_next_item(req);
                    $cast(tmp, req);
                    seq_item_port.item_done();
                    peek_done = 0;
                    ++slave_sequence_put_num;
                end
            end
            begin
                #0.1;
            end
        join_any

        if(slave_sequence_get_num != slave_sequence_put_num)
            `uvm_fatal(get_type_name(), $sformatf("slave_sequence_get_num=%0d,slave_sequence_put_num=%0d, slave_response_sequence has delay!", slave_sequence_get_num, slave_sequence_put_num))


        if(tmp.data.size != db.rd_tr[cid].tr.length+1)
            `uvm_fatal("callback_run", $sformatf("callback function of \"run\" modify the trans.data.size form %0d to %0d", db.rd_tr[cid].tr.length+1, tmp.data.size))
        if(tmp.ruser.size != db.rd_tr[cid].tr.length+1)
            `uvm_fatal("callback_run", $sformatf("callback function of \"run\" modify the trans.ruser.size form %0d to %0d", db.rd_tr[cid].tr.length+1, tmp.ruser.size))
        if(tmp.rvalid_delay.size != db.rd_tr[cid].tr.length+1)
            `uvm_fatal("callback_run", $sformatf("callback function of \"run\" modify the trans.rvalid_delay.size form %0d to %0d", db.rd_tr[cid].tr.length+1, tmp.rvalid_delay.size))
        if(tmp.resp.size != db.rd_tr[cid].tr.length+1)
            `uvm_fatal("callback_run", $sformatf("callback function of \"run\" modify the trans.resp.size form %0d to %0d", db.rd_tr[cid].tr.length+1, tmp.resp.size))

        db.rd_tr[cid].tr.arready_delay = tmp.arready_delay;

        db.rd_tr[cid].tr.data         = tmp.data;
        db.rd_tr[cid].tr.ruser        = tmp.ruser;
        db.rd_tr[cid].tr.rvalid_delay = tmp.rvalid_delay;
        db.rd_tr[cid].tr.resp         = tmp.resp;


    end

    if(`SLV.arvalid === 1'b1 && ar_first_valid == 1)
        ar_first_valid = 0;

    if(`SLV.arvalid === 1'b1 && `MON.arready === 1'b1)
        ar_first_valid = 1;

   if(cfg.default_arready == 1'b0)begin

        if(`MON.arvalid & !`MON.arready & has_send_ready)begin
            db.load_arready_delay(`MON.arid);
            has_send_ready = 1'b0;
        end

        if(`MON.arvalid === 1'b1 & db.arready_delay == 0 & has_send_ready == 0)begin
            `SLV.arready <= 1'b1;
            has_send_ready = 1;
        end
        else begin
            `SLV.arready <= 1'b0;
        end


        if(`MON.arvalid === 1'b1 && db.arready_delay != 0)begin
            --db.arready_delay;
        end
    end
    else begin
        if(db.arready_delay != 0)
            --db.arready_delay;
        else if(`MON.arvalid === 1'b1 && `MON.arready === 1'b1)
            db.load_arready_delay(`MON.arid);

        if(db.arready_delay == 0)
            `SLV.arready <= 1'b1;
        else
            `SLV.arready <= 1'b0;
    end

endtask

task svk_axi_slave_driver::sample_w_linedata();
    static bit can_load_delay = 1'b0;
    static bit has_send_ready = 1'b1;
    static int idx = 0;
    svk_axi_transaction tmp;
    int cid;

    if(`SLV.wvalid === 1'b1 && w_first_valid)begin
        w_line       = new();
        w_line.id    = `SLV.wid & cfg.ID_MASK;
        w_line.data  = `SLV.wdata & cfg.DATA_MASK;
        w_line.strb  = `SLV.wstrb & cfg.WSTRB_MASK;
        w_line.user  = `SLV.wuser & cfg.DATA_USER_MASK;
        w_line.last  = `SLV.wlast;

        cid = db.put_w_linedata(w_line);


        if(db.wr_tr[cid].idx == 1 && db.wr_tr[cid].aw_vld == 0)begin
            tmp = svk_axi_transaction::type_id::create("tr");
            tmp.copy(db.wr_tr[cid].tr);
            tmp.cfg = cfg;

            db.set_aw_rand_mode(tmp);




            peek_data = tmp;
            ->has_peek_data;
            #0;
            fork
                begin
                    if(peek_done)begin
                        seq_item_port.get_next_item(req);
                        $cast(tmp, req);
                        seq_item_port.item_done();
                        peek_done = 0;
                        ++slave_sequence_put_num;
                    end
                end
                begin
                    #0.1;
                end
            join_any

            if(slave_sequence_get_num != slave_sequence_put_num)
                `uvm_fatal(get_type_name(), $sformatf("slave_sequence_get_num=%0d,slave_sequence_put_num=%0d, slave_response_sequence has delay!", slave_sequence_get_num, slave_sequence_put_num))


            db.wr_tr[cid].tr.resp         = tmp.resp;
            db.wr_tr[cid].tr.buser        = tmp.buser;
            db.wr_tr[cid].tr.awready_delay = tmp.awready_delay;
            db.wr_tr[cid].tr.wready_delay = tmp.wready_delay;
            db.wr_tr[cid].tr.bvalid_delay = tmp.bvalid_delay;
        end



        if(db.wr_tr[cid].last_finish && db.wr_tr[cid].w_vld && db.wr_tr[cid].aw_vld)begin
            tmp = svk_axi_transaction::type_id::create("tr");
            tmp.copy(db.wr_tr[cid].tr);
            tmp.cfg = cfg;
            tmp.write_finish = 1'b1;
            db.set_aw_rand_mode(tmp);



            peek_data = tmp;
            #0;
            ->has_peek_data;
            #0;
            fork
                begin
                    if(peek_done)begin
                        seq_item_port.get_next_item(req);
                        $cast(tmp, req);
                        seq_item_port.item_done();
                        peek_done = 0;
                        ++slave_sequence_put_num;
                    end
                end
                begin
                    #0.1;
                end
            join_any

            if(slave_sequence_get_num != slave_sequence_put_num)
                `uvm_fatal(get_type_name(), $sformatf("slave_sequence_get_num=%0d,slave_sequence_put_num=%0d, slave_response_sequence has delay!", slave_sequence_get_num, slave_sequence_put_num))



        end

    end

    if(`SLV.wvalid === 1'b1 && w_first_valid == 1)
        w_first_valid = 0;

    if(`SLV.wvalid === 1'b1 && `MON.wready === 1'b1)
        w_first_valid = 1;

    if(cfg.wr_interleave_en == 1'b0)begin
        if(cfg.default_wready == 1'b0)begin

            if(`MON.wvalid === 1'b1 & `MON.wready == 1'b0)
                can_load_delay = 1'b1;

            if(`MON.wvalid === 1'b1 & `MON.wready == 1'b1 & `MON.wlast == 1'b1)begin
                can_load_delay = 1'b0;
                idx = 0;
            end


            if(`MON.wvalid === 1'b1 & `MON.wready == 1'b1)
                has_send_ready = 1'b1;


            if(`MON.wvalid === 1'b1 & can_load_delay & has_send_ready == 1'b1)begin
                db.load_wready_delay(`MON.wid, idx++);
                has_send_ready = 1'b0;
            end

            if(`MON.wvalid === 1'b1 & db.wready_delay == 0 & can_load_delay)begin
                `SLV.wready <= 1'b1;

            end
            else 
                `SLV.wready <= 1'b0;

            if(`MON.wvalid === 1'b1 && db.wready_delay != 0)begin
                --db.wready_delay;
            end
        end
        else begin


            if(db.wready_delay != 0)
                --db.wready_delay;
            else if(`MON.wvalid === 1'b1 && `MON.wready === 1'b1)
                db.load_wready_delay(`MON.wid, idx++);

            if(db.wready_delay == 0)
                `SLV.wready <= 1'b1;
            else
                `SLV.wready <= 1'b0;


            if(`MON.wvalid === 1'b1 & `MON.wready == 1'b1 & `MON.wlast == 1'b1)begin
                idx = 0;
            end
        end
    end
    else begin
        static int delay = 0;
        static bit has_send_ready = 1'b1;

        if(cfg.default_wready == 1'b0)begin
            if(delay == 0 && `MON.wvalid === 1'b1 && has_send_ready==1'b1)begin
                delay = get_rand_delay();
                has_send_ready = 0;
            end

            if(delay > 0)
                delay--;

            if(`MON.wvalid === 1'b1 && delay == 0 && has_send_ready==1'b0)begin
                `SLV.wready <= 1'b1;
                has_send_ready = 1;
            end
            else
                `SLV.wready <= 1'b0;
            
        end
        else begin
            if(`MON.wvalid === 1'b1 && `MON.wready === 1'b1)
                delay = get_rand_delay();

            if(delay > 0)
                delay--;

            if(delay == 0)
                `SLV.wready <= 1'b1;
            else
                `SLV.wready <= 1'b0;
        end
    end

endtask

task svk_axi_slave_driver::drive_r_linedata();

    if((`SLV.rready === 1'b1 && `MON.rvalid === 1'b1) || (r_line != null && r_line.vld == 0))begin
        r_line = null;
    end

    if(r_line == null)begin
        r_line = db.get_r_linedata();
    end
    if(r_line == null)begin
        r_line = get_idle_r_linedata();
    end

    `SLV.rvalid <= r_line.vld;
    `SLV.rid    <= r_line.id & cfg.ID_MASK;
    `SLV.rdata  <= r_line.data & cfg.DATA_MASK;
    `SLV.rresp  <= r_line.resp;
    `SLV.rlast  <= r_line.last;
    `SLV.ruser  <= r_line.user & cfg.RESP_USER_MASK;

endtask

task svk_axi_slave_driver::drive_b_linedata();

    if((`SLV.bready === 1'b1 && `MON.bvalid === 1'b1) || (b_line != null && b_line.vld == 0))begin
        b_line = null;
    end

    if(b_line == null)begin
        b_line = db.get_b_linedata();
    end
    if(b_line == null)begin
        b_line = get_idle_b_linedata();
    end

    `SLV.bvalid <= b_line.vld;
    `SLV.bid    <= b_line.id & cfg.ID_MASK;
    `SLV.bresp  <= b_line.resp;
    `SLV.buser  <= b_line.user & cfg.RESP_USER_MASK;

endtask

function int svk_axi_slave_driver::get_wr_osd();
    return db.get_wr_osd();
endfunction

function int svk_axi_slave_driver::get_rd_osd();
    return db.get_rd_osd();
endfunction

task svk_axi_slave_driver::pre_drive();
    svk_axi_dec::wr_event_struct wr_events[$];
    svk_axi_dec::rd_event_struct rd_events[$];

    sample_aw_linedata();
    sample_ar_linedata();
    sample_w_linedata();

    get_wr_events(wr_events);
    get_rd_events(rd_events);
    foreach(wr_events[i])
        db.update_wr_status(wr_events[i]);
    foreach(rd_events[i])
        db.update_rd_status(rd_events[i]);
endtask

task svk_axi_slave_driver::drive();
    drive_r_linedata();
    drive_b_linedata();
endtask

task svk_axi_slave_driver::post_drive();
    svk_axi_transaction  tr;

    tr = db.get_wr_tr();
    if(tr != null)begin
        `uvm_do_callbacks(svk_axi_slave_driver, svk_axi_slave_callback, run(tr))
        tr.randomize(null);



        port.write(tr);
    end

    tr = db.get_rd_tr();
    if(tr != null)begin
        `uvm_do_callbacks(svk_axi_slave_driver, svk_axi_slave_callback, run(tr))
        tr.randomize(null);



        port.write(tr);
    end

    db.tick();
endtask

function svk_r_linedata svk_axi_slave_driver::get_idle_r_linedata();
    svk_r_linedata    line;

    line = new();
    line.vld = 1'b0;
    case(cfg.idle_value)
        svk_dec::IDLE_STABLE:begin
            line.id   = `MON.rid;
            line.data = `MON.rdata;
            line.resp = `MON.rresp;
            line.last = `MON.rlast;
            line.user = `MON.ruser;
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

function svk_b_linedata svk_axi_slave_driver::get_idle_b_linedata();
    svk_b_linedata    line;

    line = new();
    case(cfg.idle_value)
        svk_dec::IDLE_STABLE:begin
            line.id   = `MON.bid;
            line.resp = `MON.bresp;
            line.user = `MON.buser;
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

task svk_axi_slave_driver::reset_phase(uvm_phase phase);
    super.reset_phase(phase);

    `SLV.awready <= cfg.default_awready;
    `SLV.arready <= cfg.default_arready;
    `SLV.wready  <= cfg.default_wready;
    `SLV.rvalid  <= 0;
    `SLV.rlast   <= 0;
    `SLV.rid     <= 0;
    `SLV.rdata   <= 0;
    `SLV.rresp   <= 0;
    `SLV.ruser   <= 0;
    `SLV.bvalid  <= 0;
    `SLV.bid     <= 0;
    `SLV.bresp   <= 0;
    `SLV.buser   <= 0;
endtask

`undef SLV
`undef MON

`endif

