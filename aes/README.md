# AES-128 encryption cores on FPGA

Synthesis results of Cyclone IV E EP4CE30F29C6 using Quartus Prime Lite 22.1.

| impl.     | LEs  | Regs | Memory (Kibits) | Fmax (MHz) | Cycles per block | Notes |
| -----     | ---: | ---- | --------------: | ---------- | ---------------- | ----- |
| tbox      | 1543 |  260 | 128 (8 * 16)    |            | 11  | Basic T-box implementation. |
| tboxdp    | 1543 |  260 |  64 (8 * 8)     |            | 11  | T-box using dual port memory. |
| tboxsync  |  547 |  260 |  68 (64 + 4)    | 169 MHz    | 12  | Key expansion using synchronous S-box. |
| basic     | 4946 |  260 |  0              |            | 11  | Basic S-box impl. using asynchronous lookup. Not suitable for FPGA. |
| sbox      |      |      |                 |            |     | Key expansion using synchronous S-box. |

