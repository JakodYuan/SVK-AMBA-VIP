/**
 *  Copyright (C) 2023-2024 JakodYuan. ( JakodYuan@outlook.com )
 *
 *  Licensed under the GNU LESSER GENERAL PUBLIC LICENSE, Version 3.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *          http://www.gnu.org/licenses/lgpl.html
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

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
