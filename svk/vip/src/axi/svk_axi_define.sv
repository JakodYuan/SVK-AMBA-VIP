/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/



`ifndef SVK_AXI_ADDR_WIDTH
`define SVK_AXI_ADDR_WIDTH             64
`endif

`ifndef SVK_AXI_DATA_WIDTH
`define SVK_AXI_DATA_WIDTH             1024
`endif

`ifndef SVK_AXI_WSTRB_WIDTH
`define SVK_AXI_WSTRB_WIDTH            `SVK_AXI_DATA_WIDTH/8
`endif

`ifndef SVK_AXI_LEN_WIDTH
`define SVK_AXI_LEN_WIDTH              8
`endif

`ifndef SVK_AXI_SIZE_WIDTH
`define SVK_AXI_SIZE_WIDTH             3
`endif

`ifndef SVK_AXI_BURST_WIDTH
`define SVK_AXI_BURST_WIDTH            2
`endif

`ifndef SVK_AXI_LOCK_WIDTH
`define SVK_AXI_LOCK_WIDTH             2
`endif

`ifndef SVK_AXI_CACHE_WIDTH
`define SVK_AXI_CACHE_WIDTH            4
`endif

`ifndef SVK_AXI_PROT_WIDTH
`define SVK_AXI_PROT_WIDTH             3
`endif

`ifndef SVK_AXI_ID_WIDTH
`define SVK_AXI_ID_WIDTH               64
`endif

`ifndef SVK_AXI_QOS_WIDTH
`define SVK_AXI_QOS_WIDTH              4
`endif

`ifndef SVK_AXI_REGION_WIDTH
`define SVK_AXI_REGION_WIDTH           4
`endif

`ifndef SVK_AXI_RESP_WIDTH
`define SVK_AXI_RESP_WIDTH             2
`endif

`ifndef SVK_AXI_USER_WIDTH
`define SVK_AXI_USER_WIDTH             64
`endif





















`ifndef SVK_AXI_MAX_OSD
`define SVK_AXI_MAX_OSD                1024
`endif



`ifndef SVK_AXI_MAX_NUM_MASTER
`define SVK_AXI_MAX_NUM_MASTER         16
`endif


`ifndef SVK_AXI_MAX_NUM_SLAVE
`define SVK_AXI_MAX_NUM_SLAVE          16
`endif




`define READY_PROCESS(channel) \
begin \
    if(cfg.default_``channel``ready == 1'b0) \
        fork \
            while(1)begin \
                @(posedge (u_if.``channel``valid & !u_if.``channel``ready)); \
                db.load_``channel``ready_delay(u_if.``channel``id); \
            end \
            while(1)begin \
                @(posedge u_if.aclk) \
                if(u_if.``channel``valid === 1'b1 && db.``channel``ready_delay != 0) \
                    db.``channel``ready_delay = db.``channel``ready_delay - 1; \
            end \
            while(1)begin \
                @(u_if.``channel``valid, db.``channel``ready_delay); \
                if(u_if.``channel``valid === 1'b1 && db.``channel``ready_delay == 0) \
                    u_if.``channel``ready = 1'b1; \
                else \
                    u_if.``channel``ready = 1'b0; \
            end \
        join \
    else begin \
        fork \
            u_if.``channel``ready = 1'b1; \
            while(1)begin \
                @(u_if.mon_mp.mon_cb) \
                if(db.``channel``ready_delay != 0) \
                    db.``channel``ready_delay = db.``channel``ready_delay - 1; \
                else if(u_if.mon_mp.mon_cb.``channel``valid && u_if.mon_mp.mon_cb.``channel``ready) \
                    db.load_``channel``ready_delay(u_if.``channel``id); \
                if(db.``channel``ready_delay == 0) \
                    u_if.``channel``ready = 1'b1; \
                else \
                    u_if.``channel``ready = 1'b0; \
            end \
        join \
    end \
end



`define CON_READY_DELAY(signal)  \
    constraint  con_``signal``_delay { \
        signal``_delay dist { \
            0:/zero_delay_wt, \
            [short_delay_min:short_delay_max]:/short_delay_wt, \
            [long_delay_min:long_delay_max]:/long_delay_wt \
        }; \
    }

`define CON_VALID_DELAY(signal)  \
    constraint  con_``signal``_delay { \
        signal``_delay dist { \
            0:/zero_delay_wt, \
            [short_delay_min:short_delay_max]:/short_delay_wt, \
            [long_delay_min:long_delay_max]:/long_delay_wt \
        }; \
    }

`define CON_READY_DELAY_ARRAY(signal) \
    constraint  con_``signal``_delay { \
        signal``_delay.size == length + 1; \
        foreach(signal``_delay[i]) { \
            if(i==0 || next_delay_is_zero == 0) { \
                signal``_delay[i] dist { \
                    0:/zero_delay_wt, \
                    [short_delay_min:short_delay_max]:/short_delay_wt, \
                    [long_delay_min:long_delay_max]:/long_delay_wt \
                }; \
            } else { \
                signal``_delay[i] == 0; \
            } \
        } \
    }

`define CON_VALID_DELAY_ARRAY(signal) \
    constraint  con_``signal``_delay { \
        signal``_delay.size == length + 1; \
        foreach(signal``_delay[i]) { \
            if(i==0 || next_delay_is_zero == 0) { \
                signal``_delay[i] dist { \
                    0:/zero_delay_wt, \
                    [short_delay_min:short_delay_max]:/short_delay_wt, \
                    [long_delay_min:long_delay_max]:/long_delay_wt \
                }; \
            } else { \
                signal``_delay[i] == 0; \
            } \
        } \
    }

