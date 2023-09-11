/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/

`ifndef SVK_AXI_DEFAULT_MASTER_SEQUENCE__SV
`define SVK_AXI_DEFAULT_MASTER_SEQUENCE__SV

class svk_axi_default_master_sequence extends svk_axi_sequence;
    `uvm_object_utils(svk_axi_default_master_sequence)

    function new(string name="svk_axi_default_master_sequence");
        super.new(name);
    endfunction

    extern task pre_body(); 
    extern task post_body(); 
    extern task body(); 


endclass



task svk_axi_default_master_sequence::body();
    svk_axi_transaction tr;
    svk_axi_agent_cfg   axi_cfg;
    svk_agent_cfg       get_cfg;



    get_cfg = p_sequencer.get_cfg();
    if(!$cast(axi_cfg, get_cfg))
        `uvm_error(get_type_name(), "config type is not svk_axi_agent_cfg")


    repeat(10)begin
        tr = svk_axi_transaction::type_id::create("tr");
        tr.cfg = axi_cfg;
        tr.randomize() with {
            addr >= 'h8000_0000;
            addr <  'h8000_00ff;
            dir == svk_axi_dec::READ;
            burst == svk_axi_dec::BURST_INCR;
            length < 20;
            need_resp == 1;
        };
        `uvm_send(tr)
        if(tr.need_resp)
            get_response(rsp, tr.get_transaction_id());
    end



    repeat(10)begin
        bit [31:0] send_addr;
        svk_axi_transaction wr;

        tr = svk_axi_transaction::type_id::create("tr");
        tr.cfg = axi_cfg;
        std::randomize(send_addr) with {send_addr >= 'h8000_0000; send_addr <'h8000_00ff;};
        tr.randomize() with {
            addr == send_addr;
            dir == svk_axi_dec::WRITE;
            burst == svk_axi_dec::BURST_INCR;
            length < 20;
            need_resp == 1;
        };
        `uvm_send(tr)
        if(tr.need_resp)
            get_response(rsp, tr.get_transaction_id());


        wr = svk_axi_transaction::type_id::create("tr");
        wr.copy(tr);
        wr.dir = svk_axi_dec::READ;
        `uvm_send(wr)
        if(wr.need_resp)
            get_response(rsp, wr.get_transaction_id());
    end


    for(int i=0; i<10; ++i)begin
        tr = svk_axi_transaction::type_id::create("tr");
        tr.cfg = axi_cfg;
        tr.randomize() with {
            length < 20;
            need_resp == 1;
        };
        `uvm_send(tr)
        if(tr.need_resp)
            get_response(rsp, tr.get_transaction_id());
    end

endtask



task svk_axi_default_master_sequence::pre_body();
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


task svk_axi_default_master_sequence::post_body();
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
