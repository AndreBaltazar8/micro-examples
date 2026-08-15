# micro examples

Small, auditable functions for [micro.do](https://micro.do). Each module implements the import-free `micro.wasm.v1` ABI and can be deployed with the public [`micro` CLI](https://github.com/AndreBaltazar8/micro-cli).

## Rust hello

Install Rust 1.90 or newer and the WebAssembly target:

```sh
rustup target add wasm32-unknown-unknown
make build-rust
micro login
micro deploy hello-rust build/hello-rust.wasm
curl https://hello-rust.micro.do/
```

The local `micro-guest` crate is intentionally tiny so the complete host/guest boundary can be read in one file.

## WAT hello

With WABT's `wat2wasm` installed:

```sh
make build-wat
micro deploy hello-wat build/hello-wat.wasm
curl https://hello-wat.micro.do/
```

The WAT version returns a fixed response and is useful for inspecting the ABI without a compiler toolchain.

## Abla hello

With an [`ablac`](https://github.com/AndreBaltazar8/ablac) checkout next to this repository:

```sh
make -C ../ablac ablac
make build-abla
micro deploy hello-abla build/hello-abla.wasm
curl https://hello-abla.micro.do/
```

[`hello-abla/handler.ab`](hello-abla/handler.ab) is the complete application: one ordinary `handle(request: MicroRequest): MicroResponse` function using Abla's `$json` subparser. Text and JSON response helpers keep status, headers, and body typed; base64 appears only inside the wire adapter because the JSON envelope must carry arbitrary response bytes losslessly.

[`hello-abla/micro.ab`](hello-abla/micro.ab) defines those application types. [`hello-abla/guest.ab`](hello-abla/guest.ab) is the reusable low-level adapter that parses the request, owns the pointer/linear-memory exchange, and exports the core-WASM ABI. The resulting module has no imports or WASI dependency.

Abla currently exports foreign scalars as `i64`, so micro accepts the equivalent `micro_alloc(i64) -> i64` and `micro_handle(i64, i64) -> i64` form while retaining the same 32-bit memory offsets and packed response layout.

## Runtime contract

- exports: `memory`, `micro_alloc(i32) -> i32`, `micro_handle(i32, i32) -> i64`
- Abla scalar form: `micro_alloc(i64) -> i64`, `micro_handle(i64, i64) -> i64`
- request/response encoding: JSON in linear memory
- result packing: response pointer in the high 32 bits, response length in the low 32 bits
- imports: none, including no WASI or outbound network access

## License

MIT
