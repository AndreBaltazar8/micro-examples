use micro_guest::{MicroRequest, MicroResponse, export_micro};

fn handle(request: MicroRequest) -> MicroResponse {
    if request.method != "GET" {
        MicroResponse::text(405, "method not allowed\n")
    } else if request.path != "/" {
        MicroResponse::text(404, "not found\n")
    } else {
        MicroResponse::json(200, &serde_json::json!({ "message": "hello from Rust" }))
    }
}

export_micro!(handle);
