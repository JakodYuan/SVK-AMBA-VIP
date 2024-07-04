/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_AXI_TRANSACTION__SV
`define SVK_AXI_TRANSACTION__SV

typedef class svk_axi_agent_cfg;

class svk_axi_transaction extends uvm_sequence_item;
    rand svk_axi_dec::dir_enum                      dir            ;
    rand svk_axi_dec::length_enum                   length         ;
    rand svk_axi_dec::size_enum                     size           ;
    rand svk_axi_dec::burst_enum                    burst          ;
    rand svk_axi_dec::lock_enum                     lock           ;
    rand svk_axi_dec::cache_enum                    cache          ;
    rand svk_axi_dec::prot_enum                     prot           ;
    rand svk_axi_dec::resp_enum                     resp[]        ;

    rand bit [`SVK_AXI_WSTRB_WIDTH  -1: 0]          wstrb[]       ;
    rand bit [`SVK_AXI_DATA_WIDTH   -1: 0]          data[]        ;
    rand bit [`SVK_AXI_ADDR_WIDTH   -1: 0]          addr           ;
    rand bit [`SVK_AXI_ID_WIDTH     -1: 0]          id             ;
    rand bit [`SVK_AXI_USER_WIDTH   -1: 0]          auser          ;
    rand bit [`SVK_AXI_USER_WIDTH   -1: 0]          ruser[]       ;
    rand bit [`SVK_AXI_USER_WIDTH   -1: 0]          wuser[]       ;
    rand bit [`SVK_AXI_USER_WIDTH   -1: 0]          buser          ;
    rand bit [`SVK_AXI_QOS_WIDTH    -1: 0]          qos            ;
    rand bit [`SVK_AXI_REGION_WIDTH -1: 0]          region         ;
    uvm_object                                      extension      ;
    rand bit                                        need_resp      ;


    rand int                                        awready_delay  ;
    rand int                                        awvalid_delay  ;
    rand int                                        arready_delay  ;
    rand int                                        arvalid_delay  ;
    rand int                                        wready_delay[] ;
    rand int                                        wvalid_delay[] ;
    rand int                                        rready_delay[] ;
    rand int                                        rvalid_delay[] ;
    rand int                                        bvalid_delay   ;
    rand int                                        bready_delay   ;

    
    svk_axi_agent_cfg                               cfg;

    int unsigned short_delay_min      = 1;
    int unsigned short_delay_max      = 3;
    int unsigned long_delay_min       = 4;
    int unsigned long_delay_max       = 100;

    int unsigned zero_delay_wt        = 100;
    int unsigned short_delay_wt       = 100;
    int unsigned long_delay_wt        = 100;

    bit          next_delay_is_zero   = 1;

    bit          write_finish         = 0;


    int unsigned RESP_DECERR_wt = 1;
    int unsigned RESP_EXOKAY_wt = 1;
    int unsigned RESP_OKAY_wt   = 1;
    int unsigned RESP_SLVERR_wt = 1;

    constraint con_burst {
        burst inside {[svk_axi_dec::BURST_FIXED : svk_axi_dec::BURST_WRAP]};
    }

    constraint con_lock {
        lock inside {[svk_axi_dec::NORMAL : svk_axi_dec::LOCKED]};
    }

    constraint con_cache {
        if(lock == svk_axi_dec::EXCLUSIVE) {
            cache == svk_axi_dec::NON_CACHEABLE_NO_BUFFERABLE;
        }
    }

    constraint con_id {
        id <= ~({(`SVK_AXI_ID_WIDTH){1'b1}} << cfg.id_width);
    }

    constraint con_wstrb {
        solve size before wstrb;
        solve length before wstrb;
        wstrb.size == length + 1;

        foreach(wstrb[idx]) {
            if(length >= idx) {

                (size == svk_axi_dec::SIZE_8BIT    ) -> ((wstrb[idx] >= 128'h0) && (wstrb[idx] <= {(1){1'b1}}));
                (size == svk_axi_dec::SIZE_16BIT   ) -> ((wstrb[idx] >= 128'h0) && (wstrb[idx] <= {(2){1'b1}}));
                (size == svk_axi_dec::SIZE_32BIT   ) -> ((wstrb[idx] >= 128'h0) && (wstrb[idx] <= {(4){1'b1}}));
                (size == svk_axi_dec::SIZE_64BIT   ) -> ((wstrb[idx] >= 128'h0) && (wstrb[idx] <= {(8){1'b1}}));
                (size == svk_axi_dec::SIZE_128BIT  ) -> ((wstrb[idx] >= 128'h0) && (wstrb[idx] <= {(16){1'b1}}));
                (size == svk_axi_dec::SIZE_256BIT  ) -> ((wstrb[idx] >= 128'h0) && (wstrb[idx] <= {(32){1'b1}}));
                (size == svk_axi_dec::SIZE_512BIT  ) -> ((wstrb[idx] >= 128'h0) && (wstrb[idx] <= {(64){1'b1}}));
                (size == svk_axi_dec::SIZE_1024BIT ) -> ((wstrb[idx] >= 128'h0) && (wstrb[idx] <= {(128){1'b1}}));
            }
        }
    }

    constraint con_data {
        solve size before data;
        solve length before data;
        data.size == length + 1;
        foreach(data[idx]) {
            if (length >= idx) {
                (size == svk_axi_dec::SIZE_8BIT   ) -> data[idx][1023:8]   == 1016'h0;
                (size == svk_axi_dec::SIZE_16BIT  ) -> data[idx][1023:16]  == 1008'h0;
                (size == svk_axi_dec::SIZE_32BIT  ) -> data[idx][1023:32]  == 992'h0;
                (size == svk_axi_dec::SIZE_64BIT  ) -> data[idx][1023:64]  == 960'h0;
                (size == svk_axi_dec::SIZE_128BIT ) -> data[idx][1023:128] == 896'h0;
                (size == svk_axi_dec::SIZE_256BIT ) -> data[idx][1023:256] == 768'h0;
                (size == svk_axi_dec::SIZE_512BIT ) -> data[idx][1023:512] == 512'h0;
            }
        }
    }


    constraint con_resp {
        solve dir before resp;
        solve length before resp;
        if (dir == svk_axi_dec::READ) {
            resp.size == length + 1;
        } else {
            resp.size == 1;
        }

        foreach(resp[i]) {
            resp[i] dist {
                svk_axi_dec::OKAY   :/ RESP_OKAY_wt,
                svk_axi_dec::EXOKAY :/ (RESP_EXOKAY_wt*(lock == svk_axi_dec::EXCLUSIVE)),
                svk_axi_dec::SLVERR :/ RESP_SLVERR_wt,
                svk_axi_dec::DECERR :/ RESP_DECERR_wt
            };
        }
    }

    constraint con_length {
        solve burst before length;
        solve lock  before length;
        solve size  before length;

        if(cfg.version == svk_axi_dec::AXI4) {
            length inside {[0:255]};
        } else {
            length inside {[0:15]};
        }




        if(burst == svk_axi_dec::BURST_WRAP) {
            length inside {
                svk_axi_dec::LENGTH_2,
                svk_axi_dec::LENGTH_4,
                svk_axi_dec::LENGTH_8,
                svk_axi_dec::LENGTH_16
            };
        }

        if(lock == svk_axi_dec::EXCLUSIVE) {
            2**size * (length + 1) inside {2, 4, 8, 16, 32, 64, 128};
            if(cfg.version == svk_axi_dec::AXI4) {
                length <= svk_axi_dec::LENGTH_16;
            }
        }
    }

    constraint con_auser {
        auser <= ~({(`SVK_AXI_USER_WIDTH){1'b1}} << cfg.addr_user_width);
    }

    constraint con_wuser {
        solve length before wuser;
        wuser.size == length + 1;
        foreach(wuser[i]) {
            wuser[i] <= ~({(`SVK_AXI_USER_WIDTH){1'b1}} << cfg.data_user_width);
        }
    }

    constraint con_ruser {
        solve length before ruser;
        ruser.size == length + 1;
        foreach(ruser[i]) {

            ruser[i] <= ~({(`SVK_AXI_USER_WIDTH){1'b1}} << cfg.data_user_width);
        }
    }

    constraint con_buser {
        buser <= ~({(`SVK_AXI_RESP_WIDTH){1'b1}} << cfg.resp_user_width);

    }

    constraint con_size {

        2**size*8 <= cfg.data_width; 

    }

    constraint con_addr {
        addr <= ~({(`SVK_AXI_ADDR_WIDTH){1'b1}} << cfg.addr_width);
        if(burst == svk_axi_dec::BURST_FIXED) {
            (addr[11:0]/(1<<size))*(1<<size) + (1<<size) <= 4096;
        }
        if(burst == svk_axi_dec::BURST_INCR) {
            (addr[11:0]/(1<<size))*(1<<size) + ((length + 1) * (1<<size)) <= 4096;
        }
        if(burst == svk_axi_dec::BURST_WRAP) {
            (size == svk_axi_dec::SIZE_16BIT  ) -> addr[0]     == 1'b0;
            (size == svk_axi_dec::SIZE_32BIT  ) -> addr[1:0]   == 2'b0;
            (size == svk_axi_dec::SIZE_64BIT  ) -> addr[2:0]   == 3'b0;
            (size == svk_axi_dec::SIZE_128BIT ) -> addr[3:0]   == 4'b0;
            (size == svk_axi_dec::SIZE_256BIT ) -> addr[4:0]   == 5'b0;
            (size == svk_axi_dec::SIZE_512BIT ) -> addr[5:0]   == 6'b0;
            (size == svk_axi_dec::SIZE_1024BIT) -> addr[6:0]   == 7'b0;
        }
        if(lock == svk_axi_dec::EXCLUSIVE) {
            addr & (~({(`SVK_AXI_ADDR_WIDTH){1'b1}} << $clog2(2**size * (length+1)))) == 0;
        }
    }



    `CON_READY_DELAY(awready)
    `CON_READY_DELAY(arready)
    `CON_READY_DELAY(bready)

    `CON_VALID_DELAY(awvalid)
    `CON_VALID_DELAY(arvalid)
    `CON_VALID_DELAY(bvalid)

    `CON_READY_DELAY_ARRAY(rready)
    `CON_READY_DELAY_ARRAY(wready)

    `CON_VALID_DELAY_ARRAY(rvalid)
    `CON_VALID_DELAY_ARRAY(wvalid)


    `uvm_object_utils_begin(svk_axi_transaction)

        `uvm_field_enum(svk_axi_dec::dir_enum    ,      dir      , UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_enum(svk_axi_dec::length_enum ,      length   , UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_enum(svk_axi_dec::size_enum   ,      size     , UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_enum(svk_axi_dec::burst_enum  ,      burst    , UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_enum(svk_axi_dec::lock_enum   ,      lock     , UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_enum(svk_axi_dec::cache_enum  ,      cache    , UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_enum(svk_axi_dec::prot_enum   ,      prot     , UVM_ALL_ON | UVM_NOCOMPARE)

        `uvm_field_int(                        id       , UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_int(                        addr     , UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_int(                        auser    , UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_int(                        buser    , UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_int(                        qos      , UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_int(                        region   , UVM_ALL_ON | UVM_NOCOMPARE)

        `uvm_field_int(                        need_resp, UVM_ALL_ON | UVM_NOCOMPARE)

        `uvm_field_array_int(                  data     , UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_array_int(                  ruser    , UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_array_int(                  wuser    , UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_array_int(                  wstrb    , UVM_ALL_ON | UVM_NOCOMPARE)

        `uvm_field_array_enum(svk_axi_dec::resp_enum,   resp     , UVM_ALL_ON | UVM_NOCOMPARE)

        `uvm_field_object(                     extension, UVM_ALL_ON | UVM_NOCOMPARE)
        `uvm_field_object(                     cfg, UVM_ALL_ON | UVM_NOCOMPARE)

        `uvm_field_int(awready_delay         , UVM_ALL_ON|UVM_NOCOMPARE)
        `uvm_field_int(awvalid_delay         , UVM_ALL_ON|UVM_NOCOMPARE)
        `uvm_field_int(arready_delay         , UVM_ALL_ON|UVM_NOCOMPARE)
        `uvm_field_int(arvalid_delay         , UVM_ALL_ON|UVM_NOCOMPARE)
        `uvm_field_int(bvalid_delay          , UVM_ALL_ON|UVM_NOCOMPARE)
        `uvm_field_int(bready_delay          , UVM_ALL_ON|UVM_NOCOMPARE)
        `uvm_field_array_int(wready_delay    , UVM_ALL_ON|UVM_NOCOMPARE)
        `uvm_field_array_int(wvalid_delay    , UVM_ALL_ON|UVM_NOCOMPARE)
        `uvm_field_array_int(rready_delay    , UVM_ALL_ON|UVM_NOCOMPARE)
        `uvm_field_array_int(rvalid_delay    , UVM_ALL_ON|UVM_NOCOMPARE)

    `uvm_object_utils_end

    function new(string name="svk_axi_transaction");
        super.new(name);
    endfunction

endclass

`endif

