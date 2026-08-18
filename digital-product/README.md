# Stillroom digital product

A reviewed static-shell Micro backed by a small Abla Wasm server. The browser
uses the injected SDK for app accounts, authoritative purchase state, Stripe
Checkout, and an entitlement-checked download. The server handles the trusted
`purchase.completed` and `schedule.triggered` application events idempotently
with create-only project records keyed by stable event identity. It intentionally
contains no payment provider code or protected file under `public/`.

```sh
micro build
micro dev
micro deploy --preview
micro deploy stillroom-presets
micro products sync
micro files upload preset-files ./quiet-light.zip --entitlement preset-files
micro schedules set catalog-refresh --every-minutes 1440 --payload-file schedule.json
```

Use a non-sensitive test archive locally. Upload the real product only through
the dashboard or CLI after deployment. Product synchronization is additive and
does not delete remote resources. Schedule payloads are non-secret configuration;
external traffic cannot reach the runner-owned event route, and the handler
still deduplicates every at-least-once delivery by `x-micro-event-id`.
