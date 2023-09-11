/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/

`ifndef SVK_AHB_SEQUENCE__SV
`define SVK_AHB_SEQUENCE__SV

class svk_ahb_sequence extends svk_sequence;
    `uvm_object_utils(svk_ahb_sequence)
    `uvm_declare_p_sequencer(svk_ahb_sequencer)

    function new(string name="svk_ahb_sequence");
        super.new(name);
    endfunction

endclass

`endif
