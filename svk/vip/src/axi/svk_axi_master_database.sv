/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_AXI_MASTER_DATABASE__SV
`define SVK_AXI_MASTER_DATABASE__SV

class svk_axi_master_database extends svk_axi_database;
    svk_axi_agent_cfg           cfg;
    int                     rready_delay=0;
    int                     bready_delay=0;


    svk_axi_scheduler           sch;
    int                     aw_can_trigger = 0;
    int                     ar_can_trigger = 0;
    int                     w_can_trigger  = 0;

    extern function new(svk_axi_agent_cfg cfg);

    extern function svk_aw_linedata get_aw_linedata();
    extern function svk_w_linedata  get_w_linedata();
    extern function svk_ar_linedata get_ar_linedata();
    extern function void put_b_linedata(svk_b_linedata line);
    extern function void put_r_linedata(svk_r_linedata line);

    extern function void load_bready_delay(bit [`SVK_AXI_ID_WIDTH-1:0] id);
    extern function void load_rready_delay(bit [`SVK_AXI_ID_WIDTH-1:0] id, int idx);

    extern function void update_wr_status(svk_axi_dec::wr_event_struct e);
    extern function void update_rd_status(svk_axi_dec::rd_event_struct e);

    extern function void update_awvalid_status(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::wr_delay_event_enum delay_event);
    extern function void update_wvalid_status(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::wr_delay_event_enum delay_event);
    extern function void update_arvalid_status(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::rd_delay_event_enum delay_event);
    extern function void update_bready_status(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::wr_delay_event_enum delay_event);
    extern function void update_rready_status(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::rd_delay_event_enum delay_event);

    extern function int  get_aw_cid(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::cid_status_enum cid_status);
    extern function int  get_w_cid(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::cid_status_enum cid_status);
    extern function int  get_ar_cid(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::cid_status_enum cid_status);
    extern function int  get_b_cid(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::cid_status_enum cid_status);
    extern function int  get_r_cid(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::cid_status_enum cid_status);

    extern function void put_wr_tr(svk_axi_transaction tr);
    extern function void put_rd_tr(svk_axi_transaction tr);
    extern function svk_axi_transaction get_wr_tr();
    extern function svk_axi_transaction get_rd_tr();

    extern function void tick();

    extern function int  get_wr_osd();
    extern function int  get_rd_osd();
endclass


function svk_axi_master_database::new(svk_axi_agent_cfg cfg);
    super.new();
    this.cfg = cfg;
    for(int cid=0; cid<cfg.wr_osd; ++cid)
        wr_cid_q.push_back(cid);
    for(int cid=0; cid<cfg.rd_osd; ++cid)
        rd_cid_q.push_back(cid);

    sch = new(cfg.wr_osd);
endfunction

function svk_aw_linedata svk_axi_master_database::get_aw_linedata();

    int cid;
    int qi[$];

    qi = wr_tr.find_index with(item.valid_status == svk_axi_dec::TIME_OUT);
    cid = get_cid_with_min_tid(wr_tr, qi, wr_t2c);
    if(cid != -1 && (cfg.data_before_addr == 0 || (cfg.data_before_addr == 1 && wr_tr[cid].w_vld)))
        return wr_tr[cid].get_aw_linedata();
    else
        return null;
endfunction

function svk_w_linedata svk_axi_master_database::get_w_linedata();
    bit [`SVK_AXI_MAX_OSD-1:0] req;
    bit [`SVK_AXI_MAX_OSD-1:0] grant_tmp;
    bit                    grant[`SVK_AXI_MAX_OSD-1:0];
    int                    qi[$];
    int                    cid;
    int                    tid_q[$];

    if(cfg.wr_interleave_en)begin

        qi = wr_tr.find_index with (item.wvalid_status == svk_axi_dec::TIME_OUT);
        foreach(qi[i])begin
            bit [`SVK_AXI_ID_WIDTH-1:0] id;
            int                     same_id_cids[$];
            int                     small_tid_cids[$];
            int                     min_tid_cid;

            id = wr_tr[qi[i]].tr.id;
            same_id_cids = wr_tr.find_index with((item.tr.id & cfg.ID_MASK) == (id & cfg.ID_MASK));
            min_tid_cid = get_cid_with_min_tid(wr_tr, same_id_cids, wr_t2c);
            small_tid_cids = wr_tr.find_index with(item.tid < wr_tr[min_tid_cid].tid && item.last_finish == 0);

            if(id == wr_tr[min_tid_cid].tr.id)begin
                bit all_has_send = 1;
                foreach(small_tid_cids[j])begin
                    if(wr_tr[small_tid_cids[j]].idx == 0)begin
                        all_has_send = 0;
                        break;
                    end
                end
                if(all_has_send && small_tid_cids.size < cfg.wr_interleave_depth)
                    if(cfg.data_before_addr || (!cfg.data_before_addr && wr_tr[min_tid_cid].aw_vld))
                        return wr_tr[min_tid_cid].get_w_linedata();
            end
        end
        return null;

















    end
    else begin

        qi = wr_tr.find_index with (item.wvalid_status == svk_axi_dec::TIME_OUT && item.idx != 0 && item.last_finish == 0);
        if(qi.size > 1)
            `uvm_fatal("svk_axi_master_database", $sformatf("wr_interleave_en = 0, should only one burst is sending:size=%0d", qi.size))
        else if(qi.size == 1)begin
            cid = qi[0];
            return wr_tr[cid].get_w_linedata();
        end
        else begin


            qi = wr_tr.find_index with(item.wvalid_status == svk_axi_dec::TIME_OUT && item.idx == 0 && item.last_finish == 0);
            cid = get_cid_with_min_tid(wr_tr, qi, wr_t2c);
            if(cid != -1)
                return wr_tr[cid].get_w_linedata();
            else
                return null;

        end
    end

endfunction

function svk_ar_linedata svk_axi_master_database::get_ar_linedata();

    int cid;
    int qi[$];

    qi = rd_tr.find_index with(item.valid_status == svk_axi_dec::TIME_OUT);
    cid = get_cid_with_min_tid(rd_tr, qi, rd_t2c);
    if(cid != -1)
        return rd_tr[cid].get_ar_linedata();
    else
        return null;

endfunction

function void svk_axi_master_database::put_b_linedata(svk_b_linedata line);
    line.cid = get_b_cid(line.id, svk_axi_dec::MST_GET_RSP_WITH_MIN_TID);
    if(line.cid == -1)
        `uvm_fatal("cid", "cid = -1")
    wr_tr[line.cid].put_b_linedata(line);
endfunction

function void svk_axi_master_database::put_r_linedata(svk_r_linedata line);
    line.cid = get_r_cid(line.id, svk_axi_dec::MST_GET_RSP_WITH_MIN_TID);
    if(line.cid == -1)
        `uvm_fatal("cid", "cid = -1")
    rd_tr[line.cid].put_r_linedata(line);
endfunction


function void svk_axi_master_database::load_bready_delay(bit [`SVK_AXI_ID_WIDTH-1:0] id);
    int cid;

    cid = get_b_cid(id, svk_axi_dec::MST_GET_RSP_WITH_MIN_TID);
    if(cid == -1)
        rready_delay = 0;
    else begin
        bready_delay = wr_tr[cid].tr.bready_delay;

    end

endfunction


function void svk_axi_master_database::load_rready_delay(bit [`SVK_AXI_ID_WIDTH-1:0] id, int idx);
    int cid;

    cid = get_r_cid(id, svk_axi_dec::MST_GET_RSP_WITH_MIN_TID);
    if(cid == -1)
        rready_delay = 0;
    else begin
        rready_delay = rd_tr[cid].tr.rready_delay[idx];

    end

endfunction

function void svk_axi_master_database::update_awvalid_status(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::wr_delay_event_enum delay_event);
    int cid;

    if(cfg.m_awvalid_delay_event == delay_event)begin
        --aw_can_trigger;
        cid = get_aw_cid(id, svk_axi_dec::MST_VALID_NOTSTART_WITH_MIN_TID);
        if(cid != -1)begin
            wr_tr[cid].valid_status = svk_axi_dec::WAITING;
            ++aw_can_trigger;

            if(wr_tr[cid].tr.awvalid_delay == 0)begin
                wr_tr[cid].valid_status = svk_axi_dec::TIME_OUT;
            end
        end
    end

    if(svk_axi_dec::WT_AW_HANDSHAKE_EVENT == delay_event)begin
        cid = get_aw_cid(id, svk_axi_dec::MST_VALID_TIMEOUT);
        wr_tr[cid].valid_status = svk_axi_dec::FINISH;
        wr_tr[cid].valid_wait_cycle = 33'h1_ffff_ffff;
    end

endfunction

function void svk_axi_master_database::update_wvalid_status(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::wr_delay_event_enum delay_event);
    int cid;

    if(cfg.m_first_wvalid_delay_event == delay_event)begin
        --w_can_trigger;
        cid = get_w_cid(id, svk_axi_dec::MST_VALID_NOTSTART_WITH_MIN_TID);
        if(cid != -1)begin
            wr_tr[cid].wvalid_status = svk_axi_dec::WAITING;
            ++w_can_trigger;
            if(wr_tr[cid].tr.wvalid_delay[wr_tr[cid].idx] == 0)begin
                wr_tr[cid].wvalid_status = svk_axi_dec::TIME_OUT;
            end
        end
    end

    if(svk_axi_dec::WT_W_HANDSHAKE_EVENT == delay_event)begin
        cid = get_w_cid(id, svk_axi_dec::MST_VALID_TIMEOUT);
        if(cid != -1)begin
            wr_tr[cid].wvalid_status = svk_axi_dec::FINISH;
            wr_tr[cid].wvalid_wait_cycle = 33'h1_ffff_ffff;
        end


    end

    if(cfg.m_next_wvalid_delay_event == delay_event)begin
        cid = get_w_cid(id, svk_axi_dec::MST_NEXT_WVALID);
        if(cid != -1)begin
            wr_tr[cid].wvalid_status = svk_axi_dec::WAITING;
            if(wr_tr[cid].tr.wvalid_delay[wr_tr[cid].idx] == 0)begin
                wr_tr[cid].wvalid_status = svk_axi_dec::TIME_OUT;
            end
        end
    end

endfunction

function void svk_axi_master_database::update_arvalid_status(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::rd_delay_event_enum delay_event);
    int cid;

    if(cfg.m_arvalid_delay_event == delay_event)begin
        --ar_can_trigger;
        cid = get_ar_cid(id, svk_axi_dec::MST_VALID_NOTSTART_WITH_MIN_TID);
        if(cid != -1)begin
            rd_tr[cid].valid_status = svk_axi_dec::WAITING;
            ++ar_can_trigger;
            if(rd_tr[cid].tr.arvalid_delay == 0)begin
                rd_tr[cid].valid_status = svk_axi_dec::TIME_OUT;
            end
        end
    end

    if(svk_axi_dec::RD_AR_HANDSHAKE_EVENT == delay_event)begin
        cid = get_ar_cid(id, svk_axi_dec::MST_VALID_TIMEOUT);
        rd_tr[cid].valid_status = svk_axi_dec::FINISH;
        rd_tr[cid].valid_wait_cycle = 33'h1_ffff_ffff;
    end

endfunction

function void svk_axi_master_database::update_bready_status(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::wr_delay_event_enum delay_event);
    int cid;

    if(svk_axi_dec::WT_B_HANDSHAKE_EVENT == delay_event)begin
        cid = get_b_cid(id, svk_axi_dec::MST_GET_RSP_WITH_MIN_TID);
        wr_tr[cid].ready_status = svk_axi_dec::FINISH;

    end



endfunction

function void svk_axi_master_database::update_rready_status(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::rd_delay_event_enum delay_event);
    int cid;

    if(svk_axi_dec::RD_R_HANDSHAKE_EVENT == delay_event)begin
        cid = get_r_cid(id, svk_axi_dec::MST_GET_RSP_WITH_MIN_TID);
        if(rd_tr[cid].last_finish)begin
            rd_tr[cid].ready_status = svk_axi_dec::FINISH;

        end
        else begin
            rd_tr[cid].ready_status = svk_axi_dec::NOT_START;

        end
    end



endfunction

function int svk_axi_master_database::get_aw_cid(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::cid_status_enum cid_status);
    int qi[$];
    int tid;
    int cid;
    int tid_q[$];

    case(cid_status)
        svk_axi_dec::MST_VALID_NOTSTART_WITH_MIN_TID:begin
            qi = wr_tr.find_index with (item.valid_status == svk_axi_dec::NOT_START);
            cid = get_cid_with_min_tid(wr_tr, qi, wr_t2c);
            if(cid != -1)
                return cid;
            else
                return -1;
        end
        svk_axi_dec::MST_VALID_TIMEOUT:begin
            qi = wr_tr.find_index with ((item.tr.id & cfg.ID_MASK) == (id & cfg.ID_MASK) && item.valid_status == svk_axi_dec::TIME_OUT);
            cid = get_cid_with_min_tid(wr_tr, qi, wr_t2c);
            if(cid != -1)
                return cid;
            else
                `uvm_fatal("svk_axi_master_database", $sformatf("not have AW svk_axi_dec::TIME_OUT"))
        end
        default:
            `uvm_fatal("svk_axi_master_database", $sformatf("cid status is error:%s", cid_status.name))
    endcase
endfunction

function int svk_axi_master_database::get_w_cid(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::cid_status_enum cid_status);
    int qi[$];
    int tid;
    int cid;
    int tid_q[$];

    case(cid_status)
        svk_axi_dec::MST_VALID_NOTSTART_WITH_MIN_TID:begin
            case(cfg.version)
                svk_axi_dec::AXI3:begin
                    qi = wr_tr.find_index with (item.wvalid_status == svk_axi_dec::NOT_START);
                    cid = get_cid_with_min_tid(wr_tr, qi, wr_t2c);
                    if(cid != -1)
                        return cid;
                    else
                        return -1;
                end
                svk_axi_dec::AXI4:begin
                    qi = wr_tr.find_index with (item.wvalid_status != svk_axi_dec::NOT_START && item.last_finish == 0);
                    if(qi.size == 0)begin
                        qi = wr_tr.find_index with (item.wvalid_status == svk_axi_dec::NOT_START);
                        cid = get_cid_with_min_tid(wr_tr, qi, wr_t2c);
                        if(cid != -1)
                            return cid;
                        else
                            return -1;
                    end
                    else begin
                        return -1;
                    end
                end
            endcase
        end
        svk_axi_dec::MST_NEXT_WVALID:begin
            case(cfg.version)
                svk_axi_dec::AXI3:begin
                    qi = wr_tr.find_index with ((item.tr.id & cfg.ID_MASK) == (id & cfg.ID_MASK) && (item.wvalid_status == svk_axi_dec::TIME_OUT || item.wvalid_status == svk_axi_dec::FINISH) && item.last_finish == 0 && item.idx != 0);
                    if(qi.size == 1)
                        return qi[0];
                    else if(qi.size > 1)
                        `uvm_fatal("svk_axi_master_database", $sformatf("more than one packet with id=%0d is being sent", id))
                    else
                        return -1;
                end
                svk_axi_dec::AXI4:begin
                    qi = wr_tr.find_index with ((item.wvalid_status == svk_axi_dec::TIME_OUT || item.wvalid_status == svk_axi_dec::FINISH) && item.last_finish == 0 && item.idx != 0);
                    if(qi.size == 1)
                        return qi[0];
                    else if(qi.size > 1)
                        `uvm_fatal("svk_axi_master_database", $sformatf("more than one packet is being sent"))
                    else
                        return -1;
                end
            endcase
        end
        svk_axi_dec::MST_VALID_TIMEOUT:begin
            case(cfg.version)
                svk_axi_dec::AXI3:begin
                    qi = wr_tr.find_index with ((item.tr.id & cfg.ID_MASK) == (id & cfg.ID_MASK) && item.wvalid_status == svk_axi_dec::TIME_OUT);
                    cid = get_cid_with_min_tid(wr_tr, qi, wr_t2c);
                    if(cid != -1)
                        return cid;
                    else
                        return -1;
                end
                svk_axi_dec::AXI4:begin
                    qi = wr_tr.find_index with (item.wvalid_status == svk_axi_dec::TIME_OUT);
                    if(qi.size == 1)
                        return qi[0];
                    else
                        return -1;
                end
            endcase
        end
        default:
            `uvm_fatal("svk_axi_master_database", $sformatf("cid status is error:%s", cid_status.name))
    endcase
endfunction

function int svk_axi_master_database::get_ar_cid(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::cid_status_enum cid_status);
    int qi[$];
    int tid;
    int cid;
    int tid_q[$];

    case(cid_status) inside
        svk_axi_dec::MST_VALID_NOTSTART_WITH_MIN_TID:begin
            qi = rd_tr.find_index with (item.valid_status == svk_axi_dec::NOT_START);
            cid = get_cid_with_min_tid(rd_tr, qi, rd_t2c);
            if(cid != -1)
                return cid;
            else
                return -1;
        end
        svk_axi_dec::MST_VALID_TIMEOUT:begin
            qi = rd_tr.find_index with ((item.tr.id & cfg.ID_MASK) == (id & cfg.ID_MASK) && item.valid_status == svk_axi_dec::TIME_OUT);
            cid = get_cid_with_min_tid(rd_tr, qi, rd_t2c);
            if(cid != -1)
                return cid;
            else
                `uvm_fatal("svk_axi_master_database", $sformatf("not have AR svk_axi_dec::TIME_OUT"))
        end
        default:
            `uvm_fatal("svk_axi_master_database", $sformatf("cid status is error:%s", cid_status.name))
    endcase
endfunction

function int svk_axi_master_database::get_b_cid(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::cid_status_enum cid_status);
    int qi[$];
    int tid;
    int cid;
    int tid_q[$];

    case(cid_status) inside
        svk_axi_dec::MST_GET_RSP_WITH_MIN_TID:begin
            qi = wr_tr.find_index with ((item.tr.id & cfg.ID_MASK) == (id & cfg.ID_MASK) && item.valid_status == svk_axi_dec::FINISH &&
                                        item.wvalid_status == svk_axi_dec::FINISH && item.ready_status == svk_axi_dec::NOT_START);
            cid = get_cid_with_min_tid(wr_tr, qi, wr_t2c);
            return cid;
        end
        default:
                `uvm_fatal("svk_axi_master_database", $sformatf("cid status is error:%s", cid_status.name))
    endcase
endfunction

function int svk_axi_master_database::get_r_cid(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::cid_status_enum cid_status);
    int qi[$];
    int tid;
    int cid;
    int tid_q[$];

    case(cid_status) inside
        svk_axi_dec::MST_GET_RSP_WITH_MIN_TID:begin
            qi = rd_tr.find_index with ((item.tr.id & cfg.ID_MASK) == (id & cfg.ID_MASK) && item.ready_status == svk_axi_dec::NOT_START);
            cid = get_cid_with_min_tid(rd_tr, qi, rd_t2c);
            return cid;
        end
        default:
            `uvm_fatal("svk_axi_master_database", $sformatf("cid status is error:%s", cid_status.name))
    endcase
endfunction

function void svk_axi_master_database::put_wr_tr(svk_axi_transaction tr);
    svk_axi_transaction_wrap wtr;
    int tid;
    int cid;
    int qi[$];

    cid = wr_cid_q.pop_front();
    tid = ++wr_tid_cnt;
    wtr = svk_axi_transaction_wrap::type_id::create("tr");
    wtr.tr = tr;


    wtr.cid = cid;
    wtr.tid = tid;


    if(aw_can_trigger == 0)begin
        ++aw_can_trigger;
        if(wtr.tr.awvalid_delay == 0)
            wtr.valid_status = svk_axi_dec::TIME_OUT;
        else
            wtr.valid_status = svk_axi_dec::WAITING;
    end
    else begin
        wtr.valid_status = svk_axi_dec::NOT_START;
    end

    if(w_can_trigger == 0 || cfg.wr_interleave_en)begin
        ++w_can_trigger;
        if(wtr.tr.wvalid_delay[0] == 0)
            wtr.wvalid_status = svk_axi_dec::TIME_OUT;
        else
            wtr.wvalid_status = svk_axi_dec::WAITING;
    end
    else begin
        wtr.wvalid_status = svk_axi_dec::NOT_START;
    end

    wr_tr[cid] = wtr;
    wr_t2c[tid] = cid;
endfunction

function void svk_axi_master_database::put_rd_tr(svk_axi_transaction tr);
    svk_axi_transaction_wrap rtr;
    int tid;
    int cid;
    int qi[$];

    cid = rd_cid_q.pop_front();
    tid = ++rd_tid_cnt;
    rtr = svk_axi_transaction_wrap::type_id::create("tr");
    rtr.tr  = tr;

    rtr.cid = cid;
    rtr.tid = tid;


    if(ar_can_trigger == 0)begin
        ++ar_can_trigger;
        if(rtr.tr.arvalid_delay == 0)
            rtr.valid_status = svk_axi_dec::TIME_OUT;
        else
            rtr.valid_status = svk_axi_dec::WAITING;
    end
    else begin
        rtr.valid_status = svk_axi_dec::NOT_START;
    end

    rd_tr[cid] = rtr;
    rd_t2c[tid] = cid;
endfunction

function svk_axi_transaction svk_axi_master_database::get_wr_tr();
    svk_axi_transaction      tr;
    int                  qi[$];
    int                  cid;

    qi = wr_tr.find_index with (item.ready_status == svk_axi_dec::FINISH && item.last_finish);
    if(qi.size > 1)
        `uvm_fatal("svk_axi_master_database", $sformatf("more than one cmd are finished at a time: %0d", qi.size))
    else if(qi.size == 1)begin
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

function svk_axi_transaction svk_axi_master_database::get_rd_tr();
    svk_axi_transaction      tr;
    int                  qi[$];
    int                  cid;

    qi = rd_tr.find_index with (item.ready_status == svk_axi_dec::FINISH && item.last_finish);
    if(qi.size > 1)
        `uvm_fatal("svk_axi_master_database", $sformatf("more than one cmd are finished at a time: %0d", qi.size))
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


function void svk_axi_master_database::update_wr_status(svk_axi_dec::wr_event_struct e);
    update_awvalid_status(e.id, e.wr_event);
    update_wvalid_status(e.id, e.wr_event);
    update_bready_status(e.id, e.wr_event);
endfunction

function void svk_axi_master_database::update_rd_status(svk_axi_dec::rd_event_struct e);
    update_arvalid_status(e.id, e.rd_event);
    update_rready_status(e.id, e.rd_event);
endfunction

function void svk_axi_master_database::tick();
    foreach(wr_tr[cid])begin
        if(wr_tr[cid].valid_status == svk_axi_dec::WAITING)begin
            --wr_tr[cid].tr.awvalid_delay;
            if(wr_tr[cid].tr.awvalid_delay == 0)begin
                wr_tr[cid].valid_status = svk_axi_dec::TIME_OUT;
            end
        end
        if(wr_tr[cid].wvalid_status == svk_axi_dec::WAITING)begin
            --wr_tr[cid].tr.wvalid_delay[wr_tr[cid].idx];
            if(wr_tr[cid].tr.wvalid_delay[wr_tr[cid].idx] == 0)begin
                wr_tr[cid].wvalid_status = svk_axi_dec::TIME_OUT;
            end
        end
    end

    foreach(rd_tr[cid])begin
        if(rd_tr[cid].valid_status == svk_axi_dec::WAITING)begin
            --rd_tr[cid].tr.arvalid_delay;
            if(rd_tr[cid].tr.arvalid_delay == 0)begin
                rd_tr[cid].valid_status = svk_axi_dec::TIME_OUT;
            end
        end
    end

    foreach(wr_tr[cid])begin

        if(wr_tr[cid].valid_wait_cycle != 33'h1_ffff_ffff && wr_tr[cid].valid_status == svk_axi_dec::TIME_OUT)begin
            ++wr_tr[cid].valid_wait_cycle;
            if(wr_tr[cid].valid_wait_cycle > cfg.ready_timeout_time)
                `uvm_fatal("post_drive", $sformatf("aw channel:id=%0h has time out timeout_time=%0d", wr_tr[cid].tr.id, cfg.ready_timeout_time))
        end

        if(wr_tr[cid].wvalid_wait_cycle != 33'h1_ffff_ffff && wr_tr[cid].wvalid_status == svk_axi_dec::TIME_OUT)begin
            ++wr_tr[cid].wvalid_wait_cycle;
            if(wr_tr[cid].wvalid_wait_cycle > cfg.ready_timeout_time)
                `uvm_fatal("post_drive", $sformatf("w channel:id=%0h has time out timeout_time=%0d", wr_tr[cid].tr.id, cfg.ready_timeout_time))
        end
    end
    foreach(rd_tr[cid])begin

        if(rd_tr[cid].valid_wait_cycle != 33'h1_ffff_ffff && rd_tr[cid].valid_status == svk_axi_dec::TIME_OUT)begin
            ++rd_tr[cid].valid_wait_cycle;
            if(rd_tr[cid].valid_wait_cycle > cfg.ready_timeout_time)
                `uvm_fatal("post_drive", $sformatf("ar channel:id=%0h has time out timeout_time=%0d", rd_tr[cid].tr.id, cfg.ready_timeout_time))
        end
    end





endfunction

function int svk_axi_master_database::get_wr_osd();
    return wr_cid_q.size();
endfunction

function int svk_axi_master_database::get_rd_osd();
    return rd_cid_q.size();
endfunction

`endif

