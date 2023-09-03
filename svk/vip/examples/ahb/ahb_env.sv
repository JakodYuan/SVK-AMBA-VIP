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

class ahb_env extends uvm_env;
    `uvm_component_utils(ahb_env)
    svk_ahb_sys_env         ahb_sys_env;
    svk_ahb_sys_env_cfg     ahb_sys_env_cfg;

    function new(string name="ahb_env", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ahb_sys_env_cfg = cust_ahb_sys_env_cfg::type_id::create("ahb_sys_env_cfg");
        uvm_config_db#(svk_ahb_sys_env_cfg)::set(this, "ahb_sys_env", "cfg", ahb_sys_env_cfg);
        ahb_sys_env = svk_ahb_sys_env::type_id::create("ahb_sys_env", this);
    endfunction
    
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        for(bit [31:0] addr='h8000_0000; addr<'h8000_00ff; ++addr)begin
            ahb_sys_env.slave[0].mem.set(addr, addr[7:0]);
        end
    endfunction 

endclass
