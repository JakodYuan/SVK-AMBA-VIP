/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_APB_IF__SV
`define SVK_APB_IF__SV

interface svk_apb_if();
    logic                             pclk;
    logic                             presetn;

    logic [`SVK_APB_ADDR_WIDTH -1 :0] paddr;
    logic                             psel;
    logic [`SVK_APB_DATA_WIDTH -1 :0] pwdata;
    logic [`SVK_APB_DATA_WIDTH -1 :0] prdata;
    logic                             penable;
    logic                             pwrite;
    logic                             pready;
    logic                             pslverr;
    logic [2                  :0]     pprot;
    logic [`SVK_APB_STRB_WIDTH -1 :0] pstrb;
    logic [`SVK_APB_USER_WIDTH -1 :0] puser;


    clocking mst_cb @(posedge pclk);
        default input #0.1ns output #0.1ns;

        output paddr;
        output psel;
        output pwdata;
        input  prdata;
        output penable;
        output pwrite;
        input  pready;
        input  pslverr;
        output pprot;
        output pstrb;
        output puser;

    endclocking

    clocking slv_cb @(posedge pclk);
        default input #0.1ns output #0.1ns;

        input  paddr;
        input  psel;
        input  pwdata;
        output prdata;
        input  penable;
        input  pwrite;
        output pready;
        output pslverr;
        input  pprot;
        input  pstrb;
        input  puser;

    endclocking

    clocking mon_cb @(posedge pclk);
        default input #0.1ns output #0.1ns;

        input  paddr;
        input  psel;
        input  pwdata;
        input  prdata;
        input  penable;
        input  pwrite;
        input  pready;
        input  pslverr;
        input  pprot;
        input  pstrb;
        input  puser;

    endclocking

    modport mst_mp(clocking mst_cb);
    modport slv_mp(clocking slv_cb);
    modport mon_mp(clocking mon_cb);


    default disable iff(!presetn);
    default clocking mon_cb;

    a1:assert property((!psel & !penable) |=> !(psel & penable));
    a2:assert property((psel & !penable) |=> (psel & penable));
    a3:assert property(!(!psel & penable));
    a4:assert property((psel & penable & !pready) |=> $stable({psel,penable,pwdata,pwrite,pprot,pstrb}));
    a5:assert property((psel & penable & pready) |=> !penable);
    a6:assert property((psel) |-> !$isunknown({penable,pwdata,pwrite,pprot,pstrb,pready}));
    a7:assert property(!$isunknown({psel,penable}));


endinterface


`endif

