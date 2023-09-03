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

`ifndef SVK_AHB_REG_EXTENSION__SV
`define SVK_AHB_REG_EXTENSION__SV


class svk_ahb_reg_extension extends svk_extension;
    `uvm_object_utils(svk_ahb_reg_extension)

    bit data_or_instr;
    bit privileged;
    bit bufferable;
    bit modifiable;
    bit nonsec;

    function void pack_extension(uvm_sequence_item tr);
        svk_ahb_transaction ahb_tr;

        if(!$cast(ahb_tr, tr))
            `uvm_error(get_type_name, "ahb_extension must add to ahb_transaction")

        ahb_tr.prot[0]  = data_or_instr;
        ahb_tr.prot[1]  = privileged;
        ahb_tr.prot[2]  = bufferable;
        ahb_tr.prot[3]  = modifiable;
        ahb_tr.nonsec   = svk_ahb_dec::nonsec_enum'(nonsec);
    endfunction

    function void unpack_extension(uvm_sequence_item tr);
        svk_ahb_transaction ahb_tr;

        if(!$cast(ahb_tr, tr))
            `uvm_error(get_type_name, "ahb_extension must add to ahb_transaction")

         data_or_instr = ahb_tr.prot[0];
         privileged    = ahb_tr.prot[1];
         bufferable    = ahb_tr.prot[2];
         modifiable    = ahb_tr.prot[3];
         nonsec        = ahb_tr.nonsec ;
    endfunction


    function new(string name="");
        super.new(name);
    endfunction
endclass

`endif
