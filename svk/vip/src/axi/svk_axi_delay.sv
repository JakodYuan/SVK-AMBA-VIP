/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_AXI_DELAY__SV
`define SVK_AXI_DELAY__SV
class svk_axi_delay_cfg extends uvm_object;
    int unsigned short_delay_min      = 1;
    int unsigned short_delay_max      = 3;
    int unsigned long_delay_min       = 4;
    int unsigned long_delay_max       = 100;

    int unsigned zero_delay_wt      = 100;
    int unsigned short_delay_wt     = 100;
    int unsigned long_delay_wt      = 100;

    bit          next_delay_is_zero = 1;


    `uvm_object_utils_begin(svk_axi_delay_cfg)
        `uvm_field_int(short_delay_min     , UVM_ALL_ON)
        `uvm_field_int(short_delay_max     , UVM_ALL_ON)
        `uvm_field_int(long_delay_min      , UVM_ALL_ON)
        `uvm_field_int(long_delay_max      , UVM_ALL_ON)
        `uvm_field_int(zero_delay_wt     , UVM_ALL_ON)
        `uvm_field_int(short_delay_wt    , UVM_ALL_ON)
        `uvm_field_int(long_delay_wt     , UVM_ALL_ON)
        `uvm_field_int(next_delay_is_zero, UVM_ALL_ON)
    `uvm_object_utils_end


    function new(string name="svk_axi_delay_cfg");
        super.new(name);
    endfunction

endclass


class svk_axi_delay_cfgs extends uvm_object;
    
    svk_axi_delay_cfg      awvalid_delay_cfg;
    svk_axi_delay_cfg      awready_delay_cfg;
    svk_axi_delay_cfg      arvalid_delay_cfg;
    svk_axi_delay_cfg      arready_delay_cfg;
    svk_axi_delay_cfg      wvalid_delay_cfg;
    svk_axi_delay_cfg      wready_delay_cfg;
    svk_axi_delay_cfg      rvalid_delay_cfg;
    svk_axi_delay_cfg      rready_delay_cfg;
    svk_axi_delay_cfg      bvalid_delay_cfg;
    svk_axi_delay_cfg      bready_delay_cfg;
    svk_axi_delay_cfg      common_delay_cfg;

    bit                all_in_one = 1;
    bit                first_ready_delay_not_zero = 0;


    `uvm_object_utils_begin(svk_axi_delay_cfgs)
        `uvm_field_object(awvalid_delay_cfg       , UVM_ALL_ON)
        `uvm_field_object(awready_delay_cfg       , UVM_ALL_ON)
        `uvm_field_object(arvalid_delay_cfg       , UVM_ALL_ON)
        `uvm_field_object(arready_delay_cfg       , UVM_ALL_ON)
        `uvm_field_object(wvalid_delay_cfg        , UVM_ALL_ON)
        `uvm_field_object(wready_delay_cfg        , UVM_ALL_ON)
        `uvm_field_object(rvalid_delay_cfg        , UVM_ALL_ON)
        `uvm_field_object(rready_delay_cfg        , UVM_ALL_ON)
        `uvm_field_object(bvalid_delay_cfg        , UVM_ALL_ON)
        `uvm_field_object(bready_delay_cfg        , UVM_ALL_ON)
        `uvm_field_object(common_delay_cfg        , UVM_ALL_ON)
        `uvm_field_int(all_in_one                 , UVM_ALL_ON)
        `uvm_field_int(first_ready_delay_not_zero , UVM_ALL_ON)
    `uvm_object_utils_end


    function new(string name="svk_axi_delay_cfgs");
        super.new(name);
        awvalid_delay_cfg = svk_axi_delay_cfg::type_id::create("awvalid_delay_cfg");
        awready_delay_cfg = svk_axi_delay_cfg::type_id::create("awready_delay_cfg");
        arvalid_delay_cfg = svk_axi_delay_cfg::type_id::create("arvalid_delay_cfg");
        arready_delay_cfg = svk_axi_delay_cfg::type_id::create("arready_delay_cfg");
        wvalid_delay_cfg  = svk_axi_delay_cfg::type_id::create("wvalid_delay_cfg");
        wready_delay_cfg  = svk_axi_delay_cfg::type_id::create("wready_delay_cfg");
        rvalid_delay_cfg  = svk_axi_delay_cfg::type_id::create("rvalid_delay_cfg");
        rready_delay_cfg  = svk_axi_delay_cfg::type_id::create("rready_delay_cfg");
        bvalid_delay_cfg  = svk_axi_delay_cfg::type_id::create("bvalid_delay_cfg");
        bready_delay_cfg  = svk_axi_delay_cfg::type_id::create("bready_delay_cfg");
        common_delay_cfg  = svk_axi_delay_cfg::type_id::create("bready_delay_cfg");
    endfunction
    
endclass

`endif
