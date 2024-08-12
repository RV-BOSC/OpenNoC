/*
* Copyright (c) 2024 Beijing Institute of Open Source Chip
* OpenNoC is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
* See the Mulan PSL v2 for more details.
*
* Author:
*    Jianxing Wang <wangjianxing@bosc.ac.cn>
*    Jianhong Zhang <zhangjianhong@bosc.ac.cn> 
*    Li Zhao <lizhao@bosc.ac.cn>
*/

`ifndef CHIE_DEFINES_UNDEFINE
`ifndef CHIE_DEFINES
`define CHIE_DEFINES


`define CHIE_REQ_ADDR_WIDTH_PARAM                   44
// CHIE REQ FLIT
`define CHIE_REQ_FLIT_QOS_WIDTH                        4
`define CHIE_REQ_FLIT_QOS_LSB                          0
`define CHIE_REQ_FLIT_QOS_MSB                          3
`define CHIE_REQ_FLIT_QOS_RANGE                        3:0

`define CHIE_REQ_FLIT_TGTID_WIDTH                      CHIE_NID_WIDTH_PARAM
`define CHIE_REQ_FLIT_TGTID_LSB                        4
`define CHIE_REQ_FLIT_TGTID_MSB                        CHIE_NID_WIDTH_PARAM+3
`define CHIE_REQ_FLIT_TGTID_RANGE                      CHIE_NID_WIDTH_PARAM+3:4

`define CHIE_REQ_FLIT_SRCID_WIDTH                      CHIE_NID_WIDTH_PARAM
`define CHIE_REQ_FLIT_SRCID_LSB                        CHIE_NID_WIDTH_PARAM+4
`define CHIE_REQ_FLIT_SRCID_MSB                        CHIE_NID_WIDTH_PARAM*2+3
`define CHIE_REQ_FLIT_SRCID_RANGE                      CHIE_NID_WIDTH_PARAM*2+3:CHIE_NID_WIDTH_PARAM+4

`define CHIE_REQ_FLIT_TXNID_WIDTH                      12
`define CHIE_REQ_FLIT_TXNID_LSB                        CHIE_NID_WIDTH_PARAM*2+4
`define CHIE_REQ_FLIT_TXNID_MSB                        CHIE_NID_WIDTH_PARAM*2+15
`define CHIE_REQ_FLIT_TXNID_RANGE                      CHIE_NID_WIDTH_PARAM*2+15:CHIE_NID_WIDTH_PARAM*2+4

`define CHIE_REQ_FLIT_RETURNNID_WIDTH                  CHIE_NID_WIDTH_PARAM
`define CHIE_REQ_FLIT_RETURNNID_LSB                    CHIE_NID_WIDTH_PARAM*2+16
`define CHIE_REQ_FLIT_RETURNNID_MSB                    CHIE_NID_WIDTH_PARAM*3+15
`define CHIE_REQ_FLIT_RETURNNID_RANGE                  CHIE_NID_WIDTH_PARAM*3+15:CHIE_NID_WIDTH_PARAM*2+16

`define CHIE_REQ_FLIT_STASHNID_WIDTH                   CHIE_NID_WIDTH_PARAM
`define CHIE_REQ_FLIT_STASHNID_LSB                     CHIE_NID_WIDTH_PARAM*2+16
`define CHIE_REQ_FLIT_STASHNID_MSB                     CHIE_NID_WIDTH_PARAM*3+15
`define CHIE_REQ_FLIT_STASHNID_RANGE                   CHIE_NID_WIDTH_PARAM*3+15:CHIE_NID_WIDTH_PARAM*2+16

`define CHIE_REQ_FLIT_STASHNIDVALID_WIDTH              1
`define CHIE_REQ_FLIT_STASHNIDVALID_LSB                CHIE_NID_WIDTH_PARAM*3+16
`define CHIE_REQ_FLIT_STASHNIDVALID_MSB                CHIE_NID_WIDTH_PARAM*3+16
`define CHIE_REQ_FLIT_STASHNIDVALID_RANGE              CHIE_NID_WIDTH_PARAM*3+16

`define CHIE_REQ_FLIT_ENDIAN_WIDTH                     1
`define CHIE_REQ_FLIT_ENDIAN_LSB                       CHIE_NID_WIDTH_PARAM*3+16
`define CHIE_REQ_FLIT_ENDIAN_MSB                       CHIE_NID_WIDTH_PARAM*3+16
`define CHIE_REQ_FLIT_ENDIAN_RANGE                     CHIE_NID_WIDTH_PARAM*3+16

`define CHIE_REQ_FLIT_RETURNTXNID_WIDTH                12
`define CHIE_REQ_FLIT_RETURNTXNID_LSB                  CHIE_NID_WIDTH_PARAM*3+17
`define CHIE_REQ_FLIT_RETURNTXNID_MSB                  CHIE_NID_WIDTH_PARAM*3+28
`define CHIE_REQ_FLIT_RETURNTXNID_RANGE                CHIE_NID_WIDTH_PARAM*3+28:CHIE_NID_WIDTH_PARAM*3+17

`define CHIE_REQ_FLIT_OPCODE_WIDTH                     7
`define CHIE_REQ_FLIT_OPCODE_LSB                       CHIE_NID_WIDTH_PARAM*3+29
`define CHIE_REQ_FLIT_OPCODE_MSB                       CHIE_NID_WIDTH_PARAM*3+35
`define CHIE_REQ_FLIT_OPCODE_RANGE                     CHIE_NID_WIDTH_PARAM*3+35:CHIE_NID_WIDTH_PARAM*3+29

`define CHIE_REQ_FLIT_SIZE_WIDTH                       3
`define CHIE_REQ_FLIT_SIZE_LSB                         CHIE_NID_WIDTH_PARAM*3+36
`define CHIE_REQ_FLIT_SIZE_MSB                         CHIE_NID_WIDTH_PARAM*3+38
`define CHIE_REQ_FLIT_SIZE_RANGE                       CHIE_NID_WIDTH_PARAM*3+38:CHIE_NID_WIDTH_PARAM*3+36

`define CHIE_REQ_FLIT_ADDR_WIDTH                       CHIE_REQ_ADDR_WIDTH_PARAM
`define CHIE_REQ_FLIT_ADDR_LSB                         CHIE_NID_WIDTH_PARAM*3+39
`define CHIE_REQ_FLIT_ADDR_MSB                         CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+38
`define CHIE_REQ_FLIT_ADDR_RANGE                       CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+38:CHIE_NID_WIDTH_PARAM*3+39

`define CHIE_REQ_FLIT_NS_WIDTH                         1
`define CHIE_REQ_FLIT_NS_LSB                           CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+39
`define CHIE_REQ_FLIT_NS_MSB                           CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+39
`define CHIE_REQ_FLIT_NS_RANGE                         CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+39

`define CHIE_REQ_FLIT_LIKELYSHARED_WIDTH               1
`define CHIE_REQ_FLIT_LIKELYSHARED_LSB                 CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+40
`define CHIE_REQ_FLIT_LIKELYSHARED_MSB                 CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+40
`define CHIE_REQ_FLIT_LIKELYSHARED_RANGE               CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+40

`define CHIE_REQ_FLIT_ALLOWRETRY_WIDTH                 1
`define CHIE_REQ_FLIT_ALLOWRETRY_LSB                   CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+41
`define CHIE_REQ_FLIT_ALLOWRETRY_MSB                   CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+41
`define CHIE_REQ_FLIT_ALLOWRETRY_RANGE                 CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+41

`define CHIE_REQ_FLIT_ORDER_WIDTH                      2
`define CHIE_REQ_FLIT_ORDER_LSB                        CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+42
`define CHIE_REQ_FLIT_ORDER_MSB                        CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+43
`define CHIE_REQ_FLIT_ORDER_RANGE                      CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+43:CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+42

`define CHIE_REQ_FLIT_PCRDTYPE_WIDTH                   4
`define CHIE_REQ_FLIT_PCRDTYPE_LSB                     CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+44
`define CHIE_REQ_FLIT_PCRDTYPE_MSB                     CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+47
`define CHIE_REQ_FLIT_PCRDTYPE_RANGE                   CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+47:CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+44

`define CHIE_REQ_FLIT_MEMATTR_WIDTH                    4
`define CHIE_REQ_FLIT_MEMATTR_LSB                      CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+48
`define CHIE_REQ_FLIT_MEMATTR_MSB                      CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+51
`define CHIE_REQ_FLIT_MEMATTR_RANGE                    CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+51:CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+48

`define CHIE_REQ_FLIT_MEMATTR_EARLYWRACK_WIDTH         1
`define CHIE_REQ_FLIT_MEMATTR_EARLYWRACK_LSB           CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+48
`define CHIE_REQ_FLIT_MEMATTR_EARLYWRACK_MSB           CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+48
`define CHIE_REQ_FLIT_MEMATTR_EARLYWRACK_RANGE         CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+48

`define CHIE_REQ_FLIT_MEMATTR_DEVICE_WIDTH             1
`define CHIE_REQ_FLIT_MEMATTR_DEVICE_LSB               CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+49
`define CHIE_REQ_FLIT_MEMATTR_DEVICE_MSB               CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+49
`define CHIE_REQ_FLIT_MEMATTR_DEVICE_RANGE             CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+49

`define CHIE_REQ_FLIT_MEMATTR_CACHEABLE_WIDTH          1
`define CHIE_REQ_FLIT_MEMATTR_CACHEABLE_LSB            CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+50
`define CHIE_REQ_FLIT_MEMATTR_CACHEABLE_MSB            CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+50
`define CHIE_REQ_FLIT_MEMATTR_CACHEABLE_RANGE          CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+50

`define CHIE_REQ_FLIT_MEMATTR_ALLOCATE_WIDTH           1
`define CHIE_REQ_FLIT_MEMATTR_ALLOCATE_LSB             CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+51
`define CHIE_REQ_FLIT_MEMATTR_ALLOCATE_MSB             CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+51
`define CHIE_REQ_FLIT_MEMATTR_ALLOCATE_RANGE           CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+51

`define CHIE_REQ_FLIT_SNPATTR_WIDTH                    1
`define CHIE_REQ_FLIT_SNPATTR_LSB                      CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+52
`define CHIE_REQ_FLIT_SNPATTR_MSB                      CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+52
`define CHIE_REQ_FLIT_SNPATTR_RANGE                    CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+52

`define CHIE_REQ_FLIT_DODWT_WIDTH                      1
`define CHIE_REQ_FLIT_DODWT_LSB                        CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+52
`define CHIE_REQ_FLIT_DODWT_MSB                        CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+52
`define CHIE_REQ_FLIT_DODWT_RANGE                      CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+52

`define CHIE_REQ_FLIT_LPID_WIDTH                       8
`define CHIE_REQ_FLIT_LPID_LSB                         CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+53
`define CHIE_REQ_FLIT_LPID_MSB                         CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+60
`define CHIE_REQ_FLIT_LPID_RANGE                       CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+60:CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+53

`define CHIE_REQ_FLIT_EXCL_WIDTH                       1
`define CHIE_REQ_FLIT_EXCL_LSB                         CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+61
`define CHIE_REQ_FLIT_EXCL_MSB                         CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+61
`define CHIE_REQ_FLIT_EXCL_RANGE                       CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+61

`define CHIE_REQ_FLIT_SNOOPME_WIDTH                    1
`define CHIE_REQ_FLIT_SNOOPME_LSB                      CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+61
`define CHIE_REQ_FLIT_SNOOPME_MSB                      CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+61
`define CHIE_REQ_FLIT_SNOOPME_RANGE                    CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+61

`define CHIE_REQ_FLIT_EXPCOMPACK_WIDTH                 1
`define CHIE_REQ_FLIT_EXPCOMPACK_LSB                   CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+62
`define CHIE_REQ_FLIT_EXPCOMPACK_MSB                   CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+62
`define CHIE_REQ_FLIT_EXPCOMPACK_RANGE                 CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+62

`define CHIE_REQ_FLIT_TAGOP_WIDTH                      2
`define CHIE_REQ_FLIT_TAGOP_LSB                        CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+63
`define CHIE_REQ_FLIT_TAGOP_MSB                        CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+64
`define CHIE_REQ_FLIT_TAGOP_RANGE                      CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+64:CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+63

`define CHIE_REQ_FLIT_TRACETAG_WIDTH                   1
`define CHIE_REQ_FLIT_TRACETAG_LSB                     CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+65
`define CHIE_REQ_FLIT_TRACETAG_MSB                     CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+65
`define CHIE_REQ_FLIT_TRACETAG_RANGE                   CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+65

`define CHIE_REQ_FLIT_WIDTH                            CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+66
`define CHIE_REQ_FLIT_LSB                              0
`define CHIE_REQ_FLIT_MSB                              CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+65
`define CHIE_REQ_FLIT_RANGE                            CHIE_REQ_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*3+65:0

// CHIE RSP FLIT
`define CHIE_RSP_FLIT_QOS_WIDTH                        4
`define CHIE_RSP_FLIT_QOS_LSB                          0
`define CHIE_RSP_FLIT_QOS_MSB                          3
`define CHIE_RSP_FLIT_QOS_RANGE                        3:0

`define CHIE_RSP_FLIT_TGTID_WIDTH                      CHIE_NID_WIDTH_PARAM
`define CHIE_RSP_FLIT_TGTID_LSB                        4
`define CHIE_RSP_FLIT_TGTID_MSB                        CHIE_NID_WIDTH_PARAM+3
`define CHIE_RSP_FLIT_TGTID_RANGE                      CHIE_NID_WIDTH_PARAM+3:4

`define CHIE_RSP_FLIT_SRCID_WIDTH                      CHIE_NID_WIDTH_PARAM
`define CHIE_RSP_FLIT_SRCID_LSB                        CHIE_NID_WIDTH_PARAM+4
`define CHIE_RSP_FLIT_SRCID_MSB                        CHIE_NID_WIDTH_PARAM*2+3
`define CHIE_RSP_FLIT_SRCID_RANGE                      CHIE_NID_WIDTH_PARAM*2+3:CHIE_NID_WIDTH_PARAM+4

`define CHIE_RSP_FLIT_TXNID_WIDTH                      12
`define CHIE_RSP_FLIT_TXNID_LSB                        CHIE_NID_WIDTH_PARAM*2+4
`define CHIE_RSP_FLIT_TXNID_MSB                        CHIE_NID_WIDTH_PARAM*2+15
`define CHIE_RSP_FLIT_TXNID_RANGE                      CHIE_NID_WIDTH_PARAM*2+15:CHIE_NID_WIDTH_PARAM*2+4

`define CHIE_RSP_FLIT_OPCODE_WIDTH                     5
`define CHIE_RSP_FLIT_OPCODE_LSB                       CHIE_NID_WIDTH_PARAM*2+16
`define CHIE_RSP_FLIT_OPCODE_MSB                       CHIE_NID_WIDTH_PARAM*2+20
`define CHIE_RSP_FLIT_OPCODE_RANGE                     CHIE_NID_WIDTH_PARAM*2+20:CHIE_NID_WIDTH_PARAM*2+16

`define CHIE_RSP_FLIT_RESPERR_WIDTH                    2
`define CHIE_RSP_FLIT_RESPERR_LSB                      CHIE_NID_WIDTH_PARAM*2+21
`define CHIE_RSP_FLIT_RESPERR_MSB                      CHIE_NID_WIDTH_PARAM*2+22
`define CHIE_RSP_FLIT_RESPERR_RANGE                    CHIE_NID_WIDTH_PARAM*2+22:CHIE_NID_WIDTH_PARAM*2+21

`define CHIE_RSP_FLIT_RESP_WIDTH                       3
`define CHIE_RSP_FLIT_RESP_LSB                         CHIE_NID_WIDTH_PARAM*2+23
`define CHIE_RSP_FLIT_RESP_MSB                         CHIE_NID_WIDTH_PARAM*2+25
`define CHIE_RSP_FLIT_RESP_RANGE                       CHIE_NID_WIDTH_PARAM*2+25:CHIE_NID_WIDTH_PARAM*2+23

`define CHIE_RSP_FLIT_FWDSTATE_WIDTH                   3
`define CHIE_RSP_FLIT_FWDSTATE_LSB                     CHIE_NID_WIDTH_PARAM*2+26
`define CHIE_RSP_FLIT_FWDSTATE_MSB                     CHIE_NID_WIDTH_PARAM*2+28
`define CHIE_RSP_FLIT_FWDSTATE_RANGE                   CHIE_NID_WIDTH_PARAM*2+28:CHIE_NID_WIDTH_PARAM*2+26

`define CHIE_RSP_FLIT_DATAPULL_WIDTH                   3
`define CHIE_RSP_FLIT_DATAPULL_LSB                     CHIE_NID_WIDTH_PARAM*2+26
`define CHIE_RSP_FLIT_DATAPULL_MSB                     CHIE_NID_WIDTH_PARAM*2+28
`define CHIE_RSP_FLIT_DATAPULL_RANGE                   CHIE_NID_WIDTH_PARAM*2+28:CHIE_NID_WIDTH_PARAM*2+26

`define CHIE_RSP_FLIT_CBUSY_WIDTH                      3
`define CHIE_RSP_FLIT_CBUSY_LSB                        CHIE_NID_WIDTH_PARAM*2+29
`define CHIE_RSP_FLIT_CBUSY_MSB                        CHIE_NID_WIDTH_PARAM*2+31
`define CHIE_RSP_FLIT_CBUSY_RANGE                      CHIE_NID_WIDTH_PARAM*2+31:CHIE_NID_WIDTH_PARAM*2+29

`define CHIE_RSP_FLIT_DBID_WIDTH                       12
`define CHIE_RSP_FLIT_DBID_LSB                         CHIE_NID_WIDTH_PARAM*2+32
`define CHIE_RSP_FLIT_DBID_MSB                         CHIE_NID_WIDTH_PARAM*2+43
`define CHIE_RSP_FLIT_DBID_RANGE                       CHIE_NID_WIDTH_PARAM*2+43:CHIE_NID_WIDTH_PARAM*2+32

`define CHIE_RSP_FLIT_PCRDTYPE_WIDTH                   4
`define CHIE_RSP_FLIT_PCRDTYPE_LSB                     CHIE_NID_WIDTH_PARAM*2+44
`define CHIE_RSP_FLIT_PCRDTYPE_MSB                     CHIE_NID_WIDTH_PARAM*2+47
`define CHIE_RSP_FLIT_PCRDTYPE_RANGE                   CHIE_NID_WIDTH_PARAM*2+47:CHIE_NID_WIDTH_PARAM*2+44

`define CHIE_RSP_FLIT_TAGOP_WIDTH                      2
`define CHIE_RSP_FLIT_TAGOP_LSB                        CHIE_NID_WIDTH_PARAM*2+48
`define CHIE_RSP_FLIT_TAGOP_MSB                        CHIE_NID_WIDTH_PARAM*2+49
`define CHIE_RSP_FLIT_TAGOP_RANGE                      CHIE_NID_WIDTH_PARAM*2+49:CHIE_NID_WIDTH_PARAM*2+48

`define CHIE_RSP_FLIT_TRACETAG_WIDTH                   1
`define CHIE_RSP_FLIT_TRACETAG_LSB                     CHIE_NID_WIDTH_PARAM*2+50
`define CHIE_RSP_FLIT_TRACETAG_MSB                     CHIE_NID_WIDTH_PARAM*2+50
`define CHIE_RSP_FLIT_TRACETAG_RANGE                   CHIE_NID_WIDTH_PARAM*2+50

`define CHIE_RSP_FLIT_WIDTH                            CHIE_NID_WIDTH_PARAM*2+51
`define CHIE_RSP_FLIT_LSB                              0
`define CHIE_RSP_FLIT_MSB                              CHIE_NID_WIDTH_PARAM*2+50
`define CHIE_RSP_FLIT_RANGE                            CHIE_NID_WIDTH_PARAM*2+50:0

// CHIE SNP FLIT
`define CHIE_SNP_FLIT_QOS_WIDTH                        4
`define CHIE_SNP_FLIT_QOS_LSB                          0
`define CHIE_SNP_FLIT_QOS_MSB                          3
`define CHIE_SNP_FLIT_QOS_RANGE                        3:0

`define CHIE_SNP_FLIT_SRCID_WIDTH                      CHIE_NID_WIDTH_PARAM
`define CHIE_SNP_FLIT_SRCID_LSB                        4
`define CHIE_SNP_FLIT_SRCID_MSB                        CHIE_NID_WIDTH_PARAM+3
`define CHIE_SNP_FLIT_SRCID_RANGE                      CHIE_NID_WIDTH_PARAM+3:4

`define CHIE_SNP_FLIT_TXNID_WIDTH                      12
`define CHIE_SNP_FLIT_TXNID_LSB                        CHIE_NID_WIDTH_PARAM+4
`define CHIE_SNP_FLIT_TXNID_MSB                        CHIE_NID_WIDTH_PARAM+15
`define CHIE_SNP_FLIT_TXNID_RANGE                      CHIE_NID_WIDTH_PARAM+15:CHIE_NID_WIDTH_PARAM+4

`define CHIE_SNP_FLIT_FWDNID_WIDTH                     CHIE_NID_WIDTH_PARAM
`define CHIE_SNP_FLIT_FWDNID_LSB                       CHIE_NID_WIDTH_PARAM+16
`define CHIE_SNP_FLIT_FWDNID_MSB                       CHIE_NID_WIDTH_PARAM*2+15
`define CHIE_SNP_FLIT_FWDNID_RANGE                     CHIE_NID_WIDTH_PARAM*2+15:CHIE_NID_WIDTH_PARAM+16

`define CHIE_SNP_FLIT_FWDTXNID_WIDTH                   12
`define CHIE_SNP_FLIT_FWDTXNID_LSB                     CHIE_NID_WIDTH_PARAM*2+16
`define CHIE_SNP_FLIT_FWDTXNID_MSB                     CHIE_NID_WIDTH_PARAM*2+27
`define CHIE_SNP_FLIT_FWDTXNID_RANGE                   CHIE_NID_WIDTH_PARAM*2+27:CHIE_NID_WIDTH_PARAM*2+16

`define CHIE_SNP_FLIT_FWDTXNID_STASHLPID_WIDTH         5
`define CHIE_SNP_FLIT_FWDTXNID_STASHLPID_LSB           CHIE_NID_WIDTH_PARAM*2+16
`define CHIE_SNP_FLIT_FWDTXNID_STASHLPID_MSB           CHIE_NID_WIDTH_PARAM*2+20
`define CHIE_SNP_FLIT_FWDTXNID_STASHLPID_RANGE         CHIE_NID_WIDTH_PARAM*2+20:CHIE_NID_WIDTH_PARAM*2+16

`define CHIE_SNP_FLIT_FWDTXNID_STASHLPIDVALID_WIDTH    1
`define CHIE_SNP_FLIT_FWDTXNID_STASHLPIDVALID_LSB      CHIE_NID_WIDTH_PARAM*2+21
`define CHIE_SNP_FLIT_FWDTXNID_STASHLPIDVALID_MSB      CHIE_NID_WIDTH_PARAM*2+21
`define CHIE_SNP_FLIT_FWDTXNID_STASHLPIDVALID_RANGE    CHIE_NID_WIDTH_PARAM*2+21

`define CHIE_SNP_FLIT_FWDTXNID_VMIDEXT_WIDTH           12
`define CHIE_SNP_FLIT_FWDTXNID_VMIDEXT_LSB             CHIE_NID_WIDTH_PARAM*2+16
`define CHIE_SNP_FLIT_FWDTXNID_VMIDEXT_MSB             CHIE_NID_WIDTH_PARAM*2+27
`define CHIE_SNP_FLIT_FWDTXNID_VMIDEXT_RANGE           CHIE_NID_WIDTH_PARAM*2+27:CHIE_NID_WIDTH_PARAM*2+16

`define CHIE_SNP_FLIT_OPCODE_WIDTH                     5
`define CHIE_SNP_FLIT_OPCODE_LSB                       CHIE_NID_WIDTH_PARAM*2+28
`define CHIE_SNP_FLIT_OPCODE_MSB                       CHIE_NID_WIDTH_PARAM*2+32
`define CHIE_SNP_FLIT_OPCODE_RANGE                     CHIE_NID_WIDTH_PARAM*2+32:CHIE_NID_WIDTH_PARAM*2+28

`define CHIE_SNP_FLIT_ADDR_WIDTH                       CHIE_SNP_ADDR_WIDTH_PARAM
`define CHIE_SNP_FLIT_ADDR_LSB                         CHIE_NID_WIDTH_PARAM*2+33
`define CHIE_SNP_FLIT_ADDR_MSB                         CHIE_SNP_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*2+32
`define CHIE_SNP_FLIT_ADDR_RANGE                       CHIE_SNP_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*2+32:CHIE_NID_WIDTH_PARAM*2+33

`define CHIE_SNP_FLIT_NS_WIDTH                         1
`define CHIE_SNP_FLIT_NS_LSB                           CHIE_SNP_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*2+33
`define CHIE_SNP_FLIT_NS_MSB                           CHIE_SNP_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*2+33
`define CHIE_SNP_FLIT_NS_RANGE                         CHIE_SNP_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*2+33

`define CHIE_SNP_FLIT_DONOTGOTOSD_WIDTH                1
`define CHIE_SNP_FLIT_DONOTGOTOSD_LSB                  CHIE_SNP_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*2+34
`define CHIE_SNP_FLIT_DONOTGOTOSD_MSB                  CHIE_SNP_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*2+34
`define CHIE_SNP_FLIT_DONOTGOTOSD_RANGE                CHIE_SNP_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*2+34

`define CHIE_SNP_FLIT_RETTOSRC_WIDTH                   1
`define CHIE_SNP_FLIT_RETTOSRC_LSB                     CHIE_SNP_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*2+35
`define CHIE_SNP_FLIT_RETTOSRC_MSB                     CHIE_SNP_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*2+35
`define CHIE_SNP_FLIT_RETTOSRC_RANGE                   CHIE_SNP_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*2+35

`define CHIE_SNP_FLIT_TRACETAG_WIDTH                   1
`define CHIE_SNP_FLIT_TRACETAG_LSB                     CHIE_SNP_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*2+36
`define CHIE_SNP_FLIT_TRACETAG_MSB                     CHIE_SNP_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*2+36
`define CHIE_SNP_FLIT_TRACETAG_RANGE                   CHIE_SNP_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*2+36

`define CHIE_SNP_FLIT_WIDTH                            CHIE_SNP_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*2+37
`define CHIE_SNP_FLIT_LSB                              0
`define CHIE_SNP_FLIT_MSB                              CHIE_SNP_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*2+36
`define CHIE_SNP_FLIT_RANGE                            CHIE_SNP_ADDR_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM*2+36:0

// CHIE DAT FLIT
`define CHIE_DAT_FLIT_QOS_WIDTH                        4
`define CHIE_DAT_FLIT_QOS_LSB                          0
`define CHIE_DAT_FLIT_QOS_MSB                          3
`define CHIE_DAT_FLIT_QOS_RANGE                        3:0

`define CHIE_DAT_FLIT_TGTID_WIDTH                      CHIE_NID_WIDTH_PARAM
`define CHIE_DAT_FLIT_TGTID_LSB                        4
`define CHIE_DAT_FLIT_TGTID_MSB                        CHIE_NID_WIDTH_PARAM+3
`define CHIE_DAT_FLIT_TGTID_RANGE                      CHIE_NID_WIDTH_PARAM+3:4

`define CHIE_DAT_FLIT_SRCID_WIDTH                      CHIE_NID_WIDTH_PARAM
`define CHIE_DAT_FLIT_SRCID_LSB                        CHIE_NID_WIDTH_PARAM+4
`define CHIE_DAT_FLIT_SRCID_MSB                        CHIE_NID_WIDTH_PARAM*2+3
`define CHIE_DAT_FLIT_SRCID_RANGE                      CHIE_NID_WIDTH_PARAM*2+3:CHIE_NID_WIDTH_PARAM+4

`define CHIE_DAT_FLIT_TXNID_WIDTH                      12
`define CHIE_DAT_FLIT_TXNID_LSB                        CHIE_NID_WIDTH_PARAM*2+4
`define CHIE_DAT_FLIT_TXNID_MSB                        CHIE_NID_WIDTH_PARAM*2+15
`define CHIE_DAT_FLIT_TXNID_RANGE                      CHIE_NID_WIDTH_PARAM*2+15:CHIE_NID_WIDTH_PARAM*2+4

`define CHIE_DAT_FLIT_HOMENID_WIDTH                    CHIE_NID_WIDTH_PARAM
`define CHIE_DAT_FLIT_HOMENID_LSB                      CHIE_NID_WIDTH_PARAM*2+16
`define CHIE_DAT_FLIT_HOMENID_MSB                      CHIE_NID_WIDTH_PARAM*3+15
`define CHIE_DAT_FLIT_HOMENID_RANGE                    CHIE_NID_WIDTH_PARAM*3+15:CHIE_NID_WIDTH_PARAM*2+16

`define CHIE_DAT_FLIT_OPCODE_WIDTH                     4
`define CHIE_DAT_FLIT_OPCODE_LSB                       CHIE_NID_WIDTH_PARAM*3+16
`define CHIE_DAT_FLIT_OPCODE_MSB                       CHIE_NID_WIDTH_PARAM*3+19
`define CHIE_DAT_FLIT_OPCODE_RANGE                     CHIE_NID_WIDTH_PARAM*3+19:CHIE_NID_WIDTH_PARAM*3+16

`define CHIE_DAT_FLIT_RESPERR_WIDTH                    2
`define CHIE_DAT_FLIT_RESPERR_LSB                      CHIE_NID_WIDTH_PARAM*3+20
`define CHIE_DAT_FLIT_RESPERR_MSB                      CHIE_NID_WIDTH_PARAM*3+21
`define CHIE_DAT_FLIT_RESPERR_RANGE                    CHIE_NID_WIDTH_PARAM*3+21:CHIE_NID_WIDTH_PARAM*3+20

`define CHIE_DAT_FLIT_RESP_WIDTH                       3
`define CHIE_DAT_FLIT_RESP_LSB                          CHIE_NID_WIDTH_PARAM*3+22
`define CHIE_DAT_FLIT_RESP_MSB                          CHIE_NID_WIDTH_PARAM*3+24
`define CHIE_DAT_FLIT_RESP_RANGE                        CHIE_NID_WIDTH_PARAM*3+24: CHIE_NID_WIDTH_PARAM*3+22

`define CHIE_DAT_FLIT_DATASOURCE_WIDTH                 4
`define CHIE_DAT_FLIT_DATASOURCE_LSB                   CHIE_NID_WIDTH_PARAM*3+25
`define CHIE_DAT_FLIT_DATASOURCE_MSB                   CHIE_NID_WIDTH_PARAM*3+28
`define CHIE_DAT_FLIT_DATASOURCE_RANGE                 CHIE_NID_WIDTH_PARAM*3+28:CHIE_NID_WIDTH_PARAM*3+25

`define CHIE_DAT_FLIT_FWDSTATE_WIDTH                   4
`define CHIE_DAT_FLIT_FWDSTATE_LSB                     CHIE_NID_WIDTH_PARAM*3+25
`define CHIE_DAT_FLIT_FWDSTATE_MSB                     CHIE_NID_WIDTH_PARAM*3+28
`define CHIE_DAT_FLIT_FWDSTATE_RANGE                   CHIE_NID_WIDTH_PARAM*3+28:CHIE_NID_WIDTH_PARAM*3+25

`define CHIE_DAT_FLIT_DATAPULL_WIDTH                   4
`define CHIE_DAT_FLIT_DATAPULL_LSB                     CHIE_NID_WIDTH_PARAM*3+25
`define CHIE_DAT_FLIT_DATAPULL_MSB                     CHIE_NID_WIDTH_PARAM*3+28
`define CHIE_DAT_FLIT_DATAPULL_RANGE                   CHIE_NID_WIDTH_PARAM*3+28:CHIE_NID_WIDTH_PARAM*3+25

`define CHIE_DAT_FLIT_CBUSY_WIDTH                      3
`define CHIE_DAT_FLIT_CBUSY_LSB                        CHIE_NID_WIDTH_PARAM*3+29
`define CHIE_DAT_FLIT_CBUSY_MSB                        CHIE_NID_WIDTH_PARAM*3+31
`define CHIE_DAT_FLIT_CBUSY_RANGE                      CHIE_NID_WIDTH_PARAM*3+31:CHIE_NID_WIDTH_PARAM*3+29

`define CHIE_DAT_FLIT_DBID_WIDTH                       12
`define CHIE_DAT_FLIT_DBID_LSB                         CHIE_NID_WIDTH_PARAM*3+32
`define CHIE_DAT_FLIT_DBID_MSB                         CHIE_NID_WIDTH_PARAM*3+43
`define CHIE_DAT_FLIT_DBID_RANGE                       CHIE_NID_WIDTH_PARAM*3+43:CHIE_NID_WIDTH_PARAM*3+32

`define CHIE_DAT_FLIT_CCID_WIDTH                       2
`define CHIE_DAT_FLIT_CCID_LSB                         CHIE_NID_WIDTH_PARAM*3+44
`define CHIE_DAT_FLIT_CCID_MSB                         CHIE_NID_WIDTH_PARAM*3+45
`define CHIE_DAT_FLIT_CCID_RANGE                       CHIE_NID_WIDTH_PARAM*3+45:CHIE_NID_WIDTH_PARAM*3+44

`define CHIE_DAT_FLIT_DATAID_WIDTH                     2
`define CHIE_DAT_FLIT_DATAID_LSB                       CHIE_NID_WIDTH_PARAM*3+46
`define CHIE_DAT_FLIT_DATAID_MSB                       CHIE_NID_WIDTH_PARAM*3+47
`define CHIE_DAT_FLIT_DATAID_RANGE                     CHIE_NID_WIDTH_PARAM*3+47:CHIE_NID_WIDTH_PARAM*3+46

`define CHIE_DAT_FLIT_TAGOP_WIDTH                      2
`define CHIE_DAT_FLIT_TAGOP_LSB                        CHIE_NID_WIDTH_PARAM*3+48
`define CHIE_DAT_FLIT_TAGOP_MSB                        CHIE_NID_WIDTH_PARAM*3+49
`define CHIE_DAT_FLIT_TAGOP_RANGE                      CHIE_NID_WIDTH_PARAM*3+49:CHIE_NID_WIDTH_PARAM*3+48

`define CHIE_DAT_FLIT_TAG_WIDTH                        CHIE_DATA_WIDTH_PARAM/32
`define CHIE_DAT_FLIT_TAG_LSB                          CHIE_NID_WIDTH_PARAM*3+50
`define CHIE_DAT_FLIT_TAG_MSB                          CHIE_NID_WIDTH_PARAM*3+CHIE_DATA_WIDTH_PARAM/32+49
`define CHIE_DAT_FLIT_TAG_RANGE                        CHIE_NID_WIDTH_PARAM*3+CHIE_DATA_WIDTH_PARAM/32+49:CHIE_NID_WIDTH_PARAM*3+50

`define CHIE_DAT_FLIT_TU_WIDTH                         CHIE_DATA_WIDTH_PARAM/128
`define CHIE_DAT_FLIT_TU_LSB                           CHIE_NID_WIDTH_PARAM*3+CHIE_DATA_WIDTH_PARAM/32+50
`define CHIE_DAT_FLIT_TU_MSB                           CHIE_NID_WIDTH_PARAM*3+CHIE_DATA_WIDTH_PARAM/32+CHIE_DATA_WIDTH_PARAM/128+49
`define CHIE_DAT_FLIT_TU_RANGE                         CHIE_NID_WIDTH_PARAM*3+CHIE_DATA_WIDTH_PARAM/32+CHIE_DATA_WIDTH_PARAM/128+49:CHIE_NID_WIDTH_PARAM*3+CHIE_DATA_WIDTH_PARAM/32+50

`define CHIE_DAT_FLIT_TRACETAG_WIDTH                   1
`define CHIE_DAT_FLIT_TRACETAG_LSB                     CHIE_NID_WIDTH_PARAM*3+CHIE_DATA_WIDTH_PARAM/32+CHIE_DATA_WIDTH_PARAM/128+50
`define CHIE_DAT_FLIT_TRACETAG_MSB                     CHIE_NID_WIDTH_PARAM*3+CHIE_DATA_WIDTH_PARAM/32+CHIE_DATA_WIDTH_PARAM/128+50
`define CHIE_DAT_FLIT_TRACETAG_RANGE                   CHIE_NID_WIDTH_PARAM*3+CHIE_DATA_WIDTH_PARAM/32+CHIE_DATA_WIDTH_PARAM/128+50

`define CHIE_DAT_FLIT_BE_WIDTH                         CHIE_BE_WIDTH_PARAM
`define CHIE_DAT_FLIT_BE_LSB                           CHIE_NID_WIDTH_PARAM*3+CHIE_DATA_WIDTH_PARAM/32+CHIE_DATA_WIDTH_PARAM/128+51
`define CHIE_DAT_FLIT_BE_MSB                           CHIE_NID_WIDTH_PARAM*3+CHIE_BE_WIDTH_PARAM+CHIE_DATA_WIDTH_PARAM/32+CHIE_DATA_WIDTH_PARAM/128+50
`define CHIE_DAT_FLIT_BE_RANGE                         CHIE_NID_WIDTH_PARAM*3+CHIE_BE_WIDTH_PARAM+CHIE_DATA_WIDTH_PARAM/32+CHIE_DATA_WIDTH_PARAM/128+50:CHIE_NID_WIDTH_PARAM*3+CHIE_DATA_WIDTH_PARAM/32+CHIE_DATA_WIDTH_PARAM/128+51

`define CHIE_DAT_FLIT_DATA_WIDTH                       CHIE_DATA_WIDTH_PARAM
`define CHIE_DAT_FLIT_DATA_LSB                         CHIE_NID_WIDTH_PARAM*3+CHIE_BE_WIDTH_PARAM+CHIE_DATA_WIDTH_PARAM/32+CHIE_DATA_WIDTH_PARAM/128+51
`define CHIE_DAT_FLIT_DATA_MSB                         CHIE_NID_WIDTH_PARAM*3+CHIE_DATA_WIDTH_PARAM+CHIE_BE_WIDTH_PARAM+CHIE_DATA_WIDTH_PARAM/32+CHIE_DATA_WIDTH_PARAM/128+50
`define CHIE_DAT_FLIT_DATA_RANGE                       CHIE_NID_WIDTH_PARAM*3+CHIE_DATA_WIDTH_PARAM+CHIE_BE_WIDTH_PARAM+CHIE_DATA_WIDTH_PARAM/32+CHIE_DATA_WIDTH_PARAM/128+50:CHIE_NID_WIDTH_PARAM*3+CHIE_BE_WIDTH_PARAM+CHIE_DATA_WIDTH_PARAM/32+CHIE_DATA_WIDTH_PARAM/128+51

`define CHIE_DAT_FLIT_DATACHECK_WIDTH                  CHIE_DATACHECK_WIDTH_PARAM
`define CHIE_DAT_FLIT_DATACHECK_LSB                    CHIE_NID_WIDTH_PARAM*3+CHIE_DATA_WIDTH_PARAM+CHIE_BE_WIDTH_PARAM+CHIE_DATA_WIDTH_PARAM/32+CHIE_DATA_WIDTH_PARAM/128+51
`define CHIE_DAT_FLIT_DATACHECK_MSB                    CHIE_NID_WIDTH_PARAM*3+CHIE_DATACHECK_WIDTH_PARAM+CHIE_DATA_WIDTH_PARAM+CHIE_BE_WIDTH_PARAM+CHIE_DATA_WIDTH_PARAM/32+CHIE_DATA_WIDTH_PARAM/128+50
`define CHIE_DAT_FLIT_DATACHECK_RANGE                  CHIE_NID_WIDTH_PARAM*3+CHIE_DATACHECK_WIDTH_PARAM+CHIE_DATA_WIDTH_PARAM+CHIE_BE_WIDTH_PARAM+CHIE_DATA_WIDTH_PARAM/32+CHIE_DATA_WIDTH_PARAM/128+50:CHIE_NID_WIDTH_PARAM*3+CHIE_DATA_WIDTH_PARAM+CHIE_BE_WIDTH_PARAM+CHIE_DATA_WIDTH_PARAM/32+CHIE_DATA_WIDTH_PARAM/128+51

`define CHIE_DAT_FLIT_POISON_WIDTH                     CHIE_POISON_WIDTH_PARAM
`define CHIE_DAT_FLIT_POISON_LSB                       CHIE_NID_WIDTH_PARAM*3+CHIE_DATACHECK_WIDTH_PARAM+CHIE_DATA_WIDTH_PARAM+CHIE_BE_WIDTH_PARAM+CHIE_DATA_WIDTH_PARAM/32+CHIE_DATA_WIDTH_PARAM/128+51
`define CHIE_DAT_FLIT_POISON_MSB                       CHIE_NID_WIDTH_PARAM*3+CHIE_POISON_WIDTH_PARAM+CHIE_DATACHECK_WIDTH_PARAM+CHIE_DATA_WIDTH_PARAM+CHIE_BE_WIDTH_PARAM+CHIE_DATA_WIDTH_PARAM/32+CHIE_DATA_WIDTH_PARAM/128+50
`define CHIE_DAT_FLIT_POISON_RANGE                     CHIE_NID_WIDTH_PARAM*3+CHIE_POISON_WIDTH_PARAM+CHIE_DATACHECK_WIDTH_PARAM+CHIE_DATA_WIDTH_PARAM+CHIE_BE_WIDTH_PARAM+CHIE_DATA_WIDTH_PARAM/32+CHIE_DATA_WIDTH_PARAM/128+50:CHIE_NID_WIDTH_PARAM*3+CHIE_DATACHECK_WIDTH_PARAM+CHIE_DATA_WIDTH_PARAM+CHIE_BE_WIDTH_PARAM+CHIE_DATA_WIDTH_PARAM/32+CHIE_DATA_WIDTH_PARAM/128+51

`define CHIE_DAT_FLIT_WIDTH                            CHIE_NID_WIDTH_PARAM*3+CHIE_POISON_WIDTH_PARAM+CHIE_DATACHECK_WIDTH_PARAM+CHIE_DATA_WIDTH_PARAM+CHIE_BE_WIDTH_PARAM+CHIE_DATA_WIDTH_PARAM/32+CHIE_DATA_WIDTH_PARAM/128+51
`define CHIE_DAT_FLIT_LSB                              0
`define CHIE_DAT_FLIT_MSB                              CHIE_NID_WIDTH_PARAM*3+CHIE_POISON_WIDTH_PARAM+CHIE_DATACHECK_WIDTH_PARAM+CHIE_DATA_WIDTH_PARAM+CHIE_BE_WIDTH_PARAM+CHIE_DATA_WIDTH_PARAM/32+CHIE_DATA_WIDTH_PARAM/128+50
`define CHIE_DAT_FLIT_RANGE                            CHIE_NID_WIDTH_PARAM*3+CHIE_POISON_WIDTH_PARAM+CHIE_DATACHECK_WIDTH_PARAM+CHIE_DATA_WIDTH_PARAM+CHIE_BE_WIDTH_PARAM+CHIE_DATA_WIDTH_PARAM/32+CHIE_DATA_WIDTH_PARAM/128+50:0


///////////////////////////////////////////////////////////////////////////////
// CHIE op constants                                                         //
///////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// CHIE REQ OP CONSTANTS
`define CHIE_REQLCRDRETURN                             {1'h0,6'h00}
`define CHIE_READSHARED                                {1'h0,6'h01}
`define CHIE_READCLEAN                                 {1'h0,6'h02}
`define CHIE_READONCE                                  {1'h0,6'h03}
`define CHIE_READNOSNP                                 {1'h0,6'h04}
`define CHIE_PCRDRETURN                                {1'h0,6'h05}
`define CHIE_READUNIQUE                                {1'h0,6'h07}
`define CHIE_CLEANSHARED                               {1'h0,6'h08}
`define CHIE_CLEANINVALID                              {1'h0,6'h09}
`define CHIE_MAKEINVALID                               {1'h0,6'h0a}
`define CHIE_CLEANUNIQUE                               {1'h0,6'h0b}
`define CHIE_MAKEUNIQUE                                {1'h0,6'h0c}
`define CHIE_EVICT                                     {1'h0,6'h0d}
`define CHIE_READNOSNPSEP                              {1'h0,6'h11}
`define CHIE_CLEANSHAREDPERSISTSEP                     {1'h0,6'h13}
`define CHIE_DVMOP                                     {1'h0,6'h14}
`define CHIE_WRITEEVICTFULL                            {1'h0,6'h15}
`define CHIE_WRITECLEANFULL                            {1'h0,6'h17}
`define CHIE_WRITEUNIQUEPTL                            {1'h0,6'h18}
`define CHIE_WRITEUNIQUEFULL                           {1'h0,6'h19}
`define CHIE_WRITEBACKPTL                              {1'h0,6'h1a}
`define CHIE_WRITEBACKFULL                             {1'h0,6'h1b}
`define CHIE_WRITENOSNPPTL                             {1'h0,6'h1c}
`define CHIE_WRITENOSNPFULL                            {1'h0,6'h1d}
`define CHIE_WRITEUNIQUEFULLSTASH                      {1'h0,6'h20}
`define CHIE_WRITEUNIQUEPTLSTASH                       {1'h0,6'h21}
`define CHIE_STASHONCESHARED                           {1'h0,6'h22}
`define CHIE_STASHONCEUNIQUE                           {1'h0,6'h23}
`define CHIE_READONCECLEANINVALID                      {1'h0,6'h24}
`define CHIE_READONCEMAKEINVALID                       {1'h0,6'h25}
`define CHIE_READNOTSHAREDDIRTY                        {1'h0,6'h26}
`define CHIE_CLEANSHAREDPERSIST                        {1'h0,6'h27}
`define CHIE_ATOMICSTORE_ADD                           {1'h0,6'h28}
`define CHIE_ATOMICSTORE_CLR                           {1'h0,6'h29}
`define CHIE_ATOMICSTORE_EOR                           {1'h0,6'h2a}
`define CHIE_ATOMICSTORE_SET                           {1'h0,6'h2b}
`define CHIE_ATOMICSTORE_SMAX                          {1'h0,6'h2c}
`define CHIE_ATOMICSTORE_SMIN                          {1'h0,6'h2d}
`define CHIE_ATOMICSTORE_UMAX                          {1'h0,6'h2e}
`define CHIE_ATOMICSTORE_UMIN                          {1'h0,6'h2f}
`define CHIE_ATOMICLOAD_ADD                            {1'h0,6'h30}
`define CHIE_ATOMICLOAD_CLR                            {1'h0,6'h31}
`define CHIE_ATOMICLOAD_EOR                            {1'h0,6'h32}
`define CHIE_ATOMICLOAD_SET                            {1'h0,6'h33}
`define CHIE_ATOMICLOAD_SMAX                           {1'h0,6'h34}
`define CHIE_ATOMICLOAD_SMIN                           {1'h0,6'h35}
`define CHIE_ATOMICLOAD_UMAX                           {1'h0,6'h36}
`define CHIE_ATOMICLOAD_UMIN                           {1'h0,6'h37}
`define CHIE_ATOMICSWAP                                {1'h0,6'h38}
`define CHIE_ATOMICCOMPARE                             {1'h0,6'h39}
`define CHIE_PREFETCHTGT                               {1'h0,6'h3a}

`define CHIE_SNOOPFILTEREVICT                          {1'h1,6'h00}
`define CHIE_MAKEREADUNIQUE                            {1'h1,6'h01}
`define CHIE_WRITEEVICTOREVICT                         {1'h1,6'h02}
`define CHIE_WRITEUNIQUEZERO                           {1'h1,6'h03}
`define CHIE_WRITENOSNPZERO                            {1'h1,6'h04}
`define CHIE_STASHONCESEPSHARED                        {1'h1,6'h07}
`define CHIE_STASHONCESEPUNIQUE                        {1'h1,6'h08}
`define CHIE_READPREFERUNIQUE                          {1'h1,6'h0c}
`define CHIE_WRITENOSNPFULLCLEANSH                     {1'h1,6'h10}
`define CHIE_WRITENOSNPFULLCLEANINV                    {1'h1,6'h11}
`define CHIE_WRITENOSNPFULLCLEANSHPERSEP               {1'h1,6'h12}
`define CHIE_WRITEUNIQUEFULLCLEANSH                    {1'h1,6'h14}
`define CHIE_WRITEUNIQUEFULLCLEANSHPERSEP              {1'h1,6'h16}
`define CHIE_WRITEBACKFULLCLEANSH                      {1'h1,6'h18}
`define CHIE_WRITEBACKFULLCLEANINV                     {1'h1,6'h19}
`define CHIE_WRITEBACKFULLCLEANSHPERSEP                {1'h1,6'h1a}
`define CHIE_WRITECLEANFULLCLEANSH                     {1'h1,6'h1c}
`define CHIE_WRITECLEANFULLCLEANSHPERSEP               {1'h1,6'h1e}
`define CHIE_WRITENOSNPPTLCLEANSH                      {1'h1,6'h20}
`define CHIE_WRITENOSNPPTLCLEANINV                     {1'h1,6'h21}
`define CHIE_WRITENOSNPPTLCLEANSHPERSEP                {1'h1,6'h22}
`define CHIE_WRITEUNIQUEPTLCLEANSH                     {1'h1,6'h24}
`define CHIE_WRITEUNIQUEPTLCLEANSHPERSEP               {1'h1,6'h26}

////////////////////////////////////////////////////////////////////////////////
// CHIE RSP OP CONSTANTS
`define CHIE_RSPLCRDRETURN                             5'h00
`define CHIE_SNPRESP                                   5'h01
`define CHIE_COMPACK                                   5'h02
`define CHIE_RETRYACK                                  5'h03
`define CHIE_COMP                                      5'h04
`define CHIE_COMPDBIDRESP                              5'h05
`define CHIE_DBIDRESP                                  5'h06
`define CHIE_PCRDGRANT                                 5'h07
`define CHIE_READRECEIPT                               5'h08
`define CHIE_SNPRESPFWDED                              5'h09
`define CHIE_TAGMATCH                                  5'h0a
`define CHIE_RESPSEPDATA                               5'h0b
`define CHIE_PERSIST                                   5'h0c
`define CHIE_COMPPERSIST                               5'h0d
`define CHIE_DBIDRESPORD                               5'h0e
`define CHIE_STASHDONE                                 5'h10
`define CHIE_COMPSTASHDONE                             5'h11
`define CHIE_COMPCMO                                   5'h14

////////////////////////////////////////////////////////////////////////////////
// CHIE SNP OP CONSTANTS
`define CHIE_SNPLCRDRETURN                             5'h00
`define CHIE_SNPSHARED                                 5'h01
`define CHIE_SNPCLEAN                                  5'h02
`define CHIE_SNPONCE                                   5'h03
`define CHIE_SNPNOTSHAREDDIRTY                         5'h04
`define CHIE_SNPUNIQUESTASH                            5'h05
`define CHIE_SNPMAKEINVALIDSTASH                       5'h06
`define CHIE_SNPUNIQUE                                 5'h07
`define CHIE_SNPCLEANSHARED                            5'h08
`define CHIE_SNPCLEANINVALID                           5'h09
`define CHIE_SNPMAKEINVALID                            5'h0a
`define CHIE_SNPSTASHUNIQUE                            5'h0b
`define CHIE_SNPSTASHSHARED                            5'h0c
`define CHIE_SNPDVMOP                                  5'h0d
`define CHIE_SNPQUERY                                  5'h10
`define CHIE_SNPSHAREDFWD                              5'h11
`define CHIE_SNPCLEANFWD                               5'h12
`define CHIE_SNPONCEFWD                                5'h13
`define CHIE_SNPNOTSHAREDDIRTYFWD                      5'h14
`define CHIE_SNPPREFERUNIQUE                           5'h15
`define CHIE_SNPPREFERUNIQUEFWD                        5'h16
`define CHIE_SNPUNIQUEFWD                              5'h17

////////////////////////////////////////////////////////////////////////////////
// CHIE DAT OP CONSTANTS
`define CHIE_DATLCRDRETURN                             4'h0
`define CHIE_SNPRESPDATA                               4'h1
`define CHIE_COPYBACKWRDATA                            4'h2
`define CHIE_NONCOPYBACKWRDATA                         4'h3
`define CHIE_COMPDATA                                  4'h4
`define CHIE_SNPRESPDATAPTL                            4'h5
`define CHIE_SNPRESPDATAFWDED                          4'h6
`define CHIE_WRITEDATACANCEL                           4'h7
`define CHIE_DATASEPRESP                               4'hb
`define CHIE_NCBWRDATACOMPACK                          4'hc

///////////////////////////////////////////////////////////////////////////////
// CHIE size constants
`define CHIE_SIZE1B                                    3'h0
`define CHIE_SIZE2B                                    3'h1
`define CHIE_SIZE4B                                    3'h2
`define CHIE_SIZE8B                                    3'h3
`define CHIE_SIZE16B                                   3'h4
`define CHIE_SIZE32B                                   3'h5
`define CHIE_SIZE64B                                   3'h6

///////////////////////////////////////////////////////////////////////////////
//
///////////////////////////////////////////////////////////////////////////////
// SIGNAL CHIE_SNP_EFF_ADDR
`define CHIE_SNP_EFF_ADDR_WIDTH                        41
`define CHIE_SNP_EFF_ADDR_LSB                          3
`define CHIE_SNP_EFF_ADDR_MSB                          43
`define CHIE_SNP_EFF_ADDR_RANGE                        43:3


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CHIC DVM address/data field constants                                                                    //
//                                                                                                          //
// These constants provide the bit positions in the respective flit fields.                                 //
// For example, to get the VMID out of a DVM request, you would do:                                         //
//                                                                                                          //
//           flit_addr[`CHIA_REQ_FLIT_ADDR_WIDTH-1:0] = RXREQFLIT[`CHIA_REQ_FLIT_ADDR_RANGE];                 //
//           dvm_vmid[`CHIA_REQ_FLIT_ADDR_DVM_VMID_WIDTH-1:0] = flit_addr[`CHIA_REQ_FLIT_ADDR_DVM_VMID_RANGE];//
//                                                                                                          //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// CHIE REQ FLIT ADDR DVM
`define CHIE_REQ_FLIT_ADDR_DVM_PAD_WIDTH               3
`define CHIE_REQ_FLIT_ADDR_DVM_PAD_LSB                 0
`define CHIE_REQ_FLIT_ADDR_DVM_PAD_MSB                 2
`define CHIE_REQ_FLIT_ADDR_DVM_PAD_RANGE               2:0

`define CHIE_REQ_FLIT_ADDR_DVM_PARTNUM_WIDTH           1
`define CHIE_REQ_FLIT_ADDR_DVM_PARTNUM_LSB             3
`define CHIE_REQ_FLIT_ADDR_DVM_PARTNUM_MSB             3
`define CHIE_REQ_FLIT_ADDR_DVM_PARTNUM_RANGE           3

`define CHIE_REQ_FLIT_ADDR_DVM_VAVALID_WIDTH           1
`define CHIE_REQ_FLIT_ADDR_DVM_VAVALID_LSB             4
`define CHIE_REQ_FLIT_ADDR_DVM_VAVALID_MSB             4
`define CHIE_REQ_FLIT_ADDR_DVM_VAVALID_RANGE           4

`define CHIE_REQ_FLIT_ADDR_DVM_VMIDVALID_WIDTH         1
`define CHIE_REQ_FLIT_ADDR_DVM_VMIDVALID_LSB           5
`define CHIE_REQ_FLIT_ADDR_DVM_VMIDVALID_MSB           5
`define CHIE_REQ_FLIT_ADDR_DVM_VMIDVALID_RANGE         5

`define CHIE_REQ_FLIT_ADDR_DVM_ASIDVALID_WIDTH         1
`define CHIE_REQ_FLIT_ADDR_DVM_ASIDVALID_LSB           6
`define CHIE_REQ_FLIT_ADDR_DVM_ASIDVALID_MSB           6
`define CHIE_REQ_FLIT_ADDR_DVM_ASIDVALID_RANGE         6

`define CHIE_REQ_FLIT_ADDR_DVM_SECURE_WIDTH            2
`define CHIE_REQ_FLIT_ADDR_DVM_SECURE_LSB              7
`define CHIE_REQ_FLIT_ADDR_DVM_SECURE_MSB              8
`define CHIE_REQ_FLIT_ADDR_DVM_SECURE_RANGE            8:7

`define CHIE_REQ_FLIT_ADDR_DVM_HYP_WIDTH               2
`define CHIE_REQ_FLIT_ADDR_DVM_HYP_LSB                 9
`define CHIE_REQ_FLIT_ADDR_DVM_HYP_MSB                 10
`define CHIE_REQ_FLIT_ADDR_DVM_HYP_RANGE               10:9

`define CHIE_REQ_FLIT_ADDR_DVM_TYPE_WIDTH              3
`define CHIE_REQ_FLIT_ADDR_DVM_TYPE_LSB                11
`define CHIE_REQ_FLIT_ADDR_DVM_TYPE_MSB                13
`define CHIE_REQ_FLIT_ADDR_DVM_TYPE_RANGE              13:11

`define CHIE_REQ_FLIT_ADDR_DVM_VMID_WIDTH              8
`define CHIE_REQ_FLIT_ADDR_DVM_VMID_LSB                14
`define CHIE_REQ_FLIT_ADDR_DVM_VMID_MSB                21
`define CHIE_REQ_FLIT_ADDR_DVM_VMID_RANGE              21:14

`define CHIE_REQ_FLIT_ADDR_DVM_ASID_WIDTH              16
`define CHIE_REQ_FLIT_ADDR_DVM_ASID_LSB                22
`define CHIE_REQ_FLIT_ADDR_DVM_ASID_MSB                37
`define CHIE_REQ_FLIT_ADDR_DVM_ASID_RANGE              37:22

`define CHIE_REQ_FLIT_ADDR_DVM_S2S1_WIDTH              2
`define CHIE_REQ_FLIT_ADDR_DVM_S2S1_LSB                38
`define CHIE_REQ_FLIT_ADDR_DVM_S2S1_MSB                39
`define CHIE_REQ_FLIT_ADDR_DVM_S2S1_RANGE              39:38

`define CHIE_REQ_FLIT_ADDR_DVM_L_WIDTH                 1
`define CHIE_REQ_FLIT_ADDR_DVM_L_LSB                   40
`define CHIE_REQ_FLIT_ADDR_DVM_L_MSB                   40
`define CHIE_REQ_FLIT_ADDR_DVM_L_RANGE                 40

`define CHIE_REQ_FLIT_ADDR_DVM_WIDTH                   41
`define CHIE_REQ_FLIT_ADDR_DVM_LSB                     0
`define CHIE_REQ_FLIT_ADDR_DVM_MSB                     40
`define CHIE_REQ_FLIT_ADDR_DVM_RANGE                   40:0


////////////////////////////////////////////////////////////////////////////////
// CHIE DVMOP Type CONSTANTS
`define CHIE_DVMOP_TLBI                                3'h0
`define CHIE_DVMOP_BPI                                 3'h1
`define CHIE_DVMOP_PICI                                3'h2
`define CHIE_DVMOP_VICI                                3'h3
`define CHIE_DVMOP_SYNC                                3'h4

////////////////////////////////////////////////////////////////////////////////
// CHIE DVMOP Exception Level Constants
`define CHIE_DVMOP_EL_GUESTOS                          2'h2
`define CHIE_DVMOP_EL_HYP                              2'h3
`define CHIE_DVMOP_EL_EL3                              2'h1

////////////////////////////////////////////////////////////////////////////////
// CHIE DAT FLIT DATA DVM
`define CHIE_DAT_FLIT_DATA_DVM_PAD1_WIDTH              4
`define CHIE_DAT_FLIT_DATA_DVM_PAD1_LSB                0
`define CHIE_DAT_FLIT_DATA_DVM_PAD1_MSB                3
`define CHIE_DAT_FLIT_DATA_DVM_PAD1_RANGE              3:0

`define CHIE_DAT_FLIT_DATA_DVM_ADDR_WIDTH              51
`define CHIE_DAT_FLIT_DATA_DVM_ADDR_LSB                4
`define CHIE_DAT_FLIT_DATA_DVM_ADDR_MSB                54
`define CHIE_DAT_FLIT_DATA_DVM_ADDR_RANGE              54:4

`define CHIE_DAT_FLIT_DATA_DVM_PAD2_WIDTH              1
`define CHIE_DAT_FLIT_DATA_DVM_PAD2_LSB                55
`define CHIE_DAT_FLIT_DATA_DVM_PAD2_MSB                55
`define CHIE_DAT_FLIT_DATA_DVM_PAD2_RANGE              55

`define CHIE_DAT_FLIT_DATA_DVM_VMIDEXT_WIDTH           8
`define CHIE_DAT_FLIT_DATA_DVM_VMIDEXT_LSB             56
`define CHIE_DAT_FLIT_DATA_DVM_VMIDEXT_MSB             63
`define CHIE_DAT_FLIT_DATA_DVM_VMIDEXT_RANGE           63:56

`define CHIE_DAT_FLIT_DATA_DVM_WIDTH                   64
`define CHIE_DAT_FLIT_DATA_DVM_LSB                     0
`define CHIE_DAT_FLIT_DATA_DVM_MSB                     63
`define CHIE_DAT_FLIT_DATA_DVM_RANGE                   63:0


////////////////////////////////////////////////////////////////////////////////
// CHIE SNP FLIT ADDR DVM
`define CHIE_SNP_FLIT_ADDR_DVM_PAD_WIDTH               3
`define CHIE_SNP_FLIT_ADDR_DVM_PAD_LSB                 0
`define CHIE_SNP_FLIT_ADDR_DVM_PAD_MSB                 2
`define CHIE_SNP_FLIT_ADDR_DVM_PAD_RANGE               2:0

`define CHIE_SNP_FLIT_ADDR_DVM_PARTNUM_WIDTH           1
`define CHIE_SNP_FLIT_ADDR_DVM_PARTNUM_LSB             3
`define CHIE_SNP_FLIT_ADDR_DVM_PARTNUM_MSB             3
`define CHIE_SNP_FLIT_ADDR_DVM_PARTNUM_RANGE           3

`define CHIE_SNP_FLIT_ADDR_DVM_VAVALID_WIDTH           1
`define CHIE_SNP_FLIT_ADDR_DVM_VAVALID_LSB             4
`define CHIE_SNP_FLIT_ADDR_DVM_VAVALID_MSB             4
`define CHIE_SNP_FLIT_ADDR_DVM_VAVALID_RANGE           4

`define CHIE_SNP_FLIT_ADDR_DVM_VMIDVALID_WIDTH         1
`define CHIE_SNP_FLIT_ADDR_DVM_VMIDVALID_LSB           5
`define CHIE_SNP_FLIT_ADDR_DVM_VMIDVALID_MSB           5
`define CHIE_SNP_FLIT_ADDR_DVM_VMIDVALID_RANGE         5

`define CHIE_SNP_FLIT_ADDR_DVM_ASIDVALID_WIDTH         1
`define CHIE_SNP_FLIT_ADDR_DVM_ASIDVALID_LSB           6
`define CHIE_SNP_FLIT_ADDR_DVM_ASIDVALID_MSB           6
`define CHIE_SNP_FLIT_ADDR_DVM_ASIDVALID_RANGE         6

`define CHIE_SNP_FLIT_ADDR_DVM_SECURE_WIDTH            2
`define CHIE_SNP_FLIT_ADDR_DVM_SECURE_LSB              7
`define CHIE_SNP_FLIT_ADDR_DVM_SECURE_MSB              8
`define CHIE_SNP_FLIT_ADDR_DVM_SECURE_RANGE            8:7

`define CHIE_SNP_FLIT_ADDR_DVM_HYP_WIDTH               2
`define CHIE_SNP_FLIT_ADDR_DVM_HYP_LSB                 9
`define CHIE_SNP_FLIT_ADDR_DVM_HYP_MSB                 10
`define CHIE_SNP_FLIT_ADDR_DVM_HYP_RANGE               10:9

`define CHIE_SNP_FLIT_ADDR_DVM_TYPE_WIDTH              3
`define CHIE_SNP_FLIT_ADDR_DVM_TYPE_LSB                11
`define CHIE_SNP_FLIT_ADDR_DVM_TYPE_MSB                13
`define CHIE_SNP_FLIT_ADDR_DVM_TYPE_RANGE              13:11

`define CHIE_SNP_FLIT_ADDR_DVM_VMID_WIDTH              8
`define CHIE_SNP_FLIT_ADDR_DVM_VMID_LSB                14
`define CHIE_SNP_FLIT_ADDR_DVM_VMID_MSB                21
`define CHIE_SNP_FLIT_ADDR_DVM_VMID_RANGE              21:14

`define CHIE_SNP_FLIT_ADDR_DVM_ASID_WIDTH              16
`define CHIE_SNP_FLIT_ADDR_DVM_ASID_LSB                22
`define CHIE_SNP_FLIT_ADDR_DVM_ASID_MSB                37
`define CHIE_SNP_FLIT_ADDR_DVM_ASID_RANGE              37:22

`define CHIE_SNP_FLIT_ADDR_DVM_S2S1_WIDTH              2
`define CHIE_SNP_FLIT_ADDR_DVM_S2S1_LSB                38
`define CHIE_SNP_FLIT_ADDR_DVM_S2S1_MSB                39
`define CHIE_SNP_FLIT_ADDR_DVM_S2S1_RANGE              39:38

`define CHIE_SNP_FLIT_ADDR_DVM_L_WIDTH                 1
`define CHIE_SNP_FLIT_ADDR_DVM_L_LSB                   40
`define CHIE_SNP_FLIT_ADDR_DVM_L_MSB                   40
`define CHIE_SNP_FLIT_ADDR_DVM_L_RANGE                 40

`define CHIE_SNP_FLIT_ADDR_DVM_PART1ADDR_WIDTH         7
`define CHIE_SNP_FLIT_ADDR_DVM_PART1ADDR_LSB           41
`define CHIE_SNP_FLIT_ADDR_DVM_PART1ADDR_MSB           47
`define CHIE_SNP_FLIT_ADDR_DVM_PART1ADDR_RANGE         47:41

`define CHIE_SNP_FLIT_ADDR_DVM_WIDTH                   48
`define CHIE_SNP_FLIT_ADDR_DVM_LSB                     0
`define CHIE_SNP_FLIT_ADDR_DVM_MSB                     47
`define CHIE_SNP_FLIT_ADDR_DVM_RANGE                   47:0

`define CHIE_SNP_FLIT_ADDR_DVM_TMP_PAD_WIDTH           4
`define CHIE_SNP_FLIT_ADDR_DVM_TMP_PAD_LSB             0
`define CHIE_SNP_FLIT_ADDR_DVM_TMP_PAD_MSB             3
`define CHIE_SNP_FLIT_ADDR_DVM_TMP_PAD_RANGE           3:0

`define CHIE_SNP_FLIT_ADDR_DVM_TMP_PART2ADDR_WIDTH     44
`define CHIE_SNP_FLIT_ADDR_DVM_TMP_PART2ADDR_LSB       4
`define CHIE_SNP_FLIT_ADDR_DVM_TMP_PART2ADDR_MSB       47
`define CHIE_SNP_FLIT_ADDR_DVM_TMP_PART2ADDR_RANGE     47:4

`define CHIE_SNP_FLIT_ADDR_DVM_TMP_WIDTH               48
`define CHIE_SNP_FLIT_ADDR_DVM_TMP_LSB                 0
`define CHIE_SNP_FLIT_ADDR_DVM_TMP_MSB                 47
`define CHIE_SNP_FLIT_ADDR_DVM_TMP_RANGE               47:0


`define CHIE_SNP_FLIT_ADDR_DVM_PART2ADDR_WIDTH         `CHIE_SNP_FLIT_ADDR_DVM_TMP_PART2ADDR_WIDTH
`define CHIE_SNP_FLIT_ADDR_DVM_PART2ADDR_LSB           `CHIE_SNP_FLIT_ADDR_DVM_TMP_PART2ADDR_LSB
`define CHIE_SNP_FLIT_ADDR_DVM_PART2ADDR_MSB           `CHIE_SNP_FLIT_ADDR_DVM_TMP_PART2ADDR_MSB
`define CHIE_SNP_FLIT_ADDR_DVM_PART2ADDR_RANGE         `CHIE_SNP_FLIT_ADDR_DVM_TMP_PART2ADDR_RANGE


/////////////////////////////////////////////////////////////////////////////////////////////////////
// CHIE MemAttr/SnpAttr field constants                                                            //
//                                                                                                 //
// These constants provide the bit positions in the respective flit fields.                        //
// For example, to get the Cacheable bit out of a request, you would do:                           //
//                                                                                                 //
//          mem_attr[`CHIC_REQ_FLIT_MEMATTR_WIDTH-1:0] = RXREQFLIT[`CHIC_REQ_FLIT_MEMATTR_RANGE];  //
//          cacheable[`CHIC_MEMATTR_CACHEABLE_WIDTH-1:0] = mem_attr[`CHIC_MEMATTR_CACHEABLE_RANGE];//
//                                                                                                 //
/////////////////////////////////////////////////////////////////////////////////////////////////////
`define CHIE_MEMATTR_EARLYWRACK_WIDTH                  1
`define CHIE_MEMATTR_EARLYWRACK_LSB                    0
`define CHIE_MEMATTR_EARLYWRACK_MSB                    0
`define CHIE_MEMATTR_EARLYWRACK_RANGE                  0

`define CHIE_MEMATTR_DEVICE_WIDTH                      1
`define CHIE_MEMATTR_DEVICE_LSB                        1
`define CHIE_MEMATTR_DEVICE_MSB                        1
`define CHIE_MEMATTR_DEVICE_RANGE                      1

`define CHIE_MEMATTR_CACHEABLE_WIDTH                   1
`define CHIE_MEMATTR_CACHEABLE_LSB                     2
`define CHIE_MEMATTR_CACHEABLE_MSB                     2
`define CHIE_MEMATTR_CACHEABLE_RANGE                   2

`define CHIE_MEMATTR_ALLOCATE_WIDTH                    1
`define CHIE_MEMATTR_ALLOCATE_LSB                      3
`define CHIE_MEMATTR_ALLOCATE_MSB                      3
`define CHIE_MEMATTR_ALLOCATE_RANGE                    3

`define CHIE_MEMATTR_WIDTH                             4
`define CHIE_MEMATTR_LSB                               0
`define CHIE_MEMATTR_MSB                               3
`define CHIE_MEMATTR_RANGE                             3:0

//`define CHIE_ORDER_NONE                                2'b00
//`define CHIE_ORDER_RSVD                                2'b01
//`define CHIE_ORDER_REQ_WR_OBS                          2'b10
//`define CHIE_ORDER_END_POINT                           2'b11
//`define CHIE_RESP_ERR_NORM_OK                          2'b00
//`define CHIE_RESP_ERR_EX_OK                            2'b01
//`define CHIE_RESP_ERR_DATA                             2'b10
//`define CHIE_RESP_ERR_NON_DATA                         2'b11

`define CHIE_SNP_RESP_I                                3'b000
`define CHIE_SNP_RESP_SC                               3'b001
`define CHIE_SNP_RESP_UC_UD                            3'b010
`define CHIE_SNP_RESP_SD                               3'b011
`define CHIE_SNP_RESP_I_PD                             3'b100
`define CHIE_SNP_RESP_SC_PD                            3'b101
`define CHIE_SNP_RESP_UC_PD                            3'b110
`define CHIE_COMP_RESP_I                               3'b000
`define CHIE_COMP_RESP_SC                              3'b001
`define CHIE_COMP_RESP_UC                              3'b010
`define CHIE_COMP_RESP_UD_PD                           3'b110
`define CHIE_COMP_RESP_SD_PD                           3'b111
`define CHIE_WRDATA_RESP_I                             3'b000
`define CHIE_WRDATA_RESP_SC                            3'b001
`define CHIE_WRDATA_RESP_UC                            3'b010
`define CHIE_WRDATA_RESP_UD_PD                         3'b110
`define CHIE_WRDATA_RESP_SD_PD                         3'b111

`define CHIE_DATASOURCE_DEFAULT                        4'b000
`define CHIE_DATASOURCE_PEER_CPU_CACHE                 4'b001
`define CHIE_DATASOURCE_LOCAL_CLUSTER_CACHE            4'b010
`define CHIE_DATASOURCE_ICN_CACHE                      4'b011
`define CHIE_DATASOURCE_PEER_CLUSTER_CACHE             4'b100
`define CHIE_DATASOURCE_REMOTE_CHIP_CACHE              4'b101
`define CHIE_DATASOURCE_LOCAL_CLUSTER_CACHE_UNUSED_PREFETCH            4'b1010
`define CHIE_DATASOURCE_ICN_CACHE_UNUSED_PREFETCH        4'b1011

///////////////////////////////////////////////////////////////////////////////
// CHIC LINKACTIVE State Constants (encoded as {LA_REQ, LA_ACK})             //
///////////////////////////////////////////////////////////////////////////////
`define CHIE_TXLA_STOP                                 2'b00
`define CHIE_TXLA_ACTIVATE                             2'b10
`define CHIE_TXLA_RUN                                  2'b11
`define CHIE_TXLA_DEACTIVATE                           2'b01
`define CHIE_RXLA_STOP                                 2'b00
`define CHIE_RXLA_ACTIVATE                             2'b10
`define CHIE_RXLA_RUN                                  2'b11
`define CHIE_RXLA_DEACTIVATE                           2'b01

`endif // CHIE_DEFINES

`else // CHIE_DEFINES_UNDEFINE set

`undef CHIE_DEFINES
`undef CHIE_REQ_FLIT_QOS_WIDTH
`undef CHIE_REQ_FLIT_QOS_LSB
`undef CHIE_REQ_FLIT_QOS_MSB
`undef CHIE_REQ_FLIT_QOS_RANGE
`undef CHIE_REQ_FLIT_TGTID_WIDTH
`undef CHIE_REQ_FLIT_TGTID_LSB
`undef CHIE_REQ_FLIT_TGTID_MSB
`undef CHIE_REQ_FLIT_TGTID_RANGE
`undef CHIE_REQ_FLIT_SRCID_WIDTH
`undef CHIE_REQ_FLIT_SRCID_LSB
`undef CHIE_REQ_FLIT_SRCID_MSB
`undef CHIE_REQ_FLIT_SRCID_RANGE
`undef CHIE_REQ_FLIT_TXNID_WIDTH
`undef CHIE_REQ_FLIT_TXNID_LSB
`undef CHIE_REQ_FLIT_TXNID_MSB
`undef CHIE_REQ_FLIT_TXNID_RANGE
`undef CHIE_REQ_FLIT_RETURNNID_WIDTH
`undef CHIE_REQ_FLIT_RETURNNID_LSB
`undef CHIE_REQ_FLIT_RETURNNID_MSB
`undef CHIE_REQ_FLIT_RETURNNID_RANGE
`undef CHIE_REQ_FLIT_STASHNID_WIDTH
`undef CHIE_REQ_FLIT_STASHNID_LSB
`undef CHIE_REQ_FLIT_STASHNID_MSB
`undef CHIE_REQ_FLIT_STASHNID_RANGE
`undef CHIE_REQ_FLIT_STASHNIDVALID_WIDTH
`undef CHIE_REQ_FLIT_STASHNIDVALID_LSB
`undef CHIE_REQ_FLIT_STASHNIDVALID_MSB
`undef CHIE_REQ_FLIT_STASHNIDVALID_RANGE
`undef CHIE_REQ_FLIT_ENDIAN_WIDTH
`undef CHIE_REQ_FLIT_ENDIAN_LSB
`undef CHIE_REQ_FLIT_ENDIAN_MSB
`undef CHIE_REQ_FLIT_ENDIAN_RANGE
`undef CHIE_REQ_FLIT_RETURNTXNID_WIDTH
`undef CHIE_REQ_FLIT_RETURNTXNID_LSB
`undef CHIE_REQ_FLIT_RETURNTXNID_MSB
`undef CHIE_REQ_FLIT_RETURNTXNID_RANGE
`undef CHIE_REQ_FLIT_OPCODE_WIDTH
`undef CHIE_REQ_FLIT_OPCODE_LSB
`undef CHIE_REQ_FLIT_OPCODE_MSB
`undef CHIE_REQ_FLIT_OPCODE_RANGE
`undef CHIE_REQ_FLIT_SIZE_WIDTH
`undef CHIE_REQ_FLIT_SIZE_LSB
`undef CHIE_REQ_FLIT_SIZE_MSB
`undef CHIE_REQ_FLIT_SIZE_RANGE
`undef CHIE_REQ_FLIT_ADDR_WIDTH
`undef CHIE_REQ_FLIT_ADDR_LSB
`undef CHIE_REQ_FLIT_ADDR_MSB
`undef CHIE_REQ_FLIT_ADDR_RANGE
`undef CHIE_REQ_FLIT_NS_WIDTH
`undef CHIE_REQ_FLIT_NS_LSB
`undef CHIE_REQ_FLIT_NS_MSB
`undef CHIE_REQ_FLIT_NS_RANGE
`undef CHIE_REQ_FLIT_LIKELYSHARED_WIDTH
`undef CHIE_REQ_FLIT_LIKELYSHARED_LSB
`undef CHIE_REQ_FLIT_LIKELYSHARED_MSB
`undef CHIE_REQ_FLIT_LIKELYSHARED_RANGE0
`undef CHIE_REQ_FLIT_ALLOWRETRY_WIDTH
`undef CHIE_REQ_FLIT_ALLOWRETRY_LSB
`undef CHIE_REQ_FLIT_ALLOWRETRY_MSB
`undef CHIE_REQ_FLIT_ALLOWRETRY_RANGE
`undef CHIE_REQ_FLIT_ORDER_WIDTH
`undef CHIE_REQ_FLIT_ORDER_LSB
`undef CHIE_REQ_FLIT_ORDER_MSB
`undef CHIE_REQ_FLIT_ORDER_RANGE
`undef CHIE_REQ_FLIT_PCRDTYPE_WIDTH
`undef CHIE_REQ_FLIT_PCRDTYPE_LSB
`undef CHIE_REQ_FLIT_PCRDTYPE_MSB
`undef CHIE_REQ_FLIT_PCRDTYPE_RANGE
`undef CHIE_REQ_FLIT_MEMATTR_WIDTH
`undef CHIE_REQ_FLIT_MEMATTR_LSB
`undef CHIE_REQ_FLIT_MEMATTR_MSB
`undef CHIE_REQ_FLIT_MEMATTR_RANGE
`undef CHIE_REQ_FLIT_MEMATTR_EARLYWRACK_WIDTH
`undef CHIE_REQ_FLIT_MEMATTR_EARLYWRACK_LSB
`undef CHIE_REQ_FLIT_MEMATTR_EARLYWRACK_MSB
`undef CHIE_REQ_FLIT_MEMATTR_EARLYWRACK_RANGE
`undef CHIE_REQ_FLIT_MEMATTR_DEVICE_WIDTH
`undef CHIE_REQ_FLIT_MEMATTR_DEVICE_LSB
`undef CHIE_REQ_FLIT_MEMATTR_DEVICE_MSB
`undef CHIE_REQ_FLIT_MEMATTR_DEVICE_RANGE
`undef CHIE_REQ_FLIT_MEMATTR_CACHEABLE_WIDTH
`undef CHIE_REQ_FLIT_MEMATTR_CACHEABLE_LSB
`undef CHIE_REQ_FLIT_MEMATTR_CACHEABLE_MSB
`undef CHIE_REQ_FLIT_MEMATTR_CACHEABLE_RANGE
`undef CHIE_REQ_FLIT_MEMATTR_ALLOCATE_WIDTH
`undef CHIE_REQ_FLIT_MEMATTR_ALLOCATE_LSB
`undef CHIE_REQ_FLIT_MEMATTR_ALLOCATE_MSB
`undef CHIE_REQ_FLIT_MEMATTR_ALLOCATE_RANGE
`undef CHIE_REQ_FLIT_SNPATTR_WIDTH
`undef CHIE_REQ_FLIT_SNPATTR_LSB
`undef CHIE_REQ_FLIT_SNPATTR_MSB
`undef CHIE_REQ_FLIT_SNPATTR_RANGE
`undef CHIE_REQ_FLIT_DODWT_WIDTH
`undef CHIE_REQ_FLIT_DODWT_LSB
`undef CHIE_REQ_FLIT_DODWT_MSB
`undef CHIE_REQ_FLIT_DODWT_RANGE
`undef CHIE_REQ_FLIT_LPID_WIDTH
`undef CHIE_REQ_FLIT_LPID_LSB
`undef CHIE_REQ_FLIT_LPID_MSB
`undef CHIE_REQ_FLIT_LPID_RANGE
`undef CHIE_REQ_FLIT_EXCL_WIDTH
`undef CHIE_REQ_FLIT_EXCL_LSB
`undef CHIE_REQ_FLIT_EXCL_MSB
`undef CHIE_REQ_FLIT_EXCL_RANGE
`undef CHIE_REQ_FLIT_SNOOPME_WIDTH
`undef CHIE_REQ_FLIT_SNOOPME_LSB
`undef CHIE_REQ_FLIT_SNOOPME_MSB
`undef CHIE_REQ_FLIT_SNOOPME_RANGE
`undef CHIE_REQ_FLIT_EXPCOMPACK_WIDTH
`undef CHIE_REQ_FLIT_EXPCOMPACK_LSB
`undef CHIE_REQ_FLIT_EXPCOMPACK_MSB
`undef CHIE_REQ_FLIT_EXPCOMPACK_RANGE
`undef CHIE_REQ_FLIT_TAGOP_WIDTH
`undef CHIE_REQ_FLIT_TAGOP_LSB
`undef CHIE_REQ_FLIT_TAGOP_MSB
`undef CHIE_REQ_FLIT_TAGOP_RANGE
`undef CHIE_REQ_FLIT_TRACETAG_WIDTH
`undef CHIE_REQ_FLIT_TRACETAG_LSB
`undef CHIE_REQ_FLIT_TRACETAG_MSB
`undef CHIE_REQ_FLIT_TRACETAG_RANGE
`undef CHIE_REQ_FLIT_WIDTH
`undef CHIE_REQ_FLIT_LSB
`undef CHIE_REQ_FLIT_MSB
`undef CHIE_REQ_FLIT_RANGE
`undef CHIE_RSP_FLIT_QOS_WIDTH
`undef CHIE_RSP_FLIT_QOS_LSB
`undef CHIE_RSP_FLIT_QOS_MSB
`undef CHIE_RSP_FLIT_QOS_RANGE
`undef CHIE_RSP_FLIT_TGTID_WIDTH
`undef CHIE_RSP_FLIT_TGTID_LSB
`undef CHIE_RSP_FLIT_TGTID_MSB
`undef CHIE_RSP_FLIT_TGTID_RANGE
`undef CHIE_RSP_FLIT_SRCID_WIDTH
`undef CHIE_RSP_FLIT_SRCID_LSB
`undef CHIE_RSP_FLIT_SRCID_MSB
`undef CHIE_RSP_FLIT_SRCID_RANGE
`undef CHIE_RSP_FLIT_TXNID_WIDTH
`undef CHIE_RSP_FLIT_TXNID_LSB
`undef CHIE_RSP_FLIT_TXNID_MSB
`undef CHIE_RSP_FLIT_TXNID_RANGE
`undef CHIE_RSP_FLIT_OPCODE_WIDTH
`undef CHIE_RSP_FLIT_OPCODE_LSB
`undef CHIE_RSP_FLIT_OPCODE_MSB
`undef CHIE_RSP_FLIT_OPCODE_RANGE
`undef CHIE_RSP_FLIT_RESPERR_WIDTH
`undef CHIE_RSP_FLIT_RESPERR_LSB
`undef CHIE_RSP_FLIT_RESPERR_MSB
`undef CHIE_RSP_FLIT_RESPERR_RANGE
`undef CHIE_RSP_FLIT_RESP_WIDTH
`undef CHIE_RSP_FLIT_RESP_LSB
`undef CHIE_RSP_FLIT_RESP_MSB
`undef CHIE_RSP_FLIT_RESP_RANGE
`undef CHIE_RSP_FLIT_FWDSTATE_WIDTH
`undef CHIE_RSP_FLIT_FWDSTATE_LSB
`undef CHIE_RSP_FLIT_FWDSTATE_MSB
`undef CHIE_RSP_FLIT_FWDSTATE_RANGE
`undef CHIE_RSP_FLIT_DATAPULL_WIDTH
`undef CHIE_RSP_FLIT_DATAPULL_LSB
`undef CHIE_RSP_FLIT_DATAPULL_MSB
`undef CHIE_RSP_FLIT_DATAPULL_RANGE
`undef CHIE_RSP_FLIT_CBUSY_WIDTH
`undef CHIE_RSP_FLIT_CBUSY_LSB
`undef CHIE_RSP_FLIT_CBUSY_MSB
`undef CHIE_RSP_FLIT_CBUSY_RANGE
`undef CHIE_RSP_FLIT_DBID_WIDTH
`undef CHIE_RSP_FLIT_DBID_LSB
`undef CHIE_RSP_FLIT_DBID_MSB
`undef CHIE_RSP_FLIT_DBID_RANGE
`undef CHIE_RSP_FLIT_PCRDTYPE_WIDTH
`undef CHIE_RSP_FLIT_PCRDTYPE_LSB
`undef CHIE_RSP_FLIT_PCRDTYPE_MSB
`undef CHIE_RSP_FLIT_PCRDTYPE_RANGE
`undef CHIE_RSP_FLIT_TAGOP_WIDTH
`undef CHIE_RSP_FLIT_TAGOP_LSB
`undef CHIE_RSP_FLIT_TAGOP_MSB
`undef CHIE_RSP_FLIT_TAGOP_RANGE
`undef CHIE_RSP_FLIT_TRACETAG_WIDTH
`undef CHIE_RSP_FLIT_TRACETAG_LSB
`undef CHIE_RSP_FLIT_TRACETAG_MSB
`undef CHIE_RSP_FLIT_TRACETAG_RANGE
`undef CHIE_RSP_FLIT_WIDTH
`undef CHIE_RSP_FLIT_LSB
`undef CHIE_RSP_FLIT_MSB
`undef CHIE_RSP_FLIT_RANGE
`undef CHIE_SNP_FLIT_QOS_WIDTH
`undef CHIE_SNP_FLIT_QOS_LSB
`undef CHIE_SNP_FLIT_QOS_MSB
`undef CHIE_SNP_FLIT_QOS_RANGE
`undef CHIE_SNP_FLIT_SRCID_WIDTH
`undef CHIE_SNP_FLIT_SRCID_LSB
`undef CHIE_SNP_FLIT_SRCID_MSB
`undef CHIE_SNP_FLIT_SRCID_RANGE
`undef CHIE_SNP_FLIT_TXNID_WIDTH
`undef CHIE_SNP_FLIT_TXNID_LSB
`undef CHIE_SNP_FLIT_TXNID_MSB
`undef CHIE_SNP_FLIT_TXNID_RANGE
`undef CHIE_SNP_FLIT_FWDNID_WIDTH
`undef CHIE_SNP_FLIT_FWDNID_LSB
`undef CHIE_SNP_FLIT_FWDNID_MSB
`undef CHIE_SNP_FLIT_FWDNID_RANGE
`undef CHIE_SNP_FLIT_FWDTXNID_WIDTH
`undef CHIE_SNP_FLIT_FWDTXNID_LSB
`undef CHIE_SNP_FLIT_FWDTXNID_MSB
`undef CHIE_SNP_FLIT_FWDTXNID_RANGE
`undef CHIE_SNP_FLIT_FWDTXNID_STASHLPID_WIDTH
`undef CHIE_SNP_FLIT_FWDTXNID_STASHLPID_LSB
`undef CHIE_SNP_FLIT_FWDTXNID_STASHLPID_MSB
`undef CHIE_SNP_FLIT_FWDTXNID_STASHLPID_RANGE
`undef CHIE_SNP_FLIT_FWDTXNID_STASHLPIDVALID_WIDTH
`undef CHIE_SNP_FLIT_FWDTXNID_STASHLPIDVALID_LSB
`undef CHIE_SNP_FLIT_FWDTXNID_STASHLPIDVALID_MSB
`undef CHIE_SNP_FLIT_FWDTXNID_STASHLPIDVALID_RANGE
`undef CHIE_SNP_FLIT_FWDTXNID_VMIDEXT_WIDTH
`undef CHIE_SNP_FLIT_FWDTXNID_VMIDEXT_LSB
`undef CHIE_SNP_FLIT_FWDTXNID_VMIDEXT_MSB
`undef CHIE_SNP_FLIT_FWDTXNID_VMIDEXT_RANGE
`undef CHIE_SNP_FLIT_OPCODE_WIDTH
`undef CHIE_SNP_FLIT_OPCODE_LSB
`undef CHIE_SNP_FLIT_OPCODE_MSB
`undef CHIE_SNP_FLIT_OPCODE_RANGE
`undef CHIE_SNP_FLIT_ADDR_WIDTH
`undef CHIE_SNP_FLIT_ADDR_LSB
`undef CHIE_SNP_FLIT_ADDR_MSB
`undef CHIE_SNP_FLIT_ADDR_RANGE
`undef CHIE_SNP_FLIT_NS_WIDTH
`undef CHIE_SNP_FLIT_NS_LSB
`undef CHIE_SNP_FLIT_NS_MSB
`undef CHIE_SNP_FLIT_NS_RANGE
`undef CHIE_SNP_FLIT_DONOTGOTOSD_WIDTH
`undef CHIE_SNP_FLIT_DONOTGOTOSD_LSB
`undef CHIE_SNP_FLIT_DONOTGOTOSD_MSB
`undef CHIE_SNP_FLIT_DONOTGOTOSD_RANGE
`undef CHIE_SNP_FLIT_RETTOSRC_WIDTH
`undef CHIE_SNP_FLIT_RETTOSRC_LSB
`undef CHIE_SNP_FLIT_RETTOSRC_MSB
`undef CHIE_SNP_FLIT_RETTOSRC_RANGE
`undef CHIE_SNP_FLIT_TRACETAG_WIDTH
`undef CHIE_SNP_FLIT_TRACETAG_LSB
`undef CHIE_SNP_FLIT_TRACETAG_MSB
`undef CHIE_SNP_FLIT_TRACETAG_RANGE
`undef CHIE_SNP_FLIT_WIDTH
`undef CHIE_SNP_FLIT_LSB
`undef CHIE_SNP_FLIT_MSB
`undef CHIE_SNP_FLIT_RANGE
`undef CHIE_DAT_FLIT_QOS_WIDTH
`undef CHIE_DAT_FLIT_QOS_LSB
`undef CHIE_DAT_FLIT_QOS_MSB
`undef CHIE_DAT_FLIT_QOS_RANGE
`undef CHIE_DAT_FLIT_TGTID_WIDTH
`undef CHIE_DAT_FLIT_TGTID_LSB
`undef CHIE_DAT_FLIT_TGTID_MSB
`undef CHIE_DAT_FLIT_TGTID_RANGE
`undef CHIE_DAT_FLIT_SRCID_WIDTH
`undef CHIE_DAT_FLIT_SRCID_LSB
`undef CHIE_DAT_FLIT_SRCID_MSB
`undef CHIE_DAT_FLIT_SRCID_RANGE
`undef CHIE_DAT_FLIT_TXNID_WIDTH
`undef CHIE_DAT_FLIT_TXNID_LSB
`undef CHIE_DAT_FLIT_TXNID_MSB
`undef CHIE_DAT_FLIT_TXNID_RANGE
`undef CHIE_DAT_FLIT_HOMENID_WIDTH
`undef CHIE_DAT_FLIT_HOMENID_LSB
`undef CHIE_DAT_FLIT_HOMENID_MSB
`undef CHIE_DAT_FLIT_HOMENID_RANGE
`undef CHIE_DAT_FLIT_OPCODE_WIDTH
`undef CHIE_DAT_FLIT_OPCODE_LSB
`undef CHIE_DAT_FLIT_OPCODE_MSB
`undef CHIE_DAT_FLIT_OPCODE_RANGE
`undef CHIE_DAT_FLIT_RESPERR_WIDTH
`undef CHIE_DAT_FLIT_RESPERR_LSB
`undef CHIE_DAT_FLIT_RESPERR_MSB
`undef CHIE_DAT_FLIT_RESPERR_RANGE
`undef CHIE_DAT_FLIT_RESP_WIDTH
`undef CHIE_DAT_FLIT_RESP_LSB
`undef CHIE_DAT_FLIT_RESP_MSB
`undef CHIE_DAT_FLIT_RESP_RANGE
`undef CHIE_DAT_FLIT_DATASOURCE_WIDTH
`undef CHIE_DAT_FLIT_DATASOURCE_LSB
`undef CHIE_DAT_FLIT_DATASOURCE_MSB
`undef CHIE_DAT_FLIT_DATASOURCE_RANGE
`undef CHIE_DAT_FLIT_FWDSTATE_WIDTH
`undef CHIE_DAT_FLIT_FWDSTATE_LSB
`undef CHIE_DAT_FLIT_FWDSTATE_MSB
`undef CHIE_DAT_FLIT_FWDSTATE_RANGE
`undef CHIE_DAT_FLIT_DATAPULL_WIDTH
`undef CHIE_DAT_FLIT_DATAPULL_LSB
`undef CHIE_DAT_FLIT_DATAPULL_MSB
`undef CHIE_DAT_FLIT_DATAPULL_RANGE
`undef CHIE_DAT_FLIT_CBUSY_WIDTH
`undef CHIE_DAT_FLIT_CBUSY_LSB
`undef CHIE_DAT_FLIT_CBUSY_MSB
`undef CHIE_DAT_FLIT_CBUSY_RANGE
`undef CHIE_DAT_FLIT_DBID_WIDTH
`undef CHIE_DAT_FLIT_DBID_LSB
`undef CHIE_DAT_FLIT_DBID_MSB
`undef CHIE_DAT_FLIT_DBID_RANGE
`undef CHIE_DAT_FLIT_CCID_WIDTH
`undef CHIE_DAT_FLIT_CCID_LSB
`undef CHIE_DAT_FLIT_CCID_MSB
`undef CHIE_DAT_FLIT_CCID_RANGE
`undef CHIE_DAT_FLIT_DATAID_WIDTH
`undef CHIE_DAT_FLIT_DATAID_LSB
`undef CHIE_DAT_FLIT_DATAID_MSB
`undef CHIE_DAT_FLIT_DATAID_RANGE
`undef CHIE_DAT_FLIT_TAGOP_WIDTH
`undef CHIE_DAT_FLIT_TAGOP_LSB
`undef CHIE_DAT_FLIT_TAGOP_MSB
`undef CHIE_DAT_FLIT_TAGOP_RANGE
`undef CHIE_DAT_FLIT_TAG_WIDTH
`undef CHIE_DAT_FLIT_TAG_LSB
`undef CHIE_DAT_FLIT_TAG_MSB
`undef CHIE_DAT_FLIT_TAG_RANGE
`undef CHIE_DAT_FLIT_TU_WIDTH
`undef CHIE_DAT_FLIT_TU_LSB
`undef CHIE_DAT_FLIT_TU_MSB
`undef CHIE_DAT_FLIT_TU_RANGE
`undef CHIE_DAT_FLIT_TRACETAG_WIDTH
`undef CHIE_DAT_FLIT_TRACETAG_LSB
`undef CHIE_DAT_FLIT_TRACETAG_MSB
`undef CHIE_DAT_FLIT_TRACETAG_RANGE
`undef CHIE_DAT_FLIT_BE_WIDTH
`undef CHIE_DAT_FLIT_BE_LSB
`undef CHIE_DAT_FLIT_BE_MSB
`undef CHIE_DAT_FLIT_BE_RANGE
`undef CHIE_DAT_FLIT_DATA_WIDTH
`undef CHIE_DAT_FLIT_DATA_LSB
`undef CHIE_DAT_FLIT_DATA_MSB
`undef CHIE_DAT_FLIT_DATA_RANGE
`undef CHIE_DAT_FLIT_WIDTH
`undef CHIE_DAT_FLIT_LSB
`undef CHIE_DAT_FLIT_MSB
`undef CHIE_DAT_FLIT_RANGE
`undef CHIE_REQLCRDRETURN
`undef CHIE_READSHARED
`undef CHIE_READCLEAN
`undef CHIE_READONCE
`undef CHIE_READNOSNP
`undef CHIE_PCRDRETURN
`undef CHIE_READUNIQUE
`undef CHIE_CLEANSHARED
`undef CHIE_CLEANINVALID
`undef CHIE_MAKEINVALID
`undef CHIE_CLEANUNIQUE
`undef CHIE_MAKEUNIQUE
`undef CHIE_EVICT
`undef CHIE_READNOSNPSEP
`undef CHIE_CLEANSHAREDPERSISTSEP
`undef CHIE_DVMOP
`undef CHIE_WRITEEVICTFULL
`undef CHIE_WRITECLEANFULL
`undef CHIE_WRITEUNIQUEPTL
`undef CHIE_WRITEUNIQUEFULL
`undef CHIE_WRITEBACKPTL
`undef CHIE_WRITEBACKFULL
`undef CHIE_WRITENOSNPPTL
`undef CHIE_WRITENOSNPFULL
`undef CHIE_WRITEUNIQUEFULLSTASH
`undef CHIE_WRITEUNIQUEPTLSTASH
`undef CHIE_STASHONCESHARED
`undef CHIE_STASHONCEUNIQUE
`undef CHIE_READONCECLEANINVALID
`undef CHIE_READONCEMAKEINVALID
`undef CHIE_READNOTSHAREDDIRTY
`undef CHIE_CLEANSHAREDPERSIST
`undef CHIE_ATOMICSTORE_ADD
`undef CHIE_ATOMICSTORE_CLR
`undef CHIE_ATOMICSTORE_EOR
`undef CHIE_ATOMICSTORE_SET
`undef CHIE_ATOMICSTORE_SMAX
`undef CHIE_ATOMICSTORE_SMIN
`undef CHIE_ATOMICSTORE_UMAX
`undef CHIE_ATOMICSTORE_UMIN
`undef CHIE_ATOMICLOAD_ADD
`undef CHIE_ATOMICLOAD_CLR
`undef CHIE_ATOMICLOAD_EOR
`undef CHIE_ATOMICLOAD_SET
`undef CHIE_ATOMICLOAD_SMAX
`undef CHIE_ATOMICLOAD_SMIN
`undef CHIE_ATOMICLOAD_UMAX
`undef CHIE_ATOMICLOAD_UMIN
`undef CHIE_ATOMICSWAP
`undef CHIE_ATOMICCOMPARE
`undef CHIE_PREFETCHTGT
`undef CHIE_MAKEREADUNIQUE
`undef CHIE_WRITEEVICTOREVICT
`undef CHIE_WRITEUNIQUEZERO
`undef CHIE_WRITENOSNPZERO
`undef CHIE_STASHONCESEPSHARED
`undef CHIE_STASHONCESEPUNIQUE
`undef CHIE_READPREFERUNIQUE
`undef CHIE_WRITENOSNPFULLCLEANSH
`undef CHIE_WRITENOSNPFULLCLEANINV
`undef CHIE_WRITENOSNPFULLCLEANSHPERSEP
`undef CHIE_WRITEUNIQUEFULLCLEANSH
`undef CHIE_WRITEUNIQUEFULLCLEANSHPERSEP
`undef CHIE_WRITEBACKFULLCLEANSH
`undef CHIE_WRITEBACKFULLCLEANINV
`undef CHIE_WRITEBACKFULLCLEANSHPERSEP
`undef CHIE_WRITECLEANFULLCLEANSH
`undef CHIE_WRITECLEANFULLCLEANSHPERSEP
`undef CHIE_WRITENOSNPPTLCLEANSH
`undef CHIE_WRITENOSNPPTLCLEANINV
`undef CHIE_WRITENOSNPPTLCLEANSHPERSEP
`undef CHIE_WRITEUNIQUEPTLCLEANSH
`undef CHIE_CHIE_WRITEUNIQUEPTLCLEANSHPERSEP
`undef CHIE_RSPLCRDRETURN
`undef CHIE_SNPRESP
`undef CHIE_COMPACK
`undef CHIE_RETRYACK
`undef CHIE_COMP
`undef CHIE_COMPDBIDRESP
`undef CHIE_DBIDRESP
`undef CHIE_PCRDGRANT
`undef CHIE_READRECEIPT
`undef CHIE_SNPRESPFWDED
`undef CHIE_TAGMATCH
`undef CHIE_RESPSEPDATA
`undef CHIE_PERSIST
`undef CHIE_COMPPERSIST
`undef CHIE_DBIDRESPORD
`undef CHIE_STASHDONE
`undef CHIE_COMPSTASHDONE
`undef CHIE_COMPCMO
`undef CHIE_SNPLCRDRETURN
`undef CHIE_SNPSHARED
`undef CHIE_SNPCLEAN
`undef CHIE_SNPONCE
`undef CHIE_SNPNOTSHAREDDIRTY
`undef CHIE_SNPUNIQUESTASH
`undef CHIE_SNPMAKEINVALIDSTASH
`undef CHIE_SNPUNIQUE
`undef CHIE_SNPCLEANSHARED
`undef CHIE_SNPCLEANINVALID
`undef CHIE_SNPMAKEINVALID
`undef CHIE_SNPSTASHUNIQUE
`undef CHIE_SNPSTASHSHARED
`undef CHIE_SNPDVMOP
`undef CHIE_SNPQUERY
`undef CHIE_SNPSHAREDFWD
`undef CHIE_SNPCLEANFWD
`undef CHIE_SNPONCEFWD
`undef CHIE_SNPNOTSHAREDDIRTYFWD
`undef CHIE_SNPPREFERUNIQUE
`undef CHIE_SNPPREFERUNIQUEFWD
`undef CHIE_SNPUNIQUEFWD
`undef CHIE_DATLCRDRETURN
`undef CHIE_SNPRESPDATA
`undef CHIE_COPYBACKWRDATA
`undef CHIE_NONCOPYBACKWRDATA
`undef CHIE_COMPDATA
`undef CHIE_SNPRESPDATAPTL
`undef CHIE_SNPRESPDATAFWDED
`undef CHIE_WRITEDATACANCEL
`undef CHIE_DATASEPRESP
`undef CHIE_NCBWRDATACOMPACK
`undef CHIE_SIZE1B
`undef CHIE_SIZE2B
`undef CHIE_SIZE4B
`undef CHIE_SIZE8B
`undef CHIE_SIZE16B
`undef CHIE_SIZE32B
`undef CHIE_SIZE64B
`undef CHIE_SNP_EFF_ADDR_WIDTH
`undef CHIE_SNP_EFF_ADDR_LSB
`undef CHIE_SNP_EFF_ADDR_MSB
`undef CHIE_SNP_EFF_ADDR_RANGE
`undef CHIE_REQ_FLIT_ADDR_DVM_PAD_WIDTH
`undef CHIE_REQ_FLIT_ADDR_DVM_PAD_LSB
`undef CHIE_REQ_FLIT_ADDR_DVM_PAD_MSB
`undef CHIE_REQ_FLIT_ADDR_DVM_PAD_RANGE
`undef CHIE_REQ_FLIT_ADDR_DVM_PARTNUM_WIDTH
`undef CHIE_REQ_FLIT_ADDR_DVM_PARTNUM_LSB
`undef CHIE_REQ_FLIT_ADDR_DVM_PARTNUM_MSB
`undef CHIE_REQ_FLIT_ADDR_DVM_PARTNUM_RANGE
`undef CHIE_REQ_FLIT_ADDR_DVM_VAVALID_WIDTH
`undef CHIE_REQ_FLIT_ADDR_DVM_VAVALID_LSB
`undef CHIE_REQ_FLIT_ADDR_DVM_VAVALID_MSB
`undef CHIE_REQ_FLIT_ADDR_DVM_VAVALID_RANGE
`undef CHIE_REQ_FLIT_ADDR_DVM_VMIDVALID_WIDTH
`undef CHIE_REQ_FLIT_ADDR_DVM_VMIDVALID_LSB
`undef CHIE_REQ_FLIT_ADDR_DVM_VMIDVALID_MSB
`undef CHIE_REQ_FLIT_ADDR_DVM_VMIDVALID_RANGE
`undef CHIE_REQ_FLIT_ADDR_DVM_ASIDVALID_WIDTH
`undef CHIE_REQ_FLIT_ADDR_DVM_ASIDVALID_LSB
`undef CHIE_REQ_FLIT_ADDR_DVM_ASIDVALID_MSB
`undef CHIE_REQ_FLIT_ADDR_DVM_ASIDVALID_RANGE
`undef CHIE_REQ_FLIT_ADDR_DVM_SECURE_WIDTH
`undef CHIE_REQ_FLIT_ADDR_DVM_SECURE_LSB
`undef CHIE_REQ_FLIT_ADDR_DVM_SECURE_MSB
`undef CHIE_REQ_FLIT_ADDR_DVM_SECURE_RANGE
`undef CHIE_REQ_FLIT_ADDR_DVM_HYP_WIDTH
`undef CHIE_REQ_FLIT_ADDR_DVM_HYP_LSB
`undef CHIE_REQ_FLIT_ADDR_DVM_HYP_MSB
`undef CHIE_REQ_FLIT_ADDR_DVM_HYP_RANGE
`undef CHIE_REQ_FLIT_ADDR_DVM_TYPE_WIDTH
`undef CHIE_REQ_FLIT_ADDR_DVM_TYPE_LSB
`undef CHIE_REQ_FLIT_ADDR_DVM_TYPE_MSB
`undef CHIE_REQ_FLIT_ADDR_DVM_TYPE_RANGE
`undef CHIE_REQ_FLIT_ADDR_DVM_VMID_WIDTH
`undef CHIE_REQ_FLIT_ADDR_DVM_VMID_LSB
`undef CHIE_REQ_FLIT_ADDR_DVM_VMID_MSB
`undef CHIE_REQ_FLIT_ADDR_DVM_VMID_RANGE
`undef CHIE_REQ_FLIT_ADDR_DVM_ASID_WIDTH
`undef CHIE_REQ_FLIT_ADDR_DVM_ASID_LSB
`undef CHIE_REQ_FLIT_ADDR_DVM_ASID_MSB
`undef CHIE_REQ_FLIT_ADDR_DVM_ASID_RANGE
`undef CHIE_REQ_FLIT_ADDR_DVM_S2S1_WIDTH
`undef CHIE_REQ_FLIT_ADDR_DVM_S2S1_LSB
`undef CHIE_REQ_FLIT_ADDR_DVM_S2S1_MSB
`undef CHIE_REQ_FLIT_ADDR_DVM_S2S1_RANGE
`undef CHIE_REQ_FLIT_ADDR_DVM_L_WIDTH
`undef CHIE_REQ_FLIT_ADDR_DVM_L_LSB
`undef CHIE_REQ_FLIT_ADDR_DVM_L_MSB
`undef CHIE_REQ_FLIT_ADDR_DVM_L_RANGE
`undef CHIE_DVMOP_TLBI
`undef CHIE_DVMOP_BPI
`undef CHIE_DVMOP_PICI
`undef CHIE_DVMOP_VICI
`undef CHIE_DVMOP_SYNC
`undef CHIE_DVMOP_EL_GUESTOS
`undef CHIE_DVMOP_EL_HYP
`undef CHIE_DVMOP_EL_EL3
`undef CHIE_DAT_FLIT_DATA_DVM_PAD1_WIDTH
`undef CHIE_DAT_FLIT_DATA_DVM_PAD1_LSB
`undef CHIE_DAT_FLIT_DATA_DVM_PAD1_MSB
`undef CHIE_DAT_FLIT_DATA_DVM_PAD1_RANGE
`undef CHIE_DAT_FLIT_DATA_DVM_ADDR_WIDTH
`undef CHIE_DAT_FLIT_DATA_DVM_ADDR_LSB
`undef CHIE_DAT_FLIT_DATA_DVM_ADDR_MSB
`undef CHIE_DAT_FLIT_DATA_DVM_ADDR_RANGE
`undef CHIE_DAT_FLIT_DATA_DVM_PAD2_WIDTH
`undef CHIE_DAT_FLIT_DATA_DVM_PAD2_LSB
`undef CHIE_DAT_FLIT_DATA_DVM_PAD2_MSB
`undef CHIE_DAT_FLIT_DATA_DVM_PAD2_RANGE
`undef CHIE_DAT_FLIT_DATA_DVM_VMIDEXT_WIDTH
`undef CHIE_DAT_FLIT_DATA_DVM_VMIDEXT_LSB
`undef CHIE_DAT_FLIT_DATA_DVM_VMIDEXT_MSB
`undef CHIE_DAT_FLIT_DATA_DVM_VMIDEXT_RANGE
`undef CHIE_SNP_FLIT_ADDR_DVM_PAD_WIDTH
`undef CHIE_SNP_FLIT_ADDR_DVM_PAD_LSB
`undef CHIE_SNP_FLIT_ADDR_DVM_PAD_MSB
`undef CHIE_SNP_FLIT_ADDR_DVM_PAD_RANGE
`undef CHIE_SNP_FLIT_ADDR_DVM_PARTNUM_WIDTH
`undef CHIE_SNP_FLIT_ADDR_DVM_PARTNUM_LSB
`undef CHIE_SNP_FLIT_ADDR_DVM_PARTNUM_MSB
`undef CHIE_SNP_FLIT_ADDR_DVM_PARTNUM_RANGE
`undef CHIE_SNP_FLIT_ADDR_DVM_VAVALID_WIDTH
`undef CHIE_SNP_FLIT_ADDR_DVM_VAVALID_LSB
`undef CHIE_SNP_FLIT_ADDR_DVM_VAVALID_MSB
`undef CHIE_SNP_FLIT_ADDR_DVM_VAVALID_RANGE
`undef CHIE_SNP_FLIT_ADDR_DVM_VMIDVALID_WIDTH
`undef CHIE_SNP_FLIT_ADDR_DVM_VMIDVALID_LSB
`undef CHIE_SNP_FLIT_ADDR_DVM_VMIDVALID_MSB
`undef CHIE_SNP_FLIT_ADDR_DVM_VMIDVALID_RANGE
`undef CHIE_SNP_FLIT_ADDR_DVM_ASIDVALID_WIDTH
`undef CHIE_SNP_FLIT_ADDR_DVM_ASIDVALID_LSB
`undef CHIE_SNP_FLIT_ADDR_DVM_ASIDVALID_MSB
`undef CHIE_SNP_FLIT_ADDR_DVM_ASIDVALID_RANGE
`undef CHIE_SNP_FLIT_ADDR_DVM_SECURE_WIDTH
`undef CHIE_SNP_FLIT_ADDR_DVM_SECURE_LSB
`undef CHIE_SNP_FLIT_ADDR_DVM_SECURE_MSB
`undef CHIE_SNP_FLIT_ADDR_DVM_SECURE_RANGE
`undef CHIE_SNP_FLIT_ADDR_DVM_HYP_WIDTH
`undef CHIE_SNP_FLIT_ADDR_DVM_HYP_LSB
`undef CHIE_SNP_FLIT_ADDR_DVM_HYP_MSB
`undef CHIE_SNP_FLIT_ADDR_DVM_HYP_RANGE
`undef CHIE_SNP_FLIT_ADDR_DVM_TYPE_WIDTH
`undef CHIE_SNP_FLIT_ADDR_DVM_TYPE_LSB
`undef CHIE_SNP_FLIT_ADDR_DVM_TYPE_MSB
`undef CHIE_SNP_FLIT_ADDR_DVM_TYPE_RANGE
`undef CHIE_SNP_FLIT_ADDR_DVM_VMID_WIDTH
`undef CHIE_SNP_FLIT_ADDR_DVM_VMID_LSB
`undef CHIE_SNP_FLIT_ADDR_DVM_VMID_MSB
`undef CHIE_SNP_FLIT_ADDR_DVM_VMID_RANGE
`undef CHIE_SNP_FLIT_ADDR_DVM_ASID_WIDTH
`undef CHIE_SNP_FLIT_ADDR_DVM_ASID_LSB
`undef CHIE_SNP_FLIT_ADDR_DVM_ASID_MSB
`undef CHIE_SNP_FLIT_ADDR_DVM_ASID_RANGE
`undef CHIE_SNP_FLIT_ADDR_DVM_S2S1_WIDTH
`undef CHIE_SNP_FLIT_ADDR_DVM_S2S1_LSB
`undef CHIE_SNP_FLIT_ADDR_DVM_S2S1_MSB
`undef CHIE_SNP_FLIT_ADDR_DVM_S2S1_RANGE
`undef CHIE_SNP_FLIT_ADDR_DVM_L_WIDTH
`undef CHIE_SNP_FLIT_ADDR_DVM_L_LSB
`undef CHIE_SNP_FLIT_ADDR_DVM_L_MSB
`undef CHIE_SNP_FLIT_ADDR_DVM_L_RANGE
`undef CHIE_SNP_FLIT_ADDR_DVM_PART1ADDR_WIDTH
`undef CHIE_SNP_FLIT_ADDR_DVM_PART1ADDR_LSB
`undef CHIE_SNP_FLIT_ADDR_DVM_PART1ADDR_MSB
`undef CHIE_SNP_FLIT_ADDR_DVM_PART1ADDR_RANGE
`undef CHIE_SNP_FLIT_ADDR_DVM_TMP_PAD_WIDTH
`undef CHIE_SNP_FLIT_ADDR_DVM_TMP_PAD_LSB
`undef CHIE_SNP_FLIT_ADDR_DVM_TMP_PAD_MSB
`undef CHIE_SNP_FLIT_ADDR_DVM_TMP_PAD_RANGE
`undef CHIE_SNP_FLIT_ADDR_DVM_TMP_PART2ADDR_WIDTH
`undef CHIE_SNP_FLIT_ADDR_DVM_TMP_PART2ADDR_LSB
`undef CHIE_SNP_FLIT_ADDR_DVM_TMP_PART2ADDR_MSB
`undef CHIE_SNP_FLIT_ADDR_DVM_TMP_PART2ADDR_RANGE
`undef CHIE_MEMATTR_EARLYWRACK_WIDTH
`undef CHIE_MEMATTR_EARLYWRACK_LSB
`undef CHIE_MEMATTR_EARLYWRACK_MSB
`undef CHIE_MEMATTR_EARLYWRACK_RANGE
`undef CHIE_MEMATTR_DEVICE_WIDTH
`undef CHIE_MEMATTR_DEVICE_LSB
`undef CHIE_MEMATTR_DEVICE_MSB
`undef CHIE_MEMATTR_DEVICE_RANGE
`undef CHIE_MEMATTR_CACHEABLE_WIDTH
`undef CHIE_MEMATTR_CACHEABLE_LSB
`undef CHIE_MEMATTR_CACHEABLE_MSB
`undef CHIE_MEMATTR_CACHEABLE_RANGE
`undef CHIE_MEMATTR_ALLOCATE_WIDTH
`undef CHIE_MEMATTR_ALLOCATE_LSB
`undef CHIE_MEMATTR_ALLOCATE_MSB
`undef CHIE_MEMATTR_ALLOCATE_RANGE
`undef CHIE_MEMATTR_WIDTH
`undef CHIE_MEMATTR_LSB
`undef CHIE_MEMATTR_MSB
`undef CHIE_MEMATTR_RANGE
`undef CHIE_SNP_RESP_I
`undef CHIE_SNP_RESP_SC
`undef CHIE_SNP_RESP_UC_UD
`undef CHIE_SNP_RESP_SD
`undef CHIE_SNP_RESP_I_PD
`undef CHIE_SNP_RESP_SC_PD
`undef CHIE_SNP_RESP_UC_PD
`undef CHIE_COMP_RESP_I
`undef CHIE_COMP_RESP_SC
`undef CHIE_COMP_RESP_UC
`undef CHIE_COMP_RESP_UD_PD
`undef CHIE_COMP_RESP_SD_PD
`undef CHIE_WRDATA_RESP_I
`undef CHIE_WRDATA_RESP_SC
`undef CHIE_WRDATA_RESP_UC
`undef CHIE_WRDATA_RESP_UD_PD
`undef CHIE_WRDATA_RESP_SD_PD
`undef CHIE_DATASOURCE_DEFAULT
`undef CHIE_DATASOURCE_PEER_CPU_CACHE
`undef CHIE_DATASOURCE_LOCAL_CLUSTER_CACHE
`undef CHIE_DATASOURCE_ICN_CACHE
`undef CHIE_DATASOURCE_PEER_CLUSTER_CACHE
`undef CHIE_DATASOURCE_REMOTE_CHIP_CACHE
`undef CHIE_DATASOURCE_LOCAL_CLUSTER_CACHE_UNUSED_PREFETCH
`undef CHIE_DATASOURCE_ICN_CACHE_UNUSED_PREFETCH
`undef CHIE_TXLA_STOP
`undef CHIE_TXLA_ACTIVATE
`undef CHIE_TXLA_RUN
`undef CHIE_TXLA_DEACTIVATE
`undef CHIE_RXLA_STOP
`undef CHIE_RXLA_ACTIVATE
`undef CHIE_RXLA_RUN
`undef CHIE_RXLA_DEACTIVATE

`endif // CHIE_DEFINES_UNDEFINE
