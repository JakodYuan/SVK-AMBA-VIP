/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/



`ifndef SVK_RM__SV
`define SVK_RM__SV

class svk_rm extends uvm_component;
    `uvm_analysis_imp_decl(_mon)
    `uvm_analysis_imp_decl(_chk)

    uvm_analysis_export#(uvm_sequence_item) svk_export;
    uvm_analysis_port#(uvm_sequence_item)   svk_port;
    svk_dec::switch_enum                    work_en = svk_dec::ON;



    `uvm_component_utils_begin(svk_rm)
        `uvm_field_enum(svk_dec::switch_enum, work_en , UVM_ALL_ON)
    `uvm_component_utils_end


    function new(string name="svk_rm", uvm_component parent);
        super.new(name, parent);


        svk_export = new("svk_mon_export", this);
        svk_port   = new("svk_chk_port", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);


    endfunction

endclass
`endif

