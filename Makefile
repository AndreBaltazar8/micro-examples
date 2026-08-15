ABLA_ROOT ?= ../ablac
ABLA_COMPILER ?= $(ABLA_ROOT)/build/ablac

.PHONY: build build-rust build-wat build-abla deploy-rust deploy-wat deploy-abla

build: build-rust build-wat build-abla

build-rust:
	cargo build --release --target wasm32-unknown-unknown -p micro-example-hello
	mkdir -p build
	cp target/wasm32-unknown-unknown/release/micro_example_hello.wasm build/hello-rust.wasm

build-wat:
	mkdir -p build
	wat2wasm hello-wat/hello.wat -o build/hello-wat.wasm

build-abla:
	ABLA_SYSROOT=$(ABLA_ROOT) $(ABLA_COMPILER) build hello-abla/build.ab -o build/hello-abla-builder --no-cache

deploy-rust: build-rust
	micro deploy hello-rust build/hello-rust.wasm

deploy-wat: build-wat
	micro deploy hello-wat build/hello-wat.wasm

deploy-abla: build-abla
	micro deploy hello-abla build/hello-abla.wasm
