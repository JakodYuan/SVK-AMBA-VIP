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
`ifndef SVK_ACCESS_SEQUENCE__SV
`define SVK_ACCESS_SEQUENCE__SV

class svk_access_sequence extends uvm_sequence;
    `uvm_object_utils(svk_access_sequence)

    function new(string name="svk_access_sequence");
        super.new(name);
    endfunction

    task body();
        `uvm_send(req);
        get_response(rsp, req.get_transaction_id());
    endtask

endclass

`endif
