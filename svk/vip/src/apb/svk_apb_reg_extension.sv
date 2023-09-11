/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_APB_REG_EXTENSION__SV
`define SVK_APB_REG_EXTENSION__SV


class svk_apb_reg_extension extends svk_extension;
    `uvm_object_utils(svk_apb_reg_extension)

    bit privil;
    bit secure;
    bit data_or_instr;

    function void pack_extension(uvm_sequence_item tr);
        svk_apb_transaction apb_tr;

        if(!$cast(apb_tr, tr))
            `uvm_error(get_type_name, "apb_extension must add to apb_transaction")

        apb_tr.prot[0]  = privil;
        apb_tr.prot[1]  = secure;
        apb_tr.prot[2]  = data_or_instr;
    endfunction

    function void unpack_extension(uvm_sequence_item tr);
        svk_apb_transaction apb_tr;

        if(!$cast(apb_tr, tr))
            `uvm_error(get_type_name, "apb_extension must add to apb_transaction")

        privil        = apb_tr.prot[0];
        secure        = apb_tr.prot[1];
        data_or_instr = apb_tr.prot[2];
    endfunction


    function new(string name="");
        super.new(name);
    endfunction
endclass

`endif
