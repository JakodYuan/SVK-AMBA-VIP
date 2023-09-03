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

`ifndef SVK_ENV__SV
`define SVK_ENV__SV

class svk_env extends uvm_env;
    `uvm_component_utils(svk_env)

    svk_agent                   agts[string];
    svk_checker                 chks[string];
    svk_rm                      rms[string];
    svk_virtual_sequencer       vsqr;

    function new(string name="env" , uvm_component parent);
        super.new(name, parent);
    endfunction


    function void build_phase(uvm_phase phase);
        vsqr = svk_virtual_sequencer::type_id::create("vsqr", this);

    endfunction

    function void connect_phase(uvm_phase phase);
        foreach(agts[inst_path])begin
            vsqr.add_sqr(inst_path, agts[inst_path].get_sequencer());
        end
    endfunction



    function svk_agent get_agent(string wild_name);
        foreach(agts[inst_path])begin
            if(uvm_is_match({"*",wild_name,"*"}, inst_path))begin
                return agts[inst_path];
            end
        end
        `uvm_fatal("", {wild_name, " is not exist in agts"})
    endfunction



    function void agt_connect_chk(string agt_wild_name, string chk_name);
        svk_agent agt;

        agt = get_agent(agt_wild_name);
        if(!chks.exists(chk_name))
            `uvm_fatal(get_full_name(), {chk_name, " is not exits in chks"});

        agt.get_observed_port().connect(chks[chk_name].svk_export1);

        `uvm_info(get_full_name(), $sformatf("agt->chk:%s connect to %s", {agt.get_full_name(),".svk_port"},
           {chks[chk_name].get_full_name(),".svk_export1"}), UVM_NONE)
    endfunction



    function void agt_connect_chk0(string agt_wild_name, string chk_name);
        svk_agent agt;

        agt = get_agent(agt_wild_name);
        if(!chks.exists(chk_name))
            `uvm_fatal(get_full_name(), {chk_name, " is not exits in chks"});

        agt.get_observed_port().connect(chks[chk_name].svk_export0);

        `uvm_info(get_full_name(), $sformatf("agt->chk:%s connect to %s", {agt.get_full_name(),".svk_port"},
           {chks[chk_name].get_full_name(),".svk_export0"}), UVM_NONE)
    endfunction


    function void agt_connect_rm(string agt_wild_name, string rm_name);
        svk_agent agt;

        agt = get_agent(agt_wild_name);
        if(!rms.exists(rm_name))
            `uvm_fatal(get_full_name(), {rm_name, " is not exits in chks"});

        agt.get_observed_port().connect(rms[rm_name].svk_export);

        `uvm_info(get_full_name(), $sformatf("agt->rm:%s connect to %s", {agt.get_full_name(),".svk_port"},
           {rms[rm_name].get_full_name(),".svk_export"}), UVM_NONE)
    endfunction




    function void rm_connect_chk(string rm_name, string chk_name);

        if(!chks.exists(chk_name))
            `uvm_fatal(get_full_name(), {chk_name, " is not exits in chks"});
        if(!rms.exists(rm_name))
            `uvm_fatal(get_full_name(), {rm_name, " is not exits in chks"});

        rms[rm_name].svk_port.connect(chks[chk_name].svk_export0);

        `uvm_info(get_full_name(), $sformatf("rm->chk:%s connect to %s", {rms[rm_name].get_full_name(), ".svk_port"},
           {chks[chk_name].get_full_name(),".svk_export0"}), UVM_NONE)
    endfunction


    function void rm_connect_rm(string rm1_name, rm2_name);
        if(!rms.exists(rm1_name))
            `uvm_fatal(get_full_name(), {rm1_name, " is not exits in chks"});
        if(!rms.exists(rm2_name))
            `uvm_fatal(get_full_name(), {rm2_name, " is not exits in chks"});

        rms[rm1_name].svk_port.connect(rms[rm2_name].svk_export);

        `uvm_info(get_full_name(), $sformatf("rm->rm:%s connect to %s", {rms[rm1_name].get_full_name(), ".svk_port"},
           {rms[rm2_name].get_full_name(),".svk_export"}), UVM_NONE)
    endfunction


    task run_phase(uvm_phase phase);
        #30ns;
        foreach(abs[inst_path])begin
            abs[inst_path].drive(agts[inst_path].get_work_mode());
        end

    endtask

endclass
`endif
