/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_APB_REG_CHECK__SV
`define SVK_APB_REG_CHECK__SV

class svk_apb_reg_check extends uvm_reg_sequence;
    `uvm_object_utils(svk_apb_reg_check)

    parameter  STEP_NUM = 9;
    typedef enum {UP, DOWN}                             scan_dir_e;
    typedef enum {RST, back2back, SEQUE, READ_ONLY}     scan_mode_e;
    typedef enum {PATTERN_5A, PATTERN_A5, PATTERN_RAND} scan_pattern_e;

    uvm_reg_block           model;
    uvm_reg_addr_t          addr_s;
    uvm_reg_addr_t          addr_e;
    int unsigned            step_size = 2;
    int unsigned            step_byte;
    bit                     skip_regs[uvm_reg];
    bit[STEP_NUM:0]         step_en;
    uvm_path_e              wr_path;
    uvm_path_e              rd_path;
    uvm_status_e            rsv_expect_status;
    uvm_status_e            rsv_expect_rdata;


    extern function new(string name="");
    extern function void configure( uvm_reg_block model,
                                    uvm_reg_addr_t addr_s,
                                    uvm_reg_addr_t addr_e,
                                    uvm_path_e     wr_path = UVM_FRONTDOOR,
                                    uvm_path_e     rd_path = UVM_FRONTDOOR,
                                    int unsigned step_size = 2,
                                    bit skip_regs[uvm_reg] = '{},
                                    bit [STEP_NUM-1:0] step_en={STEP_NUM{1'b1}},
                                    uvm_status_e rsv_expect_status = UVM_IS_OK,
                                    uvm_reg_data_t rsv_expect_rdata = 0);
    extern task scan();
    extern task scan_rst(bit check_en);
    extern task scan_seque(bit check_en, scan_dir_e dir, scan_pattern_e pattern);
    extern task scan_back2back(bit check_en, scan_dir_e dir, scan_pattern_e pattern);
    extern function uvm_reg_data_t get_data(scan_pattern_e pattern);
    extern task write_check(uvm_reg_addr_t addr, uvm_reg_data_t wdata, uvm_path_e path);
    extern task read_check(uvm_reg_addr_t addr, uvm_path_e path);
    extern task access_rsv_addr(ref uvm_status_e status, uvm_reg_bus_op rw);
endclass

function svk_apb_reg_check::new(string name="");
    super.new(name);
endfunction

function void svk_apb_reg_check::configure( uvm_reg_block model,
                                    uvm_reg_addr_t addr_s,
                                    uvm_reg_addr_t addr_e,
                                    uvm_path_e     wr_path = UVM_FRONTDOOR,
                                    uvm_path_e     rd_path = UVM_FRONTDOOR,
                                    int unsigned step_size = 2,
                                    bit skip_regs[uvm_reg] = '{},
                                    bit[STEP_NUM-1:0] step_en={STEP_NUM{1'b1}},
                                    uvm_status_e rsv_expect_status = UVM_IS_OK,
                                    uvm_reg_data_t rsv_expect_rdata = 0);
    this.model      = model;
    this.addr_s     = addr_s;
    this.addr_e     = addr_e;
    this.wr_path    = wr_path;
    this.rd_path    = rd_path;
    this.skip_regs  = skip_regs;
    this.step_en    = step_en;
    this.step_size  = step_size;
    this.rsv_expect_status = rsv_expect_status;
    this.rsv_expect_rdata  = rsv_expect_rdata;
    this.step_byte  = 1 << step_size;

    if(addr_s >= addr_e)
        `uvm_error("apb_reg_check", "addr_e must bigger than addr_s")

    if((addr_s | addr_e) & ({64{1'b1}}>>(64-step_size)))
        `uvm_error("apb_reg_check", "addr_s and addr_e must aligned to step_size")

endfunction:configure

task svk_apb_reg_check::scan();

    `uvm_info(get_type_name(), "step 1, check reset value.", UVM_NONE)
    scan_rst(step_en[0]);


    `uvm_info(get_type_name(), "step 2, write 5a5a in all the read all(up)", UVM_NONE)
    scan_seque(step_en[1], UP, PATTERN_5A);

    `uvm_info(get_type_name(), "step 3, write a5a5 in all the read all(up)", UVM_NONE)
    scan_seque(step_en[2], UP, PATTERN_A5);
    scan_seque(step_en[2], UP, PATTERN_RAND);

    `uvm_info(get_type_name(), "step 4, write 5a5a in all the read all(down)", UVM_NONE)
    scan_seque(step_en[3], DOWN, PATTERN_5A);

    `uvm_info(get_type_name(), "step 5, write a5a5 in all the read all(down)", UVM_NONE)
    scan_seque(step_en[4], DOWN, PATTERN_A5);
    scan_seque(step_en[4], DOWN, PATTERN_RAND);


    `uvm_info(get_type_name(), "step 6, write 5a5a immediately read(up)", UVM_NONE)
    scan_back2back(step_en[5], UP, PATTERN_5A);

    `uvm_info(get_type_name(), "step 7, write a5a5 immediately read(up)", UVM_NONE)
    scan_back2back(step_en[6], UP, PATTERN_A5);
    scan_back2back(step_en[6], UP, PATTERN_RAND);

    `uvm_info(get_type_name(), "step 8, write 5a5a immediately read(down)", UVM_NONE)
    scan_back2back(step_en[7], DOWN, PATTERN_5A);

    `uvm_info(get_type_name(), "step 9, write a5a5 immediately read(down)", UVM_NONE)
    scan_back2back(step_en[8], DOWN, PATTERN_A5);
    scan_back2back(step_en[8], DOWN, PATTERN_RAND);

endtask:scan

task svk_apb_reg_check::scan_rst(bit check_en);
    if(check_en)begin
        for(uvm_reg_addr_t addr = addr_s; addr <= addr_e && addr >= addr_s; addr=addr+step_byte)begin
            read_check(addr, rd_path);
        end
    end else begin
        `uvm_info(get_type_name(), "skip scan rst", UVM_NONE)
    end
endtask:scan_rst

function uvm_reg_data_t svk_apb_reg_check::get_data(scan_pattern_e pattern);
    case(pattern)
        PATTERN_A5  : get_data = 64'hA5A5A5A5_A5A5A5A5;
        PATTERN_5A  : get_data = 64'h5A5A5A5A_5A5A5A5A;
        PATTERN_RAND: get_data = {$urandom,$urandom};
        default     : get_data = {$urandom,$urandom};
    endcase
endfunction:get_data

task svk_apb_reg_check::scan_seque(bit check_en, scan_dir_e dir, scan_pattern_e pattern);
    if(check_en)begin
        if(dir == UP)begin
            for(uvm_reg_addr_t addr = addr_s; addr <= addr_e && addr >= addr_s; addr=addr+step_byte)begin
                uvm_reg_data_t data = get_data(pattern);
                write_check(addr, data, wr_path);
            end
            for(uvm_reg_addr_t addr = addr_s; addr <= addr_e && addr >= addr_s; addr=addr+step_byte)begin
                read_check(addr, rd_path);
            end
        end else begin
            for(uvm_reg_addr_t addr = addr_e; addr >= addr_s && addr <= addr_e; addr=addr-step_byte)begin
                uvm_reg_data_t data = get_data(pattern);
                write_check(addr, data, wr_path);
            end
            for(uvm_reg_addr_t addr = addr_e; addr >= addr_s && addr <= addr_e; addr=addr-step_byte)begin
                read_check(addr, rd_path);
            end
        end
    end else begin
       `uvm_info(get_type_name(), $sformatf("skip scan seque:dir=%0s, pattern=%0s", dir.name, pattern.name), UVM_NONE) 
    end
endtask:scan_seque

task svk_apb_reg_check::scan_back2back(bit check_en, scan_dir_e dir, scan_pattern_e pattern);
    if(check_en)begin
        if(dir == UP)begin
            for(uvm_reg_addr_t addr = addr_s; addr <= addr_e && addr >= addr_s; addr=addr+step_byte)begin
                uvm_reg_data_t data = get_data(pattern);
                write_check(addr, data, wr_path);
                read_check(addr, rd_path);
            end
        end else begin
            for(uvm_reg_addr_t addr = addr_e; addr >= addr_e && addr <= addr_e; addr=addr-step_byte)begin
                uvm_reg_data_t data = get_data(pattern);
                write_check(addr, data, wr_path);
                read_check(addr, rd_path);
            end
        end
    end else begin
       `uvm_info(get_type_name(), $sformatf("skip scan back2back:dir=%0s, pattern=%0s", dir.name, pattern.name), UVM_NONE) 
    end
endtask:scan_back2back


task svk_apb_reg_check::write_check(uvm_reg_addr_t addr, uvm_reg_data_t wdata, uvm_path_e path);
    uvm_status_e status;
    uvm_reg reg_tmp = model.default_map.get_reg_by_offset(addr);

    if(reg_tmp != null)begin
        if(skip_regs.exists(reg_tmp))
            return;
        if(path == UVM_BACKDOOR)begin
            if(reg_tmp.has_hdl_path())begin
                reg_tmp.write(status, wdata, UVM_BACKDOOR);
            end else begin
                `uvm_warning(get_type_name(), $sformatf("reg not has hdl path!\n%s", reg_tmp.sprint()))
                reg_tmp.write(status, wdata);
            end
        end else begin
            reg_tmp.write(status, wdata);
        end
        if(status == UVM_NOT_OK)
            `uvm_error(get_type_name(), $sformatf("write addr=%0h failed!\n%0s", addr, reg_tmp.sprint()))
    end else begin
        uvm_reg_bus_op rw;
        rw.kind = UVM_WRITE;
        rw.addr = addr;
        rw.data = wdata;
        access_rsv_addr(status, rw);
        if(status != rsv_expect_status)
            `uvm_error(get_type_name(), $sformatf("write rsv addr=%0h rsv_expect_status != status:status = %0s", addr, status.name))
    end
endtask:write_check

task svk_apb_reg_check::read_check(uvm_reg_addr_t addr, uvm_path_e path); 
    uvm_status_e status;
    uvm_reg reg_tmp = model.default_map.get_reg_by_offset(addr);

    if(reg_tmp != null)begin
        if(skip_regs.exists(reg_tmp))
            return;
        if(path == UVM_BACKDOOR)begin
            if(reg_tmp.has_hdl_path())begin
                reg_tmp.mirror(status, UVM_CHECK, UVM_BACKDOOR);
            end else begin
                `uvm_warning(get_type_name(), $sformatf("reg not has hdl path!\n%s", reg_tmp.sprint()))
                reg_tmp.mirror(status, UVM_CHECK);
            end
        end else begin
            reg_tmp.mirror(status, UVM_CHECK);
        end
        if(status == UVM_NOT_OK)
            `uvm_error(get_type_name(), $sformatf("mirror addr=%0h failed!\n%0s", addr, reg_tmp.sprint()))
    end else begin
        uvm_reg_bus_op rw;
        rw.kind = UVM_READ;
        rw.addr = addr;
        access_rsv_addr(status, rw);
        if(status != rsv_expect_status)
            `uvm_error(get_type_name(), $sformatf("read rsv addr=%0h rsv_expect_status != status:status = %0s", addr, status.name))
        if(rw.data != rsv_expect_rdata)
            `uvm_error(get_type_name(), $sformatf("read rsv addr=%0h rsv_expect_rdata != rw.data = %0h", addr, rw.data))
    end
endtask:read_check


task svk_apb_reg_check::access_rsv_addr(ref uvm_status_e status, uvm_reg_bus_op rw);
    uvm_reg_adapter     adapter;
    uvm_reg_item        reg_item;
    uvm_sequence_item   tr;

    adapter = model.default_map.get_adapter();
    reg_item = uvm_reg_item::type_id::create("item");
    adapter.m_set_item(reg_item);
    tr = adapter.reg2bus(rw);
    adapter.m_set_item(null);

    tr.set_sequencer(model.default_map.get_sequencer());
    `uvm_send(tr);
    tr.end_event.wait_on();

    if(adapter.provides_responses)
        get_base_response(tr);

    adapter.bus2reg(tr, rw);

endtask:access_rsv_addr


`endif
