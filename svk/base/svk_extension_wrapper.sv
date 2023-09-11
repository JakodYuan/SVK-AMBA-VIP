/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_EXTENSION_WRAPPER__SV
`define SVK_EXTENSION_WRAPPER__SV

class svk_extension_wrapper extends svk_extension;
    `uvm_object_utils(svk_extension_wrapper)

    svk_extension exts[uvm_object_wrapper];

    function void pack_extension(uvm_sequence_item tr);
        foreach(exts[i])begin
            exts[i].pack_extension(tr);
        end
    endfunction

    function void unpack_extension(uvm_sequence_item tr);
        foreach(exts[i])begin
            exts[i].unpack_extension(tr);
        end
    endfunction


    function void add_extension(svk_extension ext);
        if(!exts.exists(ext.get_object_type()))begin
            exts[ext.get_object_type()] = ext;
        end
    endfunction

    function new(string name="");
        super.new(name);
    endfunction
endclass

`endif
