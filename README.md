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

## Runtime contract

- exports: `memory`, `micro_alloc(i32) -> i32`, `micro_handle(i32, i32) -> i64`
- request/response encoding: JSON in linear memory
- result packing: response pointer in the high 32 bits, response length in the low 32 bits
- imports: none, including no WASI or outbound network access

## License

MIT
