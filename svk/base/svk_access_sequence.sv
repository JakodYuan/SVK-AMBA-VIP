/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/

`ifndef SVK_ACCESS_SEQUENCE__SV
`define SVK_ACCESS_SEQUENCE__SV

class svk_access_sequence extends uvm_sequence;
    `uvm_object_utils(svk_access_sequence)

    function new(string name="svk_access_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_send(req);
        get_response(rsp, req.get_transaction_id());
    endtask

endclass

`endif
