# Stillroom digital product

A reviewed static-shell Micro that uses the injected browser SDK for app
accounts, authoritative purchase state, Stripe Checkout, and an
entitlement-checked download. It intentionally contains no payment provider
code and no protected file under `public/`.

```sh
micro build
micro dev
micro deploy --preview
micro deploy stillroom-presets
micro products sync
micro files upload preset-files ./quiet-light.zip --entitlement preset-files
```

Use a non-sensitive test archive locally. Upload the real product only through
the dashboard or CLI after deployment. Product synchronization is additive and
does not delete remote resources.
