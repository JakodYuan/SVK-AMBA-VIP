/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/

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