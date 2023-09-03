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
`ifndef SVK_APB_SEQUENCE__SV
`define SVK_APB_SEQUENCE__SV

class svk_apb_sequence extends svk_sequence;
    `uvm_object_utils(svk_apb_sequence)
    `uvm_declare_p_sequencer(svk_apb_sequencer)

    function new(string name="svk_apb_sequence");
        super.new(name);
    endfunction

endclass

`endif
