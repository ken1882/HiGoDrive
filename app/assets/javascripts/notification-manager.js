class NotificationManager{
  constructor(){
    throw "This is a static class"
  }

  static initialize(){
    $(document).ready(this.ready);
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
    NotificationManager.setup(NotificationManager.logSubscription);
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
    navigator.serviceWorker.ready.then((serviceWorkerRegistration) => {
      const pushManager = serviceWorkerRegistration.pushManager
      pushManager.getSubscription()
      .then((subscription) => {
        if (subscription) {
          NotificationManager.refreshSubscription(pushManager, subscription, onSubscribed);
        } else {
          NotificationManager.pushManagerSubscribe(pushManager, onSubscribed);
        }
      })
    });
  }

  static refreshSubscription(pushManager, subscription) {
    console.log('Refreshing subscription');
    return subscription.unsubscribe().then((bool) => {
      this.pushManagerSubscribe(pushManager);
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
}