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
class cust_ahb_sys_env_cfg extends svk_ahb_sys_env_cfg;
    `uvm_object_utils(cust_ahb_sys_env_cfg)

    function new(string name="cust_ahb_sys_env_cfg");
        super.new(name);

        master_num = 1;
        slave_num  = 1;
        create_sub_cfg(master_num, slave_num);
        for(int i=0; i<master_num; ++i)begin
            master_cfg[i].work_mode                = svk_dec::MASTER;
            master_cfg[i].hready_time_out          = 1000;
            master_cfg[i].data_width               = 32;
            master_cfg[i].addr_width               = 32;
            master_cfg[i].enable_strb              = 1;
            master_cfg[i].cancle_after_error       = 1;
        end
        for(int i=0; i<slave_num; ++i)begin
            slave_cfg[i].work_mode                = svk_dec::SLAVE;
            slave_cfg[i].hready_time_out          = 1000;
            slave_cfg[i].data_width               = 32;
            slave_cfg[i].addr_width               = 32;
            slave_cfg[i].enable_strb              = 1;
            slave_cfg[i].cancle_after_error       = 1;
        end
    endfunction


endclass
