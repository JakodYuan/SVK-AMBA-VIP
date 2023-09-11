/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_APB_DEC__SV
`define SVK_APB_DEC__SV

class svk_apb_dec;

    typedef enum {
        READ = 0,
        WRITE = 1
    } dir_enum;

    typedef enum {
        APB3 = 0,
        APB4 = 1
    } version_enum;

endclass

`endif
