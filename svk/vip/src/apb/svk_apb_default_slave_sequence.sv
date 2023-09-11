/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/

`ifndef SVK_APB_DEFAULT_SLAVE_SEQUENCE__SV
`define SVK_APB_DEFAULT_SLAVE_SEQUENCE__SV

class svk_apb_default_slave_sequence extends svk_apb_sequence;
    `uvm_object_utils(svk_apb_default_slave_sequence)

    function new(string name="svk_apb_default_slave_sequence");
        super.new(name);
    endfunction


    task body();
        svk_apb_transaction tr;
        svk_apb_agent_cfg   apb_cfg;
        svk_agent_cfg       get_cfg;



        get_cfg = p_sequencer.get_cfg();
        if(!$cast(apb_cfg, get_cfg))
            `uvm_error(get_type_name(), "config type is not svk_apb_agent_cfg")
        
        while(1)begin
            p_sequencer.response_request_port.peek(req);
            $cast(tr, req);

            if(tr.dir == svk_apb_dec::WRITE)begin
                p_sequencer.write_data_to_mem(tr);
            end
            else if(tr.dir == svk_apb_dec::READ)begin
                p_sequencer.read_data_from_mem(tr);
            end


            `uvm_send(tr)
        end

    endtask

endclass


`endif
