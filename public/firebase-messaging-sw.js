// Service Worker Oficial para PWA y Firebase Cloud Messaging — Óptica Dens
const CACHE_NAME = 'optica-dens-pwa-v2.5';
const ASSETS = ['/index.html', '/manifest.json'];

self.addEventListener('install', (event) => {
  event.waitUntil(caches.open(CACHE_NAME).then((cache) => cache.addAll(ASSETS)));
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(self.clients.claim());
});

self.addEventListener('push', (event) => {
  const payload = event.data ? event.data.json() : { title: 'Óptica Dens', body: 'Nueva alerta del sistema' };
  event.waitUntil(
    self.registration.showNotification(payload.title || 'Óptica Dens', {
      body: payload.body,
      icon: '/logo-optica-dens.jpg',
      badge: '/logo-optica-dens.jpg',
      data: payload.data || {}
    })
  );
});
