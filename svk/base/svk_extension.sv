/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_EXTENSION__SV
`define SVK_EXTENSION__SV

virtual class svk_extension extends uvm_object;

    pure virtual function void pack_extension(uvm_sequence_item tr);
    pure virtual function void unpack_extension(uvm_sequence_item tr);

    virtual function void add_extension(svk_extension ext);

    endfunction

    function new(string name="");
        super.new(name);
    endfunction
endclass

`endif
