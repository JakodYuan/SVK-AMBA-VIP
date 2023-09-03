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

`ifndef SVK_APB_DEFINE__SV
`define SVK_APB_DEFINE__SV


`ifndef SVK_APB_ADDR_WIDTH
`define SVK_APB_ADDR_WIDTH 32
`endif

`ifndef SVK_APB_DATA_WIDTH
`define SVK_APB_DATA_WIDTH 32
`endif

`ifndef SVK_APB_USER_WIDTH
`define SVK_APB_USER_WIDTH 8
`endif

`ifndef SVK_APB_STRB_WIDTH
`define SVK_APB_STRB_WIDTH `SVK_APB_DATA_WIDTH/8
`endif

`ifndef SVK_APB_MAX_NUM_MASTER
`define SVK_APB_MAX_NUM_MASTER 16
`endif

`ifndef SVK_APB_MAX_NUM_SLAVE
`define SVK_APB_MAX_NUM_SLAVE 16
`endif


`endif

