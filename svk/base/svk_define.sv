/***********************************************************
 *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
 *  All right reserved.
************************************************************/


`ifndef SVK_DEFINE__SV
`define SVK_DEFINE__SV




`ifndef SVK_IS_EMPTY_Q
`define SVK_IS_EMPTY_Q(q) \
    if(q.size != 0)begin \
        `uvm_error("IS_EMPTY_Q", $sformatf("queue is not emtpy! size=%0d", q.size)) \
        foreach(q[i])begin \
            `uvm_info("IS_EMPTY_Q", q[i], UVM_NONE); \
        end \
    end
`endif

`ifndef SVK_CLI_DEF
`define SVK_CLI_DEF(name,typ) \
    static typ name;
`endif


`ifndef SVK_CLI_DEF_Q
`define SVK_CLI_DEF_Q(name,typ,num) \
    static typ name[num];
`endif



`ifndef SVK_CLI_GET
`define SVK_CLI_GET(name,def_val,typ) \
    if(!($value$plusargs(`"name=%0``typ`",name))) \
        name = def_val; \
    `uvm_info("CLI_GET", $sformatf(`"name=``typ``'%0``typ`",name), UVM_NONE)
`endif



`ifndef SVK_CLI_GET_Q
`define SVK_CLI_GET_Q(name,def_val,typ) \
    foreach(``name``[i])begin \
        string name_string; \
        name_string = $sformatf(`"name[%0d]=%%0``typ`",i); \
        if(!($value$plusargs(name_string,``name[i]))) \
            ``name[i] = def_val; \
        `uvm_info("CLI_GET", $sformatf(`"name[%0d]=``typ``'%0``typ`",i,name), UVM_NONE) \
    end
`endif


`ifndef SVK_CMP
`define SVK_CMP(exp, dat, describe) \
    if(exp != dat)begin \
        `uvm_error("CMP", $sformatf("%s: EXP=%0h != DAT=%0h", describe, exp, dat)) \
    end
`endif


`define SVK_STR(str)                 "str"
`define SVK_CON(a, b)                a``_``b


`define SVK_REG2WIRE_CON_CHK(field, hier, msb, lsb, delay=50) \
    begin \
        reg [31:0] wdata; \
        uvm_status_e status; \
        std::randomize(wdata); \
        field.write(status, wdata); \
        #delay; \
        if(hier != wdata[msb:lsb])begin \
            `uvm_error("SVK_REG2WIRE_CON_CHK", $sformatf("reg=%0h, hier=%0h", wdata[msb:lsb], hier)) \
        end \
    end

`define SVK_WIRE2REG_CON_CHK(field, hier, msb, lsb, delay=50) \
    begin \
        static reg [31:0] wdata; \
        reg [31:0] rdata; \
        uvm_status_e status; \
        std::randomize(wdata); \
        force hier = wdata; \
        #delay; \
        field.read(status, rdata); \
        if(wdata[msb:lsb] != rdata[msb:lsb])begin \
            `uvm_error("SVK_REG2WIRE_CON_CHK", $sformatf("reg=%0h, hier=%0h", rdata[msb:lsb], wdata[msb:lsb])) \
        end \
    end

`define SVK_WIRE2WIRE_CON_CHK(hier1, hier2, delay=50) \
    begin \
        static reg [31:0] data; \
        std::randomize(data); \
        force hier1 = data; \
        #delay; \
        if(hier2 != hier1)begin \
            `uvm_error("SVK_REG2WIRE_CON_CHK", $sformatf("hier1=%0h, hier2=%0h", hier1, hier2)) \
        end \
    end

`endif

