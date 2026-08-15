(module
  (memory (export "memory") 1 128)
  (global $heap (mut i32) (i32.const 4096))
  (func (export "micro_alloc") (param $length i32) (result i32)
    (local $pointer i32)
    global.get $heap
    local.tee $pointer
    local.get $length
    i32.add
    global.set $heap
    local.get $pointer)
  (data (i32.const 0) "{\22status\22:200,\22headers\22:[[\22content-type\22,\22text/plain; charset=utf-8\22]],\22body_base64\22:\22aGVsbG8gZnJvbSBtaWNyby5kbwo=\22}")
  (func (export "micro_handle") (param i32 i32) (result i64)
    i64.const 116))
