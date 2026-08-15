use base64::Engine as _;
use micro_guest::{MicroRequest, MicroResponse, export_micro};

fn handle(request: MicroRequest) -> MicroResponse {
    let body = format!("hello from micro: {} {}\n", request.method, request.path);
    MicroResponse {
        status: 200,
        headers: vec![("content-type".into(), "text/plain; charset=utf-8".into())],
        body_base64: base64::engine::general_purpose::STANDARD.encode(body),
    }
}

export_micro!(handle);
