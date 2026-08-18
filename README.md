# Micro examples

Reviewed sites and small, auditable Wasm servers for [micro.do](https://micro.do). Build and deploy them with the public [`micro` CLI](https://github.com/microdotdo/micro-cli), directly or through the official [`micro-sites` skill](https://github.com/microdotdo/micro-mcp).

## Digital-product storefront

[`digital-product/`](digital-product/) is the product-level starting point. It
is a complete responsive storefront using the injected browser SDK for app
authentication, checkout, authoritative purchase state, and protected
downloads. Its small Abla Wasm server records trusted `purchase.completed` and
`schedule.triggered` events exactly once. The stable product is declared in
`micro.yaml`; the paid archive is never committed under `public/`.

```sh
cd digital-product
micro build
micro dev
```

Use this example when a harness is building a paid download or member library.
Use the smaller examples below when inspecting a particular guest-language
boundary.

The checked-in [`gallery.json`](digital-product/gallery.json) makes this the
first reviewed gallery candidate. It contains public descriptive metadata only;
after deploying the example as a public Micro, an operator records the exact
repository commit or review ticket as the consent receipt and curates that
immutable deployment through Micro's private gallery API. The candidate file
does not publish the entry, create a project, or reserve a slug.

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

If WABT is installed outside `PATH`, set `WAT2WASM=/absolute/path/to/wat2wasm`.
On systems where locally built Abla executables need an explicit OpenSSL
runtime path, set `ABLA_TEST_LD_LIBRARY_PATH=/path/to/openssl/lib` when running
the Make targets.

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

[`hello-abla/micro.ab`](hello-abla/micro.ab) defines those application types and the sole allowlisted host capability. [`hello-abla/guest.ab`](hello-abla/guest.ab) is the reusable low-level adapter that parses the request, owns the pointer/linear-memory exchange, and exports the core-WASM ABI. It uses Abla's forward-only JSON reader and streaming encoder: fields are expressed by name, strings use the standard escaping rules, headers remain a validated lazy slice, and no dynamic JSON tree or handwritten wire punctuation is needed. The resulting module has no WASI dependency. It imports only `env::micro_platform_call(i64, i64, i64, i64) -> i64`, which accepts bounded JSON and receives runner-derived project, environment, and app-user scope.

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
guest allocator. Binaryen's static metrics count 27,709 operations across 25
Abla functions versus 45,328 operations across 235 Rust functions. The
opposite dynamic-fuel result therefore comes from the executed adapter paths
and their value/memory work, not from a larger static Abla program.

## Runtime contract

- exports: `memory`, `micro_alloc(i32) -> i32`, `micro_handle(i32, i32) -> i64`
- request/response encoding: JSON in linear memory
- result packing: response pointer in the high 32 bits, response length in the low 32 bits
- imports: none, or the sole typed `env::micro_platform_call` host capability; never WASI or outbound network access

## License

MIT
