var logger = console;
self.queued_messages = [];

function onPush(event){
  let title = "HiGoDrive";
  let body = (event.data && event.data.text()) || "Yay a message";
  let tag = "push-ga-notification-tag-" + Date();
  console.log("Received push message", event);
  console.log(`Message: ${title}`)
  self.queued_messages.push(title);
  event.waitUntil(
    self.registration.showNotification(title, { body, tag })
  );
}

function onPushSubscriptionChange(event) {
  console.log("Push subscription change event detected", event);
}

self.addEventListener('install', (event) => {
  logger.log('install event started.');
  event.waitUntil(self.skipWaiting());
});

self.addEventListener('activate', (event) => {
  logger.log('activate event started.');
  event.waitUntil((function(){
    self.clients.claim();
    console.log("[SW] Clients claimed");
  })());
});

self.addEventListener('fetch', (event) => {
  self.skipWaiting();
});

self.addEventListener("push", onPush);
self.addEventListener("pushsubscriptionchange", onPushSubscriptionChange);

self.addEventListener('message', (event) => {
  event.ports[0].postMessage({'new_msg': self.queued_messages});
  self.queued_messages = [];
});