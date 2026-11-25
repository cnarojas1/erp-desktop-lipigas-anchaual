# Login browser regression checks

Use Node 22+ and Playwright Chromium in an isolated browser (no personal profile).
Install Playwright outside this repository if desired:

```sh
npm install --prefix "$TMPDIR/lipigas-login-qa" playwright
"$TMPDIR/lipigas-login-qa/node_modules/.bin/playwright" install chromium
export PLAYWRIGHT_MODULE="$TMPDIR/lipigas-login-qa/node_modules/playwright"
python3 -m http.server 8765 --bind 127.0.0.1
# In another terminal, with the same PLAYWRIGHT_MODULE:
node tests/login.mjs
node tests/cache-update.mjs
BASE_URL=https://cnarojas1.github.io/erp-desktop-lipigas-anchaual/ node tests/login.mjs
```

`login.mjs` checks demo login, wrong-password rejection, account persistence
and login after reload, landing routing, delayed initialization, visible storage
failure, non-destructive v1 migration (inline and external keys), preservation of
an existing admin password and product, and offline cached login.
`cache-update.mjs` starts its own loopback server and checks upgrading an existing
service worker with stale cached HTML to the current worker and a working login.
All records are created only in disposable isolated browser contexts.

Scope: browser-local demonstration authentication, not server authentication or
cross-device synchronization. The existing password storage and token format are
not production-grade security. Reload intentionally asks for login again while
keeping IndexedDB records. Native Tauri, mobile browsers and other ERP workflows
are not covered by these tests. `index.js` is an unused HTML duplicate; the served
entry points are `index.html` and `app.html` and import `src/main.js`.
