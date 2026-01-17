# Hardware Digital Systems I: 32-bit Neural Network Accelerator (RISC-V Based)

[![Verilog](https://img.shields.io/badge/HDL-Verilog-blue.svg)]()
[![Simulation](https://img.shields.io/badge/Tools-Icarus_Verilog_|_GTKWave-orange.svg)]()
[![Architecture](https://img.shields.io/badge/ISA-RISC--V-red.svg)]()

## 📌 Project Overview
Design and RTL implementation of a specialized **Hardware Accelerator** optimized for neural network computations. The core architecture follows the **RISC-V ISA** for instruction handling but is specifically tuned to accelerate **Multiply-Accumulate (MAC)** operations, which are the fundamental building blocks of AI inference.

---

## 🏗️ Architecture & Component Analysis

The system is built hierarchically to ensure high-speed data processing:

### 1. MAC-Optimized ALU
While supporting standard RISC-V arithmetic (ADD, SUB) and logical operations (AND, OR, XOR), the ALU is optimized for the mathematical requirements of neural processing, featuring zero and overflow detection for precision control.

### 2. Register File with Internal Forwarding
A 32-bit register bank featuring an **Internal Forwarding mechanism**. This allows the result of a calculation to be fed back into the next instruction immediately, preventing "stalls" during intensive neural network weight updates.

### 3. Dedicated Calculator Module (CALC)
A custom hardware block that interfaces with the ALU to execute multi-stage computational flows, managing internal status flags to ensure synchronized data output.

### 4. Processor Control Unit (FSM)
A robust **Finite State Machine** that manages the complete lifecycle of an instruction:
- **Fetch:** Instructions from ROM.
- **Decode:** Signal routing for operands.
- **Execute:** Final computation and write-back to the register file.



---

## 🔬 Performance & Verification
Validated using **Icarus Verilog** and **GTKWave**, the accelerator successfully executed complex instruction sequences with:
- **Zero Timing Faults:** Confirmed through rigorous waveform analysis.
- **High Throughput:** Achieved by resolving data hazards via the internal forwarding logic in the Register File.
- **Accuracy:** Full verification of the 32-bit data path under various load scenarios.
