ABLA_ROOT ?= ../ablac
ABLA_COMPILER ?= $(ABLA_ROOT)/build/ablac
WAT2WASM ?= wat2wasm
RUN_TEST := $(if $(ABLA_TEST_LD_LIBRARY_PATH),env LD_LIBRARY_PATH=$(ABLA_TEST_LD_LIBRARY_PATH),)

.PHONY: build build-rust build-wat build-abla build-digital-product test-digital-product deploy-rust deploy-wat deploy-abla

build: build-rust build-wat build-abla build-digital-product

build-rust:
	cargo build --release --target wasm32-unknown-unknown -p micro-example-hello
	mkdir -p build hello-rust/.micro/build
	cp target/wasm32-unknown-unknown/release/micro_example_hello.wasm build/hello-rust.wasm
	cp build/hello-rust.wasm hello-rust/.micro/build/app.wasm

build-wat:
	mkdir -p build hello-wat/.micro/build
	$(WAT2WASM) hello-wat/hello.wat -o build/hello-wat.wasm
	cp build/hello-wat.wasm hello-wat/.micro/build/app.wasm

build-abla:
	ABLA_SYSROOT=$(ABLA_ROOT) $(ABLA_COMPILER) build hello-abla/build.ab -o build/hello-abla-builder --no-cache
	mkdir -p hello-abla/.micro/build
	cp build/hello-abla.wasm hello-abla/.micro/build/app.wasm

build-digital-product: test-digital-product
	mkdir -p build
	ABLA_SYSROOT=$(ABLA_ROOT) $(ABLA_COMPILER) build digital-product-build.ab -o build/digital-product-builder --no-cache

test-digital-product:
	mkdir -p build
	ABLA_SYSROOT=$(ABLA_ROOT) $(ABLA_COMPILER) build digital-product-html-test.ab -o build/digital-product-html-test --no-cache
	$(RUN_TEST) build/digital-product-html-test

deploy-rust: build-rust
	cd hello-rust && micro build && micro deploy hello-rust

deploy-wat: build-wat
	cd hello-wat && micro build && micro deploy hello-wat

deploy-abla: build-abla
	cd hello-abla && micro build && micro deploy hello-abla
