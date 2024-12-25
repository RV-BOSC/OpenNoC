# 1 OpenNoC 介绍

OpenNoC 是基于 AMBA CHI 协议实现的，协议版本为 0050E.b，用来进行连接多核、内存控制器和外设的一个总线。目前 OpenNoC 实现了 HNF, HNI, RNI 和 XP, 该仓库主要包含 HNF & HNI & RNI & SXP 源码以及一些 testbench.

# 2 目录说明
```
.
├── doc                       // design documents
│   ├── hnf                   // hnf design overview
├── README.md                 // README
└── rtl                       // verilog code
    ├── include               // header files, including macro definitions.
    ├── misc                  // SXP and miscellaneous files
    ├── src                   
    │   ├── hnf               // HN-F Component code
    │   ├── hni               // HN-I Component code
    │   └── hni               // RN-I Component code
    └── tb                    // test top
    └── case                  // test case
    └── Makefile              // compile script
    └── file_list_tb.f        // list of all src and header files

```
# 3 使用说明
  为确保正确使用相关内容，请阅读以下说明
## 3.1 参数配置说明
  以下是 SXP & HNF & HNI & RNI 的一些参数说明，使用者可以按照需求在例化相应模块时指定。
### 3.1.1 SXP 参数配置

目前 SXP 将REQ, RSP, DAT, SNP 都当做了相同处理，其中 CHI 中 snp 报文并没有 tgtid 字段，SXP 在标准的 snp 报文后增加了 tgtid 字段用作路由，长度固定为7bit。SXP 只是根据 tgtid 进行路由，并不对 flit 进行任何修改，包括snp报文.

SXP中代码只有单个通道的功能: `rtl/misc/chi_xp_channel.v` ,如何组织成一个SXP交给了使用者。使用时需要根据通道类型参数化配置 `FLIT_WIDTH` 和 `FLIT_TGT_OFFSET` (这个目前只有SNP通道需要配置，其他通道使用默认的4就好).

### 3.1.2 HNF 参数配置
以下是一些 HNF 参数配置，可根据需求修改 rtl/include/hnf_param.v 文件下的 HNF_PARAM 宏包含内容。除了以下说明的参数，HNF_PARAM 宏下的其他参数请使用默认值。需要额外说明的是 L3 CacheLineSize 固定为64字节。

* CHIE_REQ_ADDR_WIDTH_PARAM
  * REQ 报文地址位宽
* CHIE_SNP_ADDR_WIDTH_PARAM
  * SNP 报文地址位宽。CHI e.b 协议规定该值为 (CHIE_REQ_ADDR_WIDTH_PARAM-3)
* HNF_MSHR_RNF_NUM_PARAM
  * NoC 中 RNF 个数。
* RNF_NID_LIST_PARAM
  * NoC 中 RNF nodeid 列表
* HNF_NID_PARAM
  * HNF nodeid
* SNF_NID_PARAM
  * SNF nodeid
* XP_LCRD_NUM_PARAM
  * HNF 各通道的 L-Credit 最大计数值。最大值为15
* HNF_SF_ENTRIES_NUM_PARAM
  * Snoop Filter Entry 总数目
* HNF_SF_WAY_NUM_PARAM
  * Snoop Filter Way
* HNF_L3_CACHE_SIZE_PARAM
  * L3 Cache 总大小，单位为KB
* HNF_L3_WAY_NUM_PARAM
  * L3 Cache way

### 3.1.3 RNI 参数配置
以下是一些 RNI 参数配置，可根据需求修改 rtl/include/rni_param.v 文件下的 RNI_PARAM 宏包含内容。除了以下说明的参数，RNI_PARAM 宏下的其他参数请使用默认值。

* CHIE_NID_WIDTH_PARAM
  * NODEID 的位宽，CHI e.b 协议规定该值为（7-11）
* CHIE_REQ_ADDR_WIDTH_PARAM
  * REQ 报文地址位宽
* CHIE_SNP_ADDR_WIDTH_PARAM
  * SNP 报文地址位宽。CHI e.b 协议规定该值为 (CHIE_REQ_ADDR_WIDTH_PARAM-3)
* RNI_NID_PARAM
  * RNI nodeid
* HNF_NID_PARAM
  * HNF nodeid

## 3.2 RTL 编译说明
1. 'make com' 编译 file_list 内所有的文件。
2. 'make sim' 运行 testcases。
3. 'make run_dve' 查看波形图。
4. 'make clean' 清除掉所有编译和仿真生成的文件。
