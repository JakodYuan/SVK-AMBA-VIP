/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_AXI_REG_EXTENSION__SV
`define SVK_AXI_REG_EXTENSION__SV


class svk_axi_reg_extension extends svk_extension;
    `uvm_object_utils(svk_axi_reg_extension)

    svk_axi_dec::prot_enum  prot;
    svk_axi_dec::lock_enum  lock;
    svk_axi_dec::cache_enum cache;

    function void pack_extension(uvm_sequence_item tr);
        svk_axi_transaction axi_tr;

        if(!$cast(axi_tr, tr))
            `uvm_error(get_type_name, "axi_extension must add to axi_transaction")

        axi_tr.prot  = prot;
        axi_tr.lock  = lock;
        axi_tr.cache = cache;
    endfunction

    function void unpack_extension(uvm_sequence_item tr);
        svk_axi_transaction axi_tr;

        if(!$cast(axi_tr, tr))
            `uvm_error(get_type_name, "axi_extension must add to axi_transaction")

        prot  = axi_tr.prot;
        lock  = axi_tr.lock;
        cache = axi_tr.cache;
    endfunction


    function new(string name="");
        super.new(name);
    endfunction
endclass

`endif
