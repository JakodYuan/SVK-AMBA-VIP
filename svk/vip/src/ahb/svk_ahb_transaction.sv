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

`ifndef SVK_AHB_TRANSACTION__SV
`define SVK_AHB_TRANSACTION__SV


class svk_ahb_transaction extends uvm_sequence_item;

    rand logic [`SVK_AHB_ADDR_WIDTH-1:0]            addr;
    rand logic [`SVK_AHB_CTRL_USER_WIDTH-1:0]       ctrl_user;
    rand logic                                      lock;
    rand int unsigned                               num_idle_cycles = 1;
    rand int unsigned                               num_incr_beats = 1;

    rand logic [`SVK_AHB_DATA_WIDTH-1:0]            data[];
    rand logic [`SVK_AHB_STRB_WIDTH-1:0]            strb[];
    rand logic [`SVK_AHB_DATA_USER_WIDTH-1:0]       data_user[];
    rand int unsigned                               num_busy_cycles[];
    rand int unsigned                               num_wait_cycles[];

    rand svk_ahb_dec::dir_enum                      dir;

    rand svk_ahb_dec::burst_enum                    burst;
    rand svk_ahb_dec::nonsec_enum                   nonsec;
    rand svk_ahb_dec::size_enum                     size;
    rand logic [`SVK_AHB_PROT_WIDTH-1:0]            prot;

    rand svk_ahb_dec::resp_enum                     resp[];


    int unsigned                                    RESP_OKAY_wt   = 10;
    int unsigned                                    RESP_ERROR_wt  = 10;
    int unsigned                                    RESP_RETRY_wt  = 10;
    int unsigned                                    RESP_SPLIT_wt  = 10;


    svk_ahb_agent_cfg                               cfg;
    bit                                             is_finish;
    rand int                                        length;

    int                                             cmd_idx;
    int                                             dat_idx;
    int                                             rsp_idx;

    rand bit                                        need_resp;


    `uvm_object_utils_begin(svk_ahb_transaction)
        `uvm_field_int(need_resp               , UVM_ALL_ON)
        `uvm_field_int(addr                    , UVM_ALL_ON)
        `uvm_field_int(prot                    , UVM_ALL_ON)
        `uvm_field_int(ctrl_user               , UVM_ALL_ON)
        `uvm_field_int(lock                    , UVM_ALL_ON)
        `uvm_field_int(need_resp               , UVM_ALL_ON)
        `uvm_field_int(num_incr_beats          , UVM_ALL_ON)
        `uvm_field_int(num_idle_cycles         , UVM_ALL_ON)

        `uvm_field_int(cmd_idx         , UVM_ALL_ON)
        `uvm_field_int(dat_idx         , UVM_ALL_ON)
        `uvm_field_int(rsp_idx         , UVM_ALL_ON)

        `uvm_field_array_int(data              , UVM_ALL_ON)
        `uvm_field_array_int(strb              , UVM_ALL_ON)
        `uvm_field_array_int(data_user         , UVM_ALL_ON)
        `uvm_field_array_int(num_busy_cycles   , UVM_ALL_ON)
        `uvm_field_array_int(num_wait_cycles   , UVM_ALL_ON)

        `uvm_field_enum(svk_ahb_dec::dir_enum       , dir        , UVM_ALL_ON)

        `uvm_field_enum(svk_ahb_dec::burst_enum     , burst      , UVM_ALL_ON)
        `uvm_field_enum(svk_ahb_dec::nonsec_enum    , nonsec     , UVM_ALL_ON)
        `uvm_field_enum(svk_ahb_dec::size_enum      , size       , UVM_ALL_ON)
        `uvm_field_array_enum(svk_ahb_dec::resp_enum, resp       , UVM_ALL_ON)

        `uvm_field_object(cfg                  , UVM_ALL_ON)


    `uvm_object_utils_end

    constraint con_size {
        2**size*8 <= cfg.data_width;
    }

    constraint con_dir {
        dir dist {svk_ahb_dec::READ :/1, svk_ahb_dec::WRITE :/1};
    }


    constraint con_addr {
        size == svk_ahb_dec::SIZE_16BIT   -> addr[0:0] == 0;
        size == svk_ahb_dec::SIZE_32BIT   -> addr[1:0] == 0;
        size == svk_ahb_dec::SIZE_64BIT   -> addr[2:0] == 0;
        size == svk_ahb_dec::SIZE_128BIT  -> addr[3:0] == 0;
        size == svk_ahb_dec::SIZE_256BIT  -> addr[4:0] == 0;
        size == svk_ahb_dec::SIZE_512BIT  -> addr[5:0] == 0;
        size == svk_ahb_dec::SIZE_1024BIT -> addr[6:0] == 0;
        
        addr <= ({(`SVK_AHB_ADDR_WIDTH+1){1'b1}} << cfg.addr_width) - 1;

        (addr[9:0]/(1<<size))*(1<<size) + (length * (1<<size)) <= 1024;
    }

    constraint con_data {
        solve length before data;
        if(dir == svk_ahb_dec::WRITE || dir == svk_ahb_dec::READ) {
            data.size == length;
            foreach(data[i]) {
                data[i] <= ({(`SVK_AHB_DATA_WIDTH+1){1'b1}} << cfg.data_width) - 1;
            }
        }
    }


    constraint con_strb {
        solve length before strb;

        if(dir == svk_ahb_dec::READ) {
            strb.size == 0;
        } else {
            strb.size == length;
            foreach(strb[i]) {
                strb[i] < ({(`SVK_AHB_STRB_WIDTH+1){1'b1}} << (cfg.data_width/8)) - 1;
            }
        }
    }

    constraint con_ctrl_user {
        ctrl_user < ({(`SVK_AHB_CTRL_USER_WIDTH+1){1'b1}} << cfg.ctrl_user_width);
    }

    constraint con_data_user {
        data_user.size == length;
        foreach(data_user[i]) {
            data_user[i] < ({(`SVK_AHB_DATA_USER_WIDTH+1){1'b1}} << cfg.data_user_width);
        }
    }

    constraint con_lock {

    }










    constraint con_burst {
        burst dist { 
            svk_ahb_dec::SINGLE := 1,
            svk_ahb_dec::INCR   := 1,
            svk_ahb_dec::WRAP4  := 1,
            svk_ahb_dec::INCR4  := 1,
            svk_ahb_dec::WRAP8  := 1,
            svk_ahb_dec::INCR8  := 1,
            svk_ahb_dec::WRAP16 := 1,
            svk_ahb_dec::INCR16 := 1
        };
    }



    constraint con_length {
        burst == svk_ahb_dec::SINGLE -> length == 1;
        burst == svk_ahb_dec::INCR   -> length == num_incr_beats;
        burst == svk_ahb_dec::WRAP4  -> length == 4;
        burst == svk_ahb_dec::INCR4  -> length == 4;
        burst == svk_ahb_dec::WRAP8  -> length == 8;
        burst == svk_ahb_dec::INCR8  -> length == 8;
        burst == svk_ahb_dec::WRAP16 -> length == 16;
        burst == svk_ahb_dec::INCR16 -> length == 16;
    }


    constraint con_resp {
        resp.size == length;
        foreach(resp[i]) {
            resp[i] dist {0:/RESP_OKAY_wt, 1:/RESP_ERROR_wt, 2:/RESP_RETRY_wt, 3:/RESP_SPLIT_wt};
        }
    }


    constraint con_num_idle_cycles {
        num_idle_cycles dist {0:/6, [1:3]:/3, [4:10]:/2};
    }

    constraint con_num_busy_cycles {
        solve length before num_busy_cycles;
        num_busy_cycles.size == length - 1;
        foreach(num_busy_cycles[i]) {
            num_busy_cycles[i] dist {0:/6, [1:3]:/3, [4:10]:/2};
        }
    };

    constraint con_num_wait_cycles {
        solve length before num_wait_cycles;
        num_wait_cycles.size == length;
        foreach(num_wait_cycles[i]) {
            num_wait_cycles[i] dist {0:/6, [1:3]:/3, [4:10]:/2};
        }
    };


    constraint con_need_resp {
        soft need_resp == 1;
    }

    function new(string name="");
        super.new(name);
    endfunction

    function int get_len();
        int len;

        case(burst)
            svk_ahb_dec::SINGLE  : len = 1;
            svk_ahb_dec::INCR    : len = num_incr_beats;
            svk_ahb_dec::WRAP4   : len = 4;
            svk_ahb_dec::INCR4   : len = 4;
            svk_ahb_dec::WRAP8   : len = 8;
            svk_ahb_dec::INCR8   : len = 8;
            svk_ahb_dec::WRAP16  : len = 16;
            svk_ahb_dec::INCR16  : len = 16;
        endcase

        return len;
    endfunction
endclass


`endif

