# Mesh Generator
Mesh Generator 主要可以根据用户自定义配置完成 Mesh XP 的自动连接工作, 用户只需要根据配置正确将 CHI 节点连接到 Mesh XP 上就可以工作.

# 使用说明
配置 mesh_xxx.json, 要求 Mesh 是一个矩形, 里面每个XP节点都必须配置. 下面以工具中的 mesh_2x2.json 为例:
```
{
    "XP0_0": {         //XP的名字,可以根据拓扑自定义,符合 verilog 实例名称就可以
        "X": 0,        //XP的X坐标,目前是支持3bit,即0-7
        "Y": 0,        //XP的Y坐标,目前是支持3bit,即0-7
        "P0": "RNF",   //P0的类型,目前支持 RNF, RNI, HNF, HNI, SNF, 当端口没有连接时,请配置为 NONE
        "P1": "NONE"
    },
    "XP1_0": {
        "X": 1,
        "Y": 0,
        "P0": "HNF",
        "P1": "NONE"
    },
    "XP0_1": {
        "X": 0,
        "Y": 1,
        "P0": "HNI",
        "P1": "NONE"
    },
    "XP1_1": {
        "X": 1,
        "Y": 1,
        "P0": "NONE",
        "P1": "NONE"
    }
}

```
根据配置生成 Mesh 网络:
```shell
./mesh_gen.py -f xxx.json
...
Generate Mesh Wrapper mesh_wrapper_xxx.sv
```
请将以下文件放入目标工程下: `mesh_wrapper_xxx.sv, chi_xp_node.sv, chi_xp_channel.v`
