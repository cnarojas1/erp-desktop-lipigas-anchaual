const CACHE_NAME = 'erp-lipigas-v1.0.4';
const urlsToCache = [
  './',
  './app.html',
  './index.html',
  './manifest.json',
  './src/main.js',
  './sqlite/schema.sql',
  './scripts/init-db.js'
];

self.addEventListener('install', function(event) {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(function(cache) {
        return cache.addAll(urlsToCache);
      })
  );
});

self.addEventListener('fetch', function(event) {
  event.respondWith(
    caches.match(event.request)
      .then(function(response) {
        return response || fetch(event.request);
      })
  );
});