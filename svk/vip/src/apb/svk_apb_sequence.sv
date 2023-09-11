/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/

`ifndef SVK_APB_SEQUENCE__SV
`define SVK_APB_SEQUENCE__SV

class svk_apb_sequence extends svk_sequence;
    `uvm_object_utils(svk_apb_sequence)
    `uvm_declare_p_sequencer(svk_apb_sequencer)

    function new(string name="svk_apb_sequence");
        super.new(name);
    endfunction

endclass

`endif
