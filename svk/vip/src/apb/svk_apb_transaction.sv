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

`ifndef SVK_APB_TRANSACTION__SV
`define SVK_APB_TRANSACTION__SV


class svk_apb_transaction extends uvm_sequence_item;

    rand svk_apb_dec::dir_enum                dir;
    rand bit [`SVK_APB_ADDR_WIDTH-1:0]        addr;
    rand bit [`SVK_APB_DATA_WIDTH-1:0]        data;
    rand bit [`SVK_APB_STRB_WIDTH-1:0]        strb;
    rand bit [`SVK_APB_USER_WIDTH-1:0]        user;
    rand bit [2                    :0]        prot;
    rand bit                                  resp;

    rand bit                                  need_resp      = 1 ;

    rand int unsigned                         ready_delay    = 0 ;

    rand int unsigned                         RESP_OKAY_wt   = 10;
    rand int unsigned                         RESP_ERROR_wt  = 10;

    int unsigned                              short_delay_l  = 0 ;
    int unsigned                              short_delay_h  = 2 ;
    int unsigned                              long_delay_l   = 3 ;
    int unsigned                              long_delay_h   = 99;

    int unsigned                              zero_delay_wt  = 10;
    int unsigned                              short_delay_wt = 0 ;
    int unsigned                              long_delay_wt  = 0 ;


    svk_apb_agent_cfg                             cfg;

    `uvm_object_utils_begin(svk_apb_transaction)
        `uvm_field_enum(svk_apb_dec::dir_enum, dir        , UVM_ALL_ON)
        `uvm_field_int(addr                  , UVM_ALL_ON)
        `uvm_field_int(data                  , UVM_ALL_ON)
        `uvm_field_int(strb                  , UVM_ALL_ON)
        `uvm_field_int(user                  , UVM_ALL_ON)
        `uvm_field_int(prot                  , UVM_ALL_ON)
        `uvm_field_int(resp                  , UVM_ALL_ON)
        `uvm_field_int(ready_delay           , UVM_ALL_ON)
        `uvm_field_int(need_resp             , UVM_ALL_ON)

        `uvm_field_int(RESP_OKAY_wt          , UVM_ALL_ON)
        `uvm_field_int(RESP_ERROR_wt         , UVM_ALL_ON)

        `uvm_field_int(short_delay_l         , UVM_ALL_ON)
        `uvm_field_int(short_delay_h         , UVM_ALL_ON)
        `uvm_field_int(long_delay_l          , UVM_ALL_ON)
        `uvm_field_int(long_delay_h          , UVM_ALL_ON)

        `uvm_field_int(zero_delay_wt         , UVM_ALL_ON)
        `uvm_field_int(short_delay_wt        , UVM_ALL_ON)
        `uvm_field_int(long_delay_wt         , UVM_ALL_ON)
        `uvm_field_object(cfg                , UVM_ALL_ON)
    `uvm_object_utils_end


    constraint con_need_resp {
        soft need_resp == 1;
    }

    constraint con_strb {
        dir == svk_apb_dec::READ  -> strb == 'h0;
        dir == svk_apb_dec::WRITE -> strb inside {[1:15]};
    }


    constraint con_addr {
        addr[1:0] == 0;
        addr <= ((`SVK_APB_ADDR_WIDTH'h1) << cfg.addr_width) - 1;
    }

    constraint con_data {
        data <= ((`SVK_APB_DATA_WIDTH'h1) << cfg.data_width) - 1;
    }

    constraint con_resp {
        resp dist {0:/RESP_OKAY_wt, 1:/RESP_ERROR_wt};
    }


    constraint con_ready_delay {
        ready_delay dist {
            0                              :/ zero_delay_wt,
            [short_delay_l:short_delay_h]  :/ short_delay_wt,
            [long_delay_l :long_delay_h]   :/ long_delay_wt
        };
    };

    function new(string name="");
        super.new(name);
    endfunction
endclass


`endif
