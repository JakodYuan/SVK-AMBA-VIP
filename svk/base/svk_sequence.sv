/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_SEQUENCE__SV
`define SVK_SEQUENCE__SV

class svk_sequence extends uvm_sequence;
    `uvm_object_utils(svk_sequence)



    extern function new(string name="svk_sequence");




endclass


function svk_sequence::new(string name="svk_sequence");
    super.new(name);
endfunction




































`endif
