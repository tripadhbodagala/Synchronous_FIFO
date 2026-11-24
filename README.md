# Synchronous FIFO: UVM Verification Environment

A UVM testbench for a 16-deep, 4-bit-wide synchronous FIFO written in SystemVerilog. It includes a self-checking scoreboard with a reference model, a directed and constrained-random sequence, and functional coverage.

## Design Under Test

`sync_fifo` is a single-clock FIFO.

| Parameter | Value |
|-----------|-------|
| Depth | 16 entries |
| Data width | 4 bits |
| Pointers | 5-bit read and write pointers (extra MSB distinguishes full from empty) |
| Read output | Registered: `dout` is valid the cycle after an accepted read |
| Flags | `full` and `empty` are combinational from the pointers |
| Reset | Synchronous, active high; clears pointers, memory and `dout` |

**Ports:** `clk, rst, we, re, din[3:0]` in; `dout[3:0], full, empty` out.

**Behaviour:**
- A write is accepted when `we && !full`.
- A read is accepted when `re && !empty`.
- Writes at full and reads at empty are ignored.

## Testbench Architecture

```
test
 └── environment
      ├── agent
      │    ├── sequencer ── driver ──► DUT (via fifo_if, drv_cb)
      │    └── monitor   ◄── DUT      (via fifo_if, mon_cb)
      └── scoreboard  ◄── monitor (analysis port → uvm_tlm_analysis_fifo)
```

| Component | Role |
|-----------|------|
| `fifo_if` | Interface with `drv_cb` / `mon_cb` clocking blocks (1-unit skew) and modports |
| `fifo_txn` | Sequence item: `rst, we, re, din` (random) plus observed `dout, full, empty` |
| `fifo_cfg` | Agent config object: holds the virtual interface and active/passive mode |
| `env_config` | Environment config: enables the agent and scoreboard, carries `fifo_cfg` |
| `driver` | Applies one transaction per clock; holds reset for the first cycles of the run |
| `monitor` | Samples every clock edge and publishes a transaction through an analysis port |
| `sequencer` | Standard `uvm_sequencer` for `fifo_txn` |
| `agent` | Builds the monitor always, and the driver and sequencer when active |
| `sequencee` | The stimulus sequence (see below) |
| `scoreboard` | Reference-model checker plus functional coverage |
| `environment` | Builds the agent and scoreboard, connects the monitor to the scoreboard |
| `test` | Fetches the virtual interface, builds the config objects, runs the sequence |
| `fifo_pkg` | Package that includes all the classes in dependency order |
| `top` | Instantiates the clock, interface and DUT, and calls `run_test("test")` |

## Stimulus (`sequencee`)

1. **Fill:** 18 writes (16 to fill, 2 overflow attempts).
2. **Drain:** 18 reads (16 to empty, 2 underflow attempts).
3. **Mixed random traffic:** 200 cycles, write-biased (60 / 40) and read-biased (40 / 60) with reset low.
4. **Reset while full:** fill, then assert reset.
5. **Reset while partially full:** write 5 entries, then assert reset.
6. **Reset mid-traffic:** 20 random cycles, then assert reset.
7. **Idle cycles** after the final reset.

## Checking

The scoreboard keeps a queue as a reference model and processes one transaction per clock.

- **Flags:** `full` and `empty` are compared against the model's state before the edge.
- **Data:** when a read is accepted at one edge, the expected value is held and compared against `dout` at the next sample, because the DUT output is registered.
- **Reset:** the model is cleared and any pending data check is dropped. Samples before the first reset are ignored.
- **Final report:** `TEST PASSED` is printed only if checks ran and none failed. If nothing reached the scoreboard, it reports an error.

## Functional Coverage

`fifo_cg` (sampled every non-reset cycle):
- Write and read activity.
- Occupancy bins: empty, low (1-4), mid (5-11), high (12-15), full.
- Occupancy transitions: first write, last read, becomes full, leaves full.
- `full` and `empty` flag values.
- Every data value written and every data value read back.
- Cross of write × read × occupancy (20 bins), including overflow and underflow attempts and simultaneous read and write.

`reset_cg`: occupancy at the time of reset (empty, partial, full).

Coverage percentages are printed in `report_phase`.

## File Layout

Compile in this order:

```
sync_fifo.sv     DUT
fifo_if.sv       interface
fifo_pkg.sv      package (includes the files below)
  fifo_txn.sv
  fifo_cfg.sv
  env_config.sv
  driver.sv
  monitor.sv
  sequencer.sv
  agent.sv
  sequencee.sv
  scoreboard.sv
  environment.sv
  test.sv
top.sv           top-level module
```

`fifo_uvm_tb_corrected.sv` contains all of these in one file, split by `// ===== FILE: name.sv` markers.

## Running

Any UVM-capable simulator works. Example with Synopsys VCS (adjust for your tool and UVM setup):

```
vcs -sverilog -ntb_opts uvm -timescale=1ns/1ps \
    sync_fifo.sv fifo_if.sv fifo_pkg.sv top.sv -top top
./simv +UVM_TESTNAME=test
```

When compiled with `VCS` defined, `top.sv` dumps FSDB waveforms (`$fsdbDumpvars`). Remove or replace that block if you use another simulator.

## Expected Result

A clean run ends with:

```
SB: PASS=<n> FAIL=0, left in model=<k>
COV: fifo_cg=<x>%  reset_cg=<y>%
SB: TEST PASSED
```

## Notes

- All source files use `` `timescale 1ns/1ps ``.
- The RTL resets every memory location, which synthesizes to registers rather than a RAM. Remove the reset loop if you want a memory-style implementation.
