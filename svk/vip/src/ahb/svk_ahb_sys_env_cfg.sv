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
`ifndef SVK_AHB_SYS_ENV_CFG__SV
`define SVK_AHB_SYS_ENV_CFG__SV

class svk_ahb_sys_env_cfg extends uvm_object;
    `uvm_object_utils(svk_ahb_sys_env_cfg)

    int master_num;
    int slave_num;

    svk_ahb_agent_cfg master_cfg[`SVK_AHB_MAX_NUM_MASTER-1:0];
    svk_ahb_agent_cfg slave_cfg[`SVK_AHB_MAX_NUM_SLAVE-1:0];

    function new(string name="svk_ahb_sys_env_cfg");
        super.new(name);
    endfunction

    function void create_sub_cfg(int master_num, int slave_num);
        this.master_num = master_num;
        this.slave_num  = slave_num;

        for(int i=0; i<master_num; ++i)begin
            master_cfg[i] = svk_ahb_agent_cfg::type_id::create($sformatf("master_cfg[%0d]",i));
        end
        for(int i=0; i<slave_num; ++i)begin
            slave_cfg[i] = svk_ahb_agent_cfg::type_id::create($sformatf("slave_cfg[%0d]",i));
        end

    endfunction

endclass

`endif
