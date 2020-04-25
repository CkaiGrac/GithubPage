'use strict';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "index.html": "873f550b3313f53c312fabf8e434e3eb",
"/": "873f550b3313f53c312fabf8e434e3eb",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "115e937bb829a890521f72d2e664b632",
"assets/packages/flutter_markdown/assets/logo.png": "67642a0b80f3d50277c44cde8f450e50",
"assets/packages/open_iconic_flutter/assets/open-iconic.woff": "3cf97837524dd7445e9d1462e3c4afe2",
"assets/assets/config.json": "8533ed984a41e7650510ff883ed5d1ef",
"assets/FontManifest.json": "96880f5cbd12a15751331cdbdac93202",
"assets/fonts/MaterialIcons-Regular.ttf": "56d3ffdef7a25659eab6a68a3fbfaf16",
"assets/AssetManifest.json": "10faab0ce40ef72208afa454b49962cc",
"assets/LICENSE": "40cb5dac495fc009cc7b1139b099c7e0",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"main.dart.js": "ba2f678877beec4b1f1ad841112dbdf4",
"manifest.json": "124da18a113bb7031c239b1711b8faea"
};

self.addEventListener('activate', function (event) {
  event.waitUntil(
    caches.keys().then(function (cacheName) {
      return caches.delete(cacheName);
    }).then(function (_) {
      return caches.open(CACHE_NAME);
    }).then(function (cache) {
      return cache.addAll(Object.keys(RESOURCES));
    })
  );
});

self.addEventListener('fetch', function (event) {
  event.respondWith(
    caches.match(event.request)
      .then(function (response) {
        if (response) {
          return response;
        }
        return fetch(event.request);
      })
  );
});
