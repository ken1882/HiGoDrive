class NotificationManager{
  constructor(){
    throw "This is a static class"
  }

  static initialize(){
    this.messages = [];
    setTimeout(()=>{
      if(!window._flagSWready){this.refreshServiceWorker();}
    }, 5000);
    setTimeout(()=>{
      $(document).ready(this.ready);
    }, 1000);
  }

  static isSupported(){
    return !!("Notification" in window);
  }

  static isPermissionGranted(){
    return Notification.permission === "granted";
  }

  static askPermission(){
    if(Notification.permission == "denied"){
      return false;
    }
    Notification.requestPermission().then((result) => {
      return result;
    });
  }


  static ready() {
    NotificationManager.setup(NotificationManager.sendSubInfo);
    
    if (navigator.serviceWorker) {
      logger.log('Registering serviceworker');
      navigator.serviceWorker.register('/serviceworker.js')
        .then(function(reg) {
          logger.log(reg.scope, 'register');
          logger.log('Service worker change, registered the service worker');
        });
    } else {
      alertSWSupport();
    }
  }

  static refreshServiceWorker(){
    console.log("Refreshing ServiceWorkers")
    navigator.serviceWorker.getRegistrations().then(function(registrations){
      for(let registration of registrations){
       registration.unregister();
      }
    });
  }

  static setup(onSubscribed) {
    console.log('Setting up push subscription');
  
    if (!window.PushManager) {
      console.warn('Push messaging is not supported in your browser');
    }
  
    if (!this.isSupported()) {
      console.warn('Notifications are not supported in your browser');
      return;
    }
  
    if (!this.isPermissionGranted) {
      Notification.requestPermission(function (permission) {
        // If the user accepts, let's create a notification
        if (permission === "granted") {
          console.log('Permission to receive notifications granted!');
          this.subscribe(onSubscribed);
        }
      });
      return;
    } else {
      console.log('Permission to receive notifications granted!');
      this.subscribe(onSubscribed);
    }
  }

  static getSubscription() {
    return navigator.serviceWorker.ready
    .then((serviceWorkerRegistration) => {
      return serviceWorkerRegistration.pushManager.getSubscription()
      .catch((error) => {
        console.warn('Error during getSubscription()', error);
      });
    });
  }

  static subscribe(onSubscribed) {
    console.log("Waiting for ServiceWorker Ready...");
    navigator.serviceWorker.ready.then((serviceWorkerRegistration) => {
      console.log("Service Worker is ready!");
      window._flagSWready = true;
      const pushManager = serviceWorkerRegistration.pushManager
      pushManager.getSubscription()
      .then((subscription) => {
        console.log("Process subscription")
        if (subscription) {
          NotificationManager.refreshSubscription(pushManager, subscription, onSubscribed);
        } else {
          NotificationManager.pushManagerSubscribe(pushManager, onSubscribed);
        }
      })
    });
  }

  static refreshSubscription(pushManager, subscription, onSubscribed) {
    console.log('Refreshing subscription');
    return subscription.unsubscribe().then((_) => {
      this.pushManagerSubscribe(pushManager, onSubscribed);
    });
  }
  
  static pushManagerSubscribe(pushManager, onSubscribed) {
    console.log('Subscribing started...');
  
    pushManager.subscribe({
      userVisibleOnly: true,
      applicationServerKey: window.publicKey
    })
    .then(onSubscribed)
    .then(() => { console.log('Subcribing finished: success!')})
    .catch((e) => {
      if (Notification.permission === 'denied') {
        console.warn('Permission to send notifications denied');
      } else {
        console.error('Unable to subscribe to push', e);
      }
    });
  }

  static logSubscription(subscription) {
    console.log("Current subscription", subscription.toJSON());
  }

  static formHeaders() {
    return new Headers({
      'Content-Type': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'X-CSRF-Token': Util.AuthToken,
    });
  }

  static sendSubInfo(subscription) {
    NotificationManager.logSubscription(subscription);
    NotificationManager.getSubscription().then((subscription) => {
      return fetch("/api/v0/push_notifications", {
        headers: NotificationManager.formHeaders(),
        method: 'POST',
        credentials: 'include',
        body: JSON.stringify({ subscription: subscription.toJSON() })
      }).then((response) => {
        console.log("Push response", response);
        if (response.status >= 500) {
          console.error(response.statusText);
          alert("Sorry, there was a problem sending the notification. Try resubscribing to push messages and resending.");
        }
      })
      .catch((e) => {
        logger.error("Error sending notification", e);
      });
    })
  }
  
  static sendNotification() {
    this.getSubscription().then((subscription) => {
      return fetch("/api/v0/notification_test", {
        headers: this.formHeaders(),
        method: 'POST',
        credentials: 'include',
        body: JSON.stringify({ subscription: subscription.toJSON() })
      }).then((response) => {
        console.log("Push response", response);
        if (response.status >= 500) {
          console.error(response.statusText);
          alert("Sorry, there was a problem sending the notification. Try resubscribing to push messages and resending.");
        }
      })
      .catch((e) => {
        console.error("Error sending notification", e);
      });
    })
  }
}