/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_AXI_SLAVE_DATABASE__SV
`define SVK_AXI_SLAVE_DATABASE__SV

class svk_axi_slave_database extends svk_axi_database;
    svk_axi_agent_cfg               cfg;
    int                             arready_delay=0;
    int                             awready_delay=0;
    int                             wready_delay=0;



    int                             last_wr_cid;
    int                             last_rd_cid;
    svk_axi_scheduler               sch;


    extern function new(svk_axi_agent_cfg cfg);

    extern function svk_b_linedata get_b_linedata();
    extern function svk_r_linedata get_r_linedata();

    extern function void set_aw_rand_mode(svk_axi_transaction tr);
    extern function void set_ar_rand_mode(svk_axi_transaction tr);
    extern function void set_w_rand_mode(svk_axi_transaction tr, bit aw_vld);

    extern function int put_aw_linedata(svk_aw_linedata line);
    extern function int put_ar_linedata(svk_ar_linedata line);
    extern function int put_w_linedata(svk_w_linedata line);

    extern task arready_process();
    extern task awready_process();
    extern task wready_process();

    extern function void load_awready_delay(bit [`SVK_AXI_ID_WIDTH-1:0] id);
    extern function void load_arready_delay(bit [`SVK_AXI_ID_WIDTH-1:0] id);
    extern function void load_wready_delay(bit [`SVK_AXI_ID_WIDTH-1:0] id, int idx);

    extern function void update_rd_status(svk_axi_dec::rd_event_struct e);
    extern function void update_wr_status(svk_axi_dec::wr_event_struct e);

    extern function void update_awready_status(bit[`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::wr_delay_event_enum delay_event);
    extern function void update_wready_status(bit[`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::wr_delay_event_enum delay_event);
    extern function void update_arready_status(bit[`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::rd_delay_event_enum delay_event);
    extern function void update_bvalid_status(bit[`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::wr_delay_event_enum delay_event);
    extern function void update_rvalid_status(bit[`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::rd_delay_event_enum delay_event);


    extern function int  get_aw_cid(bit[`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::cid_status_enum cid_status);
    extern function int  get_w_cid(bit[`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::cid_status_enum cid_status);
    extern function int  get_ar_cid(bit[`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::cid_status_enum cid_status);
    extern function int  get_b_cid(bit[`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::cid_status_enum cid_status);
    extern function int  get_r_cid(bit[`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::cid_status_enum cid_status);

    extern function svk_axi_transaction get_wr_tr();
    extern function svk_axi_transaction get_rd_tr();

    extern function void tick();
    extern function int  get_wr_osd();
    extern function int  get_rd_osd();

endclass

function svk_axi_slave_database::new(svk_axi_agent_cfg cfg);
    this.cfg = cfg;
    for(int cid=0; cid<=cfg.wr_osd; ++cid)begin
        wr_cid_q.push_back(cid);
    end
    for(int cid=0; cid<=cfg.rd_osd; ++cid)begin
        rd_cid_q.push_back(cid);
    end

    sch = new(cfg.rd_osd);
endfunction


function void svk_axi_slave_database::load_awready_delay(bit [`SVK_AXI_ID_WIDTH-1:0] id);
    int cid;

    cid = get_aw_cid(id, svk_axi_dec::SLV_GET_REQ_WITH_MAX_TID);
    if(cid == -1)
        awready_delay = 0;
    else
        awready_delay = wr_tr[cid].tr.awready_delay;


endfunction

function void svk_axi_slave_database::load_arready_delay(bit [`SVK_AXI_ID_WIDTH-1:0] id);
    int cid;

    cid = get_ar_cid(id, svk_axi_dec::SLV_GET_REQ_WITH_MAX_TID);
    if(cid == -1)
        arready_delay = 0;
    else
        arready_delay = rd_tr[cid].tr.arready_delay;


endfunction

function void svk_axi_slave_database::load_wready_delay(bit [`SVK_AXI_ID_WIDTH-1:0] id, int idx);
    int cid;

    cid = get_w_cid(id, svk_axi_dec::SLV_GET_REQ_WITH_MAX_TID);
    if(cid == -1)
        wready_delay = 0;
    else
        wready_delay = wr_tr[cid].tr.wready_delay[idx];



endfunction


function svk_b_linedata svk_axi_slave_database::get_b_linedata();
    int idx;
    int cid;
    int tid_q[$];
    int qi[$];

    if(cfg.wr_out_of_order_en == 1)begin
        qi = wr_tr.find_index with(item.valid_status==svk_axi_dec::TIME_OUT && item.last_finish);
        if(qi.size > 0)begin
            cid = get_cid_with_min_tid(wr_tr, qi, wr_t2c);
            return wr_tr[cid].get_b_linedata();
        end
        else begin
            return null;
        end
    end
    else begin
        foreach(wr_t2c[tid])begin
            tid_q.push_back(tid);
        end
        qi = tid_q.min();
        if(qi.size == 1)begin
            cid = wr_t2c[qi[0]];
            if(wr_tr[cid].valid_status == svk_axi_dec::TIME_OUT && wr_tr[cid].last_finish)begin
                return wr_tr[cid].get_b_linedata();
            end
            else  begin
                return null;
            end
        end
        else begin
            return null;
        end
    end
endfunction

function svk_r_linedata svk_axi_slave_database::get_r_linedata();
    bit                         grant[`SVK_AXI_MAX_OSD-1:0];
    bit [`SVK_AXI_MAX_OSD-1:0]  grant_tmp;
    bit [`SVK_AXI_MAX_OSD-1:0]  req;
    int                         cid;
    int                         qi[$];
    int                         idx;
    int                         tid_q[$];
    bit [`SVK_AXI_ID_WIDTH-1:0] busy_id[$];

    case({cfg.rd_out_of_order_en, cfg.rd_interleave_en})
        2'b11:begin
            bit [`SVK_AXI_ID_WIDTH-1:0] id;
            int                     id_qi[$];

            qi = rd_tr.find_index with (item.ready_status == svk_axi_dec::FINISH && item.valid_status == svk_axi_dec::TIME_OUT);
            foreach(qi[i])begin
                id = rd_tr[qi[i]].tr.id;
                id_qi = rd_tr.find_index with((item.tr.id & cfg.ID_MASK) == (id & cfg.ID_MASK));
                cid = get_cid_with_min_tid(rd_tr, id_qi, rd_t2c);
                if(id == rd_tr[cid].tr.id)
                    return rd_tr[cid].get_r_linedata();
                else
                    continue;
            end
            return null;

        end
        2'b10:begin

            qi = rd_tr.find_index with (item.idx != 0 && item.last_finish == 0);
            if(qi.size > 1)
                `uvm_fatal("svk_axi_slave_database", $sformatf("rd_interleave_en = 0, should only one burst is sending:size=%0d", qi.size))
            else if(qi.size == 1)begin
                cid = qi[0];
                if(rd_tr[cid].valid_status == svk_axi_dec::TIME_OUT)
                    return rd_tr[cid].get_r_linedata();
                else
                    return null;
            end
            else begin

                qi = rd_tr.find_index with (item.ready_status == svk_axi_dec::FINISH && item.valid_status == svk_axi_dec::TIME_OUT && item.idx == 0);
                if(qi.size > 0)begin
                    cid = get_cid_with_min_tid(rd_tr, qi, rd_t2c);
                    return rd_tr[cid].get_r_linedata();
                end
                else begin
                    return null;
                end
            end
        end
        2'b01:begin
            bit [`SVK_AXI_ID_WIDTH-1:0] id;
            int                         id_qi[$];
            int                         tid_qi[$];
            bit                         has_not_send;

            qi = rd_tr.find_index with (item.ready_status == svk_axi_dec::FINISH && item.valid_status == svk_axi_dec::TIME_OUT);
            foreach(qi[i])begin
                id = rd_tr[qi[i]].tr.id;
                id_qi = rd_tr.find_index with((item.tr.id & cfg.ID_MASK) == (id & cfg.ID_MASK));
                cid = get_cid_with_min_tid(rd_tr, id_qi, rd_t2c);
                tid_qi = rd_tr.find_index with(item.tid < rd_tr[cid].tid);

                if(id == rd_tr[cid].tr.id)begin
                    foreach(tid_qi[j])begin
                        if(rd_tr[tid_qi[j]].idx == 0)begin
                            has_not_send = 1;
                            break;
                        end
                    end
                    if(has_not_send == 0)
                        return rd_tr[cid].get_r_linedata();
                    else
                        has_not_send = 0;
                end
            end
            return null;

        end
        2'b00:begin
            foreach(rd_t2c[tid])begin
                tid_q.push_back(tid);
            end
            qi = tid_q.min();
            if(qi.size == 1)begin
                cid = rd_t2c[qi[0]];
                if(rd_tr[cid].ready_status == svk_axi_dec::FINISH && rd_tr[cid].valid_status == svk_axi_dec::TIME_OUT && rd_tr[cid].last_finish == 0)
                    return rd_tr[cid].get_r_linedata();
                else begin
                    return null;
                end
            end
            else begin
                return null;
            end
        end
    endcase
endfunction

function void svk_axi_slave_database::set_aw_rand_mode(svk_axi_transaction tr);

    tr.dir.rand_mode(0);
    tr.length.rand_mode(0);
    tr.size.rand_mode(0);
    tr.burst.rand_mode(0);
    tr.lock.rand_mode(0);
    tr.cache.rand_mode(0);
    tr.prot.rand_mode(0);
    tr.resp.rand_mode(1);
    tr.wstrb.rand_mode(0);
    tr.data.rand_mode(0);
    tr.addr.rand_mode(0);
    tr.id.rand_mode(0);
    tr.auser.rand_mode(0);
    tr.ruser.rand_mode(0);
    tr.wuser.rand_mode(0);
    tr.buser.rand_mode(1);
    tr.qos.rand_mode(0);
    tr.region.rand_mode(0);
    tr.need_resp.rand_mode(0);
    tr.awready_delay.rand_mode(1);
    tr.awvalid_delay.rand_mode(0);
    tr.arready_delay.rand_mode(0);
    tr.arvalid_delay.rand_mode(0);



        tr.wready_delay.rand_mode(1);
    tr.wvalid_delay.rand_mode(0);
    tr.rready_delay.rand_mode(0);
    tr.rvalid_delay.rand_mode(0);
    tr.bvalid_delay.rand_mode(1);
    tr.bready_delay.rand_mode(0);
    
    tr.con_burst.constraint_mode(0);
    tr.con_lock.constraint_mode(0);
    tr.con_cache.constraint_mode(0);
    tr.con_wstrb.constraint_mode(0);
    tr.con_data.constraint_mode(0);
    tr.con_resp.constraint_mode(1);
    tr.con_length.constraint_mode(0);
    tr.con_wuser.constraint_mode(0);
    tr.con_ruser.constraint_mode(0);
    tr.con_size.constraint_mode(0);
    tr.con_addr.constraint_mode(0);
    tr.con_buser.constraint_mode(1);
    tr.con_awready_delay.constraint_mode(1);
    tr.con_awvalid_delay.constraint_mode(0);
    tr.con_arready_delay.constraint_mode(0);
    tr.con_arvalid_delay.constraint_mode(0);



        tr.con_wready_delay.constraint_mode(1);
    tr.con_wvalid_delay.constraint_mode(0);
    tr.con_bready_delay.constraint_mode(0);
    tr.con_bvalid_delay.constraint_mode(1);
    tr.con_rready_delay.constraint_mode(0);
    tr.con_rvalid_delay.constraint_mode(0);
endfunction

function int svk_axi_slave_database::put_aw_linedata(svk_aw_linedata line);
    int cid;
    svk_axi_transaction tmp;

    cid = get_aw_cid(line.id, svk_axi_dec::SLV_ALLOCATE_NEW);
    line.cid = cid;
    if(!wr_tr.exists(cid))begin
        wr_tr[cid] = svk_axi_transaction_wrap::type_id::create("tr");
        wr_tr[cid].tr.cfg = cfg;
        wr_tr[cid].cid = cid;
        wr_tr[cid].tid = ++wr_tid_cnt;
        wr_t2c[wr_tid_cnt] = cid;
    end
    else begin
        `uvm_info("put_aw_linedata", "data_before_addr", UVM_HIGH)
    end
    wr_tr[cid].put_aw_linedata(line);

    if(wr_tr[cid].w_vld == 0)begin
        set_aw_rand_mode(wr_tr[cid].tr);

        wr_tr[cid].tr.randomize();
    end


    return cid;
endfunction

function void svk_axi_slave_database::set_ar_rand_mode(svk_axi_transaction tr);

    tr.dir.rand_mode(0);
    tr.length.rand_mode(0);
    tr.size.rand_mode(0);
    tr.burst.rand_mode(0);
    tr.lock.rand_mode(0);
    tr.cache.rand_mode(0);
    tr.prot.rand_mode(0);
    tr.resp.rand_mode(1);
    tr.wstrb.rand_mode(0);
    tr.data.rand_mode(1);
    tr.addr.rand_mode(0);
    tr.id.rand_mode(0);
    tr.auser.rand_mode(0);
    tr.ruser.rand_mode(1);
    tr.wuser.rand_mode(0);
    tr.buser.rand_mode(0);
    tr.qos.rand_mode(0);
    tr.region.rand_mode(0);
    tr.need_resp.rand_mode(0);
    tr.awready_delay.rand_mode(0);
    tr.awvalid_delay.rand_mode(0);
    tr.arready_delay.rand_mode(1);
    tr.arvalid_delay.rand_mode(0);
    tr.wready_delay.rand_mode(0);
    tr.wvalid_delay.rand_mode(0);
    tr.rready_delay.rand_mode(0);
    tr.rvalid_delay.rand_mode(1);
    tr.bvalid_delay.rand_mode(0);
    tr.bready_delay.rand_mode(0);
    

    tr.con_burst.constraint_mode(0);
    tr.con_lock.constraint_mode(0);
    tr.con_cache.constraint_mode(0);
    tr.con_wstrb.constraint_mode(0);
    tr.con_data.constraint_mode(1);
    tr.con_resp.constraint_mode(1);
    tr.con_length.constraint_mode(0);
    tr.con_wuser.constraint_mode(0);
    tr.con_ruser.constraint_mode(1);
    tr.con_size.constraint_mode(0);
    tr.con_addr.constraint_mode(0);
    tr.con_buser.constraint_mode(0);
    tr.con_awready_delay.constraint_mode(0);
    tr.con_awvalid_delay.constraint_mode(0);
    tr.con_arready_delay.constraint_mode(1);
    tr.con_arvalid_delay.constraint_mode(0);
    tr.con_wready_delay.constraint_mode(0);
    tr.con_wvalid_delay.constraint_mode(0);
    tr.con_bready_delay.constraint_mode(0);
    tr.con_bvalid_delay.constraint_mode(0);
    tr.con_rready_delay.constraint_mode(0);
    tr.con_rvalid_delay.constraint_mode(1);
endfunction


function int svk_axi_slave_database::put_ar_linedata(svk_ar_linedata line);
    bit[`SVK_AXI_ADDR_WIDTH-1:0] align_addr;
    int                      cid;

    cid = get_ar_cid(line.id, svk_axi_dec::SLV_ALLOCATE_NEW);
    line.cid = cid;
    if(!rd_tr.exists(cid))begin
        rd_tr[cid] = svk_axi_transaction_wrap::type_id::create("tr");
        rd_tr[cid].tr.cfg = cfg;
        rd_tr[cid].cid = cid;
        rd_tr[cid].tid = ++rd_tid_cnt;
        rd_t2c[rd_tid_cnt] = cid;
    end
    else begin
        `uvm_fatal("put_ar_linedata", "new cid has exists")
    end

    rd_tr[cid].put_ar_linedata(line);

    set_ar_rand_mode(rd_tr[cid].tr);


    rd_tr[cid].tr.randomize(); 

    return cid;
endfunction


function void svk_axi_slave_database::set_w_rand_mode(svk_axi_transaction tr, bit aw_vld);
    tr.dir.rand_mode(0);
    tr.length.rand_mode(0);
    tr.size.rand_mode(0);
    tr.burst.rand_mode(0);
    tr.lock.rand_mode(0);
    tr.cache.rand_mode(0);
    tr.prot.rand_mode(0);
    tr.resp.rand_mode(0);
    tr.wstrb.rand_mode(0);
    tr.data.rand_mode(0);
    tr.addr.rand_mode(0);
    tr.id.rand_mode(0);
    tr.auser.rand_mode(0);
    tr.ruser.rand_mode(0);
    tr.wuser.rand_mode(0);
    tr.buser.rand_mode(0);
    tr.qos.rand_mode(0);
    tr.region.rand_mode(0);
    tr.need_resp.rand_mode(0);
    tr.awready_delay.rand_mode(0);
    tr.awvalid_delay.rand_mode(0);
    tr.arready_delay.rand_mode(0);
    tr.arvalid_delay.rand_mode(0);
    if(aw_vld == 1)
        tr.wready_delay.rand_mode(0);
    else
        tr.wready_delay.rand_mode(1);
    tr.wvalid_delay.rand_mode(0);
    tr.rready_delay.rand_mode(0);
    tr.rvalid_delay.rand_mode(0);
    tr.bvalid_delay.rand_mode(0);
    tr.bready_delay.rand_mode(0);

    tr.con_burst.constraint_mode(0);
    tr.con_lock.constraint_mode(0);
    tr.con_cache.constraint_mode(0);
    tr.con_wstrb.constraint_mode(0);
    tr.con_data.constraint_mode(0);
    tr.con_resp.constraint_mode(0);
    tr.con_length.constraint_mode(0);
    tr.con_wuser.constraint_mode(0);
    tr.con_ruser.constraint_mode(0);
    tr.con_size.constraint_mode(0);
    tr.con_addr.constraint_mode(0);
    tr.con_buser.constraint_mode(0);
    tr.con_awready_delay.constraint_mode(0);
    tr.con_awvalid_delay.constraint_mode(0);
    tr.con_arready_delay.constraint_mode(0);
    tr.con_arvalid_delay.constraint_mode(0);
    if(aw_vld == 1)
        tr.con_wready_delay.constraint_mode(0);
    else
        tr.con_wready_delay.constraint_mode(1);
    tr.con_wvalid_delay.constraint_mode(0);
    tr.con_bready_delay.constraint_mode(0);
    tr.con_bvalid_delay.constraint_mode(0);
    tr.con_rready_delay.constraint_mode(0);
    tr.con_rvalid_delay.constraint_mode(0);
endfunction

function int svk_axi_slave_database::put_w_linedata(svk_w_linedata line);
    int cid;
    int delay;

    cid = get_w_cid(line.id, svk_axi_dec::SLV_ALLOCATE_NEW);
    line.cid = cid;
    if(!wr_tr.exists(cid))begin
        wr_tr[cid] = svk_axi_transaction_wrap::type_id::create("tr");
        wr_tr[cid].tr.cfg = cfg;
        wr_tr[cid].cid = cid;
        wr_tr[cid].tid = ++wr_tid_cnt;
        wr_t2c[wr_tid_cnt] = cid;

        wr_tr[cid].put_w_linedata(line);

        set_aw_rand_mode(wr_tr[cid].tr);
        wr_tr[cid].tr.length = svk_axi_dec::LENGTH_256;
        wr_tr[cid].tr.randomize();
    end
    else begin
        wr_tr[cid].put_w_linedata(line);
    end






    return cid;
endfunction

function void svk_axi_slave_database::update_awready_status(bit[`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::wr_delay_event_enum delay_event);
    int cid;

    if(svk_axi_dec::WT_AW_HANDSHAKE_EVENT == delay_event)begin 
        cid = get_aw_cid(id, svk_axi_dec::SLV_GET_REQ_WITH_MAX_TID);
        wr_tr[cid].ready_status = svk_axi_dec::FINISH;

    end



endfunction

function void svk_axi_slave_database::update_wready_status(bit[`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::wr_delay_event_enum delay_event);
    int cid;

    if(svk_axi_dec::WT_W_HANDSHAKE_EVENT == delay_event)begin 
        cid = get_w_cid(id, svk_axi_dec::SLV_GET_REQ_WITH_MAX_TID);
        if(wr_tr[cid].last_finish == 1'b1)
            wr_tr[cid].wready_status = svk_axi_dec::FINISH;
        else
            wr_tr[cid].wready_status = svk_axi_dec::NOT_START;

    end



endfunction

function void svk_axi_slave_database::update_arready_status(bit[`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::rd_delay_event_enum delay_event);
    int cid;

    if(svk_axi_dec::RD_AR_HANDSHAKE_EVENT == delay_event)begin
        cid = get_ar_cid(id, svk_axi_dec::SLV_GET_REQ_WITH_MAX_TID);
        rd_tr[cid].ready_status = svk_axi_dec::FINISH;

    end



endfunction

function void svk_axi_slave_database::update_bvalid_status(bit[`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::wr_delay_event_enum delay_event);
    int cid;

    if(cfg.m_bvalid_delay_event == delay_event)begin
        cid = get_b_cid(id, svk_axi_dec::SLV_VALID_NOTSTART_WITH_MIN_TID);
        wr_tr[cid].valid_status = svk_axi_dec::WAITING;
        if(wr_tr[cid].tr.bvalid_delay == 0)
            wr_tr[cid].valid_status = svk_axi_dec::TIME_OUT;
    end

    if(svk_axi_dec::WT_B_HANDSHAKE_EVENT == delay_event)begin
        cid = get_b_cid(id, svk_axi_dec::SLV_VALID_TIMEOUT);
        wr_tr[cid].valid_status = svk_axi_dec::FINISH;
        wr_tr[cid].valid_wait_cycle = 33'h1_ffff_ffff;
    end

endfunction

function void svk_axi_slave_database::update_rvalid_status(bit[`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::rd_delay_event_enum delay_event);
    int cid;

    if(cfg.m_first_rvalid_delay_event == delay_event)begin
        cid = get_r_cid(id, svk_axi_dec::SLV_VALID_NOTSTART_WITH_MIN_TID);
        rd_tr[cid].valid_status = svk_axi_dec::WAITING;
        if(rd_tr[cid].tr.rvalid_delay[rd_tr[cid].idx] == 0)
            rd_tr[cid].valid_status = svk_axi_dec::TIME_OUT;
    end

    if(svk_axi_dec::RD_R_HANDSHAKE_EVENT == delay_event)begin
        cid = get_r_cid(id, svk_axi_dec::SLV_VALID_TIMEOUT);
        rd_tr[cid].valid_status = svk_axi_dec::FINISH;
        rd_tr[cid].valid_wait_cycle = 33'h1_ffff_ffff;
    end

    if(cfg.m_next_rvalid_delay_event == delay_event)begin
        cid = get_r_cid(id, svk_axi_dec::SLV_NEXT_RVALID);
        if(cid != -1)begin
            rd_tr[cid].valid_status = svk_axi_dec::WAITING;
            if(rd_tr[cid].tr.rvalid_delay[rd_tr[cid].idx] == 0)begin
                rd_tr[cid].valid_status = svk_axi_dec::TIME_OUT;
            end
        end
    end

endfunction

function void svk_axi_slave_database::update_rd_status(svk_axi_dec::rd_event_struct e);
    update_arready_status(e.id, e.rd_event);
    update_rvalid_status(e.id, e.rd_event);
endfunction

function void svk_axi_slave_database::update_wr_status(svk_axi_dec::wr_event_struct e);
    update_awready_status(e.id, e.wr_event);
    update_wready_status(e.id, e.wr_event);
    update_bvalid_status(e.id, e.wr_event);
endfunction

function int svk_axi_slave_database::get_aw_cid(bit[`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::cid_status_enum cid_status);
    int qi[$];
    int cid;
    int tid;
    int tid_q[$];

    case(cid_status) inside
        svk_axi_dec::SLV_ALLOCATE_NEW:begin
            case(cfg.version)
                svk_axi_dec::AXI3:begin
                    qi = wr_tr.find_index with ((item.tr.id & cfg.ID_MASK) == (id & cfg.ID_MASK) && item.w_vld == 1 && item.aw_vld == 0);
                    if(qi.size > 0)begin
                        cid = get_cid_with_min_tid(wr_tr, qi, wr_t2c);
                        return cid;
                    end
                    else begin
                        if(wr_cid_q.size == 0)
                            `uvm_fatal("svk_axi_slave_database", "write outstanding > cfg.wr_osd")
                        cid = wr_cid_q.pop_front();
                        if(wr_cid_q.size == 1)
                            last_wr_cid = cid;
                        return cid;
                    end
                end
                svk_axi_dec::AXI4:begin
                    qi = wr_tr.find_index with (item.w_vld == 1 && item.aw_vld == 0);
                    if(qi.size > 0)begin
                        cid = get_cid_with_min_tid(wr_tr, qi, wr_t2c);
                        return cid;
                    end
                    else begin
                        if(rd_cid_q.size == 0)
                            `uvm_fatal("svk_axi_slave_database", "write outstanding > cfg.wr_osd")
                        cid = wr_cid_q.pop_front();
                        if(wr_cid_q.size == 1)
                            last_wr_cid = cid;
                        return cid;
                    end
                end
            endcase
        end
        svk_axi_dec::SLV_GET_REQ_WITH_MAX_TID:begin
            qi = wr_tr.find_index with ((item.tr.id & cfg.ID_MASK) == (id & cfg.ID_MASK) && item.aw_vld == 1);
            cid = get_cid_with_max_tid(wr_tr, qi, wr_t2c);
            if(cid != -1)
                return cid;
            else
                `uvm_fatal("svk_axi_slave_database", $sformatf("The number of data be getted not one: %0d", qi.size))
        end
        default:
            `uvm_fatal("svk_axi_slave_database", $sformatf("cid status is error:%s", cid_status.name))
    endcase
endfunction

function int svk_axi_slave_database::get_w_cid(bit[`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::cid_status_enum cid_status);
    int qi[$];
    int cid;
    int tid;
    int tid_q[$];

    case(cid_status) inside
        svk_axi_dec::SLV_ALLOCATE_NEW:begin
            case(cfg.version)
                svk_axi_dec::AXI3:begin
                    qi = wr_tr.find_index with ((item.tr.id & cfg.ID_MASK) == (id & cfg.ID_MASK) && item.last_finish == 0);
                    if(qi.size > 0)begin
                        cid = get_cid_with_min_tid(wr_tr, qi, wr_t2c);
                        return cid;
                    end
                    else begin
                        if(rd_cid_q.size == 0)
                            `uvm_fatal("svk_axi_slave_database", "write outstanding > cfg.wr_osd")
                        cid = wr_cid_q.pop_front();
                        if(wr_cid_q.size == 1)
                            last_wr_cid = cid;
                        return cid;
                    end
                end
                svk_axi_dec::AXI4:begin

                    qi = wr_tr.find_index with (item.w_vld == 1'b1 && item.last_finish == 0);
                    if(qi.size > 1)begin
                        `uvm_fatal("svk_axi_slave_database", $sformatf("more than one w burst is sending: %0d", qi.size))
                    end
                    else if(qi.size == 1)begin
                        return qi[0];
                    end
                    else begin

                        qi = wr_tr.find_index with (item.w_vld == 1'b0 && item.aw_vld == 1'b1);
                        if(qi.size > 0)begin
                            cid = get_cid_with_min_tid(wr_tr, qi, wr_t2c);
                            return cid;
                        end
                        else begin
                            cid = wr_cid_q.pop_front();
                            if(wr_cid_q.size == 1)
                                last_wr_cid = cid;
                            return cid;
                        end
                    end
                end
            endcase
        end
        svk_axi_dec::SLV_GET_REQ_WITH_MAX_TID:begin
            case(cfg.version)
                svk_axi_dec::AXI3:begin
                    qi = wr_tr.find_index with ((item.tr.id & cfg.ID_MASK) == (id & cfg.ID_MASK) && item.w_vld == 1);
                    cid = get_cid_with_max_tid(wr_tr, qi, wr_t2c);
                    if(cid != -1)
                        return cid;
                    else
                        `uvm_fatal("svk_axi_slave_database", $sformatf("The number of data be getted not one: %0d", qi.size))
                end
                svk_axi_dec::AXI4:begin
                    qi = wr_tr.find_index with (item.w_vld == 1);
                    cid = get_cid_with_max_tid(wr_tr, qi, wr_t2c);
                    if(cid != -1)
                        return cid;
                    else
                        `uvm_fatal("svk_axi_slave_database", $sformatf("The number of data be getted not one: %0d", qi.size))
                end
            endcase
        end
        default:
            `uvm_fatal("svk_axi_slave_database", $sformatf("cid status is error:%s", cid_status.name))
    endcase
endfunction

function int svk_axi_slave_database::get_ar_cid(bit[`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::cid_status_enum cid_status);
    int qi[$];
    int cid;
    int tid;
    int tid_q[$];

    case(cid_status) inside
        svk_axi_dec::SLV_ALLOCATE_NEW:begin 
            cid = rd_cid_q.pop_front();
            if(rd_cid_q.size == 1)
                last_rd_cid = cid;
            return cid;
        end
        svk_axi_dec::SLV_GET_REQ_WITH_MAX_TID:begin
            qi = rd_tr.find_index with ((item.tr.id & cfg.ID_MASK) == (id & cfg.ID_MASK));
            cid = get_cid_with_max_tid(rd_tr, qi, rd_t2c);
            if(cid != -1)
                return cid;
            else
                `uvm_fatal("svk_axi_slave_database", $sformatf("The number of data be getted not one: %0d", qi.size))
        end
        default:
            `uvm_fatal("svk_axi_slave_database", $sformatf("cid status is error:%s", cid_status.name))
    endcase
endfunction

function int svk_axi_slave_database::get_b_cid(bit[`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::cid_status_enum cid_status);
    int qi[$];
    int cid;
    int tid;
    int tid_q[$];

    case(cid_status)
        svk_axi_dec::SLV_VALID_NOTSTART_WITH_MIN_TID:begin 
            if(cfg.version == svk_axi_dec::AXI4 && cfg.bvalid_delay_event == svk_axi_dec::BV_LAST_W_HANDSHAKE_EVENT)begin
                qi = wr_tr.find_index with (item.last_finish == 1 && item.valid_status == svk_axi_dec::NOT_START);
                if(qi.size == 1)
                    return qi[0];
                else
                    `uvm_fatal("svk_axi_slave_database", $sformatf("The number of data be getted not one: %0d", qi.size))
            end
            else begin
                qi = wr_tr.find_index with ((item.tr.id & cfg.ID_MASK) == (id & cfg.ID_MASK) && item.valid_status == svk_axi_dec::NOT_START);
                cid = get_cid_with_min_tid(wr_tr, qi, wr_t2c);
                if(cid != -1)
                    return cid;
                else
                    `uvm_fatal("svk_axi_slave_database", $sformatf("The number of data be getted not one: %0d", qi.size))
            end
        end
        svk_axi_dec::SLV_VALID_TIMEOUT:begin
            qi = wr_tr.find_index with ((item.tr.id & cfg.ID_MASK) == (id & cfg.ID_MASK) && item.valid_status == svk_axi_dec::TIME_OUT);
            cid = get_cid_with_min_tid(wr_tr, qi, wr_t2c);
            if(cid != -1)
                return cid;
            else
                `uvm_fatal("svk_axi_slave_database", $sformatf("not have B svk_axi_dec::TIME_OUT"))
        end
        default:
            `uvm_fatal("svk_axi_slave_database", $sformatf("cid status is error:%s", cid_status.name))
    endcase
endfunction

function int svk_axi_slave_database::get_r_cid(bit[`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::cid_status_enum cid_status);
    int qi[$];
    int cid;
    int tid;
    int tid_q[$];

    case(cid_status)
        svk_axi_dec::SLV_VALID_NOTSTART_WITH_MIN_TID:begin
            qi = rd_tr.find_index with ((item.tr.id & cfg.ID_MASK) == (id & cfg.ID_MASK) && item.valid_status == svk_axi_dec::NOT_START);
            cid = get_cid_with_min_tid(rd_tr, qi, rd_t2c);
            if(cid != -1)
                return cid;
            else
                `uvm_fatal("svk_axi_slave_database", $sformatf("The number of data be getted not one: %0d", qi.size))
        end
        svk_axi_dec::SLV_NEXT_RVALID:begin
            qi = rd_tr.find_index with ((item.tr.id & cfg.ID_MASK) == (id & cfg.ID_MASK) && (item.valid_status == svk_axi_dec::FINISH) && item.last_finish == 0);
            if(qi.size == 1)
                return qi[0];
            else
                return -1;
        end
        svk_axi_dec::SLV_VALID_TIMEOUT:begin
            qi = rd_tr.find_index with ((item.tr.id & cfg.ID_MASK) == (id & cfg.ID_MASK) && item.valid_status == svk_axi_dec::TIME_OUT);
            cid = get_cid_with_min_tid(rd_tr, qi, rd_t2c);
            if(cid != -1)
                return cid;
            else
                `uvm_fatal("svk_axi_slave_database", $sformatf("not have R svk_axi_dec::TIME_OUT"))
        end
        default:
            `uvm_fatal("svk_axi_slave_database", $sformatf("cid status is error:%s", cid_status.name))
    endcase
endfunction

function svk_axi_transaction svk_axi_slave_database::get_wr_tr();
    svk_axi_transaction      tr;
    int                  qi[$];
    int                  cid;


    qi = wr_tr.find_index with (item.valid_status == svk_axi_dec::FINISH && item.last_finish);

    if(qi.size > 1)
        `uvm_fatal("svk_axi_slave_database", $sformatf("more than one cmd are finished at a time: %0d", qi.size))
    else if(qi.size == 1) begin
        cid = qi[0];
        tr = svk_axi_transaction::type_id::create("tr");
        tr.copy(wr_tr[cid].tr);
        tr.set_id_info(wr_tr[cid].tr);

        wr_t2c.delete(wr_tr[cid].tid);
        wr_tr.delete(cid);
        wr_cid_q.push_back(cid);
    end

    return tr;
endfunction

function svk_axi_transaction svk_axi_slave_database::get_rd_tr();
    svk_axi_transaction         tr;
    int                     cid;
    int                     qi[$];

    qi = rd_tr.find_index with (item.valid_status == svk_axi_dec::FINISH && item.last_finish);

    if(qi.size > 1)
        `uvm_fatal("svk_axi_slave_database", $sformatf("more than one cmd are finished at a time: %0d", qi.size))
    else if(qi.size == 1)begin
        cid = qi[0];
        tr = svk_axi_transaction::type_id::create("tr");
        tr.copy(rd_tr[cid].tr);
        tr.set_id_info(rd_tr[cid].tr);

        rd_t2c.delete(rd_tr[cid].tid);
        rd_tr.delete(cid);
        rd_cid_q.push_back(cid);
    end

    return tr;
endfunction


function void svk_axi_slave_database::tick();
    foreach(wr_tr[cid])begin
        if(wr_tr[cid].valid_status == svk_axi_dec::WAITING)begin
            --wr_tr[cid].tr.bvalid_delay;
            if(wr_tr[cid].tr.bvalid_delay == 0 && wr_tr[cid].valid_status == svk_axi_dec::WAITING)begin
                wr_tr[cid].valid_status = svk_axi_dec::TIME_OUT;
            end
        end
    end

    foreach(rd_tr[cid])begin
        if(rd_tr[cid].valid_status == svk_axi_dec::WAITING)begin
            --rd_tr[cid].tr.rvalid_delay[rd_tr[cid].idx];
            if(rd_tr[cid].tr.rvalid_delay[rd_tr[cid].idx] == 0)begin
                rd_tr[cid].valid_status = svk_axi_dec::TIME_OUT;
            end
        end
    end

    foreach(wr_tr[cid])begin

        if(wr_tr[cid].valid_wait_cycle != 33'h1_ffff_ffff && wr_tr[cid].valid_status == svk_axi_dec::TIME_OUT)begin
            ++wr_tr[cid].valid_wait_cycle;
            if(wr_tr[cid].valid_wait_cycle > cfg.ready_timeout_time)
                `uvm_error("post_drive", $sformatf("b channel:id=%0h has time out timeout_time=%0d", wr_tr[cid].tr.id, cfg.ready_timeout_time))
        end
    end
    foreach(rd_tr[cid])begin

        if(rd_tr[cid].valid_wait_cycle != 33'h1_ffff_ffff && rd_tr[cid].valid_status == svk_axi_dec::TIME_OUT)begin
            ++rd_tr[cid].valid_wait_cycle;
            if(rd_tr[cid].valid_wait_cycle > cfg.ready_timeout_time)
                `uvm_error("post_drive", $sformatf("r channel:id=%0h has time out timeout_time=%0d", rd_tr[cid].tr.id, cfg.ready_timeout_time))
        end
    end






endfunction

function int svk_axi_slave_database::get_wr_osd();
    if(wr_cid_q.size() == 0)
        return 0;
    else
        return wr_cid_q.size() - 1;
endfunction

function int svk_axi_slave_database::get_rd_osd();
    if(rd_cid_q.size() == 0)
        return 0;
    else
        return rd_cid_q.size() - 1;
endfunction

`endif

