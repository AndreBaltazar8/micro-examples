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

The local `micro-guest` crate is intentionally tiny so the complete host/guest boundary can be read in one file. It gives the handler an ordinary typed request with decoded body bytes and accepts a typed response; JSON, base64, allocation, and ABI exports stay inside the adapter.

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

[`hello-abla/handler.ab`](hello-abla/handler.ab) is the complete application: one ordinary `handle(request: MicroRequest): MicroResponse` function using Abla's `#$jsons` subparser. The JSON literal is validated and encoded at build time, while text and JSON response helpers keep status, headers, and body typed. Base64 appears only inside the wire adapter because the JSON envelope must carry arbitrary response bytes losslessly.

[`hello-abla/micro.ab`](hello-abla/micro.ab) defines those application types. [`hello-abla/guest.ab`](hello-abla/guest.ab) is the reusable low-level adapter that parses the request, owns the pointer/linear-memory exchange, and exports the core-WASM ABI. It uses Abla's forward-only JSON reader and streaming encoder: fields are expressed by name, strings use the standard escaping rules, headers remain a validated lazy slice, and no dynamic JSON tree or handwritten wire punctuation is needed. The resulting module has no imports or WASI dependency.

### Measured guest profile

The final all-Abla runtime build was measured with Wasmtime fuel enabled on an
empty-body `GET /` request. The Rust module uses the same request, response,
runner, and `micro.wasm.v1` boundary.

| Guest | Module | Allocate fuel | Handle fuel | Total fuel | Peak memory | Steady wall time |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Abla | 60,355 bytes | 68 | 57,590 | 57,658 | 1,114,112 bytes | 23–30 µs |
| Rust | 156,354 bytes | 457 | 13,457 | 13,914 | 1,179,648 bytes | 26–33 µs |

Abla's module is 61% smaller and its observed wall time is comparable, while
its dynamic Wasmtime fuel remains 4.14× Rust's. The optimized Abla path reduced
fuel by 33.8% from the 87,127-fuel all-Abla starting point. Stage profiling
attributes 99.9% of the remaining fuel to request decoding, handler execution,
and response encoding inside `micro_handle`, rather than instantiation or the
guest allocator.

## Runtime contract

- exports: `memory`, `micro_alloc(i32) -> i32`, `micro_handle(i32, i32) -> i64`
- request/response encoding: JSON in linear memory
- result packing: response pointer in the high 32 bits, response length in the low 32 bits
- imports: none, including no WASI or outbound network access

## License

MIT
