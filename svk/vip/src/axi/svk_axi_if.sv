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

`ifndef SVK_AXI_IF__SV
`define SVK_AXI_IF__SV

interface svk_axi_if();

    logic                                   aclk;
    logic                                   aresetn;

    logic                                   awvalid;
    logic                                   awready;
    logic   [`SVK_AXI_ID_WIDTH     -1: 0]   awid;
    logic   [`SVK_AXI_ADDR_WIDTH   -1: 0]   awaddr;
    logic   [`SVK_AXI_LEN_WIDTH    -1: 0]   awlen;
    logic   [`SVK_AXI_SIZE_WIDTH   -1: 0]   awsize;
    logic   [`SVK_AXI_BURST_WIDTH  -1: 0]   awburst;
    logic   [`SVK_AXI_LOCK_WIDTH   -1: 0]   awlock;
    logic   [`SVK_AXI_CACHE_WIDTH  -1: 0]   awcache;
    logic   [`SVK_AXI_PROT_WIDTH   -1: 0]   awprot;
    logic   [`SVK_AXI_REGION_WIDTH -1: 0]   awregion;
    logic   [`SVK_AXI_USER_WIDTH   -1: 0]   awuser;
    logic   [`SVK_AXI_QOS_WIDTH    -1: 0]   awqos;

    logic                                   arvalid;
    logic                                   arready;
    logic   [`SVK_AXI_ID_WIDTH     -1: 0]   arid;
    logic   [`SVK_AXI_ADDR_WIDTH   -1: 0]   araddr;
    logic   [`SVK_AXI_LEN_WIDTH    -1: 0]   arlen;
    logic   [`SVK_AXI_SIZE_WIDTH   -1: 0]   arsize;
    logic   [`SVK_AXI_BURST_WIDTH  -1: 0]   arburst;
    logic   [`SVK_AXI_LOCK_WIDTH   -1: 0]   arlock;
    logic   [`SVK_AXI_CACHE_WIDTH  -1: 0]   arcache;
    logic   [`SVK_AXI_PROT_WIDTH   -1: 0]   arprot;
    logic   [`SVK_AXI_REGION_WIDTH -1: 0]   arregion;
    logic   [`SVK_AXI_USER_WIDTH   -1: 0]   aruser;
    logic   [`SVK_AXI_QOS_WIDTH    -1: 0]   arqos;

    logic                                   rvalid;
    logic                                   rready;
    logic                                   rlast;
    logic   [`SVK_AXI_ID_WIDTH     -1: 0]   rid;
    logic   [`SVK_AXI_DATA_WIDTH   -1: 0]   rdata;
    logic   [`SVK_AXI_RESP_WIDTH   -1: 0]   rresp;
    logic   [`SVK_AXI_USER_WIDTH   -1: 0]   ruser;

    logic                                   wvalid;
    logic                                   wready;
    logic                                   wlast;
    logic   [`SVK_AXI_ID_WIDTH     -1: 0]   wid;
    logic   [`SVK_AXI_DATA_WIDTH   -1: 0]   wdata;
    logic   [`SVK_AXI_WSTRB_WIDTH  -1: 0]   wstrb;
    logic   [`SVK_AXI_USER_WIDTH   -1: 0]   wuser;

    logic                                   bvalid;
    logic                                   bready;
    logic   [`SVK_AXI_ID_WIDTH     -1: 0]   bid;
    logic   [`SVK_AXI_RESP_WIDTH   -1: 0]   bresp;
    logic   [`SVK_AXI_USER_WIDTH   -1: 0]   buser;

    logic   csysreq;
    logic   csysack;
    logic   cactive;

    clocking mst_cb @(posedge aclk);
        default input #0.1 output #0.1;
        output awvalid;
        output awaddr;
        output awlen;
        output awsize;
        output awburst;
        output awlock;
        output awcache;
        output awprot;
        output awid;
        input  awready;
        output awregion;
        output awuser;
        output awqos;

        output arvalid;
        output araddr;
        output arlen;
        output arsize;
        output arburst;
        output arlock;
        output arcache;
        output arprot;
        output arid;
        input  arready;
        output arregion;
        output aruser;
        output arqos;

        input  rvalid;
        input  rlast;
        input  rdata;
        input  rresp;
        input  rid;
        input  ruser;
        output rready;

        output wvalid;
        output wlast;
        output wdata;
        output wstrb;
        output wuser;
        output wid;
        input  wready;

        input  bvalid;
        input  bresp;
        input  bid;
        input  buser;
        output bready;

        input  csysreq;
        output csysack;
        output cactive;
    endclocking

    clocking slv_cb @(posedge aclk);
        default input #0.1 output #0.1;
        input  awvalid;
        input  awaddr;
        input  awlen;
        input  awsize;
        input  awburst;
        input  awlock;
        input  awcache;
        input  awprot;
        input  awid;
        output awready;
        input  awregion;
        input  awuser;
        input  awqos;

        input  arvalid;
        input  araddr;
        input  arlen;
        input  arsize;
        input  arburst;
        input  arlock;
        input  arcache;
        input  arprot;
        input  arid;
        output arready;
        input  arregion;
        input  aruser;
        input  arqos;

        output rvalid;
        output rlast;
        output rdata;
        output rresp;
        output rid;
        output ruser;
        input  rready;

        input  wvalid;
        input  wlast;
        input  wdata;
        input  wstrb;
        input  wuser;
        input  wid;
        output wready;

        output bvalid;
        output bresp;
        output bid;
        output buser;
        input  bready;

        output csysreq;
        input  csysack;
        input  cactive;
    endclocking

    clocking mon_cb @(posedge aclk);
        default input #0.1 output #0.1;
        input  awvalid;
        input  awaddr;
        input  awlen;
        input  awsize;
        input  awburst;
        input  awlock;
        input  awcache;
        input  awprot;
        input  awid;
        input  awready;
        input  awregion;
        input  awuser;
        input  awqos;

        input  arvalid;
        input  araddr;
        input  arlen;
        input  arsize;
        input  arburst;
        input  arlock;
        input  arcache;
        input  arprot;
        input  arid;
        input  arready;
        input  arregion;
        input  aruser;
        input  arqos;

        input  rvalid;
        input  rlast;
        input  rdata;
        input  rresp;
        input  rid;
        input  ruser;
        input  rready;

        input  wvalid;
        input  wlast;
        input  wdata;
        input  wstrb;
        input  wuser;
        input  wid;
        input  wready;

        input  bvalid;
        input  bresp;
        input  bid;
        input  buser;
        input  bready;

        input  csysreq;
        input  csysack;
        input  cactive;
    endclocking

    modport mst_mp(clocking mst_cb, input aresetn);
    modport slv_mp(clocking slv_cb, input aresetn);
    modport mon_mp(clocking mon_cb, input aresetn);

    default disable iff(!aresetn);
    default clocking mon_cb;

    aw_payload_stable_check : assert property
        ((awvalid & ~awready) |=> $stable({awaddr,awlen,awsize,awburst,awlock,awcache,awprot,awid,awvalid,awregion,awuser,awqos}));


    w_payload_stable_check : assert property
        ((wvalid & ~wready) |=> $stable({wdata,wstrb,wlast,wuser,wvalid}));


    ar_payload_stable_check : assert property
        ((arvalid & ~arready) |=> $stable({araddr,arlen,arsize,arburst,arlock,arcache,arprot,arid,arvalid,arregion,aruser,arqos}));


    b_payload_stable_check : assert property
        ((bvalid & ~bready) |=> $stable({bresp,bid,buser,bvalid}));


    r_payload_stable_check : assert property
        ((rvalid & ~rready) |=> $stable({rdata,rresp,rlast,rid,rvalid}));


endinterface


`endif
