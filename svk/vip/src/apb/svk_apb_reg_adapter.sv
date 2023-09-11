/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_APB_REG_ADAPTER__SV
`define SVK_APB_REG_ADAPTER__SV


class svk_apb_reg_adapter extends uvm_reg_adapter;
    `uvm_object_utils(svk_apb_reg_adapter)

    function new(string name="svk_apb_reg_adapter");
        super.new(name);
    endfunction

    function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
        svk_apb_transaction     tr;
        svk_apb_reg_extension   ext;
        uvm_reg_item            reg_item;



        tr              = svk_apb_transaction::type_id::create("tr");
        tr.need_resp    = provides_responses;
        tr.addr         = rw.addr;
        tr.dir          = (rw.kind==UVM_READ) ? svk_apb_dec::READ : svk_apb_dec::WRITE;
        tr.strb         = 2'h3;
        if(rw.kind == UVM_WRITE)
            tr.data = rw.data;

        reg_item = get_item();
        if(!$cast(ext, reg_item.extension))begin
            ext.pack_extension(tr);
        end else begin
            `uvm_info(get_type_name(), "not svk_apb_extension", UVM_HIGH)
        end

        return tr;
    endfunction




    function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
        svk_apb_transaction     tr;
        svk_apb_reg_extension   ext;
        uvm_reg_item            reg_item;

        if(!$cast(tr, bus_item))begin
            `uvm_fatal(get_type_name(), "not svk_apb_transaction")
        end

        rw.kind = (tr.dir == svk_apb_dec::READ) ? UVM_READ : UVM_WRITE;
        rw.addr = tr.addr;
        rw.data = tr.data;
        rw.status = (tr.resp == 1'b1) ? UVM_NOT_OK : UVM_IS_OK;

        ext = svk_apb_reg_extension::type_id::create("ext");
        ext.unpack_extension(tr);
        reg_item = new();
        reg_item.extension = ext;
        m_set_item(reg_item);

    endfunction


endclass


`endif
