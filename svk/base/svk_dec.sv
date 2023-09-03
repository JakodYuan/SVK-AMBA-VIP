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