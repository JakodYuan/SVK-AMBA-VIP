/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/

`ifndef SVK_AXI_SEQUENCE__SV
`define SVK_AXI_SEQUENCE__SV

class svk_axi_sequence extends svk_sequence;
    `uvm_object_utils(svk_axi_sequence)
    `uvm_declare_p_sequencer(svk_axi_sequencer)

    function new(string name="svk_axi_sequence");
        super.new(name);
    endfunction

endclass

`endif
