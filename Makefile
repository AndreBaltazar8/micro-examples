ABLA_ROOT ?= ../ablac
ABLA_COMPILER ?= $(ABLA_ROOT)/build/ablac

.PHONY: build build-rust build-wat build-abla build-digital-product test-digital-product deploy-rust deploy-wat deploy-abla

build: build-rust build-wat build-abla build-digital-product

build-rust:
	cargo build --release --target wasm32-unknown-unknown -p micro-example-hello
	mkdir -p build
	cp target/wasm32-unknown-unknown/release/micro_example_hello.wasm build/hello-rust.wasm

build-wat:
	mkdir -p build
	wat2wasm hello-wat/hello.wat -o build/hello-wat.wasm

build-abla:
	ABLA_SYSROOT=$(ABLA_ROOT) $(ABLA_COMPILER) build hello-abla/build.ab -o build/hello-abla-builder --no-cache

build-digital-product: test-digital-product
	mkdir -p build
	ABLA_SYSROOT=$(ABLA_ROOT) $(ABLA_COMPILER) build digital-product-build.ab -o build/digital-product-builder --no-cache

test-digital-product:
	mkdir -p build
	ABLA_SYSROOT=$(ABLA_ROOT) $(ABLA_COMPILER) build digital-product-html-test.ab -o build/digital-product-html-test --no-cache
	build/digital-product-html-test

deploy-rust: build-rust
	micro deploy hello-rust build/hello-rust.wasm

deploy-wat: build-wat
	micro deploy hello-wat build/hello-wat.wasm

deploy-abla: build-abla
	micro deploy hello-abla build/hello-abla.wasm
