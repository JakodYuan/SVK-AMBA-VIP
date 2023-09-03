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

`ifndef SVK_AXI_DEC__SV
`define SVK_AXI_DEC__SV

class svk_axi_dec;
    typedef bit     dynamic_bit_array[];
    typedef string  string_queue[$];


    typedef enum {
        AXI3 = 0,
        AXI4 = 1
    } version_enum;


    typedef enum {
        READ  = 0,
        WRITE = 1
    } dir_enum;

    typedef enum {
        LENGTH_[1:256] = 0
    } length_enum;

    typedef enum {
        SIZE_8BIT    = 0,
        SIZE_16BIT   = 1,
        SIZE_32BIT   = 2,
        SIZE_64BIT   = 3,
        SIZE_128BIT  = 4,
        SIZE_256BIT  = 5,
        SIZE_512BIT  = 6,
        SIZE_1024BIT = 7
    } size_enum;

    typedef enum {
        BURST_FIXED = 0,
        BURST_INCR  = 1,
        BURST_WRAP  = 2,
        BURST_OTHER = 3
    } burst_enum;

    typedef enum {
        NORMAL     = 0,
        EXCLUSIVE  = 1,
        LOCKED     = 2,
        LOCK_OTHER = 3
    } lock_enum;

    typedef enum {
        NON_CACHEABLE_NO_BUFFERABLE           = 0,
        BUFFERABLE_ONLY                       = 1,
        CACHEABLE_BUT_NO_ALLOC                = 2,
        CACHEABLE_BUFFERABLE_BUT_NO_ALLOC     = 3,
        CACHE_OTHER_1                         = 4,
        CACHE_OTHER_2                         = 5,
        CACHEABLE_WR_THRU_ALLOC_ON_RD_ONLY    = 6,
        CACHEABLE_WR_BACK_ALLOC_ON_RD_ONLY    = 7,
        CACHE_OTHER_3                         = 8,
        CACHE_OTHER_4                         = 9,
        CACHEABLE_WR_THRU_ALLOC_ON_WR_ONLY    = 10,
        CACHEABLE_WR_BACK_ALLOC_ON_WR_ONLY    = 11,
        CACHE_OTHER_5                         = 12,
        CACHE_OTHER_6                         = 13,
        CACHEABLE_WR_THRU_ALLOC_ON_BOTH_RD_WR = 14,
        CACHEABLE_WR_BACK_ALLOC_ON_BOTH_RD_WR = 15
    } cache_enum;

    typedef enum {
        DATA_SECURE_NORMAL                = 0,
        DATA_SECURE_PRIVILEGED            = 1,
        DATA_NON_SECURE_NORMAL            = 2,
        DATA_NON_SECURE_PRIVILEGED        = 3,
        INSTRUCTION_SECURE_NORMAL         = 4,
        INSTRUCTION_SECURE_PRIVILEGED     = 5,
        INSTRUCTION_NON_SECURE_NORMAL     = 6,
        INSTRUCTION_NON_SECURE_PRIVILEGED = 7
    } prot_enum;

    typedef enum {
        OKAY   = 0,
        EXOKAY = 1,
        SLVERR = 2,
        DECERR = 3
    } resp_enum;



    typedef enum {
        NOT_START = 0,
        WAITING   = 1,
        TIME_OUT  = 2,
        FINISH    = 3
    } delay_status_enum;

    typedef enum {
        MST_VALID_NOTSTART_WITH_MIN_TID = 0,
        MST_VALID_TIMEOUT               = 1,
        MST_NEXT_WVALID                 = 2,
        MST_GET_RSP_WITH_MIN_TID        = 3,

        SLV_ALLOCATE_NEW                = 4,
        SLV_VALID_NOTSTART_WITH_MIN_TID = 5,
        SLV_VALID_TIMEOUT               = 6,
        SLV_NEXT_RVALID                 = 7,
        SLV_GET_REQ_WITH_MAX_TID        = 8,

        MON_ALLOCATE_NEW                = 9,
        MON_GET_RSP_WITH_MIN_TID        = 10
    } cid_status_enum;



    typedef enum {
        AWV_PREV_AWVALID_EVENT                       = 0,
        AWV_PREV_AW_HANDSHAKE_EVENT                  = 1,
        AWV_PREV_LAST_W_HANDSHAKE_EVENT              = 2,
        AWV_FIRST_WVALID_DATA_BEFORE_ADDR_EVENT      = 3,
        AWV_FIRST_W_HANDSHAKE_DATA_BEFORE_ADDR_EVENT = 4
    } awvalid_delay_event_enum;

    typedef enum {
        AWR_AWVALID_EVENT      = 0,
        AWR_FIRST_WVALID_EVENT = 1
    } awready_delay_event_enum;



    typedef enum {
        FWV_AWVLAID_EVENT          = 0,
        FWV_AW_HANDSHAKE_EVENT     = 1,
        FWV_PREV_W_HANDSHAKE_EVENT = 2
    } first_wvalid_delay_event_enum;

    typedef enum {
        NWV_PREV_W_HANDSHAKE_EVENT = 0,
        NWV_PREV_WVALID_EVENT      = 1
    } next_wvalid_delay_event_enum;

    typedef enum {
        WR_WVALID_EVENT = 0
    } wready_delay_event_enum;


    typedef enum {
        BV_LAST_W_HANDSHAKE_EVENT = 0,
        BV_AW_HANDSHAKE_EVENT     = 1
    } bvalid_delay_event_enum;

    typedef enum {
        BR_BVALID_EVENT = 0
    } bready_delay_event_enum;



    typedef enum {
        ARV_PREV_ARVALID_EVENT      = 0,
        ARV_PREV_AR_HANDSHAKE_EVENT = 1,
        ARV_LAST_R_HANDSHAKE_EVENT  = 2,
        ARV_FIRST_R_HANDSHAKE_EVENT = 3
    } arvalid_delay_event_enum;

    typedef enum {
        ARR_ARVALID_EVENT = 0
    } arready_delay_event_enum;


    typedef enum {
        FRV_ARVALID_EVENT      = 0,
        FRV_AR_HANDSHAKE_EVENT = 1
    } first_rvalid_delay_event_enum;

    typedef enum {
        NRV_PREV_R_HANDSHAKE_EVENT = 0,
        NRV_PREV_RVALID_EVENT      = 1
    } next_rvalid_delay_event_enum;

    typedef enum {
        RR_RVALID_EVENT = 0
    } rready_delay_event_enum;



    typedef enum {
        WT_AWVALID_EVENT           = 0,
        WT_AW_HANDSHAKE_EVENT      = 1,
        WT_WVALID_EVENT            = 2,
        WT_FIRST_WVALID_EVENT      = 3,
        WT_W_HANDSHAKE_EVENT       = 4,
        WT_LAST_W_HANDSHAKE_EVENT  = 5,
        WT_FIRST_W_HANDSHAKE_EVENT = 6,
        WT_BVALID_EVENT            = 7,
        WT_B_HANDSHAKE_EVENT       = 8
    } wr_delay_event_enum;


    typedef enum {
        RD_ARVALID_EVENT           = 0,
        RD_AR_HANDSHAKE_EVENT      = 1,
        RD_R_HANDSHAKE_EVENT       = 2,
        RD_LAST_R_HANDSHAKE_EVENT  = 3,
        RD_FIRST_R_HANDSHAKE_EVENT = 4,
        RD_RVALID_EVENT            = 5
    } rd_delay_event_enum;

    typedef struct{
        wr_delay_event_enum         wr_event;
        bit [`SVK_AXI_ID_WIDTH-1:0]     id;
    } wr_event_struct;

    typedef struct{
        rd_delay_event_enum         rd_event;
        bit [`SVK_AXI_ID_WIDTH-1:0]     id;
    } rd_event_struct;


endclass
`endif

