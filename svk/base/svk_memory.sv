/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


class svk_memory;
    svk_dec::default_value_enum     mem_default_value;
    byte                            mem[longint]; 




    function new(svk_dec::default_value_enum default_value);
        mem_default_value = default_value;
    endfunction

    function void set(bit[63:0] addr, byte value);
        mem[addr] = value;
    endfunction

    function byte get(bit[63:0] addr);
        if(mem.exists(addr))begin
            return mem[addr];
        end
        else begin
            case(mem_default_value)
                svk_dec::DEFAULT_ZERO:    return 8'h0;
                svk_dec::DEFAULT_RAND:    return $urandom_range(8'h0,8'hff);
                svk_dec::DEFAULT_MAX:     return 8'hff;
            endcase
        end
    endfunction
endclass
