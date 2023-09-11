/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_AHB_IF__SV
`define SVK_AHB_IF__SV

interface svk_ahb_if();

    logic                                       hclk;
    logic                                       hresetn;


    logic                                       hgrant;
    logic [`SVK_AHB_DATA_WIDTH      -1 :0]      hrdata;
    logic                                       hready;
    logic [`SVK_AHB_RESP_WIDTH      -1 :0]      hresp;
    logic [`SVK_AHB_ADDR_WIDTH      -1 :0]      haddr;
    logic [`SVK_AHB_BURST_WIDTH     -1 :0]      hburst;
    logic                                       hbusreq;
    logic                                       hlock;
    logic [`SVK_AHB_PROT_WIDTH      -1 :0]      hprot;
    logic                                       hnonsec;
    logic [`SVK_AHB_SIZE_WIDTH      -1 :0]      hsize;
    logic [`SVK_AHB_TRANS_WIDTH     -1 :0]      htrans;
    logic [`SVK_AHB_DATA_WIDTH      -1 :0]      hwdata;
    logic                                       hwrite;

    logic [`SVK_AHB_CTRL_USER_WIDTH -1 :0]      control_huser;
    logic [`SVK_AHB_DATA_USER_WIDTH -1 :0]      hwdata_huser;
    logic [`SVK_AHB_DATA_USER_WIDTH -1 :0]      hrdata_huser;

    logic [`SVK_AHB_SEL_WIDTH       -1 :0]      hsel;
    logic                                       hmastlock;
    logic [`SVK_AHB_MASTER_WIDTH    -1 :0]      hmaster;
    logic                                       hready_in;


    logic [`SVK_AHB_STRB_WIDTH      -1 :0]      hstrb;

    clocking mst_cb @(posedge hclk);
        default input #0.1ns output #0.1ns;
        input  hgrant;
        input  hrdata;
        input  hready;
        input  hresp;
        input  hrdata_huser;

        output haddr;
        output hburst;
        output hbusreq;
        output hlock;
        output hprot;
        output hnonsec;
        output hsize;
        output htrans;
        output hwdata;
        output hwrite;
        output hstrb;

        output control_huser;
        output hwdata_huser;
    endclocking

    clocking slv_cb @(posedge hclk);
        default input #0.1ns output #0.1ns;
        input  haddr;
        input  hburst;
        input  hmaster;
        input  hmastlock;
        input  hprot;
        input  hnonsec;
        input  hsel;
        input  hsize;
        input  htrans;
        input  hwdata;
        input  hwrite;
        input  hready_in;
        input  hstrb;
        input  hlock;

        input  control_huser;
        input  hwdata_huser;

        output hrdata;
        output hready;
        output hresp;
        output hrdata_huser;

    endclocking

    clocking mon_cb @(posedge hclk);
        default input #0.1ns output #0.1ns;

        input  hgrant;
        input  hrdata;
        input  hready;
        input  hresp;
        input  haddr;
        input  hburst;
        input  hbusreq;
        input  hlock;
        input  hprot;
        input  hnonsec;
        input  hsize;
        input  htrans;
        input  hwdata;
        input  hwrite;
        input  hstrb;

        input  control_huser;
        input  hwdata_huser;
        input  hrdata_huser;

        input  hsel;     
        input  hmastlock;
        input  hmaster;  
        input  hready_in;

    endclocking

    modport mst_mp(clocking mst_cb);
    modport slv_mp(clocking slv_cb);
    modport mon_mp(clocking mon_cb);


    default disable iff(!hresetn);
    default clocking mon_cb;










endinterface

typedef virtual svk_ahb_if svk_ahb_vif;

`endif
