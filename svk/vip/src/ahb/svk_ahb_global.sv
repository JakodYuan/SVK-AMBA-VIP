/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/



`ifndef SVK_AHB_GLOBAL__SV
`define SVK_AHB_GLOBAL__SV
function void get_lanes(svk_ahb_transaction tr, int beat,  ref int lower_byte, ref int upper_byte);
    automatic int                     data_bus_bytes;
    automatic int                     bus_bytes;
    automatic bit [`SVK_AHB_ADDR_WIDTH-1:0] align_addr;
    automatic bit [`SVK_AHB_ADDR_WIDTH-1:0] curr_addr;
    automatic int lane_idx;

    data_bus_bytes = 1 << tr.size;
    bus_bytes      = tr.cfg.data_width/8;

    if(beat == 0)
        curr_addr  = tr.addr;
    else begin
        curr_addr = tr.addr + (beat * data_bus_bytes);
    end

    align_addr = curr_addr / bus_bytes * bus_bytes;
    lower_byte = curr_addr - align_addr;
    lane_idx   = lower_byte / data_bus_bytes;
    upper_byte = (lane_idx+1)*data_bus_bytes-1;
endfunction

`endif


