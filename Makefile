.PHONY: build build-rust build-wat deploy-rust deploy-wat

build: build-rust build-wat

build-rust:
	cargo build --release --target wasm32-unknown-unknown -p micro-example-hello
	mkdir -p build
	cp target/wasm32-unknown-unknown/release/micro_example_hello.wasm build/hello-rust.wasm

build-wat:
	mkdir -p build
	wat2wasm hello-wat/hello.wat -o build/hello-wat.wasm

deploy-rust: build-rust
	micro deploy hello-rust build/hello-rust.wasm

deploy-wat: build-wat
	micro deploy hello-wat build/hello-wat.wasm
