/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


function void get_lanes(svk_axi_transaction tr, int beat, ref int lower_byte_lane, ref int upper_byte_lane, input int unsigned data_bus_bytes=0);
    automatic bit [`SVK_AXI_ADDR_WIDTH-1:0]  address_n;
    automatic bit [`SVK_AXI_ADDR_WIDTH-1:0]  aligned_addr;
    automatic bit [`SVK_AXI_ADDR_WIDTH-1:0]  wrap_address;
    automatic bit [`SVK_AXI_ADDR_WIDTH-1:0]  bus_start_addr;
    automatic int                            number_bytes;

    number_bytes = 1 << tr.size;
    aligned_addr = (tr.addr/number_bytes)*number_bytes;
    wrap_address = (tr.addr/(number_bytes*tr.length))*(number_bytes*tr.length);

    if(tr.burst == svk_axi_dec::BURST_FIXED)begin
        address_n = tr.addr;
    end
    else begin
        if(beat== 0)begin
            address_n = tr.addr;
        end
        else begin
            address_n = aligned_addr+beat*number_bytes;
        end
    end
    if(tr.burst == svk_axi_dec::BURST_WRAP)begin
        if(address_n >= wrap_address + (number_bytes*tr.length))begin
            address_n = address_n - (number_bytes*tr.length);
        end
    end

    if(data_bus_bytes == 0)begin
        `uvm_fatal("get_lanes", "data_bus_bytes = 0")

    end
    else begin
        bus_start_addr = (address_n/data_bus_bytes)*data_bus_bytes;
    end

    lower_byte_lane = address_n - bus_start_addr;

    if(tr.burst == svk_axi_dec::BURST_WRAP)begin
        upper_byte_lane = lower_byte_lane + number_bytes - 1;
    end
    else begin
        upper_byte_lane = aligned_addr + ((beat+1)*number_bytes-1) - bus_start_addr;
    end
endfunction
