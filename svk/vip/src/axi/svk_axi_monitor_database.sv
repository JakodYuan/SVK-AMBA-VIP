/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/



`ifndef SVK_AXI_MONITOR_DATABASE__SV
`define SVK_AXI_MONITOR_DATABASE__SV

class svk_axi_monitor_database extends svk_axi_database;



    int                         w_busy_cid = -1; 
    int                         r_busy_cid = -1; 

    extern function new(svk_axi_agent_cfg cfg);
    extern function void put_aw_linedata(svk_aw_linedata line);
    extern function void put_ar_linedata(svk_ar_linedata line);
    extern function void put_w_linedata(svk_w_linedata line);
    extern function void put_b_linedata(svk_b_linedata line);
    extern function void put_r_linedata(svk_r_linedata line);
    extern function int get_aw_cid(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::cid_status_enum cid_status);
    extern function int get_w_cid(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::cid_status_enum cid_status);
    extern function int get_ar_cid(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::cid_status_enum cid_status);
    extern function int get_b_cid(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::cid_status_enum cid_status);
    extern function int get_r_cid(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::cid_status_enum cid_status);
    extern function svk_axi_transaction get_wr_tr();
    extern function svk_axi_transaction get_rd_tr();
    extern function int  get_wr_osd();
    extern function int  get_rd_osd();
    extern function void trigger_rd_delay(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::rd_delay_event_enum delay_event);
    extern function void trigger_wr_delay(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::wr_delay_event_enum delay_event);
endclass

function svk_axi_monitor_database::new(svk_axi_agent_cfg cfg);
    super.new();
    this.cfg = cfg;
    for(int cid=0; cid<cfg.wr_osd; ++cid)begin
        wr_cid_q.push_back(cid);
    end
    for(int cid=0; cid<cfg.rd_osd; ++cid)begin
        rd_cid_q.push_back(cid);
    end
endfunction

function void svk_axi_monitor_database::put_aw_linedata(svk_aw_linedata line);
    int cid;

    cid = get_aw_cid(line.id, svk_axi_dec::MON_ALLOCATE_NEW);
    line.cid = cid;
    if(!wr_tr.exists(cid))begin
        wr_tr[cid] = svk_axi_transaction_wrap::type_id::create("tr");
        wr_tr[cid].tr.cfg = cfg;
        wr_tr[cid].cid = cid;
        wr_tr[cid].tid = ++wr_tid_cnt;
        wr_t2c[wr_tid_cnt] = cid;
    end
    wr_tr[cid].put_aw_linedata(line);
endfunction

function void svk_axi_monitor_database::put_ar_linedata(svk_ar_linedata line);
    int cid;

    cid = get_ar_cid(line.id, svk_axi_dec::MON_ALLOCATE_NEW);
    line.cid = cid;
    if(!rd_tr.exists(cid))begin
        rd_tr[cid] = svk_axi_transaction_wrap::type_id::create("tr");
        rd_tr[cid].tr.cfg = cfg;
        rd_tr[cid].cid = cid;
        rd_tr[cid].tid = ++rd_tid_cnt;
        rd_t2c[rd_tid_cnt] = cid;
    end
    rd_tr[cid].put_ar_linedata(line);
endfunction

function void svk_axi_monitor_database::put_w_linedata(svk_w_linedata line);
    int cid;

    cid = get_w_cid(line.id, svk_axi_dec::MON_ALLOCATE_NEW);
    line.cid = cid;
    if(!wr_tr.exists(cid))begin
        wr_tr[cid] = svk_axi_transaction_wrap::type_id::create("tr");
        wr_tr[cid].tr.cfg = cfg;
        wr_tr[cid].cid = cid;
        wr_tr[cid].tid = ++wr_tid_cnt;
        wr_t2c[wr_tid_cnt] = cid;
    end
    wr_tr[cid].put_w_linedata(line);

    if(cfg.wr_interleave_en == 1'b0)begin
        if(w_busy_cid != -1 && w_busy_cid != line.cid)begin
            `uvm_fatal("svk_axi_monitor_database", "write interleave while cfg.wr_interleave_en == 0")
        end
    end

    if(line.last == 1'b0)begin
        w_busy_cid = cid;
    end
    else begin
        w_busy_cid = -1;
    end
endfunction

function void svk_axi_monitor_database::put_b_linedata(svk_b_linedata line);
    int min_tid = wr_tid_cnt;

    line.cid = get_b_cid(line.id, svk_axi_dec::MON_GET_RSP_WITH_MIN_TID);
    wr_tr[line.cid].put_b_linedata(line);

    if(cfg.wr_out_of_order_en == 1'b0)begin
        foreach(wr_t2c[tid])begin
            if(min_tid > tid)begin
                min_tid = tid;
            end
        end
        if(wr_t2c[min_tid] != line.cid)begin
            `uvm_fatal("svk_axi_monitor_database", "write out of order while cfg.wr_out_of_order_en == 0")
        end
    end
endfunction

function void svk_axi_monitor_database::put_r_linedata(svk_r_linedata line);
    int        min_tid  = rd_tid_cnt;

    line.cid = get_r_cid(line.id, svk_axi_dec::MON_GET_RSP_WITH_MIN_TID);
    rd_tr[line.cid].put_r_linedata(line);

    if(cfg.rd_out_of_order_en == 1'b0)begin
        foreach(rd_tr[cid])begin
            if(rd_tr[cid].tid < rd_tr[line.cid].tid && rd_tr[cid].r_vld == 0)begin
                `uvm_fatal("svk_axi_monitor_database", $sformatf("read out of order while cfg.rd_out_of_order_en == 0, because id=%0h has not recived", rd_tr[cid].tr.id))
            end
        end
    end
    if(cfg.rd_interleave_en == 1'b0)begin
        if(r_busy_cid != -1 && r_busy_cid != line.cid)begin
            `uvm_fatal("svk_axi_monitor_database", "read interleave while cfg.rd_interleave_en == 0")
        end
    end

    if(line.last == 1'b0)begin
        r_busy_cid = line.cid;
    end
    else begin
        r_busy_cid = -1;
    end
endfunction

function int svk_axi_monitor_database::get_aw_cid(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::cid_status_enum cid_status);
    int qi[$];
    int cid;
    int tid;
    int tid_q[$];

    case(cid_status)
        svk_axi_dec::MON_ALLOCATE_NEW:begin
            case(cfg.version)
                svk_axi_dec::AXI3:begin
                    qi = wr_tr.find_index with ((item.tr.id & cfg.ID_MASK) == (id & cfg.ID_MASK) && item.w_vld == 1 && item.aw_vld == 0);
                    if(qi.size > 0)begin
                        foreach(qi[i])
                            tid_q.push_back(wr_tr[qi[i]].tid);
                        qi = tid_q.min();
                        tid = qi[0];
                        cid = wr_t2c[tid];
                        return cid;
                    end
                    else begin
                        if(wr_cid_q.size == 0)
                            `uvm_fatal("svk_axi_monitor_database", "write outstanding > cfg.wr_osd") 
                        cid = wr_cid_q.pop_front();
                        return cid;
                    end
                end
                svk_axi_dec::AXI4:begin
                    qi = wr_tr.find_index with (item.w_vld == 1 && item.aw_vld == 0);
                    if(qi.size > 0)begin
                        foreach(qi[i])
                            tid_q.push_back(wr_tr[qi[i]].tid);
                        qi = tid_q.min();
                        tid = qi[0];
                        cid = wr_t2c[tid];
                        return cid;
                    end
                    else begin
                        if(wr_cid_q.size == 0)
                            `uvm_fatal("svk_axi_monitor_database", "write outstanding > cfg.wr_osd") 
                        cid = wr_cid_q.pop_front();
                        return cid;
                    end
                end
            endcase
        end
        default:
            `uvm_fatal("svk_axi_monitor_database", $sformatf("cid status is error:%s", cid_status.name)) 
    endcase
endfunction

function int svk_axi_monitor_database::get_w_cid(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::cid_status_enum cid_status);
    int qi[$];
    int cid;
    int tid;
    int tid_q[$];

    case(cid_status)
        svk_axi_dec::MON_ALLOCATE_NEW:begin
            case(cfg.version)
                svk_axi_dec::AXI3:begin
                    qi = wr_tr.find_index with ((item.tr.id & cfg.ID_MASK) == (id & cfg.ID_MASK) && item.last_finish == 0);
                    if(qi.size > 0)begin
                        foreach(qi[i])
                            tid_q.push_back(wr_tr[qi[i]].tid);
                        qi = tid_q.min();
                        tid = qi[0];
                        cid = wr_t2c[tid];
                        return cid;
                    end
                    else begin
                        if(rd_cid_q.size == 0)
                            `uvm_fatal("svk_axi_monitor_database", "write outstanding > cfg.wr_osd") 
                        cid = wr_cid_q.pop_front();
                        return cid;
                    end
                end
                svk_axi_dec::AXI4:begin

                    qi = wr_tr.find_index with (item.w_vld == 1'b1 && item.last_finish == 0);
                    if(qi.size > 1)begin
                        `uvm_fatal("svk_axi_monitor_database", $sformatf("more than one w burst is sending: %0d", qi.size)) 
                    end
                    else if(qi.size == 1)begin
                        return qi[0];
                    end
                    else begin

                        qi = wr_tr.find_index with (item.w_vld == 1'b0 && item.aw_vld == 1'b1);
                        if(qi.size > 0)begin
                            foreach(qi[i])
                                tid_q.push_back(wr_tr[qi[i]].tid);
                            qi = tid_q.min();
                            tid = qi[0];
                            cid = wr_t2c[tid];
                            return cid;
                        end
                        else begin
                            cid = wr_cid_q.pop_front();
                            return cid;
                        end
                    end
                end
            endcase
        end
        default:
            `uvm_fatal("svk_axi_monitor_database", $sformatf("cid status is error:%s", cid_status.name)) 
    endcase
endfunction

function int svk_axi_monitor_database::get_ar_cid(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::cid_status_enum cid_status);
    int qi[$];
    int cid;
    int tid;
    int tid_q[$];

    case(cid_status)
        svk_axi_dec::MON_ALLOCATE_NEW:begin
            if(rd_cid_q.size == 0)
                `uvm_fatal("svk_axi_monitor_database", "read outstanding > cfg.rd_osd") 
            cid = rd_cid_q.pop_front();
            return cid;
        end
        default:
            `uvm_fatal("svk_axi_monitor_database", $sformatf("cid status is error:%s", cid_status.name)) 
    endcase
endfunction

function int svk_axi_monitor_database::get_b_cid(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::cid_status_enum cid_status);
    int tid_q[$];
    int qi[$];
    int tid;
    int cid;

    case(cid_status) inside
        svk_axi_dec::MON_GET_RSP_WITH_MIN_TID:begin
            qi = wr_tr.find_index with ((item.tr.id & cfg.ID_MASK) == (id & cfg.ID_MASK));
            foreach(qi[i])
                tid_q.push_back(wr_tr[qi[i]].tid);
            qi = tid_q.min();
            if(qi.size == 1)begin
                tid = qi[0];
                cid = wr_t2c[tid];
                return cid;
            end
            else begin
                `uvm_fatal("svk_axi_monitor_database", $sformatf("The number of data be getted not one: %0d", qi.size)) 
            end
        end
        default:
            `uvm_fatal("svk_axi_monitor_database", $sformatf("cid status is error:%s", cid_status.name)) 
    endcase
endfunction

function int svk_axi_monitor_database::get_r_cid(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::cid_status_enum cid_status);
    int qi[$];
    int tid_q[$];
    int tid;
    int cid;

    case(cid_status) inside
        svk_axi_dec::MON_GET_RSP_WITH_MIN_TID:begin
            qi = rd_tr.find_index with ((item.tr.id & cfg.ID_MASK) == (id & cfg.ID_MASK));
            foreach(qi[i])
                tid_q.push_back(rd_tr[qi[i]].tid);
            qi = tid_q.min();
            if(qi.size == 1)begin
                tid = qi[0];
                cid = rd_t2c[tid];
                return cid;
            end
            else begin
                `uvm_fatal("svk_axi_monitor_database", $sformatf("The number of data be getted not one: %0d", qi.size)) 
            end
        end
        default:
            `uvm_fatal("svk_axi_monitor_database", $sformatf("cid status is error:%s", cid_status.name)) 
    endcase
endfunction

function svk_axi_transaction svk_axi_monitor_database::get_wr_tr();
    svk_axi_transaction     tr;
    int                     qi[$];
    int                     cid;

    qi = wr_tr.find_index with (item.b_vld);
    if(qi.size > 1)
        `uvm_fatal("svk_axi_monitor_database", $sformatf("more than one cmd are finished at a time: %0d", qi.size)) 
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

function svk_axi_transaction svk_axi_monitor_database::get_rd_tr();
    svk_axi_transaction         tr;
    int                         qi[$];
    int                         cid;


    qi = rd_tr.find_index with (item.r_vld && item.last_finish);
    if(qi.size > 1)
        `uvm_fatal("svk_axi_monitor_database", $sformatf("more than one cmd are finished at a time: %0d", qi.size)) 
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

function int svk_axi_monitor_database::get_wr_osd();
    return wr_cid_q.size();
endfunction

function int svk_axi_monitor_database::get_rd_osd();
    return rd_cid_q.size();
endfunction

function void svk_axi_monitor_database::trigger_rd_delay(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::rd_delay_event_enum delay_event);

endfunction

function void svk_axi_monitor_database::trigger_wr_delay(bit [`SVK_AXI_ID_WIDTH-1:0] id, svk_axi_dec::wr_delay_event_enum delay_event);

endfunction


`endif

