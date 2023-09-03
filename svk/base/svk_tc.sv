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

`ifndef SVK_TC__SV
`define SVK_TC__SV

class svk_tc extends uvm_test;
	`uvm_component_utils(svk_tc)

	extern function new(string name="svk_tc", uvm_component parent=null);
	extern function void report_phase(uvm_phase phase);
    extern function void pre_abort();

endclass


function svk_tc::new(string name="svk_tc", uvm_component parent=null);
	super.new(name, parent);
endfunction


function void svk_tc::report_phase(uvm_phase phase);
    string log;

	uvm_report_server report_svr = uvm_report_server::get_server();
	int count_fatal 	= report_svr.get_severity_count(UVM_FATAL);
	int count_error 	= report_svr.get_severity_count(UVM_ERROR);
	int count_warning 	= report_svr.get_severity_count(UVM_WARNING);
    int mis_id_count    = report_svr.get_id_count("MISCMP");
	super.report_phase(phase);


	if(count_fatal == 0 && mis_id_count == 0)begin
		if(count_error == 0 && mis_id_count == 0)begin
            log = $sformatf("Simulation PASSED at%15t", $realtime);
            log = $sformatf("%s (%0d warnings)", log, count_warning);
            log = $sformatf("\n\n\033[32m%s\033[0m", log);

            `uvm_info(get_type_name(), log, UVM_NONE);
		end else begin
            log = $sformatf("Simulation FAILED at%15t", $realtime);
            log = $sformatf("%s (%0d errors", log, count_error);
            log = $sformatf("%s, %0d misidcount", log, mis_id_count);
            log = $sformatf("%s, %0d warnings)", log, count_warning);
            log = $sformatf("\n\n\033[31m%s\033[0m", log);

            `uvm_info(get_type_name(), log, UVM_NONE);
		end
	end else begin
        log = $sformatf("Simulation FAILED at%15t", $realtime);
        log = $sformatf("%s (%0d fatals", log, count_fatal);
        log = $sformatf("%s, %0d errors", log, count_error);
        log = $sformatf("%s, %0d misidcount", log, mis_id_count);
        log = $sformatf("%s, %0d warnings)", log, count_warning);
        log = $sformatf("\n\n\033[31m%s\033[0m", log);

        `uvm_info(get_type_name(), log, UVM_NONE);
	end
endfunction

function void svk_tc::pre_abort();
    string log;

	uvm_report_server report_svr = uvm_report_server::get_server();
	int count_fatal 	= report_svr.get_severity_count(UVM_FATAL);
	int count_error 	= report_svr.get_severity_count(UVM_ERROR);
	int count_warning 	= report_svr.get_severity_count(UVM_WARNING);
    int mis_id_count    = report_svr.get_id_count("MISCMP");

    log = $sformatf("Simulation FAILED at%15t", $realtime);
    log = $sformatf("%s (%0d fatals", log, count_fatal);
    log = $sformatf("%s, %0d errors", log, count_error);
    log = $sformatf("%s, %0d misidcount", log, mis_id_count);
    log = $sformatf("%s, %0d warnings)", log, count_warning);
    log = $sformatf("\n\n\033[31m%s\033[0m", log);

    `uvm_info(get_type_name(), log, UVM_NONE);
endfunction

`endif
