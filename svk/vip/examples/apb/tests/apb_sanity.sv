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

class apb_sanity extends apb_base_test;
    `uvm_component_utils(apb_sanity)

    function new(string name="apb_sanity", uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

		uvm_config_db#(uvm_object_wrapper)::set(null, "*apb_sys_env.master[0].sqr.main_phase", "default_sequence", svk_apb_default_master_sequence::type_id::get());
		uvm_config_db#(uvm_object_wrapper)::set(null, "*apb_sys_env.slave[0].sqr.main_phase", "default_sequence", svk_apb_default_slave_sequence::type_id::get());

    endfunction


endclass
