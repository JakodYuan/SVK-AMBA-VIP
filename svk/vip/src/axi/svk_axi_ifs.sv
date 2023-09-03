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
`ifndef SVK_AXI_IFS__SV
`define SVK_AXI_IFS__SV


interface svk_axi_ifs;

    svk_axi_if      master[`SVK_AXI_MAX_NUM_MASTER-1:0]();
    svk_axi_if      slave[`SVK_AXI_MAX_NUM_SLAVE-1:0]();

    virtual svk_axi_if master_vif[`SVK_AXI_MAX_NUM_MASTER-1:0];
    virtual svk_axi_if slave_vif[`SVK_AXI_MAX_NUM_SLAVE-1:0];
    genvar i;
    generate;
        for(i =0; i<`SVK_AXI_MAX_NUM_MASTER; i=i+1)begin:gen_master
            initial begin
                master_vif[i] = master[i];
            end
        end
    endgenerate
    generate;
        for(i =0; i<`SVK_AXI_MAX_NUM_SLAVE; i=i+1)begin:gen_slave
            initial begin
                slave_vif[i] = slave[i];
            end
        end
    endgenerate

endinterface

`endif
