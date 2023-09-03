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

`ifndef SVK_AXI_AGENT_CFG__SV
`define SVK_AXI_AGENT_CFG__SV
class svk_axi_agent_cfg extends svk_agent_cfg;

    svk_axi_dec::version_enum                      version                  = svk_axi_dec::AXI3          ;
    int unsigned                                   wr_osd                   = 1                          ;
    int unsigned                                   rd_osd                   = 10                         ;
    bit                                            wr_interleave_en         = 1'b0                       ;
    int unsigned                                   wr_interleave_depth      = 1                          ;
    bit                                            rd_interleave_en         = 1'b0                       ;
    bit                                            wr_out_of_order_en       = 1'b0                       ;
    bit                                            rd_out_of_order_en       = 1'b0                       ;

    bit                                            data_before_addr         = 1'b0                       ;

    svk_axi_dec::awvalid_delay_event_enum          awvalid_delay_event      = svk_axi_dec::AWV_PREV_AW_HANDSHAKE_EVENT;
    svk_axi_dec::arvalid_delay_event_enum          arvalid_delay_event      = svk_axi_dec::ARV_PREV_AR_HANDSHAKE_EVENT;
    svk_axi_dec::first_wvalid_delay_event_enum     first_wvalid_delay_event = svk_axi_dec::FWV_PREV_W_HANDSHAKE_EVENT ;
    svk_axi_dec::next_wvalid_delay_event_enum      next_wvalid_delay_event  = svk_axi_dec::NWV_PREV_W_HANDSHAKE_EVENT ;
    svk_axi_dec::first_rvalid_delay_event_enum     first_rvalid_delay_event = svk_axi_dec::FRV_AR_HANDSHAKE_EVENT     ;
    svk_axi_dec::next_rvalid_delay_event_enum      next_rvalid_delay_event  = svk_axi_dec::NRV_PREV_R_HANDSHAKE_EVENT ;
    svk_axi_dec::bvalid_delay_event_enum           bvalid_delay_event       = svk_axi_dec::BV_LAST_W_HANDSHAKE_EVENT  ;

    svk_axi_dec::awready_delay_event_enum          awready_delay_event      = svk_axi_dec::AWR_AWVALID_EVENT          ;
    svk_axi_dec::arready_delay_event_enum          arready_delay_event      = svk_axi_dec::ARR_ARVALID_EVENT          ;
    svk_axi_dec::wready_delay_event_enum           wready_delay_event       = svk_axi_dec::WR_WVALID_EVENT            ;
    svk_axi_dec::bready_delay_event_enum           bready_delay_event       = svk_axi_dec::BR_BVALID_EVENT            ;
    svk_axi_dec::rready_delay_event_enum           rready_delay_event       = svk_axi_dec::RR_RVALID_EVENT            ;

    bit                                            default_bready           = 1'b1                       ;
    bit                                            default_rready           = 1'b1                       ;
    bit                                            default_awready          = 1'b1                       ;
    bit                                            default_arready          = 1'b1                       ;
    bit                                            default_wready           = 1'b1                       ;
    svk_dec::default_value_enum                    mem_default_value        = svk_dec::DEFAULT_ZERO           ;
    svk_dec::idle_value_enum                       idle_value               = svk_dec::IDLE_ZERO              ;

    int unsigned                                   ready_timeout_time       = 1000                           ;
    int unsigned                                   data_width               = `SVK_AXI_DATA_WIDTH            ;
    int unsigned                                   addr_width               = `SVK_AXI_ADDR_WIDTH            ;
    int unsigned                                   id_width                 = `SVK_AXI_ID_WIDTH              ;
    int unsigned                                   data_user_width          = `SVK_AXI_USER_WIDTH            ;
    int unsigned                                   resp_user_width          = `SVK_AXI_USER_WIDTH            ;
    int unsigned                                   addr_user_width          = `SVK_AXI_USER_WIDTH            ;



    svk_axi_dec::wr_delay_event_enum               m_awvalid_delay_event;
    svk_axi_dec::wr_delay_event_enum               m_first_wvalid_delay_event; 
    svk_axi_dec::wr_delay_event_enum               m_next_wvalid_delay_event; 
    svk_axi_dec::wr_delay_event_enum               m_bready_delay_event; 
    svk_axi_dec::wr_delay_event_enum               m_awready_delay_event;
    svk_axi_dec::wr_delay_event_enum               m_wready_delay_event;
    svk_axi_dec::wr_delay_event_enum               m_bvalid_delay_event;

    svk_axi_dec::rd_delay_event_enum               m_arready_delay_event;
    svk_axi_dec::rd_delay_event_enum               m_first_rvalid_delay_event;
    svk_axi_dec::rd_delay_event_enum               m_next_rvalid_delay_event;
    svk_axi_dec::rd_delay_event_enum               m_arvalid_delay_event;
    svk_axi_dec::rd_delay_event_enum               m_rready_delay_event; 

    bit [`SVK_AXI_DATA_WIDTH-1:0]                   DATA_MASK;
    bit [`SVK_AXI_WSTRB_WIDTH-1:0]                  WSTRB_MASK;
    bit [`SVK_AXI_ADDR_WIDTH-1:0]                   ADDR_MASK;
    bit [`SVK_AXI_ID_WIDTH-1:0]                     ID_MASK;
    bit [`SVK_AXI_USER_WIDTH-1:0]                   DATA_USER_MASK;
    bit [`SVK_AXI_USER_WIDTH-1:0]                   RESP_USER_MASK;
    bit [`SVK_AXI_USER_WIDTH-1:0]                   ADDR_USER_MASK;










































































    extern function new(string name="axi_agent_cfg");
    extern function void check_cfg();

    extern function svk_axi_dec::wr_delay_event_enum awvalid_event_to_wr(svk_axi_dec::awvalid_delay_event_enum delay_event);
    extern function svk_axi_dec::wr_delay_event_enum awready_event_to_wr(svk_axi_dec::awready_delay_event_enum delay_event);
    extern function svk_axi_dec::wr_delay_event_enum first_wvalid_event_to_wr(svk_axi_dec::first_wvalid_delay_event_enum delay_event);
    extern function svk_axi_dec::wr_delay_event_enum next_wvalid_event_to_wr(svk_axi_dec::next_wvalid_delay_event_enum delay_event);
    extern function svk_axi_dec::wr_delay_event_enum wready_event_to_wr(svk_axi_dec::wready_delay_event_enum delay_event);
    extern function svk_axi_dec::wr_delay_event_enum bvalid_event_to_wr(svk_axi_dec::bvalid_delay_event_enum delay_event);
    extern function svk_axi_dec::wr_delay_event_enum bready_event_to_wr(svk_axi_dec::bready_delay_event_enum delay_event);

    extern function svk_axi_dec::rd_delay_event_enum arvalid_event_to_rd(svk_axi_dec::arvalid_delay_event_enum delay_event);
    extern function svk_axi_dec::rd_delay_event_enum arready_event_to_rd(svk_axi_dec::arready_delay_event_enum delay_event);
    extern function svk_axi_dec::rd_delay_event_enum first_rvalid_event_to_rd(svk_axi_dec::first_rvalid_delay_event_enum delay_event);
    extern function svk_axi_dec::rd_delay_event_enum next_rvalid_event_to_rd(svk_axi_dec::next_rvalid_delay_event_enum delay_event);
    extern function svk_axi_dec::rd_delay_event_enum rready_event_to_rd(svk_axi_dec::rready_delay_event_enum delay_event);


    `uvm_object_utils_begin(svk_axi_agent_cfg)
        `uvm_field_int(wr_osd                         , UVM_ALL_ON)
        `uvm_field_int(rd_osd                         , UVM_ALL_ON)
        `uvm_field_int(wr_interleave_en               , UVM_ALL_ON)
        `uvm_field_int(wr_interleave_depth            , UVM_ALL_ON)
        `uvm_field_int(rd_interleave_en               , UVM_ALL_ON)
        `uvm_field_int(rd_out_of_order_en             , UVM_ALL_ON)
        `uvm_field_int(wr_out_of_order_en             , UVM_ALL_ON)

        `uvm_field_int(data_before_addr               , UVM_ALL_ON)
        `uvm_field_int(default_bready                 , UVM_ALL_ON)
        `uvm_field_int(default_rready                 , UVM_ALL_ON)
        `uvm_field_int(default_awready                , UVM_ALL_ON)
        `uvm_field_int(default_arready                , UVM_ALL_ON)
        `uvm_field_int(default_wready                 , UVM_ALL_ON)
        `uvm_field_int(data_width                     , UVM_ALL_ON)
        `uvm_field_int(addr_width                     , UVM_ALL_ON)
        `uvm_field_int(id_width                       , UVM_ALL_ON)
        `uvm_field_int(addr_user_width                , UVM_ALL_ON)
        `uvm_field_int(data_user_width                , UVM_ALL_ON)
        `uvm_field_int(resp_user_width                , UVM_ALL_ON)
        `uvm_field_int(ready_timeout_time             , UVM_ALL_ON)

        `uvm_field_enum(svk_axi_dec::version_enum                  , version                  , UVM_ALL_ON)
        `uvm_field_enum(svk_dec::idle_value_enum                   , idle_value               , UVM_ALL_ON)
        `uvm_field_enum(svk_dec::default_value_enum                , mem_default_value        , UVM_ALL_ON)
        `uvm_field_enum(svk_dec::agent_work_mode_enum              , work_mode                , UVM_ALL_ON)

        `uvm_field_enum(svk_axi_dec::awvalid_delay_event_enum      , awvalid_delay_event      , UVM_ALL_ON)
        `uvm_field_enum(svk_axi_dec::arvalid_delay_event_enum      , arvalid_delay_event      , UVM_ALL_ON)
        `uvm_field_enum(svk_axi_dec::first_wvalid_delay_event_enum , first_wvalid_delay_event , UVM_ALL_ON)
        `uvm_field_enum(svk_axi_dec::next_wvalid_delay_event_enum  , next_wvalid_delay_event  , UVM_ALL_ON)
        `uvm_field_enum(svk_axi_dec::first_rvalid_delay_event_enum , first_rvalid_delay_event , UVM_ALL_ON)
        `uvm_field_enum(svk_axi_dec::next_rvalid_delay_event_enum  , next_rvalid_delay_event  , UVM_ALL_ON)
        `uvm_field_enum(svk_axi_dec::bvalid_delay_event_enum       , bvalid_delay_event       , UVM_ALL_ON)

        `uvm_field_enum(svk_axi_dec::awready_delay_event_enum      , awready_delay_event      , UVM_ALL_ON)
        `uvm_field_enum(svk_axi_dec::arready_delay_event_enum      , arready_delay_event      , UVM_ALL_ON)
        `uvm_field_enum(svk_axi_dec::wready_delay_event_enum       , wready_delay_event       , UVM_ALL_ON)
        `uvm_field_enum(svk_axi_dec::rready_delay_event_enum       , rready_delay_event       , UVM_ALL_ON)
        `uvm_field_enum(svk_axi_dec::bready_delay_event_enum       , bready_delay_event       , UVM_ALL_ON)


    `uvm_object_utils_end
endclass

function svk_axi_agent_cfg::new(string name);
    super.new(name);
endfunction

function void svk_axi_agent_cfg::check_cfg();
    if(data_before_addr == 0)begin
        if(!(awvalid_delay_event inside {svk_axi_dec::AWV_PREV_AWVALID_EVENT,svk_axi_dec::AWV_PREV_AW_HANDSHAKE_EVENT,svk_axi_dec::AWV_PREV_LAST_W_HANDSHAKE_EVENT}))
            `uvm_fatal(get_type_name(), $sformatf("data_before_addr=1 while awvalid_delay_event=%0s", awvalid_delay_event.name))
    end
    else begin
        if(!(awvalid_delay_event inside {svk_axi_dec::AWV_FIRST_WVALID_DATA_BEFORE_ADDR_EVENT,svk_axi_dec::AWV_FIRST_W_HANDSHAKE_DATA_BEFORE_ADDR_EVENT}))
            `uvm_fatal(get_type_name(), $sformatf("data_before_addr=0 while awvalid_delay_event=%0s", awvalid_delay_event.name))
    end

    if(version == svk_axi_dec::AXI4 && wr_interleave_en)
        `uvm_fatal(get_type_name(), "version == AXI_AXI4 while wr_interleave_en=1")


    if(rd_osd < 1 || rd_osd > 128)
        `uvm_fatal(get_type_name(), $sformatf("rd_osd=%0d", rd_osd))

    if(wr_osd < 1 || wr_osd > 128)
        `uvm_fatal(get_type_name(), $sformatf("wr_osd=%0d", wr_osd))


    if(wr_interleave_depth > wr_osd)
        `uvm_fatal(get_type_name(), $sformatf("wr_osd=%0d < wr_interleave_depth=%0d", wr_osd, wr_interleave_depth))


    m_awvalid_delay_event      = awvalid_event_to_wr(awvalid_delay_event);
    m_first_wvalid_delay_event = first_wvalid_event_to_wr(first_wvalid_delay_event);
    m_next_wvalid_delay_event  = next_wvalid_event_to_wr(next_wvalid_delay_event);
    m_bready_delay_event       = bready_event_to_wr(bready_delay_event);
    m_arvalid_delay_event      = arvalid_event_to_rd(arvalid_delay_event);
    m_rready_delay_event       = rready_event_to_rd(rready_delay_event);

    m_awready_delay_event      = awready_event_to_wr(awready_delay_event);
    m_wready_delay_event       = wready_event_to_wr(wready_delay_event);
    m_bvalid_delay_event       = bvalid_event_to_wr(bvalid_delay_event);
    m_arready_delay_event      = arready_event_to_rd(arready_delay_event);
    m_first_rvalid_delay_event = first_rvalid_event_to_rd(first_rvalid_delay_event);
    m_next_rvalid_delay_event  = next_rvalid_event_to_rd(next_rvalid_delay_event);

    DATA_MASK      = ~({(`SVK_AXI_DATA_WIDTH){1'b1}} << data_width);
    WSTRB_MASK      = ~({(`SVK_AXI_WSTRB_WIDTH){1'b1}} << (data_width/8));
    ADDR_MASK      = ~({(`SVK_AXI_ADDR_WIDTH){1'b1}} << addr_width);
    ID_MASK        = ~({(`SVK_AXI_ID_WIDTH){1'b1}} << id_width);
    DATA_USER_MASK = ~({(`SVK_AXI_USER_WIDTH){1'b1}} << data_user_width);
    RESP_USER_MASK = ~({(`SVK_AXI_USER_WIDTH){1'b1}} << resp_user_width);
    ADDR_USER_MASK = ~({(`SVK_AXI_USER_WIDTH){1'b1}} << addr_user_width);
endfunction

function svk_axi_dec::wr_delay_event_enum svk_axi_agent_cfg::awvalid_event_to_wr(svk_axi_dec::awvalid_delay_event_enum delay_event);
    case(delay_event)
        svk_axi_dec::AWV_PREV_AWVALID_EVENT:                         return svk_axi_dec::WT_AWVALID_EVENT;
        svk_axi_dec::AWV_PREV_AW_HANDSHAKE_EVENT:                    return svk_axi_dec::WT_AW_HANDSHAKE_EVENT;
        svk_axi_dec::AWV_PREV_LAST_W_HANDSHAKE_EVENT:                return svk_axi_dec::WT_LAST_W_HANDSHAKE_EVENT;
        svk_axi_dec::AWV_FIRST_WVALID_DATA_BEFORE_ADDR_EVENT:        return svk_axi_dec::WT_WVALID_EVENT;
        svk_axi_dec::AWV_FIRST_W_HANDSHAKE_DATA_BEFORE_ADDR_EVENT:   return svk_axi_dec::WT_W_HANDSHAKE_EVENT;
    endcase
endfunction

function svk_axi_dec::wr_delay_event_enum svk_axi_agent_cfg::awready_event_to_wr(svk_axi_dec::awready_delay_event_enum delay_event);
    case(delay_event)
        svk_axi_dec::AWR_AWVALID_EVENT:       return svk_axi_dec::WT_AWVALID_EVENT;
        svk_axi_dec::AWR_FIRST_WVALID_EVENT:  return svk_axi_dec::WT_FIRST_WVALID_EVENT;
    endcase
endfunction

function svk_axi_dec::wr_delay_event_enum svk_axi_agent_cfg::first_wvalid_event_to_wr(svk_axi_dec::first_wvalid_delay_event_enum delay_event);
    case(delay_event)
        svk_axi_dec::FWV_AWVLAID_EVENT         : return svk_axi_dec::WT_AWVALID_EVENT;
        svk_axi_dec::FWV_AW_HANDSHAKE_EVENT    : return svk_axi_dec::WT_AW_HANDSHAKE_EVENT;
        svk_axi_dec::FWV_PREV_W_HANDSHAKE_EVENT: return svk_axi_dec::WT_LAST_W_HANDSHAKE_EVENT;
    endcase
endfunction

function svk_axi_dec::wr_delay_event_enum svk_axi_agent_cfg::next_wvalid_event_to_wr(svk_axi_dec::next_wvalid_delay_event_enum delay_event);
    case(delay_event)
        svk_axi_dec::NWV_PREV_W_HANDSHAKE_EVENT: return svk_axi_dec::WT_W_HANDSHAKE_EVENT;
        svk_axi_dec::NWV_PREV_WVALID_EVENT     : return svk_axi_dec::WT_WVALID_EVENT;
    endcase
endfunction

function svk_axi_dec::wr_delay_event_enum svk_axi_agent_cfg::wready_event_to_wr(svk_axi_dec::wready_delay_event_enum delay_event);
    case(delay_event)
        svk_axi_dec::WR_WVALID_EVENT: return svk_axi_dec::WT_WVALID_EVENT;
    endcase
endfunction

function svk_axi_dec::wr_delay_event_enum svk_axi_agent_cfg::bvalid_event_to_wr(svk_axi_dec::bvalid_delay_event_enum delay_event);
    case(delay_event)
        svk_axi_dec::BV_LAST_W_HANDSHAKE_EVENT: return svk_axi_dec::WT_LAST_W_HANDSHAKE_EVENT;
        svk_axi_dec::BV_AW_HANDSHAKE_EVENT    : return svk_axi_dec::WT_AW_HANDSHAKE_EVENT;
    endcase
endfunction

function svk_axi_dec::wr_delay_event_enum svk_axi_agent_cfg::bready_event_to_wr(svk_axi_dec::bready_delay_event_enum delay_event);
    case(delay_event)
        svk_axi_dec::BR_BVALID_EVENT: return svk_axi_dec::WT_BVALID_EVENT;
    endcase
endfunction

function svk_axi_dec::rd_delay_event_enum svk_axi_agent_cfg::arvalid_event_to_rd(svk_axi_dec::arvalid_delay_event_enum delay_event);
    case(delay_event)
        svk_axi_dec::ARV_PREV_ARVALID_EVENT     : return svk_axi_dec::RD_ARVALID_EVENT;
        svk_axi_dec::ARV_PREV_AR_HANDSHAKE_EVENT: return svk_axi_dec::RD_AR_HANDSHAKE_EVENT;
        svk_axi_dec::ARV_LAST_R_HANDSHAKE_EVENT : return svk_axi_dec::RD_LAST_R_HANDSHAKE_EVENT;
        svk_axi_dec::ARV_FIRST_R_HANDSHAKE_EVENT: return svk_axi_dec::RD_FIRST_R_HANDSHAKE_EVENT;
    endcase
endfunction

function svk_axi_dec::rd_delay_event_enum svk_axi_agent_cfg::arready_event_to_rd(svk_axi_dec::arready_delay_event_enum delay_event);
    return svk_axi_dec::RD_ARVALID_EVENT;
endfunction

function svk_axi_dec::rd_delay_event_enum svk_axi_agent_cfg::first_rvalid_event_to_rd(svk_axi_dec::first_rvalid_delay_event_enum delay_event);
    case(delay_event)
        svk_axi_dec::FRV_ARVALID_EVENT     : return svk_axi_dec::RD_ARVALID_EVENT;
        svk_axi_dec::FRV_AR_HANDSHAKE_EVENT: return svk_axi_dec::RD_AR_HANDSHAKE_EVENT;
    endcase
endfunction

function svk_axi_dec::rd_delay_event_enum svk_axi_agent_cfg::next_rvalid_event_to_rd(svk_axi_dec::next_rvalid_delay_event_enum delay_event);
    case(delay_event)
        svk_axi_dec::NRV_PREV_RVALID_EVENT     : return svk_axi_dec::RD_RVALID_EVENT;
        svk_axi_dec::NRV_PREV_R_HANDSHAKE_EVENT: return svk_axi_dec::RD_R_HANDSHAKE_EVENT;
    endcase
endfunction

function svk_axi_dec::rd_delay_event_enum svk_axi_agent_cfg::rready_event_to_rd(svk_axi_dec::rready_delay_event_enum delay_event);
    return svk_axi_dec::RD_RVALID_EVENT;
endfunction

`endif

