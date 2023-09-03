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

`ifndef SVK_AXI_SCHEDULER__SV
`define SVK_AXI_SCHEDULER__SV

class svk_axi_scheduler;
    int start_idx;
    int end_idx;
    int num;

    function new(int num);
        this.start_idx = 0;
        this.end_idx   = num-1;
        this.num       = num;
    endfunction

    function bit[`SVK_AXI_MAX_OSD-1:0] rr_dispatch(bit[`SVK_AXI_MAX_OSD-1:0] req);
        bit [`SVK_AXI_MAX_OSD-1:0] grant;

        do
            begin
                if(req[start_idx])begin
                    grant[start_idx] = 1;
                    break;
                end
                else begin
                    if(start_idx==num-1)begin
                        start_idx = 0;
                    end
                    else begin
                        ++start_idx;
                    end
                end
            end
        while(start_idx != end_idx);

        end_idx = start_idx;
        if(start_idx == num-1)begin
            start_idx = 0;
        end
        else begin
            start_idx = start_idx + 1;
        end
        
        return grant;
    endfunction
endclass

`endif
