/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_AXI_DATABASE_SV
`define SVK_AXI_DATABASE_SV

virtual class svk_axi_database;
    svk_axi_transaction_wrap    wr_tr[int];       
    svk_axi_transaction_wrap    rd_tr[int];       
    int                         wr_cid_q[$];      
    int                         rd_cid_q[$];      
    int                         wr_tid_cnt;       
    int                         rd_tid_cnt;       
    int	                        wr_t2c[int];           
    int	                        rd_t2c[int];           
    svk_axi_agent_cfg           cfg;

    extern function int  get_cid_with_min_tid(svk_axi_transaction_wrap tr[int], int cid_q[$], int t2c[int]);
    extern function int  get_cid_with_max_tid(svk_axi_transaction_wrap tr[int], int cid_q[$], int t2c[int]);
    extern function int  get_min_wr_tid();
    extern function int  get_min_rd_tid();
    extern function int  get_max_wr_tid();
    extern function int  get_max_rd_tid();

endclass

function int svk_axi_database::get_cid_with_min_tid(svk_axi_transaction_wrap tr[int], int cid_q[$], int t2c[int]);
    int qi[$];
    int tid_q[$];
    int tid;
    int cid;

    if(cid_q.size > 0)begin
        foreach(cid_q[i])
            tid_q.push_back(tr[cid_q[i]].tid);

        qi = tid_q.min();
        tid = qi[0];
        cid = t2c[tid];

        return cid;
    end
    else begin
        return -1;
    end
endfunction

function int svk_axi_database::get_cid_with_max_tid(svk_axi_transaction_wrap tr[int], int cid_q[$], int t2c[int]);
    int qi[$];
    int tid_q[$];
    int tid;
    int cid;

    if(cid_q.size > 0)begin
        foreach(cid_q[i])
            tid_q.push_back(tr[cid_q[i]].tid);

        qi = tid_q.max();
        tid = qi[0];
        cid = t2c[tid];

        return cid;
    end
    else begin
        return -1;
    end
endfunction


function int svk_axi_database::get_min_rd_tid();
    int tid_q[$];
    int qi[$];

    if(rd_t2c.size > 0)begin
        foreach(rd_t2c[i])
            tid_q.push_back(i);
        
        qi = tid_q.min();
        return qi[0];
    end
    else begin
        return -1;
    end

endfunction


function int svk_axi_database::get_min_wr_tid();
    int tid_q[$];
    int qi[$];

    if(wr_t2c.size > 0)begin
        foreach(wr_t2c[i])
            tid_q.push_back(i);
        
        qi = tid_q.min();
        return qi[0];
    end
    else begin
        return -1;
    end

endfunction

function int svk_axi_database::get_max_rd_tid();
    int tid_q[$];
    int qi[$];

    if(rd_t2c.size > 0)begin
        foreach(rd_t2c[i])
            tid_q.push_back(i);
        
        qi = tid_q.max();
        return qi[0];
    end
    else begin
        return -1;
    end

endfunction


function int svk_axi_database::get_max_wr_tid();
    int tid_q[$];
    int qi[$];

    if(wr_t2c.size > 0)begin
        foreach(wr_t2c[i])
            tid_q.push_back(i);
        
        qi = tid_q.max();
        return qi[0];
    end
    else begin
        return -1;
    end

endfunction

`endif
