/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


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
