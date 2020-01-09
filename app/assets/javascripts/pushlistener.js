function postSWMessage(msg){
  return new Promise((resolve, reject) => {
    var channel = new MessageChannel;
    channel.port1.onmessage = (event) => {
      if(event.data.error){reject(event.data.error);}
      else{resolve(event.data);}
    };
    navigator.serviceWorker.controller.postMessage(msg, [channel.port2]);
  });
}

setInterval(()=>{
  resp = postSWMessage('').then((result) => {
    if(result.new_msg.length == 0){return ;}
    NotificationManager.messages = NotificationManager.messages.concat(result.new_msg);
  });
}, 3000)