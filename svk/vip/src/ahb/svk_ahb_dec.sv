/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_AHB_dec__SV
`define SVK_AHB_dec__SV

class svk_ahb_dec;

    typedef enum {
        SIZE_8BIT    = 0,
        SIZE_16BIT   = 1,
        SIZE_32BIT   = 2,
        SIZE_64BIT   = 3,
        SIZE_128BIT  = 4,
        SIZE_256BIT  = 5,
        SIZE_512BIT  = 6,
        SIZE_1024BIT = 8
    } size_enum;

    typedef enum {
        SINGLE = 0,
        INCR   = 1,
        WRAP4  = 2,
        INCR4  = 3,
        WRAP8  = 4,
        INCR8  = 5,
        WRAP16 = 6,
        INCR16 = 7
    } burst_enum;


    typedef enum {
        SECURE   = 0,
        NOSECURE = 1
    } nonsec_enum;


    typedef enum {
        OPCODE_FETCH = 0,
        DATA_ACCESS  = 1
    } prot0_enum;


    typedef enum {
        USER_ACCESS        = 0,
        PRIVILEDGED_ACCESS = 1
    } prot1_enum;


    typedef enum {
        NON_BUFFERABLE = 0,
        BUFFERABLE     = 1
    } prot2_enum;


    typedef enum {
        NON_CACHEABLE = 0,
        CACHEABLE     = 1
    } prot3_enum;


    typedef enum {
        OKAY  = 0,
        ERROR = 1,
        RETRY = 2,
        SPLIT = 3
    } resp_enum;

    typedef enum {
        IDLE = 0,
        BUSY = 1,
        NSEQ = 2,
        SEQ  = 3
    } trans_enum;

    typedef enum {
        READ  = 0,
        WRITE = 1
    } dir_enum;

endclass

`endif
