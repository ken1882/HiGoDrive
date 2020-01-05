function onPush(event){
  console.log("Received push message", event);

  let title = (event.data && event.data.text()) || "Yay a message";
  let body = "We have received a push message";
  let tag = "push-simple-demo-notification-tag";
  var icon = null;

  event.waitUntil(
    self.registration.showNotification(title, { body, icon, tag })
  )
}

function onPushSubscriptionChange(event) {
  console.log("Push subscription change event detected", event);
}

self.addEventListener("push", onPush);
self.addEventListener("pushsubscriptionchange", onPushSubscriptionChange);