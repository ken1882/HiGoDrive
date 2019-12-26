var logger = console;

class PushNotification{
  constructor(){
    throw "This is a static class"
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
    this.setup(this.logSubscription);
  }
  
  static setup(onSubscribed) {
    logger.log('Setting up push subscription');
  
    if (!window.PushManager) {
      logger.warn('Push messaging is not supported in your browser');
    }
  
    if (!ServiceWorkerRegistration.prototype.showNotification) {
      logger.warn('Notifications are not supported in your browser');
      return;
    }
  
    if (!this.isPermissionGranted) {
      Notification.requestPermission(function (permission) {
        // If the user accepts, let's create a notification
        if (permission === "granted") {
          logger.log('Permission to receive notifications granted!');
          this.subscribe(onSubscribed);
        }
      });
      return;
    } else {
      logger.log('Permission to receive notifications granted!');
      this.subscribe(onSubscribed);
    }
  }

  static getSubscription() {
    return navigator.serviceWorker.ready
    .then((serviceWorkerRegistration) => {
      return serviceWorkerRegistration.pushManager.getSubscription()
      .catch((error) => {
        logger.warn('Error during getSubscription()', error);
      });
    });
  }

  static subscribe(onSubscribed) {
    navigator.serviceWorker.ready.then((serviceWorkerRegistration) => {
      const pushManager = serviceWorkerRegistration.pushManager
      pushManager.getSubscription()
      .then((subscription) => {
        if (subscription) {
          refreshSubscription(pushManager, subscription, onSubscribed);
        } else {
          this.pushManagerSubscribe(pushManager, onSubscribed);
        }
      })
    });
  }

  static refreshSubscription(pushManager, subscription, onSubscribed) {
    logger.log('Refreshing subscription');
    return subscription.unsubscribe().then((bool) => {
      this.pushManagerSubscribe(pushManager);
    });
  }
  
  static pushManagerSubscribe(pushManager, onSubscribed) {
    logger.log('Subscribing started...');
  
    pushManager.subscribe({
      userVisibleOnly: true,
      applicationServerKey: window.publicKey
    })
    .then(onSubscribed)
    .then(() => { logger.log('Subcribing finished: success!')})
    .catch((e) => {
      if (Notification.permission === 'denied') {
        logger.warn('Permission to send notifications denied');
      } else {
        logger.error('Unable to subscribe to push', e);
      }
    });
  }

  static logSubscription(subscription) {
    logger.log("Current subscription", subscription.toJSON());
  }
}