/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_VIRTUAL_SEQUENCER__SV
`define SVK_VIRTUAL_SEQUENCER__SV

class svk_virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils(svk_virtual_sequencer)
    uvm_sequencer   all_sqr[string];

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void add_sqr(string name, uvm_sequencer sqr);
        if(!all_sqr.exists(name))
            all_sqr[name] = sqr;
        else
            `uvm_fatal("", {name, " is exist in all_sqr"});
    endfunction

    function uvm_sequencer get_sqr_by_name(string name);
        uvm_sequencer sqr;

        foreach(all_sqr[sqr_name])begin
            if(uvm_is_match({"*", name, "*"}, sqr_name))begin
                sqr = all_sqr[sqr_name];
                break;
            end
            if(uvm_is_match({"*", sqr_name, "*"}, name))begin
                sqr = all_sqr[sqr_name];
                break;
            end
        end

        if(sqr != null)
            return sqr;
        else
            `uvm_fatal("", {name, " is not exist in all_sqr"})
    endfunction

endclass
`endif
