/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/

`ifndef SVK_APB_DEFAULT_MASTER_SEQUENCE__SV
`define SVK_APB_DEFAULT_MASTER_SEQUENCE__SV

class svk_apb_default_master_sequence extends svk_apb_sequence;
    `uvm_object_utils(svk_apb_default_master_sequence)

    function new(string name="svk_apb_default_master_sequence");
        super.new(name);
    endfunction

    extern task pre_body(); 
    extern task post_body(); 
    extern task body(); 


endclass



task svk_apb_default_master_sequence::body();
    svk_apb_transaction tr;
    svk_apb_agent_cfg   apb_cfg;
    svk_agent_cfg       get_cfg;



    get_cfg = p_sequencer.get_cfg();
    if(!$cast(apb_cfg, get_cfg))
        `uvm_error(get_type_name(), "config type is not svk_apb_agent_cfg")
    


    repeat(10)begin
        tr = svk_apb_transaction::type_id::create("tr");
        tr.cfg = apb_cfg;
        tr.randomize() with {
            addr >= 'h8000_0000;
            addr <  'h8000_00ff;
            foreach(addr[i]) {
                if(i<$clog2(tr.cfg.data_width)) {
                    addr[i] == 0;
                }
            }
            dir == svk_apb_dec::READ;
            need_resp == 1;
        };
        `uvm_send(tr)
        if(tr.need_resp)
            get_response(rsp, tr.get_transaction_id());
    end



    repeat(10)begin
        bit [31:0] send_addr;
        svk_apb_transaction wr;

        tr = svk_apb_transaction::type_id::create("tr");
        tr.cfg = apb_cfg;
        std::randomize(send_addr) with {
            send_addr >= 'h8000_0000;
            send_addr <'h8000_00ff;
            foreach(send_addr[i]) {
                if(i<$clog2(tr.cfg.data_width)) {
                    send_addr[i] == 0;
                }
            }
        };
        tr.randomize() with {
            addr == send_addr;
            dir == svk_apb_dec::WRITE;
            need_resp == 1;
        };
        `uvm_send(tr)
        if(tr.need_resp)
            get_response(rsp, tr.get_transaction_id());


        wr = svk_apb_transaction::type_id::create("tr");
        wr.copy(tr);
        wr.dir = svk_apb_dec::READ;
        `uvm_send(wr)
        if(wr.need_resp)
            get_response(rsp, wr.get_transaction_id());
    end


    for(int i=0; i<10; ++i)begin
        tr = svk_apb_transaction::type_id::create("tr");
        tr.cfg = apb_cfg;
        tr.randomize() with {
            foreach(addr[i]) {
                if(i<$clog2(tr.cfg.data_width)) {
                    addr[i] == 0;
                }
            }
            need_resp == 1;
        };
        `uvm_send(tr)
        if(tr.need_resp)
            get_response(rsp, tr.get_transaction_id());
    end

endtask



task svk_apb_default_master_sequence::pre_body();
    super.pre_body();

    `ifdef UVM_MINOR_REV_2
    if(get_starting_phase() != null)
        get_starting_phase().raise_objection(this);
        `uvm_info(get_type_name(), "raise objection .............", UVM_NONE)
    `else
    if(starting_phase != null)
        starting_phase.raise_objection(this);    
        `uvm_info(get_type_name(), "raise objection .............", UVM_NONE)
    `endif

endtask


task svk_apb_default_master_sequence::post_body();
    super.post_body();

    `ifdef UVM_MINOR_REV_2
    if(get_starting_phase() != null)begin
        get_starting_phase().phase_done.set_drain_time(this, 100ns);
        get_starting_phase().drop_objection(this);
        `uvm_info(get_type_name(), "drop objection .............", UVM_NONE)
    end
    `else
    if(starting_phase != null)begin
        starting_phase.phase_done.set_drain_time(this, 100ns);
        starting_phase.drop_objection(this);    
        `uvm_info(get_type_name(), "drop objection .............", UVM_NONE)
    end
    `endif
endtask
`endif
