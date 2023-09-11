/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_AHB_SLAVE_DRIVER__SV
`define SVK_AHB_SLAVE_DRIVER__SV

`define SLV vif.slv_mp.slv_cb
`define MON vif.mon_mp.mon_cb

class svk_ahb_slave_driver extends uvm_driver;
    `uvm_component_utils(svk_ahb_slave_driver)


    uvm_blocking_peek_imp#(uvm_sequence_item, svk_ahb_slave_driver) response_request_imp;
    event                                                       has_peek_data;
    uvm_sequence_item                                           peek_data;
    bit                                                         peek_done;
    svk_ahb_agent_cfg                                           cfg;
    virtual svk_ahb_if                                          vif;

    bit [7:0]                                                   mem[bit[`SVK_AHB_ADDR_WIDTH-1:0]];

    int unsigned                                                slave_sequence_get_num;
    int unsigned                                                slave_sequence_put_num;


    svk_ahb_dec::trans_enum                                     lastest_trans = svk_ahb_dec::IDLE;
    svk_ahb_dec::trans_enum                                     pre_trans = svk_ahb_dec::IDLE;
    svk_ahb_dec::dir_enum                                       pre_dir = svk_ahb_dec::READ;
    svk_ahb_transaction                                         trans_q[$];
    int                                                         wait_cnt;


    extern function new(string name, uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task peek(output uvm_sequence_item data);
    extern task reset_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern task peek_user_data(ref svk_ahb_transaction tr);
    extern function void set_rand_mode(svk_ahb_transaction tr);
    extern task drive_idle();

    extern task update();
    extern function svk_ahb_transaction get_wtr();
    extern function svk_ahb_transaction get_rtr();
    extern function svk_ahb_transaction get_tr();
    extern task drive_ctrl();
    extern task drive_wdata();
    extern task drive_rdata();
    extern task drive_resp();
    extern task drive_ready();

endclass

function svk_ahb_slave_driver::new(string name, uvm_component parent);
    super.new(name, parent);
endfunction


function void svk_ahb_slave_driver::build_phase(uvm_phase phase);
    if(cfg == null)
        cfg = svk_ahb_agent_cfg::type_id::create("svk_ahb_slave_driver_cfg");
    response_request_imp = new("imp", this);
endfunction


function void svk_ahb_slave_driver::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction


task svk_ahb_slave_driver::peek(output uvm_sequence_item data);
    @has_peek_data;
    data = peek_data;
    peek_done = 1;
    slave_sequence_get_num++;
endtask

task svk_ahb_slave_driver::reset_phase(uvm_phase phase);
    drive_idle();




endtask


task svk_ahb_slave_driver::run_phase(uvm_phase phase);
    super.run_phase(phase);

    while(1)begin
        update();
        drive_ctrl();
        drive_wdata();
        drive_rdata();
        drive_resp();
        drive_ready();
        if(`MON.hready === 1'b1)begin
            pre_trans = svk_ahb_dec::trans_enum'(`SLV.htrans);
            pre_dir   = svk_ahb_dec::dir_enum'(`SLV.hwrite);
        end;
        @(`SLV);
    end

endtask



function svk_ahb_transaction svk_ahb_slave_driver::get_wtr();
    svk_ahb_transaction tr;
    foreach(trans_q[i])begin
        if(trans_q[i].dir == svk_ahb_dec::WRITE)begin
            tr = trans_q[i];
            break;
        end
    end
    return tr;
endfunction

function svk_ahb_transaction svk_ahb_slave_driver::get_rtr();
    svk_ahb_transaction tr;
    foreach(trans_q[i])begin
        if(trans_q[i].dir == svk_ahb_dec::READ)begin
            tr = trans_q[i];
            break;
        end
    end
    return tr;
endfunction

function svk_ahb_transaction svk_ahb_slave_driver::get_tr();
    if(trans_q.size != 0)
        return trans_q[0];
endfunction

task svk_ahb_slave_driver::update();
    if(`MON.hready)
        lastest_trans = svk_ahb_dec::trans_enum'(`SLV.htrans);

    if(trans_q.size != 0 && `MON.hready === 1'b0)
        wait_cnt++;
    else
        wait_cnt = 0;
endtask

task svk_ahb_slave_driver::drive_ctrl();
    static bit wait_ready = 0;
    svk_ahb_transaction tr;

    if(`SLV.htrans == svk_ahb_dec::NSEQ && !wait_ready)begin
        tr = svk_ahb_transaction::type_id::create("tr");
        tr.cfg = cfg;

        tr.addr      = `SLV.haddr;
        tr.burst     = svk_ahb_dec::burst_enum'(`SLV.hburst);
        tr.prot[0]   = svk_ahb_dec::prot0_enum'(`SLV.hprot[0]);
        tr.prot[1]   = svk_ahb_dec::prot1_enum'(`SLV.hprot[1]);
        tr.prot[2]   = svk_ahb_dec::prot2_enum'(`SLV.hprot[2]);
        tr.prot[3]   = svk_ahb_dec::prot3_enum'(`SLV.hprot[3]);
        tr.size      = svk_ahb_dec::size_enum'(`SLV.hsize);
        tr.nonsec    = svk_ahb_dec::nonsec_enum'(`SLV.hnonsec);
        tr.lock      = `SLV.hlock;
        tr.ctrl_user = `SLV.control_huser;
        $cast(tr.dir, `SLV.hwrite);

        if(tr.addr % (1<<tr.size) != 0)begin
            `uvm_warning(get_type_name(), $sformatf("addr=%0h is not align %0d bytes", tr.addr, 1<<tr.size))
        end
        if(tr.burst == svk_ahb_dec::INCR)
            tr.num_incr_beats = `SVK_AHB_MAX_INCR_LEN;

        set_rand_mode(tr);
        tr.randomize(num_wait_cycles, resp, length, data, data_user, strb);
        peek_user_data(tr);

        trans_q.push_back(tr);

        if(`MON.hready === 1'b0 && `SLV.htrans == svk_ahb_dec::SEQ)begin
            wait_ready = 1;
        end
    end

    if(`MON.hready === 1'b1 && `SLV.htrans == svk_ahb_dec::SEQ)begin
        wait_ready = 0;
    end

endtask

task svk_ahb_slave_driver::drive_wdata();
    svk_ahb_transaction             tr;
    int                             lower_byte;
    int                             upper_byte;

    if((pre_trans == svk_ahb_dec::SEQ || pre_trans == svk_ahb_dec::NSEQ) && pre_dir == svk_ahb_dec::WRITE && `MON.hready)begin
        tr = get_wtr();
        get_lanes(tr, tr.dat_idx, lower_byte, upper_byte);
        for(int i=0; i<=upper_byte-lower_byte; ++i)begin
            tr.data[tr.dat_idx][i*8 +:8] = `SLV.hwdata[(i+lower_byte)*8 +:8];
        end
        tr.strb[tr.dat_idx]      = `SLV.hstrb;
        tr.data_user[tr.dat_idx] = `SLV.hwdata_huser;
        tr.dat_idx++;
    end
endtask

task svk_ahb_slave_driver::drive_rdata();
    svk_ahb_transaction             tr;
    int                             lower_byte;
    int                             upper_byte;
    logic [`SVK_AHB_DATA_WIDTH-1:0] tmp_data;
















    if((`SLV.htrans == svk_ahb_dec::SEQ || `SLV.htrans == svk_ahb_dec::NSEQ) && `SLV.hwrite == svk_ahb_dec::READ && `MON.hready)begin
        tr = get_rtr();
        get_lanes(tr, tr.dat_idx, lower_byte, upper_byte);
        for(int i=0; i<=upper_byte-lower_byte; ++i)begin
            tmp_data[(i+lower_byte)*8 +:8] = tr.data[tr.dat_idx][i*8 +:8];
        end
        `SLV.hrdata       <= tmp_data;
        `SLV.hrdata_huser <= tr.data_user[tr.dat_idx];
        tr.dat_idx++;

    end

endtask

task svk_ahb_slave_driver::drive_resp();
    svk_ahb_transaction tr;

    if((pre_trans == svk_ahb_dec::SEQ || pre_trans == svk_ahb_dec::NSEQ) && `MON.hready)begin
        tr = get_tr();
        tr.rsp_idx++;
        if(tr.burst == svk_ahb_dec::INCR)begin
            if(`SLV.htrans == svk_ahb_dec::IDLE)begin
                tr.num_incr_beats = tr.rsp_idx;
                trans_q.pop_front();
                peek_user_data(tr);
            end
        end
        else if(tr.get_len() == tr.rsp_idx)begin
            trans_q.pop_front();
            peek_user_data(tr);
        end
        else if(`SLV.htrans == svk_ahb_dec::IDLE)begin
            trans_q.pop_front();
            peek_user_data(tr);
        end
    end


    if(`MON.hready)begin
        if(`SLV.htrans == svk_ahb_dec::SEQ || `SLV.htrans == svk_ahb_dec::NSEQ)begin
            tr = get_tr();
            if(tr.resp[tr.rsp_idx] != 0)begin
                tr.num_wait_cycles[tr.rsp_idx]++;
            end
        end
    end


    if(lastest_trans == svk_ahb_dec::SEQ || lastest_trans == svk_ahb_dec::NSEQ)begin
        tr = get_tr();
        if(tr.num_wait_cycles[tr.rsp_idx] <= wait_cnt + 1)
            `SLV.hresp <= tr.resp[tr.rsp_idx];
        else
            `SLV.hresp <= 0;
    end
    else begin
        `SLV.hresp <= 0;
    end
endtask

task svk_ahb_slave_driver::drive_ready();
    if(lastest_trans == svk_ahb_dec::IDLE || lastest_trans == svk_ahb_dec::BUSY)
        `SLV.hready <= 1'b1;
    else begin
        if(trans_q.size != 0 && wait_cnt < trans_q[0].num_wait_cycles[trans_q[0].rsp_idx])
            `SLV.hready <= 1'b0;
        else
            `SLV.hready <= 1'b1;
    end
endtask

task svk_ahb_slave_driver::peek_user_data(ref svk_ahb_transaction tr);
    svk_ahb_transaction tmp;

    tmp = svk_ahb_transaction::type_id::create("tmp");
    tmp.copy(tr);
    set_rand_mode(tmp);

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
                slave_sequence_put_num++;

                if(tr.dir == svk_ahb_dec::WRITE)begin
                    tr.num_wait_cycles = tmp.num_wait_cycles;
                    tr.resp            = tmp.resp;
                end
                else begin
                    tr.num_wait_cycles = tmp.num_wait_cycles;
                    tr.resp            = tmp.resp;
                    tr.data            = tmp.data;
                    tr.data_user       = tmp.data_user;
                end
            end
        end
        begin
            #0.1;
        end
    join_any

    if(slave_sequence_get_num != slave_sequence_put_num)
        `uvm_fatal(get_type_name(), $sformatf("slave_sequence_get_num=%0d,slave_sequence_put_num=%0d, slave_response_sequence has delay!", slave_sequence_get_num, slave_sequence_put_num))
endtask

function void svk_ahb_slave_driver::set_rand_mode(svk_ahb_transaction tr);
    tr.con_dir.constraint_mode(0);
    tr.con_addr.constraint_mode(0);


    tr.con_ctrl_user.constraint_mode(0);

    tr.con_burst.constraint_mode(0);
    tr.con_num_busy_cycles.constraint_mode(0);
    tr.con_size.constraint_mode(0);
    tr.con_lock.constraint_mode(0);
    tr.con_need_resp.constraint_mode(0);
endfunction

task svk_ahb_slave_driver::drive_idle();
    if(cfg.idle_value == svk_dec::IDLE_ZERO)begin
        `SLV.hrdata        <= 0;
        `SLV.hresp         <= 0;
        `SLV.hready        <= 0;
        `SLV.hrdata_huser  <= 0;
        @(`SLV);
    end
    else if(cfg.idle_value == svk_dec::IDLE_RAND)begin
        `SLV.hrdata        <= $urandom;
        `SLV.hresp         <= $urandom;
        `SLV.hready        <= $urandom;
        `SLV.hrdata_huser  <= $urandom;
        @(`SLV);
    end
    else if(cfg.idle_value == svk_dec::IDLE_STABLE)begin
        @(`SLV);
    end
endtask:drive_idle

`undef MON
`undef SLV

`endif

