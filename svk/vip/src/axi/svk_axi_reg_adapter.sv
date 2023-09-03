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
`ifndef SVK_AXI_REG_ADAPTER__SV
`define SVK_AXI_REG_ADAPTER__SV

typedef class svk_axi_agent_cfg;
class svk_axi_reg_adapter extends uvm_reg_adapter;
    `uvm_object_utils(svk_axi_reg_adapter)

    string tname;
    svk_axi_agent_cfg   cfg;

    function new(string name="svk_axi_reg_adapter", svk_axi_agent_cfg cfg=null);
        super.new(name);
        tname = get_type_name();
        supports_byte_enable = 1;
        provides_responses = 1;
        this.cfg = cfg;
    endfunction


    function uvm_sequence_item reg2bus(const ref uvm_reg_bus_op rw);
        bit [31:0]              burst_size_e;
        svk_axi_reg_extension   ext;
        uvm_reg_item            reg_item;
        svk_axi_transaction     tr;

        tr = svk_axi_transaction::type_id::create("tr");

        if(rw.n_bits > cfg.data_width)
            `uvm_fatal(tname, $sformatf("nbit>data_width , n_bit=%0d, data_width=%0d", rw.n_bits, cfg.data_width))

        burst_size_e = $clog2(rw.n_bits/8);

        tr.cfg    = cfg;
        tr.dir    = (rw.kind == UVM_WRITE) ? svk_axi_dec::WRITE : svk_axi_dec::READ;
        tr.addr   = rw.addr;
        tr.burst  = svk_axi_dec::BURST_INCR;
        tr.size   = svk_axi_dec::size_enum'(burst_size_e);
        tr.lock   = svk_axi_dec::NORMAL;
        tr.length = svk_axi_dec::LENGTH_1;
        tr.id     = 0;

        if(rw.kind == UVM_WRITE) begin
            bit [127:0] wstrb = 'b0;

            tr.data         = new[tr.length+1];
            tr.wstrb        = new[tr.length+1];
            tr.wuser        = new[tr.length+1];
            tr.wvalid_delay = new[tr.length+1];

            tr.awready_delay = 0; 
            foreach(tr.wvalid_delay[i])begin
                 tr.wvalid_delay[i] = 0;
            end
            tr.data[0] = rw.data;

            for(int i = 0; i < rw.n_bits/8; ++i)
                wstrb[i] = 1'b1;

            tr.wstrb[0] = wstrb;
        end
        else begin
            tr.rvalid_delay = new[tr.length+1];
            foreach(tr.rvalid_delay[i])begin
                tr.rvalid_delay[i] = 0;
            end
        end

        reg_item = get_item();
        if(!$cast(ext, reg_item.extension))begin
            ext.pack_extension(tr);
        end
        else begin
            tr.prot = svk_axi_dec::prot_enum'(0);
            `uvm_info(tname, "not svk_axi_extension", UVM_HIGH)
        end

        return tr;
    endfunction


    function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
        svk_axi_reg_extension   ext;
        uvm_reg_item            reg_item;
        svk_axi_transaction     tr;

        if(!$cast(tr, bus_item))begin
            `uvm_fatal(tname, "bus_item not svt_svk_axi_master_transaction type")
        end

        rw.kind   = (tr.dir == svk_axi_dec::READ) ? UVM_READ : UVM_WRITE;
        rw.addr   = tr.addr;
        rw.data   = rw.kind == UVM_READ ? tr.data[0] : 0;
        rw.status = tr.resp[0] == svk_axi_dec::OKAY ? UVM_IS_OK : UVM_NOT_OK; 

        ext = svk_axi_reg_extension::type_id::create("ext");
        ext.unpack_extension(tr);
        reg_item = new();
        reg_item.extension = ext;
        m_set_item(reg_item);

    endfunction

endclass

`endif