/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/

`ifndef SVK_AXI_DEFAULT_SLAVA_SEQUENCE__SV
`define SVK_AXI_DEFAULT_SLAVA_SEQUENCE__SV

class svk_axi_default_slave_sequence extends svk_axi_sequence;
    `uvm_object_utils(svk_axi_default_slave_sequence)

    function new(string name="default_slave_seq");
        super.new(name);
    endfunction

    task body();
        svk_axi_transaction tr;



        forever begin
            p_sequencer.response_request_port.peek(req);
            $cast(tr, req);

            tr.randomize();

            tr.awready_delay = 2;
            tr.arready_delay = 0;
            foreach(tr.wready_delay[i])
                tr.wready_delay[i] = i;

            tr.bvalid_delay = 1;
            foreach(tr.rvalid_delay[i])
                tr.rvalid_delay[i] = i;

            if(tr.dir == svk_axi_dec::WRITE)begin
                p_sequencer.write_data_to_mem(tr);
            end
            else if(tr.dir == svk_axi_dec::READ)begin
                p_sequencer.read_data_from_mem(tr);
            end


            `uvm_send(tr)
        end

    endtask

endclass

`endif
