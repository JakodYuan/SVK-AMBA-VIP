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

`ifndef SVK_BIND__SV
`define SVK_BIND__SV


typedef class svk_normal_bind;
static svk_normal_bind nbs[string];

virtual class svk_normal_bind;
    string      inst_path;

    task excute(string func, uvm_object obj=null);
    endtask

endclass


typedef class svk_agent_bind;
static svk_agent_bind abs[string];

virtual class svk_agent_bind extends svk_normal_bind;
    uvm_object_wrapper      wrapper;
    string                  agent_name;

	pure local virtual function void send_port();
    pure virtual function void drive(svk_dec::agent_work_mode_enum work_mode);
    pure virtual function uvm_object get_info();

    function svk_agent create_agent(uvm_component parent, bit create_mode=0);
        uvm_object obj;
        svk_agent  agt;
        uvm_factory f;

        f = uvm_factory::get();

        case(create_mode)
            1'b0:begin
                if(agent_name == "")begin
                    `uvm_fatal("create_agent", "agent_name is empty")
                end

                obj = f.create_component_by_name(agent_name, parent.get_full_name(), inst_path, parent);
                if(!$cast(agt, obj))begin
                    `uvm_fatal("create_agent", $sformatf("%s is not svk_agent", obj.get_type_name()))
                end
            end
            1'b1:begin
                if(wrapper == null)begin
                    `uvm_fatal("create_agent", "wrapper is null")
                end

                obj = f.create_component_by_type(wrapper, parent.get_full_name(), inst_path, parent);
                if(!$cast(agt, obj))begin
                    `uvm_fatal("create_agent", $sformatf("%s is not svk_agent", obj.get_type_name()))
                end
            end
        endcase

        return agt;
    endfunction

endclass


function svk_agent_bind get_agent_bind(string wildcard_path);
    svk_agent_bind ab_q[$];

    foreach(abs[inst_path])begin
        if(uvm_is_match(wildcard_path, inst_path))begin
            ab_q.push_back(abs[inst_path]);
        end
    end

    if(ab_q.size == 1)begin
        return ab_q[0];
    end
    else if(ab_q.size > 1)begin
        `uvm_error("get_agent_bind", $sformatf("find more than one svk_agent_bind with wildcard_path=%0s", wildcard_path))
        `uvm_info("get_agent_bind", "all find svk_agent_bind:", UVM_NONE)
        foreach(ab_q[i])begin
           `uvm_info("get_agent_bind", $sformatf("inst_path=%0s", ab_q[i].inst_path), UVM_NONE)
        end
    end
    else begin
        `uvm_error("get_agent_bind", $sformatf("not find any svk_agent_bind with wildcard_path=%0s", wildcard_path))
        `uvm_info("get_agent_bind", "all svk_agent_bind:", UVM_NONE)
        foreach(abs[inst_path])begin
            `uvm_info("get_agent_bind", $sformatf("inst_path=%0s", inst_path), UVM_NONE)
        end
    end
endfunction



function svk_normal_bind get_normal_bind(string wildcard_path);
    svk_normal_bind nb_q[$];

    foreach(nbs[inst_path])begin
        if(uvm_is_match(wildcard_path, inst_path))begin
            nb_q.push_back(nbs[inst_path]);
        end
    end

    if(nb_q.size == 1)begin
        return nb_q[0];
    end
    else if(nb_q.size > 1)begin
        `uvm_error("get_normal_bind", $sformatf("find more than one svk_normal_bind with wildcard_path=%0s", wildcard_path))
        `uvm_info("get_normal_bind", "all find svk_normal_bind:", UVM_NONE)
        foreach(nb_q[i])begin
           `uvm_info("get_normal_bind", $sformatf("inst_path=%0s", nb_q[i].inst_path), UVM_NONE)
        end
    end
    else begin
        `uvm_error("get_normal_bind", $sformatf("not find any svk_normal_bind with wildcard_path=%0s", wildcard_path))
        `uvm_info("get_normal_bind", "all svk_normal_bind:", UVM_NONE)
        foreach(nbs[inst_path])begin
            `uvm_info("get_normal_bind", $sformatf("inst_path=%0s", inst_path), UVM_NONE)
        end
    end
endfunction

function string remove_last_layer(string path);
    byte unsigned tmp_bytes[];
    int tmp_q[$];

    tmp_bytes = {>>byte{path}};
    tmp_q = tmp_bytes.find_index with(string'(item) == ".");
    if(tmp_q.size() < 2)begin
        $fatal(0, $sformatf("not a valid inst_name=%s!", path));
    end

    return path.substr(0, tmp_q[$] - 1);
endfunction


`define GET_INST_PATH \
function string get_inst_path(); \
    return remove_last_layer($sformatf("%m")); \
endfunction:get_inst_path

`endif

