# SVK AMBA VIP User Guide

## Caution

There VIPs WITHOUT ANY WARRANTY. The code are not guaranteed to work on any systems. Any problem please send email to the author(JakodYuan@outlook.com).

## 1. Run SVK AMBA VIP Example

SVK VIP include AXI/AHB/APB, The usage is similar to that of synopsys VIP.
The file structure is as follows
```
svk--
    |-- base
    |
    |-- vip
         |
         |-- example
         |      |
         |      |-- axi
         |      |-- ahb
         |      |-- apb
         |
         |-- src
                |-- axi
                |-- ahb
                |-- apb
```

Users can running the AXI example as follow step:
1. cd svk/vip/example/axi/
2. make run

After runing there are wave named "axi_test.fsdb" will generated

## 2. AXI


### 2.1 overview

![img](https://img2023.cnblogs.com/blog/898240/202307/898240-20230727182308639-102179832.png)

### 2.2 Integrating the VIP

There are 4 step to Integrating AXI VIP to TestBench:
1. Connecting VIP to the DUT
2. Instantiating and Configuring the VIP
3. Creating a Test Sequence
4. Creating a Test
5. Add Paths and Files for Compliling and Simulating

#### 2.2.1 Connecting VIP to the DUT



```sv
module harness;
    // 1. Include packages.
    import uvm_pkg::*;
    import svk_pkg::*;
    import svk_axi_pkg::*;
    import axi_env_pkg::*;

    ...

    // 2. instantiate and connect clock/reset.
    svk_axi_ifs u_if();
    assign u_if.master[0].aclk = clk;
    assign u_if.master[0].aresetn = rstn;
    assign u_if.slave[0].aclk = clk;
    assign u_if.slave[0].aresetn = rstn;

    // 3. connect AXI interface to the DUT, recommand use force
    initial begin
        force u_if.slave[0].awvalid  = MST_DUT.awvalid;
        force MST_DUT.awready = u_if.slave[0].awready;

        force SLV_DUT.awvalid  = u_if.master[0].awvalid;
        force u_if.master[0].awready = SLV_DUT.awready;
        ...
    end

    // 4. send virtual interface to environment, "axi_sys_env" is an instance of the AXI system environment(svk_axi_sys_env)
    initial begin
        uvm_config_db#(virtual svk_axi_ifs)::set(null, "uvm_test_top.env.axi_sys_env", "vif", u_if);
    end
endmodule
```
#### 2.1.2 Instantiating and Configuring the VIP

1. Create a customized AXI system configuration class by extending the AXI system configuration class (svk_axi_sys_cfg) and specifying the required configuration parameters.
For example:

```sv
class cust_axi_sys_env_cfg extends svk_axi_sys_env_cfg;
    `uvm_object_utils(cust_axi_sys_env_cfg)

    function new(string name="cust_axi_sys_env_cfg");
        super.new(name);

        master_num = 1;
        slave_num  = 1;
        create_sub_cfg(master_num, slave_num);
        for(int i=0; i<master_num; ++i)begin
            master_cfg[i].version                  = svk_axi_dec::AXI4;
            master_cfg[i].work_mode                = svk_dec::MASTER;
            master_cfg[i].wr_osd                   = 10;
            master_cfg[i].rd_osd                   = 10;
            master_cfg[i].ready_timeout_time       = 1000;
            master_cfg[i].data_width               = 256;
            master_cfg[i].addr_width               = 32;
            master_cfg[i].id_width                 = 8;
        end
        for(int i=0; i<slave_num; ++i)begin
            slave_cfg[i].version                  = svk_axi_dec::AXI4;
            slave_cfg[i].work_mode                = svk_dec::SLAVE;
            slave_cfg[i].wr_osd                   = 10;
            slave_cfg[i].rd_osd                   = 10;
            slave_cfg[i].ready_timeout_time       = 1000;
            slave_cfg[i].data_width               = 256;
            slave_cfg[i].addr_width               = 32;
            slave_cfg[i].id_width                 = 8;
        end
    endfunction


endclass
```

2. Instantiate the AXI system environment (svk_axi_sys_env) in the build phase of your testbench environment.
Construct the customized AXI system configuration and pass the configuration to the AXI system environment (instance of svk_axi_sys_env) in the build phase of your testbench environment

```sv
class axi_env extends uvm_env;
    `uvm_component_utils(axi_env)
    svk_axi_sys_env         axi_sys_env;
    svk_axi_sys_env_cfg     axi_sys_env_cfg;

    function new(string name="axi_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // instanciate svk_axi_sys_env
        axi_sys_env = svk_axi_sys_env::type_id::create("axi_sys_env", this);

        // set configuration to svk_axi_sys_env
        axi_sys_env_cfg = cust_axi_sys_env_cfg::type_id::create("axi_sys_env_cfg");
        uvm_config_db#(svk_axi_sys_env_cfg)::set(this, "axi_sys_env", "cfg", axi_sys_env_cfg);
    endfunction

endclass
```

#### 2.1.3 Creating a Test Sequence

The VIP provides a base sequence class (svk_axi_sequence) You can extend these base sequences to create test sequences.
The VIP also provides master and slave sequence demo (svk_axi_default_master_sequence and svk_axi_default_slave_sequence)

svk_axi_default_master_sequence

```sv
task svk_axi_default_master_sequence::body();
    svk_axi_transaction tr;
    svk_axi_agent_cfg   axi_cfg;
    svk_agent_cfg       get_cfg;


    // get agent configuration
    get_cfg = p_sequencer.get_cfg();
    if(!$cast(axi_cfg, get_cfg))
        `uvm_error(get_type_name(), "config type is not svk_axi_agent_cfg")

    repeat(10)begin
        // construct transaction and set configuration
        tr = svk_axi_transaction::type_id::create("tr");
        tr.cfg = axi_cfg;
        // randomize transactoin and send to driver
        tr.randomize() with {
            addr >= 'h8000_0000;
            addr <  'h8000_00ff;
            dir == svk_axi_dec::READ;
            burst == svk_axi_dec::BURST_INCR;
            length < 20;
            need_resp == 1;
        };
        `uvm_send(tr)
        if(tr.need_resp)
            get_response(rsp, tr.get_transaction_id());
    end

    ...

endtask
```
svk_axi_default_slave_sequence
```sv
 task body();
        svk_axi_transaction tr;

        forever begin
            // get transacton from slave dirver
            p_sequencer.response_request_port.peek(req);
            $cast(tr, req);

            // randomize and set delay
            tr.randomize();

            tr.awready_delay = 2;
            tr.arready_delay = 0;
            foreach(tr.wready_delay[i])
                tr.wready_delay[i] = i;

            tr.bvalid_delay = 1;
            foreach(tr.rvalid_delay[i])
                tr.rvalid_delay[i] = i;

            // write transaction data to memory or read data from memory to transaction
            if(tr.dir == svk_axi_dec::WRITE)begin
                p_sequencer.write_data_to_mem(tr);
            end
            else if(tr.dir == svk_axi_dec::READ)begin
                p_sequencer.read_data_from_mem(tr);
            end

            `uvm_send(tr)
        end

    endtask

```

#### 2.1.4 Creating a Test

You can create a VIP test by extending the uvm_test class. In the build phase of the extended class, you construct the testbench environment and set the respective AXI master and slave sequences.

```sv
function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    // Instanciate environment
    env = axi_env::type_id::create("env", this);

    // start sequence by default sequence mechanism
    uvm_config_db#(uvm_object_wrapper)::set(null, "*axi_sys_env.master[0].sqr.main_phase", "default_sequence", svk_axi_default_master_sequence::type_id::get());
    uvm_config_db#(uvm_object_wrapper)::set(null, "*axi_sys_env.slave[0].sqr.main_phase", "default_sequence", svk_axi_default_slave_sequence::type_id::get());

endfunction
```

#### 2.1.5 Add Paths and Files for Compliling and Simulating

```sv
// specify the directory paths for compiler to load VIP files
+incdir+../../../../svk

// Add Packges and Source file for compiler
../../../../svk/svk_pkg.sv
../../../../svk/svk_axi_pkg.sv
axi_env_pkg.sv
top.sv
```


### 2.2. More Configuration

#### 2.2.1 Agent Configuration

```sv
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
    int unsigned                                   data_user_width          = `SVK_AXI_USER_WIDTH            ; // w/r
    int unsigned                                   resp_user_width          = `SVK_AXI_USER_WIDTH            ; // b
    int unsigned                                   addr_user_width          = `SVK_AXI_USER_WIDTH            ; // aw/ar
```

---
- svk_axi_dec::version_enum version=svk_axi_dec::AXI3
Enumerated version that identify the version of AXI interface, Following are the possible values:
  - **AXI3**:
  - **AXI4**:
---
- int unsigned wr_osd = 1
Specifies the number of Write outstanding transaction a master/slave can support

---
- int unsigned rd_osd = 1
Specifies the number of Read outstanding transaction a master/slave can support

---
- bit wr_interleave_en = 0
Specifies Master/Slave wether support interleave, wr_interleave_en=1 only when verion=AXI3

---
- int unsigned wr_interleave_depth = 1
Specifies the number write transaction that can be interleaved This parameter should smaller than wr_osd. Master:Does not interleave transmitted write data beyond this value, SLAVE:checks that recieved write data is not interleaved beyond this value.

---
- bit wr_out_of_order_en = 0
Enable slave can return bid in different order with awid. Master:wd_out_of_order_en=0, check bid order is same with awid.

---
- bit rd_out_of_order_en = 0
Enable slave can return rid in different order with arid. Master:rd_out_of_order_en=0, check rid order is same with arid.

---
- bit data_before_addr = 0
Indicates that data will start before address for write transactions. data_before_addr=1,the value of awvalid_delay_event must be inside {svk_axi_dec::AWV_FIRST_WVALID_DATA_BEFORE_ADDR_EVENT,svk_axi_dec::AWV_FIRST_W_HANDSHAKE_DATA_BEFORE_ADDR_EVENT} data_before_addr=0, the value of awvalid_delay_event maust be inside {svk_axi_dec::AWV_PREV_AWVALID_EVENT,svk_axi_dec::AWV_PREV_AW_HANDSHAKE_EVENT,svk_axi_dec::AWV_PREV_LAST_W_HANDSHAKE_EVENT}

---
- svk_axi_dec::awvalid_delay_event_enum awvalid_delay_event = svk_axi_dec::AWV_PREV_AW_HANDSHAKE_EVENT
Defines a reference event from which the AWVALID delay should start. Following are the different reference events:
  - **AWV_PREV_AWVALID_EVENT**:Reference event is the previous AWVALID
  - **AWV_PREV_AW_HANDSHAKE_EVENT**:Reference event is the previous AWVALID handshake with AWREADY
  - **AWV_PREV_LAST_W_HANDSHAKE_EVENT**:Reference event is the previous WVALID and WLAST handshake with WREADY
  - **AWV_FIRST_WVALID_DATA_BEFORE_ADDR_EVENT**:This is used when data_before_addr=1, Reference event is first WVALID asset
  - **AWV_FIRST_W_HANDSHAKE_DATA_BEFORE_ADDR_EVENT**:This is used when data_before_addr=1, Reference event is first WVALID handshake with WREADY

---
- svk_axi_dec::arvalid_delay_event_enum arvalid_delay_event = svk_axi_dec::ARV_PREV_AR_HANDSHAKE_EVENT
  - **ARV_PREV_ARVALID_EVENT**:
  - **ARV_PREV_AR_HANDSHAKE_EVENT**:
  - **ARV_LAST_R_HANDSHAKE_EVENT**:
  - **ARV_FIRST_R_HANDSHAKE_EVENT**:

---
- svk_axi_dec::first_wvalid_delay_event_enum first_wvalid_delay_event = svk_axi_dec::FWV_PREV_W_HANDSHAKE_EVENT
  - **FWV_AWVLAID_EVENT**:
  - **FWV_AW_HANDSHAKE_EVENT**:
  - **FWV_PREV_W_HANDSHAKE_EVENT**:

---
- svk_axi_dec::next_wvalid_delay_event_enum next_wvalid_delay_event = svk_axi_dec::NWV_PREV_W_HANDSHAKE_EVENT
  - **NWV_PREV_W_HANDSHAKE_EVENT**:
  - **NWV_PREV_WVALID_EVENT**:(may not support)

---
- svk_axi_dec::first_rvalid_delay_event_enum first_rvalid_delay_event = svk_axi_dec::FRV_AR_HANDSHAKE_EVENT
  - **FRV_ARVALID_EVENT**:
  - **FRV_AR_HANDSHAKE_EVENT**:

---
- svk_axi_dec::next_rvalid_delay_event_enum next_rvalid_delay_event = svk_axi_dec::NRV_PREV_R_HANDSHAKE_EVENT
  - **NRV_PREV_R_HANDSHAKE_EVENT**:
  - **NRV_PREV_RVALID_EVENT**:(may not support)

---
- svk_axi_dec::bvalid_delay_event_enum bvalid_delay_event = svk_axi_dec::BV_LAST_W_HANDSHAKE_EVENT
  - **BV_LAST_W_HANDSHAKE_EVENT**:
  - **BV_AW_HANDSHAKE_EVENT**:

---
- svk_axi_dec::awready_delay_event_enum awready_delay_event = svk_axi_dec::AWR_AWVALID_EVENT
  - **AWR_AWVALID_EVENT**:
  - **AWR_FIRST_WVALID_EVENT**:(may not support)

---
- svk_axi_dec::arready_delay_event_enum arready_delay_event = svk_axi_dec::ARR_ARVALID_EVENT
  - **ARR_ARVALID_EVENT**:

---
- svk_axi_dec::wready_delay_event_enum wready_delay_event = svk_axi_dec::WR_WVALID_EVENT
  - **WR_WVALID_EVENT**:

---
- svk_axi_dec::bready_delay_event_enum bready_delay_event = svk_axi_dec::BR_BVALID_EVENT
  - **BR_BVALID_EVENT**:

---
- svk_axi_dec::rready_delay_event_enum rready_delay_event = svk_axi_dec::RR_RVALID_EVENT
  - **RR_RVALID_EVENT**:

---
- bit default_bready = 1'b1
Default value of BREADY signal.

---
- bit default_rready = 1'b1
Default value of RREADY signal.

---
- bit default_awready = 1'b1
Default value of AWREADY signal.

---
- bit default_arready = 1'b1
Default value of ARREADY signal.

---
- bit default_wready = 1'b1
Default value of WREADY signal.

---
- svk_dec::default_value_enum mem_default_value = svk_dec::DEFAULT_ZERO
Specifies the read value from memory when is not store in memory. Following is are the Possible values:
  - **svk_dec::DEFAULT_ZERO**: return 0, when address is not exist in memory
  - **svk_dec::DEFAULT_RAND**: return rand value ,when address is not exist in memory
  - **svk_dec::DEFAULT_MAX**: return max value, when address is not exist in memory

---
- svk_dec::idle_value_enum idle_value = svk_dec::IDLE_ZERO
Specifies the value when bus is idle.
  - **IDLE_ZERO**:
  - **IDLE_STABLE**:
  - **IDLE_RAND**:
  - **IDLE_MAX**:

---
- int unsigned ready_timeout_time = 1000
Specifies the max cycles which the transaction must be complete

---
- int unsigned data_width = `SVK_AXI_DATA_WIDTH
Specifies the WDATA or RDATA width

---
- int unsigned addr_width = `SVK_AXI_ADDR_WIDTH
Specifies the AWADDR or ARADDR width

---
- int unsigned id_width = `SVK_AXI_ID_WIDTH
Specifies the AWID/ARID/WID/BID/RID width

---
- int unsigned data_user_width = `SVK_AXI_USER_WIDTH
Specifies the WUSER/RUSER width

---
- int unsigned resp_user_width = `SVK_AXI_USER_WIDTH
Specifies the BUSER width

---
- int unsigned addr_user_width = `SVK_AXI_USER_WIDTH
Specifies the AWUSER and ARUSER width

#### 2.2.1 Transaction Configuration

```sv
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
```

---
- uvm_object extension
User extension

---
- rand bit need_resp
need_resp=0, master driver not return response to sequence
need_resp=1, master driver will return response to sequence

---
- rand int awready_delay
svk_axi_agent_cfg::default_awready=0, this member defines the AWREADY signal delay in number of clock cycles, The reference event used for this delay is svk_axi_agent_cfg::awready_delay_event
svk_axi_agent_cfg::default_awready=1, this member defines the number of clock cycles for which AWREADY signal should be deasset after handshake, before pulling it up again to its default value, The reference event used for this delay is svk_axi_agent_cfg::awready_delay_event

---
- rand int awvalid_delay
This value defines the number of cycles the AWVALID signal is delayed. The reference event for this delay is svk_axi_agent_cfg::awvalid_delay_event

---
- rand int arready_delay
svk_axi_agent_cfg::default_arready=0, this member defines the ARREADY signal delay in number of clock cycles, The reference event used for this delay is svk_axi_agent_cfg::arready_delay_event
svk_axi_agent_cfg::default_arready=1, this member defines the number of clock cycles for which ARREADY signal should be deasset after handshake, before pulling it up again to its default value, The reference event used for this delay is svk_axi_agent_cfg::arready_delay_event

---
- rand int arvalid_delay
This value defines the number of cycles the ARVALID signal is delayed. The reference event for this delay is svk_axi_agent_cfg::arvalid_delay_event

---
- rand int wready_delay[]
svk_axi_agent_cfg::default_wready=0, this member defines the WREADY signal delay in number of clock cycles, The reference event used for this delay is svk_axi_agent_cfg::wready_delay_event
svk_axi_agent_cfg::default_wready=1, this member defines the number of clock cycles for which WREADY signal should be deasset after handshake, before pulling it up again to its default value, The reference event used for this delay is svk_axi_agent_cfg::wready_delay_event

---
- rand int wvalid_delay[]
This value defines the number of cycles the WVALID signal is delayed. The reference event for this delay is svk_axi_agent_cfg::first_wvalid_delay_event and svk_axi_agent_cfg::next_wvalid_delay_event

---
- rand int rready_delay[]
svk_axi_agent_cfg::default_rready=0, this member defines the RREADY signal delay in number of clock cycles, The reference event used for this delay is svk_axi_agent_cfg::rready_delay_event
svk_axi_agent_cfg::default_rready=1, this member defines the number of clock cycles for which RREADY signal should be deasset after handshake, before pulling it up again to its default value, The reference event used for this delay is svk_axi_agent_cfg::rready_delay_event

---
- rand int rvalid_delay[]
This value defines the number of cycles the RVALID signal is delayed. The reference event for this delay is svk_axi_agent_cfg::first_rvalid_delay_event and svk_axi_agent_cfg::next_rvalid_delay_event

---
- rand int bvalid_delay
This value defines the number of cycles the BVALID signal is delayed. The reference event for this delay is svk_axi_agent_cfg::bvalid_delay_event

---
- rand int bready_delay
svk_axi_agent_cfg::default_bready=0, this member defines the BREADY signal delay in number of clock cycles, The reference event used for this delay is svk_axi_agent_cfg::bready_delay_event
svk_axi_agent_cfg::default_bready=1, this member defines the number of clock cycles for which BREADY signal should be deasset after handshake, before pulling it up again to its default value, The reference event used for this delay is svk_axi_agent_cfg::bready_delay_event

---
- svk_axi_agent_cfg cfg;
The agent cfg for constraint transaction




### 2.3 Macros

```sv
`define SVK_AXI_ADDR_WIDTH             64
`define SVK_AXI_DATA_WIDTH             1024
`define SVK_AXI_WSTRB_WIDTH            `SVK_AXI_DATA_WIDTH/8
`define SVK_AXI_LEN_WIDTH              8
`define SVK_AXI_SIZE_WIDTH             3
`define SVK_AXI_BURST_WIDTH            2
`define SVK_AXI_LOCK_WIDTH             2
`define SVK_AXI_CACHE_WIDTH            4
`define SVK_AXI_PROT_WIDTH             3
`define SVK_AXI_ID_WIDTH               64
`define SVK_AXI_QOS_WIDTH              4
`define SVK_AXI_REGION_WIDTH           4
`define SVK_AXI_RESP_WIDTH             2
`define SVK_AXI_USER_WIDTH             64
`define SVK_AXI_MAX_OSD                1024
`define SVK_AXI_MAX_NUM_MASTER         16
`define SVK_AXI_MAX_NUM_SLAVE          16
```

### 2.4 Interface

```sv
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
```

## 3. AHB/APB

AHB and APB VIP structure and usage is very similar to AXI, except configuration macro and interface, so AHB/APB only discribe the configuration macro and interface

### 3.1 AHB configuration and macro

#### 3.1.1 Agent Configuration

```sv
    svk_dec::default_value_enum           mem_default_value    = svk_dec::DEFAULT_ZERO;
    svk_dec::default_value_enum           default_value   = svk_dec::DEFAULT_ZERO;
    svk_dec::idle_value_enum              idle_value      = svk_dec::IDLE_ZERO;

    int unsigned                          ctrl_user_width = `SVK_AHB_CTRL_USER_WIDTH;
    int unsigned                          data_user_width = `SVK_AHB_DATA_USER_WIDTH;
    int unsigned                          addr_width      = `SVK_AHB_ADDR_WIDTH;
    int unsigned                          data_width      = `SVK_AHB_DATA_WIDTH;
    int unsigned                          hready_time_out = 500;

    bit                                   enable_strb;
    bit                                   cancle_after_error;
```

#### 3.1.1 Transaction Configuration

```sv
    rand int unsigned                               num_idle_cycles = 1;
    rand int unsigned                               num_incr_beats = 1;
    rand int unsigned                               num_busy_cycles[];
    rand int unsigned                               num_wait_cycles[];
    int unsigned                                    RESP_OKAY_wt   = 10;
    int unsigned                                    RESP_ERROR_wt  = 10;
    int unsigned                                    RESP_RETRY_wt  = 10;
    int unsigned                                    RESP_SPLIT_wt  = 10;
    bit                                             need_resp;
    svk_ahb_agent_cfg                               cfg;
```

#### 3.1.3 Macro

```sv
`define SVK_AHB_DATA_WIDTH      32  
`define SVK_AHB_RESP_WIDTH      2 
`define SVK_AHB_ADDR_WIDTH      32
`define SVK_AHB_BURST_WIDTH     3
`define SVK_AHB_PROT_WIDTH      4
`define SVK_AHB_SIZE_WIDTH      3 
`define SVK_AHB_TRANS_WIDTH     2
`define SVK_AHB_CTRL_USER_WIDTH 32
`define SVK_AHB_DATA_USER_WIDTH 32
`define SVK_AHB_SEL_WIDTH       1
`define SVK_AHB_MASTER_WIDTH    7 
`define SVK_AHB_STRB_WIDTH      `SVK_AHB_DATA_WIDTH/8
`define SVK_AHB_MAX_INCR_LEN    16
`define SVK_AHB_MAX_NUM_MASTER  16
`define SVK_AHB_MAX_NUM_SLAVE   16
```

#### 3.1.4 Interface

```sv
    logic                                       hclk;
    logic                                       hresetn;

    logic                                       hgrant;        // M
    logic [`SVK_AHB_DATA_WIDTH      -1 :0]      hrdata;        // M/S
    logic                                       hready;        // M/S
    logic [`SVK_AHB_RESP_WIDTH      -1 :0]      hresp;         // M/S
    logic [`SVK_AHB_ADDR_WIDTH      -1 :0]      haddr;         // M/S
    logic [`SVK_AHB_BURST_WIDTH     -1 :0]      hburst;        // M/S
    logic                                       hbusreq;       // M
    logic                                       hlock;         // M
    logic [`SVK_AHB_PROT_WIDTH      -1 :0]      hprot;         // M/S
    logic                                       hnonsec;       // M/S
    logic [`SVK_AHB_SIZE_WIDTH      -1 :0]      hsize;         // M/S
    logic [`SVK_AHB_TRANS_WIDTH     -1 :0]      htrans;        // M/S
    logic [`SVK_AHB_DATA_WIDTH      -1 :0]      hwdata;        // M/S
    logic                                       hwrite;        // M/S

    logic [`SVK_AHB_CTRL_USER_WIDTH -1 :0]      control_huser; // M/S
    logic [`SVK_AHB_DATA_USER_WIDTH -1 :0]      hwdata_huser;  // M/S
    logic [`SVK_AHB_DATA_USER_WIDTH -1 :0]      hrdata_huser;  // M/S

    logic [`SVK_AHB_SEL_WIDTH       -1 :0]      hsel;          // S
    logic                                       hmastlock;     // S
    logic [`SVK_AHB_MASTER_WIDTH    -1 :0]      hmaster;       // S
    logic                                       hready_in;     // S


    logic [`SVK_AHB_STRB_WIDTH      -1 :0]      hstrb;         // M/S
```

### 3.2 APB configuration

#### 3.2.1 Agent Configuration

```sv
    svk_dec::default_value_enum            mem_default_value    = svk_dec::DEFAULT_ZERO;
    svk_dec::idle_value_enum               idle_value           = svk_dec::IDLE_ZERO;
    svk_apb_dec::version_enum              version              = svk_apb_dec::APB3;
    int unsigned                           addr_width           = `SVK_APB_ADDR_WIDTH;
    int unsigned                           data_width           = `SVK_APB_DATA_WIDTH;
    int unsigned                           pready_time_out      = 500;
```

#### 3.2.1 Transaction Configuration

```sv
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
    rand bit                                  need_resp      = 1 ;
    svk_apb_agent_cfg                         cfg;
```

#### 3.2.3 Macro

```sv
`define SVK_APB_ADDR_WIDTH      32
`define SVK_APB_DATA_WIDTH      32
`define SVK_APB_USER_WIDTH      8
`define SVK_APB_STRB_WIDTH      `SVK_APB_DATA_WIDTH/8
`define SVK_APB_MAX_NUM_MASTER  16
`define SVK_APB_MAX_NUM_SLAVE   16
```

#### 3.2.4 Interface

```sv
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
```

## UVM reg adapter

AXI/AHB/APB VIPs have uvm_reg_adapter, user can use as follow.

```sv
uvm_reg_model model;
svk_axi_sys_env axi_sys_env;

model.set_sequencer(axi_sys_env.master[0].sqr, axi_sys_env.master[0].adp);
```

## Monitor port

VIPs monitor transaction to analysis port, user can call `get_oberseved_port()` to get anaysis port.

```sv
uvm_tlm_analysis_fifo#(uvm_sequence_item) fifo;
uvm_analysis_port#(uvm_sequence_item) port;

port = axi_sys_env.master[0].get_observed_port();
port.connect(fifo.analysis_export);
```

## Support the project

⭐ Add GitHub star on this page

⭐ Donate with Wechat/Alipay or by a coffee
<div>
<img style="float:left;width:30%;margin-right:5%;" src="https://img2023.cnblogs.com/blog/898240/202309/898240-20230911142753663-2109142163.png">
</div>
<img style="width:30%" src="https://img2023.cnblogs.com/blog/898240/202309/898240-20230911142215267-41824733.png">
</div>

