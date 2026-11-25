import { createRequire } from 'node:module';
import { createServer } from 'node:http';
import { readFile } from 'node:fs/promises';
import assert from 'node:assert/strict';
const require = createRequire(import.meta.url);
const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
let legacy = true;
const server = createServer(async (req, res) => {
  const path = new URL(req.url, 'http://localhost').pathname;
  res.setHeader('Cache-Control', 'no-store');
  res.setHeader('Content-Type', path.endsWith('.js') ? 'text/javascript' : path.endsWith('.json') ? 'application/json' : 'text/html');
  if (legacy && path === '/sw.js') {
    res.end(`self.addEventListener('install', e => e.waitUntil(caches.open('erp-lipigas-v1.0.4').then(c => c.put('./app.html', new Response('legacy cached page', {headers:{'Content-Type':'text/html'}}))))); self.addEventListener('fetch', e => e.respondWith(caches.match(e.request).then(r => r || fetch(e.request))));`);
    return;
  }
  try { res.end(await readFile(new URL('..' + (path === '/' ? '/index.html' : path), import.meta.url))); }
  catch { res.statusCode = 404; res.end(); }
});
await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
const base = `http://127.0.0.1:${server.address().port}/`;
const browser = await chromium.launch({ headless: true });
try {
  const context = await browser.newContext();
  const page = await context.newPage();
  page.setDefaultTimeout(5000);
  await page.goto(base);
  await page.evaluate(() => navigator.serviceWorker.ready);
  await page.goto(base + 'app.html');
  assert.equal(await page.locator('body').textContent(), 'legacy cached page');
  legacy = false;
  await page.evaluate(async () => (await navigator.serviceWorker.getRegistration()).update());
  for (let attempt = 0; attempt < 25; attempt++) {
    if (!(await page.evaluate(() => caches.keys())).includes('erp-lipigas-v1.0.4')) break;
    await new Promise(resolve => setTimeout(resolve, 200));
  }
  assert.equal((await page.evaluate(() => caches.keys())).includes('erp-lipigas-v1.0.4'), false, 'old cache must be removed');
  await page.reload();
  await page.getByText('Abrir Aplicación', { exact: true }).click();
  await page.getByRole('button', { name: 'Entrar', exact: true }).click();
  await page.locator('#dashboard').waitFor({ state: 'visible' });
  console.log('PASS existing service worker replaced, stale cache removed, real login succeeds');
} finally {
  await browser.close();
  await new Promise(resolve => server.close(resolve));
}
