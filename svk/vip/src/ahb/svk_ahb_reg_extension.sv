/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_AHB_REG_EXTENSION__SV
`define SVK_AHB_REG_EXTENSION__SV


class svk_ahb_reg_extension extends svk_extension;
    `uvm_object_utils(svk_ahb_reg_extension)

    bit data_or_instr;
    bit privileged;
    bit bufferable;
    bit modifiable;
    bit nonsec;

    function void pack_extension(uvm_sequence_item tr);
        svk_ahb_transaction ahb_tr;

        if(!$cast(ahb_tr, tr))
            `uvm_error(get_type_name, "ahb_extension must add to ahb_transaction")

        ahb_tr.prot[0]  = data_or_instr;
        ahb_tr.prot[1]  = privileged;
        ahb_tr.prot[2]  = bufferable;
        ahb_tr.prot[3]  = modifiable;
        ahb_tr.nonsec   = svk_ahb_dec::nonsec_enum'(nonsec);
    endfunction

    function void unpack_extension(uvm_sequence_item tr);
        svk_ahb_transaction ahb_tr;

        if(!$cast(ahb_tr, tr))
            `uvm_error(get_type_name, "ahb_extension must add to ahb_transaction")

         data_or_instr = ahb_tr.prot[0];
         privileged    = ahb_tr.prot[1];
         bufferable    = ahb_tr.prot[2];
         modifiable    = ahb_tr.prot[3];
         nonsec        = ahb_tr.nonsec ;
    endfunction


    function new(string name="");
        super.new(name);
    endfunction
endclass

`endif
