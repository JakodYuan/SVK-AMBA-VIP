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

`ifndef SVK_AXI_LINEDATA__SV
`define SVK_AXI_LINEDATA__SV

class svk_axi_linedata extends uvm_object;
    int cid;
    bit vld;

    `uvm_object_utils_begin(svk_axi_linedata)
        `uvm_field_int(cid, UVM_ALL_ON)
        `uvm_field_int(vld, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name="svk_axi_linedata");
        super.new(name);
    endfunction
endclass


class svk_aw_linedata extends svk_axi_linedata;
    rand bit [`SVK_AXI_ID_WIDTH    -1:0]     id    ;    
    rand bit [`SVK_AXI_ADDR_WIDTH  -1:0]     addr  ;  
    rand bit [`SVK_AXI_LEN_WIDTH   -1:0]     len   ;   
    rand bit [`SVK_AXI_SIZE_WIDTH  -1:0]     size  ;  
    rand bit [`SVK_AXI_BURST_WIDTH -1:0]     burst ; 
    rand bit [`SVK_AXI_LOCK_WIDTH  -1:0]     lock  ;  
    rand bit [`SVK_AXI_CACHE_WIDTH -1:0]     cache ; 
    rand bit [`SVK_AXI_PROT_WIDTH  -1:0]     prot  ;  
    rand bit [`SVK_AXI_QOS_WIDTH   -1:0]     qos   ;   
    rand bit [`SVK_AXI_REGION_WIDTH-1:0]     region;
    rand bit [`SVK_AXI_USER_WIDTH  -1:0]     user  ;  

    `uvm_object_utils_begin(svk_aw_linedata)
        `uvm_field_int(id    , UVM_ALL_ON)
        `uvm_field_int(addr  , UVM_ALL_ON)
        `uvm_field_int(len   , UVM_ALL_ON)
        `uvm_field_int(size  , UVM_ALL_ON)
        `uvm_field_int(burst , UVM_ALL_ON)
        `uvm_field_int(lock  , UVM_ALL_ON)
        `uvm_field_int(cache , UVM_ALL_ON)
        `uvm_field_int(prot  , UVM_ALL_ON)
        `uvm_field_int(qos   , UVM_ALL_ON)
        `uvm_field_int(region, UVM_ALL_ON)
        `uvm_field_int(user  , UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name="svk_axi_linedata");
        super.new(name);
        this.zero_cons.constraint_mode(0);
        this.max_cons.constraint_mode(0);
    endfunction

    constraint zero_cons {
        id     == 0;
        addr   == 0;
        len    == 0;
        size   == 0;
        burst  == 0;
        lock   == 0;
        cache  == 0;
        prot   == 0;
        qos    == 0;
        region == 0;
        user   == 0;
    }

    constraint max_cons {
        id     == {(`SVK_AXI_ID_WIDTH    ){1'b1}};
        addr   == {(`SVK_AXI_ADDR_WIDTH  ){1'b1}};
        len    == {(`SVK_AXI_LEN_WIDTH   ){1'b1}};
        size   == {(`SVK_AXI_SIZE_WIDTH  ){1'b1}};
        burst  == {(`SVK_AXI_BURST_WIDTH ){1'b1}};
        lock   == {(`SVK_AXI_LOCK_WIDTH  ){1'b1}};
        cache  == {(`SVK_AXI_CACHE_WIDTH ){1'b1}};
        prot   == {(`SVK_AXI_PROT_WIDTH  ){1'b1}};
        qos    == {(`SVK_AXI_QOS_WIDTH   ){1'b1}};
        region == {(`SVK_AXI_REGION_WIDTH){1'b1}};
        user   == {(`SVK_AXI_USER_WIDTH  ){1'b1}};
    }

endclass


class svk_w_linedata extends svk_axi_linedata;
    rand bit [`SVK_AXI_ID_WIDTH   -1:0] id  ;  
    rand bit [`SVK_AXI_DATA_WIDTH -1:0] data;
    rand bit [`SVK_AXI_WSTRB_WIDTH-1:0] strb;
    rand bit [0                     :0] last;
    rand bit [`SVK_AXI_USER_WIDTH -1:0] user;

    `uvm_object_utils_begin(svk_w_linedata)
        `uvm_field_int(id  , UVM_ALL_ON)
        `uvm_field_int(data, UVM_ALL_ON)
        `uvm_field_int(strb, UVM_ALL_ON)
        `uvm_field_int(last, UVM_ALL_ON)
        `uvm_field_int(user, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name="svk_axi_linedata");
        super.new(name);
        this.zero_cons.constraint_mode(0);
        this.max_cons.constraint_mode(0);
    endfunction

    constraint zero_cons {
        id   == 0;
        data == 0;
        strb == 0;
        last == 0;
        user == 0;
    }

    constraint max_cons {
        id   == {(`SVK_AXI_ID_WIDTH   ){1'b1}};
        data == {(`SVK_AXI_DATA_WIDTH ){1'b1}};
        strb == {(`SVK_AXI_WSTRB_WIDTH){1'b1}};
        user == {(`SVK_AXI_USER_WIDTH ){1'b1}};
        last == 1'b1;
    }
endclass


class svk_ar_linedata extends svk_axi_linedata;
    rand bit [`SVK_AXI_ID_WIDTH    -1:0] id    ;    
    rand bit [`SVK_AXI_ADDR_WIDTH  -1:0] addr  ;  
    rand bit [`SVK_AXI_LEN_WIDTH   -1:0] len   ;   
    rand bit [`SVK_AXI_SIZE_WIDTH  -1:0] size  ;  
    rand bit [`SVK_AXI_BURST_WIDTH -1:0] burst ; 
    rand bit [`SVK_AXI_LOCK_WIDTH  -1:0] lock  ;  
    rand bit [`SVK_AXI_CACHE_WIDTH -1:0] cache ; 
    rand bit [`SVK_AXI_PROT_WIDTH  -1:0] prot  ;  
    rand bit [`SVK_AXI_QOS_WIDTH   -1:0] qos   ;   
    rand bit [`SVK_AXI_REGION_WIDTH-1:0] region;
    rand bit [`SVK_AXI_USER_WIDTH  -1:0] user  ;  

    `uvm_object_utils_begin(svk_ar_linedata)
        `uvm_field_int(id    , UVM_ALL_ON)
        `uvm_field_int(addr  , UVM_ALL_ON)
        `uvm_field_int(len   , UVM_ALL_ON)
        `uvm_field_int(size  , UVM_ALL_ON)
        `uvm_field_int(burst , UVM_ALL_ON)
        `uvm_field_int(lock  , UVM_ALL_ON)
        `uvm_field_int(cache , UVM_ALL_ON)
        `uvm_field_int(prot  , UVM_ALL_ON)
        `uvm_field_int(qos   , UVM_ALL_ON)
        `uvm_field_int(region, UVM_ALL_ON)
        `uvm_field_int(user  , UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name="svk_axi_linedata");
        super.new(name);
        this.zero_cons.constraint_mode(0);
        this.max_cons.constraint_mode(0);
    endfunction

    constraint zero_cons {
        id    == 0;
        addr  == 0;
        len   == 0;
        size  == 0;
        burst == 0;
        lock  == 0;
        cache == 0;
        prot  == 0;
        qos   == 0;
        region== 0;
        user  == 0;
    }

    constraint max_cons {
        id    == {(`SVK_AXI_ID_WIDTH    ){1'b1}};
        addr  == {(`SVK_AXI_ADDR_WIDTH  ){1'b1}};
        len   == {(`SVK_AXI_LEN_WIDTH   ){1'b1}};
        size  == {(`SVK_AXI_SIZE_WIDTH  ){1'b1}};
        burst == {(`SVK_AXI_BURST_WIDTH ){1'b1}};
        lock  == {(`SVK_AXI_LOCK_WIDTH  ){1'b1}};
        cache == {(`SVK_AXI_CACHE_WIDTH ){1'b1}};
        prot  == {(`SVK_AXI_PROT_WIDTH  ){1'b1}};
        qos   == {(`SVK_AXI_QOS_WIDTH   ){1'b1}};
        region== {(`SVK_AXI_REGION_WIDTH){1'b1}};
        user  == {(`SVK_AXI_USER_WIDTH  ){1'b1}};
    }
endclass

class svk_b_linedata extends svk_axi_linedata;
    rand bit [`SVK_AXI_ID_WIDTH  -1:0]   id  ;
    rand bit [`SVK_AXI_RESP_WIDTH-1:0]   resp;
    rand bit [`SVK_AXI_USER_WIDTH-1:0]   user;

    `uvm_object_utils_begin(svk_b_linedata)
        `uvm_field_int(id,   UVM_ALL_ON)
        `uvm_field_int(resp, UVM_ALL_ON)
        `uvm_field_int(user, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name="svk_axi_linedata");
        super.new(name);
        this.zero_cons.constraint_mode(0);
        this.max_cons.constraint_mode(0);
    endfunction

    constraint zero_cons {
        id   == 0;
        resp == 0;
        user == 0;
    }

    constraint max_cons {
        id   == {(`SVK_AXI_ID_WIDTH  ){1'b1}};
        resp == {(`SVK_AXI_RESP_WIDTH){1'b1}};
        user == {(`SVK_AXI_USER_WIDTH){1'b1}};
    }
endclass


class svk_r_linedata extends svk_axi_linedata;
    rand bit [`SVK_AXI_ID_WIDTH  -1:0] id  ;  
    rand bit [`SVK_AXI_DATA_WIDTH-1:0] data;
    rand bit [`SVK_AXI_RESP_WIDTH-1:0] resp;
    rand bit [0:0]                     last;
    rand bit [`SVK_AXI_USER_WIDTH-1:0] user;

    `uvm_object_utils_begin(svk_r_linedata)
        `uvm_field_int(id  , UVM_ALL_ON)
        `uvm_field_int(data, UVM_ALL_ON)
        `uvm_field_int(resp, UVM_ALL_ON)
        `uvm_field_int(last, UVM_ALL_ON)
        `uvm_field_int(user, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name="svk_axi_linedata");
        super.new(name);
    endfunction

    constraint zero_cons {
        id   == 0;  
        data == 0;
        resp == 0;
        last == 0;
        user == 0;
    }

    constraint max_cons {
        id   == {(`SVK_AXI_ID_WIDTH  ){1'b1}};  
        data == {(`SVK_AXI_DATA_WIDTH){1'b1}};
        resp == {(`SVK_AXI_RESP_WIDTH){1'b1}};
        user == {(`SVK_AXI_USER_WIDTH){1'b1}};
        last ==  1;
    
    }
endclass

`endif
