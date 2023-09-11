/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/

`ifndef SVK_DEC__SV
`define SVK_DEC__SV

class svk_dec;

    typedef enum bit [0:0] {
        OFF  = 0,
        ON   = 1
    } switch_enum;

    typedef enum bit [1:0] {
        ONLY_MONITOR = 0,
        MASTER       = 1,
        SLAVE        = 2
    } agent_work_mode_enum;

    typedef enum {
        IDLE_ZERO   = 0,
        IDLE_STABLE = 1,
        IDLE_RAND   = 2,
        IDLE_MAX    = 3
    } idle_value_enum;

    typedef enum {
        DEFAULT_ZERO   = 0,
        DEFAULT_RAND   = 1,
        DEFAULT_MAX    = 2
    } default_value_enum;

endclass

`endif