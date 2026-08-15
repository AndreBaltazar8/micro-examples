//! Minimal Rust support for the `micro.wasm.v1` ABI.
//!
//! A guest exports exactly one handler with `export_micro!(handler)`. The
//! runtime provides no imports, including WASI.

use serde::{Deserialize, Serialize};

#[derive(Debug, Deserialize)]
pub struct MicroRequest {
    pub method: String,
    pub path: String,
    pub query: String,
    pub headers: Vec<(String, String)>,
    pub body_base64: String,
}

#[derive(Debug, Serialize)]
pub struct MicroResponse {
    pub status: u16,
    pub headers: Vec<(String, String)>,
    pub body_base64: String,
}

#[doc(hidden)]
pub fn decode_request(pointer: i32, length: i32) -> Result<MicroRequest, MicroResponse> {
    if pointer < 0 || length < 0 {
        return Err(error_response("invalid request memory range"));
    }
    // The host wrote exactly `length` initialized bytes after calling
    // `micro_alloc`; both values are checked above before this guest reads them.
    let bytes = unsafe { std::slice::from_raw_parts(pointer as *const u8, length as usize) };
    serde_json::from_slice(bytes).map_err(|_| error_response("invalid request JSON"))
}

#[doc(hidden)]
pub fn encode_response(response: MicroResponse) -> i64 {
    let mut encoded = serde_json::to_vec(&response)
        .unwrap_or_else(|_| br#"{"status":500,"headers":[],"body_base64":""}"#.to_vec());
    let pointer = encoded.as_mut_ptr() as usize as u32;
    let length = encoded.len() as u32;
    std::mem::forget(encoded);
    ((pointer as i64) << 32) | i64::from(length)
}

fn error_response(message: &str) -> MicroResponse {
    MicroResponse {
        status: 400,
        headers: vec![("content-type".into(), "text/plain; charset=utf-8".into())],
        body_base64: base64::Engine::encode(
            &base64::engine::general_purpose::STANDARD,
            message.as_bytes(),
        ),
    }
}

#[macro_export]
macro_rules! export_micro {
    ($handler:path) => {
        #[unsafe(no_mangle)]
        pub extern "C" fn micro_alloc(length: i32) -> i32 {
            if length < 0 {
                return -1;
            }
            let mut bytes = Vec::<u8>::with_capacity(length as usize);
            let pointer = bytes.as_mut_ptr() as usize as i32;
            std::mem::forget(bytes);
            pointer
        }

        #[unsafe(no_mangle)]
        pub extern "C" fn micro_handle(pointer: i32, length: i32) -> i64 {
            let response = match $crate::decode_request(pointer, length) {
                Ok(request) => $handler(request),
                Err(response) => response,
            };
            $crate::encode_response(response)
        }
    };
}
