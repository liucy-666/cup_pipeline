# cup_pipeline

一个基于 **SystemVerilog** 实现的五级流水线（IF / ID / EX / MEM / WB）RISC 处理器项目，用于课程设计与流水线机制学习。该工程完整实现了数据冒险与控制冒险处理，并通过仿真验证了功能正确性。

---

## ✨ 项目特性

* 五级流水线架构：IF / ID / EX / MEM / WB
* 支持常见算术、访存与控制流指令
* 完整的数据前递（Forwarding）机制
* Load-use 冒险自动 Stall
* 分支 / 跳转（`beq` / `jal` / `jr`）支持与 Flush
* 可观测性强：丰富的 `$display` 调试输出
* 纯 RTL 设计，适合 Vivado / ModelSim / iverilog 仿真



## 🧠 指令支持情况（已验证）

### 算术 / 逻辑指令

* `add`
* `addi`

### 访存指令

* `lw`
* `sw`

### 控制流指令

* `beq`
* `jal`
* `jr`

> `jal` 指令可正确将 `PC + 4` 写入 `$ra`（寄存器 31）


## 冒险处理机制

### 1️ 数据冒险（Data Hazard）

#### Forwarding（旁路）

* EX/MEM → EX
* MEM/WB → EX
* 支持 rs1 / rs2 独立前递

#### Load-use Hazard

* 当 EX 阶段为 `lw` 且 ID 阶段立即使用结果时：

  * PC 暂停
  * IF/ID 保持
  * ID/EX 插入 bubble



### 2️ 控制冒险（Control Hazard）

* 分支与跳转在 **EX 阶段** 决定
* 跳转成立时：

  * PC 被改写
  * IF/ID 阶段被 Flush
* 未采用分支预测，使用经典 stall + flush 策略



##  模块结构说明

```
├── top.sv          # 顶层模块，连接所有流水级与控制逻辑
├── imem.sv         # 指令存储器（指令直接写在 RTL 中）
├── dmem.sv         # 数据存储器
├── regfile.sv      # 寄存器文件
├── if_id.sv        # IF/ID 流水线寄存器
├── id_ex.sv        # ID/EX 流水线寄存器
├── ex_mem.sv       # EX/MEM 流水线寄存器
├── mem_wb.sv       # MEM/WB 流水线寄存器
├── forward.sv      # 前递单元
├── hazard.sv       # 冒险检测与 stall 控制
├── alu.sv          # 算术逻辑单元
├── controller.sv   # 指令译码与控制信号生成
└── testbench.sv    # 仿真测试平台
```

##  仿真与调试

* 使用 `testbench.sv` 作为顶层
* 通过 `$display` 观察：

  * PC 变化
  * 写回寄存器行为
  * Forwarding 选择
  * Stall / Flush 触发时机

### 示例调试输出

```
[RF WRITE] wa=8 wd=00000005
[FWD] A=01 B=10
[STALL] PC held
[FLUSH_if_id] at PC=00000028
```

 ### 不足之处与缺陷:
 
* 未实现分支预测
* 未实现 Cache / TLB
* 未支持异常与中断
* 单发射、顺序执行流水线


总结

本项目借着数字逻辑课程大作业的机会，实现了一颗功能完整、结构清晰的五级流水线处理器，目前仿真结果与预期一致，如果后续发现用其他的imem.sv仿真不一致，可以提交请求告诉我，欢迎各位老师同学指点QAQ！
