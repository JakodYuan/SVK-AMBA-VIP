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

`ifndef SVK_AXI_TRANSACTION_WRAP__SV
`define SVK_AXI_TRANSACTION_WRAP__SV

class svk_axi_transaction_wrap extends uvm_object;

    svk_axi_transaction                         tr;
    bit                                         last_finish;
    int                                         cid;
    int                                         tid;
    svk_axi_dec::delay_status_enum              valid_status;
    svk_axi_dec::delay_status_enum              ready_status;
    svk_axi_dec::delay_status_enum              wvalid_status;
    svk_axi_dec::delay_status_enum              wready_status;
    int                                         idx;

    bit                                         aw_vld         ;
    bit                                         w_vld          ;
    bit                                         ar_vld         ;
    bit                                         r_vld          ;
    bit                                         b_vld          ;

    bit[32:0]                                   valid_wait_cycle  = 33'h1_ffff_ffff;
    bit[32:0]                                   wvalid_wait_cycle = 33'h1_ffff_ffff;

    extern function new(string name="");
    extern function svk_aw_linedata get_aw_linedata();
    extern function svk_w_linedata  get_w_linedata();
    extern function svk_ar_linedata get_ar_linedata();
    extern function svk_r_linedata  get_r_linedata();
    extern function svk_b_linedata  get_b_linedata();
    extern function void put_aw_linedata(svk_aw_linedata line);
    extern function void put_w_linedata(svk_w_linedata line);
    extern function void put_ar_linedata(svk_ar_linedata line);
    extern function void put_r_linedata(svk_r_linedata line);
    extern function void put_b_linedata(svk_b_linedata line);
    extern function bit  is_finish();


    `uvm_object_utils_begin(svk_axi_transaction_wrap)
        `uvm_field_object(tr                           , UVM_ALL_ON)
        `uvm_field_int(last_finish                     , UVM_ALL_ON)
        `uvm_field_int(cid                             , UVM_ALL_ON)
        `uvm_field_int(tid                             , UVM_ALL_ON)
        `uvm_field_int(idx                             , UVM_ALL_ON)
        `uvm_field_enum(svk_axi_dec::delay_status_enum , valid_status  , UVM_ALL_ON)
        `uvm_field_enum(svk_axi_dec::delay_status_enum , ready_status  , UVM_ALL_ON)
        `uvm_field_enum(svk_axi_dec::delay_status_enum , wvalid_status , UVM_ALL_ON)
        `uvm_field_enum(svk_axi_dec::delay_status_enum , wready_status , UVM_ALL_ON)
        `uvm_field_int(                        aw_vld  , UVM_ALL_ON)
        `uvm_field_int(                        ar_vld  , UVM_ALL_ON)
        `uvm_field_int(                        w_vld   , UVM_ALL_ON)
        `uvm_field_int(                        r_vld   , UVM_ALL_ON)
        `uvm_field_int(                        b_vld   , UVM_ALL_ON)
    `uvm_object_utils_end

endclass


function svk_axi_transaction_wrap::new(string name="");
    tr = svk_axi_transaction::type_id::create("tr");
    valid_status  = svk_axi_dec::NOT_START;
    ready_status  = svk_axi_dec::NOT_START;
    wvalid_status = svk_axi_dec::NOT_START;
    wready_status = svk_axi_dec::NOT_START;
endfunction

function svk_aw_linedata svk_axi_transaction_wrap::get_aw_linedata();
    svk_aw_linedata line;

    if(tr.dir != svk_axi_dec::WRITE)
        `uvm_error(get_type_name(), "get_aw_linedata() dir != svk_axi_dec::WRITE")

    if(valid_status == svk_axi_dec::TIME_OUT)begin
        line         = new()    ;
        line.vld     = 1'b1     ;
        line.cid     = cid      ;
        line.id      = tr.id    ;
        line.addr    = tr.addr  ;
        line.len     = tr.length;
        line.size    = tr.size  ;
        line.burst   = tr.burst ;
        line.lock    = tr.lock  ;
        line.cache   = tr.cache ;
        line.prot    = tr.prot  ;
        line.qos     = tr.qos   ;
        line.region  = tr.region;
        line.user    = tr.auser ;

        aw_vld       = 1        ;
        valid_wait_cycle = 0 ;


        return line;
    end
    else
        return null;
endfunction

function svk_w_linedata svk_axi_transaction_wrap::get_w_linedata();
    svk_w_linedata  line;

    if(tr.dir != svk_axi_dec::WRITE)
        `uvm_error(get_type_name(), "get_w_linedata() dir != svk_axi_dec::WRITE")

    if(wvalid_status == svk_axi_dec::TIME_OUT)begin
        int lower_byte_lane;
        int upper_byte_lane;
        int data_bus_bytes;
        int byte_idx;

        data_bus_bytes = tr.cfg.data_width/8;

        line          = new()         ;
        line.vld      = 1'b1          ;
        line.cid      = cid           ;
        line.id       = tr.id         ;
        line.strb     = tr.wstrb[idx] ;
        line.user     = tr.wuser[idx] ;
        get_lanes(tr, idx, lower_byte_lane, upper_byte_lane, data_bus_bytes);
        for(int lane=0; lane<data_bus_bytes; ++lane)begin
            if(lane >= lower_byte_lane && lane <= upper_byte_lane)begin
                line.data[lane*8 +:8] = tr.data[idx][8*byte_idx +: 8];
                byte_idx++;
            end
            else begin
                line.data[lane*8 +:8] = 8'h0;
            end
        end

        w_vld         = 1             ;
        wvalid_wait_cycle = 0 ;


        ++idx;
        if((idx-1) == tr.length)
            last_finish = 1;

        line.last = last_finish;
        return line;
    end
    else
        return null;
endfunction

function svk_ar_linedata svk_axi_transaction_wrap::get_ar_linedata();
    svk_ar_linedata line;

    if(tr.dir != svk_axi_dec::READ)
        `uvm_error(get_type_name(), "get_ar_linedata() dir != svk_axi_dec::READ")

    if(valid_status == svk_axi_dec::TIME_OUT)begin
        line         = new()        ;
        line.vld     = 1'b1         ;
        line.cid     = cid          ;
        line.addr    = tr.addr      ;
        line.id      = tr.id        ;
        line.addr    = tr.addr      ;
        line.len     = tr.length    ;
        line.size    = tr.size      ;
        line.burst   = tr.burst     ;
        line.lock    = tr.lock      ;
        line.cache   = tr.cache     ;
        line.prot    = tr.prot      ;
        line.qos     = tr.qos       ;
        line.region  = tr.region    ;
        line.user    = tr.auser     ;

        ar_vld       = 1            ;
        valid_wait_cycle = 0 ;


        return line;
    end
    else
        return null;
endfunction

function svk_r_linedata svk_axi_transaction_wrap::get_r_linedata();
    svk_r_linedata line;

    if(tr.dir != svk_axi_dec::READ)
        `uvm_error(get_type_name(), "get_r_linedata() dir != svk_axi_dec::READ")

    if(valid_status  == svk_axi_dec::TIME_OUT)begin
        int lower_byte_lane;
        int upper_byte_lane;
        int data_bus_bytes;
        int byte_idx;

        data_bus_bytes = tr.cfg.data_width/8;

        line         = new()            ;
        line.vld     = 1'b1             ;
        line.cid     = cid              ;
        line.id      = tr.id            ;
        line.resp    = tr.resp[idx]     ;
        line.user    = tr.ruser[idx]    ;
        get_lanes(tr, idx, lower_byte_lane, upper_byte_lane, data_bus_bytes);
        for(int lane=0; lane<data_bus_bytes; ++lane)begin
            if(lane >= lower_byte_lane && lane <= upper_byte_lane)begin
                line.data[lane*8 +:8] = tr.data[idx][8*byte_idx +: 8];
                byte_idx++;
            end
            else begin
                line.data[lane*8 +:8] = 8'h0;
            end
        end



        valid_wait_cycle = 0 ;


        ++idx;
        if((idx-1) == tr.length)
            last_finish = 1;

        line.last = last_finish;
        return line;
    end
    else
        return null;
endfunction

function svk_b_linedata svk_axi_transaction_wrap::get_b_linedata();
    svk_b_linedata line;

    if(tr.dir != svk_axi_dec::WRITE)
        `uvm_error(get_type_name(), "get_b_linedata() dir != svk_axi_dec::WRITE")

    if(valid_status  == svk_axi_dec::TIME_OUT && aw_vld && w_vld && wready_status == svk_axi_dec::FINISH && ready_status == svk_axi_dec::FINISH)begin
        line       = new()      ;
        line.vld   = 1'b1       ;
        line.cid   = cid        ;
        line.id    = tr.id      ;
        line.resp  = tr.resp[0] ;
        line.user  = tr.buser   ;

        valid_wait_cycle = 0 ;


        return line;
    end
    else
        return null;
endfunction



function void svk_axi_transaction_wrap::put_aw_linedata(svk_aw_linedata line);
    int lower_byte_lane;
    int upper_byte_lane;
    int data_bus_bytes;
    int byte_idx;

    cid       = line.cid;
    tr.dir    = svk_axi_dec::WRITE  ;
    tr.id     = line.id    ;
    tr.addr   = line.addr  ;
    tr.qos    = line.qos   ;
    tr.auser  = line.user  ;
    aw_vld    = 1          ;
    $cast(tr.length , line.len   );
    $cast(tr.size   , line.size  );
    $cast(tr.burst  , line.burst );
    $cast(tr.lock   , line.lock  );
    $cast(tr.cache  , line.cache );
    $cast(tr.prot   , line.prot  );
    $cast(tr.region , line.region);

    if(w_vld && (idx-1) > tr.length)
        `uvm_fatal(get_type_name(), $sformatf("length and the number of data do not match:id=%0d, length=%0d, idx=%0d", tr.id, tr.length, idx))

    if(last_finish)begin
        logic [`SVK_AXI_DATA_WIDTH-1:0] tmp_datas[];

        data_bus_bytes = tr.cfg.data_width/8;
        for(int step=0; step<=tr.length; ++step)begin
            logic [`SVK_AXI_DATA_WIDTH-1:0] tmp_data;

            byte_idx = 0;
            get_lanes(tr, step, lower_byte_lane, upper_byte_lane, data_bus_bytes);
            for(int lane=lower_byte_lane; lane<=upper_byte_lane; ++lane)begin
                tmp_data[8*byte_idx +: 8] = tr.data[step][lane*8 +:8];
                byte_idx++;
            end
            tmp_datas = {tmp_datas, tmp_data};
        end
        tr.data = tmp_datas;
    end
endfunction

function void svk_axi_transaction_wrap::put_w_linedata(svk_w_linedata line);

    int lower_byte_lane;
    int upper_byte_lane;
    int data_bus_bytes;
    int byte_idx;


    if(idx == 0)begin
        tr.data.delete();
        tr.wstrb.delete();
        tr.wuser.delete();
    end


    if(tr.cfg.version == svk_axi_dec::AXI3)
        tr.id      = line.id     ;
    cid            = line.cid;
    tr.dir         = svk_axi_dec::WRITE   ;
    w_vld          = 1           ;
    tr.wstrb = {tr.wstrb, line.strb};
    tr.wuser = {tr.wuser, line.user};
    tr.data = {tr.data, line.data} ;

    ++idx;
    if(aw_vld && (idx-1) == tr.length)
        last_finish = 1;
    if(!aw_vld && line.last)
        last_finish = 1;

    if(tr.data.size != idx || tr.wstrb.size != idx || tr.wuser.size != idx)
        `uvm_fatal(get_type_name(), $sformatf("data.size=%0d, wstrb.size=%0d, wuser.size=%0d, idx=%0d", tr.data.size, tr.wstrb.size, tr.wuser.size, idx))

    if(aw_vld && last_finish && !line.last)
        `uvm_fatal(get_type_name(), "wlast signal should assert")
    else if(aw_vld && !last_finish && line.last)
        `uvm_fatal(get_type_name(), "wlast signal should't assert")

    if(last_finish && aw_vld)begin
        logic [`SVK_AXI_DATA_WIDTH-1:0] tmp_datas[];

        data_bus_bytes = tr.cfg.data_width/8;
        for(int step=0; step<=tr.length; ++step)begin
            logic [`SVK_AXI_DATA_WIDTH-1:0] tmp_data;

            byte_idx = 0;
            get_lanes(tr, step, lower_byte_lane, upper_byte_lane, data_bus_bytes);
            for(int lane=lower_byte_lane; lane<=upper_byte_lane; ++lane)begin
                tmp_data[8*byte_idx +: 8] = tr.data[step][lane*8 +:8];
                byte_idx++;
            end
            tmp_datas = {tmp_datas, tmp_data};
        end
        tr.data = tmp_datas;
    end
endfunction

function void svk_axi_transaction_wrap::put_ar_linedata(svk_ar_linedata line);
    cid       = line.cid;
    tr.dir    = svk_axi_dec::READ    ;
    tr.id     = line.id     ;
    tr.addr   = line.addr   ;
    tr.qos    = line.qos    ;
    tr.auser  = line.user   ;
    ar_vld = 1           ;
    $cast(tr.length , line.len    );
    $cast(tr.size   , line.size   );
    $cast(tr.burst  , line.burst  );
    $cast(tr.lock   , line.lock   );
    $cast(tr.cache  , line.cache  );
    $cast(tr.prot   , line.prot   );
    $cast(tr.region , line.region );
endfunction

function void svk_axi_transaction_wrap::put_r_linedata(svk_r_linedata line);

    bit [`SVK_AXI_DATA_WIDTH-1:0] tmp_data;
    int lower_byte_lane;
    int upper_byte_lane;
    int data_bus_bytes;
    int byte_idx;

    data_bus_bytes = tr.cfg.data_width/8;

    if(idx == 0)begin
        tr.data.delete();
        tr.resp.delete();
        tr.ruser.delete();
    end

    get_lanes(tr, idx, lower_byte_lane, upper_byte_lane, data_bus_bytes);
    for(int lane=lower_byte_lane; lane<=upper_byte_lane; ++lane)begin
        tmp_data[8*byte_idx +: 8] = line.data[lane*8 +:8];
        byte_idx++;
    end

    cid     = line.cid ;
    tr.id   = line.id  ;
    r_vld   = 1        ;
    tr.data = {tr.data, tmp_data} ;
    tr.resp = {tr.resp, svk_axi_dec::resp_enum'(line.resp)} ;
    tr.ruser = {tr.ruser, line.user};

    ++idx;
    if((idx-1) == tr.length)
        last_finish = 1;

    if(tr.data.size != idx || tr.resp.size != idx || tr.ruser.size != idx)
        `uvm_fatal(get_type_name(), $sformatf("data.size=%0d, resp.size=%0d, ruser.size=%0d, idx=%0d", tr.data.size, tr.resp.size, tr.ruser.size, idx))

    if(last_finish && !line.last)
        `uvm_fatal(get_type_name(), "rlast signal should assert")
    else if(!last_finish && line.last)
        `uvm_fatal(get_type_name(), "rlast signal should't assert")

    if(tr.dir != svk_axi_dec::READ)
        `uvm_error(get_type_name(), "put_r_linedata() dir != svk_axi_dec::READ")
endfunction

function void svk_axi_transaction_wrap::put_b_linedata(svk_b_linedata line);
    cid        = line.cid ;
    tr.id      = line.id  ;
    tr.buser   = line.user;
    b_vld      = 1;
    tr.resp.delete();
    tr.resp = {tr.resp , svk_axi_dec::resp_enum'(line.resp)};

    if(tr.dir != svk_axi_dec::WRITE)
        `uvm_error(get_type_name(), "put_w_linedata() dir != svk_axi_dec::WRITE")
endfunction

function bit svk_axi_transaction_wrap::is_finish();

endfunction

`endif

