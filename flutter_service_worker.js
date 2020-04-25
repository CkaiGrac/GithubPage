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
"assets/assets/note/assets/sameType.png": "ad5b3fd3eda39924be24d2d2659d5099",
"assets/assets/note/assets/renderObj.png": "dfb94964644fba5807480027a89d4d71",
"assets/assets/note/assets/after1.png": "1eb9d494129e1744192dbfb6aebf0ce4",
"assets/assets/note/assets/build.png": "94b67eacf923ffa2c24bec9df8a77a70",
"assets/assets/note/assets/debugpaint.png": "40f91695e1b795d286f6f585c18d7605",
"assets/assets/note/assets/cuttree.png": "f7ff59cf36e49d349d51d125fcfa52d6",
"assets/assets/note/assets/buildflag.png": "0d86ce3e93b024e750d19b08c1d0bf50",
"assets/assets/note/assets/flutterRender.png": "d95699214c4421e5eb4a5576b595af3d",
"assets/assets/note/assets/flutterUI.png": "b5375f9cb5f7813781c18c83af9b9c5a",
"assets/assets/note/assets/startprofile.png": "536ed0689cc7bd56e7c9826681203809",
"assets/assets/note/assets/nopaintb.png": "ae3f962b52e57b5c884f998be858d262",
"assets/assets/note/assets/observerary.png": "a7bade4bb0446ee940ca0b94260dac55",
"assets/assets/note/assets/border.png": "c8fdee907a359cb2c7e0bc42907ba113",
"assets/assets/note/assets/iosView.png": "a8475f2e546ca2d3a7438ff0665752c1",
"assets/assets/note/assets/method.png": "06e819844602c0838c289b5e2dfbce3d",
"assets/assets/note/assets/androidView.png": "2ccb68925b3c67352aa76db0d56a8318",
"assets/assets/note/assets/flutterWidgetTree.png": "c816b11b0bf5a8de399908a449e73104",
"assets/assets/note/assets/ELF_constr_of45haa3w.jpeg": "30fd764bb6bd8af6c9f52f8fdf60bb44",
"assets/assets/note/assets/stopit.png": "02700f3d806c50d3fc67bfb0b3cab2f2",
"assets/assets/note/assets/openob.png": "194772acf59ab9110606af14dede6aad",
"assets/assets/note/assets/afterpaint.png": "547ddab0d37678a6896fe92ce3722e64",
"assets/assets/note/assets/slideTransition.gif": "32cbc26ab5d31429481dcba42e03e045",
"assets/assets/note/assets/profilemode.png": "9f5cb8de2277010bf84fba508afdeaf9",
"assets/assets/note/assets/repaintb.png": "22c8045f3342221ea212079ca18d7cb8",
"assets/assets/note/assets/timeline.png": "065583014799688b268af47f8503cba6",
"assets/assets/note/01.md": "33e3afa437317f5e8824e017e125756a",
"assets/assets/note/03.md": "e29a0c7fc1a5704a8496c06a81641704",
"assets/assets/note/02.md": "4f5fa5580b197995086503fc9b0a797d",
"assets/assets/note/00.md": "498c227e76666d1aec6ad2ee51411b4f",
"assets/assets/config.json": "8533ed984a41e7650510ff883ed5d1ef",
"assets/FontManifest.json": "96880f5cbd12a15751331cdbdac93202",
"assets/fonts/MaterialIcons-Regular.ttf": "56d3ffdef7a25659eab6a68a3fbfaf16",
"assets/AssetManifest.json": "0efeec96c8a1e5d6e4c06dd4be24ae8e",
"assets/LICENSE": "40cb5dac495fc009cc7b1139b099c7e0",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"main.dart.js": "572fb47505d38273586f62c109bf7f97",
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
