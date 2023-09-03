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

`ifndef SVK_EXTENSION_WRAPPER__SV
`define SVK_EXTENSION_WRAPPER__SV

class svk_extension_wrapper extends svk_extension;
    `uvm_object_utils(svk_extension_wrapper)

    svk_extension exts[uvm_object_wrapper];

    function void pack_extension(uvm_sequence_item tr);
        foreach(exts[i])begin
            exts[i].pack_extension(tr);
        end
    endfunction

    function void unpack_extension(uvm_sequence_item tr);
        foreach(exts[i])begin
            exts[i].unpack_extension(tr);
        end
    endfunction


    function void add_extension(svk_extension ext);
        if(!exts.exists(ext.get_object_type()))begin
            exts[ext.get_object_type()] = ext;
        end
    endfunction

    function new(string name="");
        super.new(name);
    endfunction
endclass

`endif