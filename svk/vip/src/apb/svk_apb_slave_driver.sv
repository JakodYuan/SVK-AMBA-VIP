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

`ifndef SVK_APB_SLAVE_DRIVER__SV
`define SVK_APB_SLAVE_DRIVER__SV

`define SLV vif.slv_mp.slv_cb

class svk_apb_slave_driver extends uvm_driver;
    `uvm_component_utils(svk_apb_slave_driver)

    uvm_blocking_peek_imp#(uvm_sequence_item, svk_apb_slave_driver) response_request_imp;
    event                                                           has_peek_data;
    uvm_sequence_item                                               peek_data;
    bit                                                             peek_done;
    svk_apb_agent_cfg                                               cfg;
    virtual svk_apb_if                                              vif;

    int unsigned                                                slave_sequence_get_num;
    int unsigned                                                slave_sequence_put_num;
    extern function new(string name, uvm_component parent);
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern task peek(output uvm_sequence_item data);
    extern task reset_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern task main_thread();
    extern task drive_write(svk_apb_transaction tr);
    extern task drive_read(svk_apb_transaction tr);

endclass

function svk_apb_slave_driver::new(string name, uvm_component parent);
    super.new(name, parent);
endfunction


function void svk_apb_slave_driver::build_phase(uvm_phase phase);
    if(cfg == null)
        cfg = svk_apb_agent_cfg::type_id::create("apb_slave_driver_cfg");
    response_request_imp = new("imp", this);
endfunction


function void svk_apb_slave_driver::connect_phase(uvm_phase phase);
    super.connect_phase(phase);
endfunction


task svk_apb_slave_driver::peek(output uvm_sequence_item data);
    @has_peek_data;
    data = peek_data;
    peek_done = 1;
    slave_sequence_get_num++;
endtask

task svk_apb_slave_driver::reset_phase(uvm_phase phase);
    `SLV.prdata  <= 0;
    `SLV.pslverr <= 0;
    `SLV.pready  <= 0;
endtask


task svk_apb_slave_driver::run_phase(uvm_phase phase);
    super.run_phase(phase);
    main_thread();
endtask


task svk_apb_slave_driver::main_thread();
    svk_apb_transaction tr;

    while(1)begin
        tr = svk_apb_transaction::type_id::create("tr");
        tr.cfg = cfg;
        tr.con_strb.constraint_mode(0);
        tr.randomize(resp);

        do
            @(`SLV);
        while(`SLV.psel !== 1'b1);




        if(tr.addr % (cfg.data_width/8) != 0)begin
            `uvm_warning(get_type_name(), $sformatf("addr=%0h is not align %0d bytes", tr.addr, cfg.data_width/8))
        end

        tr.addr = `SLV.paddr;
        tr.prot = `SLV.pprot;
        tr.user = `SLV.puser;
        tr.strb = `SLV.pstrb;
        $cast(tr.dir, `SLV.pwrite);
        case(tr.dir)
            svk_apb_dec::WRITE : drive_write(tr);
            svk_apb_dec::READ  : drive_read(tr);
        endcase

    end
endtask


task svk_apb_slave_driver::drive_write(svk_apb_transaction tr);
    int delay;
    svk_apb_transaction tmp;

    tr.data = `SLV.pwdata;
    tr.strb = `SLV.pstrb;

    tr.con_strb.constraint_mode(0);
    tr.randomize(ready_delay, resp);

    tmp = svk_apb_transaction::type_id::create("tmp");
    tmp.copy(tr);
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

                tr.ready_delay = tmp.ready_delay;
                tr.resp        = tmp.resp;
            end
        end
        begin
            #0.1;
        end
    join_any

    if(slave_sequence_get_num != slave_sequence_put_num)
        `uvm_fatal(get_type_name(), $sformatf("slave_sequence_get_num=%0d,slave_sequence_put_num=%0d, slave_response_sequence has delay!", slave_sequence_get_num, slave_sequence_put_num))

    delay = tr.ready_delay;
    if(delay != 0)begin
        `SLV.pready <= 1'b0;
        repeat(delay) @(`SLV);
    end
    `SLV.pready  <= 1'b1;
    `SLV.pslverr <= tr.resp;
    @(`SLV)
    `SLV.pready <= $urandom_range(1);
endtask


task svk_apb_slave_driver::drive_read(svk_apb_transaction tr);
    int delay;
    svk_apb_transaction tmp;



    tr.randomize(ready_delay, resp, data);

    tmp = svk_apb_transaction::type_id::create("tmp");
    tmp.copy(tr);
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

                tr.ready_delay = tmp.ready_delay;
                tr.resp        = tmp.resp;
                tr.data        = tmp.data;
            end
        end
        begin
            #0.1;
        end
    join_any

    if(slave_sequence_get_num != slave_sequence_put_num)
        `uvm_fatal(get_type_name(), $sformatf("slave_sequence_get_num=%0d,slave_sequence_put_num=%0d, slave_response_sequence has delay!", slave_sequence_get_num, slave_sequence_put_num))

    delay = tr.ready_delay;
    if(delay != 0)begin
        `SLV.pready <= 1'b0;
        repeat(delay) @(`SLV);
    end
    `SLV.pready  <= 1'b1;
    `SLV.pslverr <= tr.resp;
    `SLV.prdata  <= tr.data;
    @(`SLV)
    `SLV.pready <= $urandom_range(1);
endtask


`undef SLV
`undef MON

`endif

