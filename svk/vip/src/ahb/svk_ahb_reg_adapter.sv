/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/

`ifndef SVK_AHB_REG_ADAPTER__SV
`define SVK_AHB_REG_ADAPTER__SV

class svk_ahb_reg_adapter extends uvm_reg_adapter;
    `uvm_object_utils(svk_ahb_reg_adapter)

    string tname;
    svk_ahb_agent_cfg   cfg;


    function new(string name="ahb2reg_adapter");
        super.new(name);
        tname = get_type_name();
        supports_byte_enable = 1;
        provides_responses = 1;
    endfunction

    function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
        bit [31:0]              burst_size_e;
        svk_ahb_reg_extension   ext;
        uvm_reg_item            reg_item;
        svk_ahb_transaction     tr;

        tr = svk_ahb_transaction::type_id::create("tr");
        tr.cfg = cfg;

        if(rw.n_bits > cfg.data_width)
            `uvm_fatal(tname, $sformatf("nbit>data_width , n_bit=%0d, data_width=%0d", rw.n_bits, cfg.data_width))
        
        burst_size_e = $clog2(rw.n_bits/8);

        tr.dir   = (rw.kind == UVM_WRITE) ? svk_ahb_dec::WRITE : svk_ahb_dec::READ;
        tr.addr  = rw.addr;
        tr.burst = svk_ahb_dec::SINGLE;
        tr.size  = svk_ahb_dec::size_enum'(burst_size_e);

        if(rw.kind == UVM_WRITE) begin
            tr.data    = new[1];
            tr.data[0] = rw.data;
        end 


        reg_item = get_item();
        if(!$cast(ext, reg_item.extension))begin
            ext.pack_extension(tr);
        end
        else begin
            tr.prot[0] = svk_ahb_dec::DATA_ACCESS;
            tr.prot[1] = svk_ahb_dec::USER_ACCESS;
            tr.prot[2] = svk_ahb_dec::NON_BUFFERABLE;
            tr.prot[3] = svk_ahb_dec::NON_CACHEABLE;
            `uvm_info(tname, "not svk_ahb_extension", UVM_HIGH)
        end

        return tr;

    endfunction

    function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
        uvm_reg_item            reg_item;
        svk_ahb_reg_extension   ext;
        svk_ahb_transaction     tr;

        if(!$cast(tr, bus_item)) begin
            `uvm_fatal(tname, "bus_item not svk_ahb_transaction type")
        end

        rw.kind   = (tr.dir == svk_ahb_dec::READ) ? UVM_READ : UVM_WRITE;
        rw.addr   = tr.addr;
        rw.data   = rw.kind == UVM_READ ? tr.data[0] : 0;
        rw.status = tr.resp[0] == svk_ahb_dec::OKAY ? UVM_IS_OK : UVM_NOT_OK; 

        ext = svk_ahb_reg_extension::type_id::create("ext");
        ext.unpack_extension(tr);
        reg_item = new();
        reg_item.extension = ext;
        m_set_item(reg_item);

    endfunction

endclass

`endif
