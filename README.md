# TIMER_IP — Timer IP: Design and Verification

Build a Timer IP and verify it (by all just Verilog).

A 64-bit, AMBA APB-compliant, count-up Timer IP, fully designed and self-checked using plain Verilog — RTL, testbench, golden reference model and coverage closure, with no external verification framework.

**Course:** Foundation of IC Design — Ho Chi Minh University of Technology, Faculty of IC Design
**Instructor:** Mr. Kham Kha
**Author:** Nguyen Nhat Khanh

---

## Overview

This repository contains the complete micro-architecture design and verification closure of a 64-bit AMBA APB-compliant count-up Timer IP. The design features an 8-stage configurable clock prescaler, 64-bit compare-match interrupt generation with Write-1-to-Clear (RW1C) capability, debug halt support, and robust APB bus slave protocol handshaking (including wait states and slave error reporting).

The verification environment employs a cycle-accurate golden reference model and self-checking layered test sequences, achieving **100% code coverage** across statements, branches, conditions, expressions, and toggles.

### Background

Timers are indispensable hardware blocks in modern Systems-on-Chip (SoCs) and microcontrollers. They provide accurate time intervals for software delays, periodic tick interrupts for Real-Time Operating Systems (RTOS), and system event tracking. Designing a standard AMBA APB-compliant Timer IP offers practical insights into bus interfacing, configurable clock prescalers, hardware interrupt handling, and industrial design verification flows.

### Scope

**In scope**
- APB Slave 64-bit count-up Timer IP supporting byte strobe (`tim_pstrb`), 1-cycle wait state (`tim_pready`), error reporting (`tim_pslverr`), and debug halt mode.
- An 8-stage prescaler, 64-bit compare match, and a maskable level interrupt.
- A layered testbench with Golden Model checking, achieving 100% code coverage (Statement, Branch, Condition, FEC Expression, Toggle).

**Out of scope**
- Physical layout (synthesis, place-and-route), multi-channel PWM outputs, and input capture modes.

---

## Repository Structure

```
TIMER_IP/
├── rtl/   # Synthesizable RTL sub-modules and the timer_top integration
├── sim/   # Simulation scripts / Makefile for automated testing
└── tb/    # Testbench, golden reference model and verification sequences
```

**Tools and languages:** Verilog, QuestaSim/ModelSim (simulator, waveform viewer and coverage analysis engine), Make/Bash scripts for automated testing.

---

## Design and Verification Flow

1. **Specification Analysis** — define IP functional requirements and register maps.
2. **RTL Design** — implement synthesizable logic in Verilog.
3. **Verification Planning** — formulate the test plan with corner-case scenarios.
4. **Testbench Development** — construct bus drivers, monitors, and scoreboards.
5. **Simulation & Waveform Debug** — run simulations and debug functional bugs via waveforms.
6. **Coverage Closure** — refine stimulus iteratively to reach 100% code coverage.

---

## Interface

| Port | Dir. | Width | Description |
| :--- | :---: | :---: | :--- |
| `sys_clk` | Input | 1 | System clock |
| `sys_rst_n` | Input | 1 | Active-low asynchronous reset |
| `tim_psel` | Input | 1 | APB slave select |
| `tim_pwrite` | Input | 1 | APB transfer direction (1: Write, 0: Read) |
| `tim_penable` | Input | 1 | APB enable strobe (access phase) |
| `tim_paddr[11:0]` | Input | 12 | APB register address bus |
| `tim_pwdata[31:0]` | Input | 32 | APB write data bus |
| `tim_prdata[31:0]` | Output | 32 | APB read data bus |
| `tim_pstrb[3:0]` | Input | 4 | APB byte-write strobe signals |
| `tim_pready` | Output | 1 | APB transfer ready handshake |
| `tim_pslverr` | Output | 1 | APB slave error response |
| `tim_int` | Output | 1 | Active-high level timer interrupt output |
| `dbg_mode` | Input | 1 | Debug mode status input from system |

---

## Register Map

| Offset | Name | Width | Access | Description |
| :--- | :---: | :---: | :---: | :--- |
| 0x00 | TCR | 32 | RW | Timer Control Register |
| 0x04 | TDR0 | 32 | RW | Timer Data Register 0 (lower 32 bits) |
| 0x08 | TDR1 | 32 | RW | Timer Data Register 1 (upper 32 bits) |
| 0x0C | TCMP0 | 32 | RW | Timer Compare Register 0 (lower 32 bits) |
| 0x10 | TCMP1 | 32 | RW | Timer Compare Register 1 (upper 32 bits) |
| 0x14 | TIER | 32 | RW | Timer Interrupt Enable Register |
| 0x18 | TISR | 32 | RW1C | Timer Interrupt Status Register |
| 0x1C | THCSR | 32 | Mixed | Timer Halt Control Status Register |
| Others | Reserved | 32 | RAZ/WI | Unmapped address space |

Key behaviors:
- `TCR.div_val` (bits 11:8) selects the prescaler divisor from divide-by-1 up to divide-by-256; modifying `div_val` or `div_en` while `timer_en = 1` is prohibited and triggers a slave error.
- `TCR.timer_en` transitioning from High to Low clears TDR0/TDR1 back to their initial values.
- `TISR.int_st` is a Write-1-to-Clear (RW1C) pending bit set when `cnt == {TCMP1, TCMP0}`; the clear action has the highest priority.
- `THCSR.halt_req`/`halt_ack` support a debug halt mode, accepted only when `dbg_mode = 1`.

---

## Micro-architecture

The top-level `timer_top` integrates five sub-modules:

1. **`apb_slave`** — interfaces directly with the AMBA APB bus. Generates byte write strobes (`wr_en0/1/2/3`), a read-enable strobe (`rd_en`), implements the single-cycle wait state (`tim_pready`), and propagates slave errors (`tim_pslverr`).
2. **`register`** — houses configuration and status registers (TCR, TCMP0/1, TIER, TISR, THCSR). Performs address decoding, manages read-data multiplexing, checks access validity, and detects falling edges of `timer_en` (`neg_timer_en`).
3. **`cnt_ctrl`** — regulates counting rate and operational modes. Integrates prescaler logic to generate tick-enable pulses (`cnt_en`), manages debug halts (`halt_ack`), and triggers synchronous reset (`cnt_clr`).
4. **`cnt`** — holds the 64-bit count value partitioned across TDR0 and TDR1. Increments on `cnt_en`, synchronously resets on `cnt_clr`, and supports byte-masked APB writes when stopped.
5. **`interrupt`** — detects compare matches between the counter and comparator registers, asserts `int_st`, supports RW1C clearance, and drives the masked interrupt signal `tim_int`.

### Key behaviors
- **Prescaler division:** under division mode (`div_en = 1`), the counter increments once every 2^`div_val` clock cycles.
- **Halt mode:** when `dbg_mode = 1` and `halt_req = 1`, `halt_ack` asserts and internal ticking freezes, retaining the sub-cycle prescaler phase.
- **Interrupt generation:** when `cnt[63:0] == {TCMP1, TCMP0}`, `int_st` is set; if `int_en = 1`, `tim_int` asserts High immediately.

---

## Verification

### Approach
The verification environment is a self-checking architecture combining a bus functional model and a cycle-accurate golden reference model:

- **Golden Reference Model** — emulates registers, prescaler division, halt behavior, and interrupt states in parallel with the DUT to produce cycle-accurate expected values (`prdata_exp`, `pslverr_exp`, `tim_int_exp`).
- **Automated scoreboarding** — transaction outputs and interrupt assertions are checked automatically at every transfer end and clock edge; any mismatch immediately triggers a failure and terminates simulation.
- **Coverage closure** — directed corner-case stimulus drives statement, branch, condition, FEC expression, and toggle coverage to 100%.

### Verification plan categories
The VPlan covers register reset values, register read/write access, reserved address and bit-field behavior (RAZ/WI), byte-strobe isolation, counter control and configuration protection, APB protocol and access timing (including back-to-back and unaligned accesses), counter operation and clearing (including 64-bit overflow wraparound), interrupt logic (including RW1C and set/clear priority), debug halt behavior, and `tim_pslverr` error generation.

### Test results

```text
# -------------------------------------------------------------
#   REG_INT_CHK              -- PASSED
#   REG_RW_CHK               -- PASSED
#   REG_RESERVED_CHK         -- PASSED
#   REG_BYTE_ACCESS_CHK      -- PASSED
#   CNT_CTRL_CHECK           -- PASSED
#   APB_PROTOCOL_CHECK       -- PASSED
#   APB_MULTIPLE_ACCESS_CHECK-- PASSED
#   APB_UNALIGNED_CHECK      -- PASSED
#   CNT_COUNTING_CHK         -- PASSED
#   INTERRUPT_CHK            -- PASSED
#   CNT_HALT_CHECK           -- PASSED
#   APB_PSLVERR_CHECK        -- PASSED
# -------------------------------------------------------------
```

### Code coverage closure

| Module | Branches | Conditions | Expressions | Statements | Toggles |
| :--- | :---: | :---: | :---: | :---: | :---: |
| `apb_slave` | 100.00% | — | 100.00% | 100.00% | 100.00% |
| `register` | 100.00% | 100.00% | 100.00% | 100.00% | 100.00% |
| `cnt_ctrl` | 100.00% | — | 100.00% | 100.00% | 100.00% |
| `cnt` | 100.00% | — | 100.00% | 100.00% | 100.00% |
| `interrupt` | 100.00% | — | 100.00% | 100.00% | 100.00% |
| `timer_top` (top-level) | — | — | — | — | 100.00% |

All enabled coverage metrics — statement, branch, condition, FEC expression, and toggle — reach **100%** with zero misses across every module.

---

## Report

The full project report — including detailed RTL listings, waveforms, the complete Verification Plan (VPlan) matrix, and testbench source — is included in this repository.
