//function : acceptTask  rejectTask onlineTask taskrunning 需串 api  acceptTask 備註待更改
var map, marker, directionsService, directionsDisplay, info;
var zoom = 17, lat = 25.1506194, lng = 121.7760687;
var relocateTimer, relocateTime = 10000, postLocationTimer, postTime = 8000;
var durationFareDegree = 0.1
var distanceFareDegree = 0.01
var infoFare, infoDistance, infoTime;
var isDriver = false;  //change passenger mode or driver mode
var geoFirst = true;
var task;
var isaccept = false;
var timesetInterval;
var isOnline = false;
var taskProcessing = false;
var taskid = {
  nowid: 0,
  nextid: 0
};
var request;
window.rejected_tasks = [];

var dest = {
  passengerlng: undefined,
  passengerlat: undefined,
  lng: undefined,
  lat: undefined,
  placeName: undefined,
  distance: undefined,
  duration: undefined,
  fare: undefined,
  helmet: undefined,
  raincoat: undefined,
  datetimepicker: undefined
};

function CenterControl(controlDiv, map) {

  // Set CSS for the control border.
  var controlUI = document.createElement('div');
  controlUI.style.backgroundColor = '#fff';
  controlUI.style.border = '3px solid #fff';
  controlUI.style.borderRadius = '3px';
  controlUI.style.boxShadow = '0 2px 6px rgba(0,0,0,.3)';
  controlUI.style.cursor = 'pointer';
  controlUI.style.marginBottom = '22px';
  controlUI.style.textAlign = 'center';
  controlUI.style.marginRight = '5px';
  controlUI.title = 'Click to recenter the map';
  controlDiv.appendChild(controlUI);

  // Set CSS for the control interior.
  var controlText = document.createElement('div');
  controlText.style.color = 'rgb(25,25,25)';
  controlText.style.fontFamily = 'Roboto,Arial,sans-serif';
  controlText.style.fontSize = '16px';
  controlText.style.lineHeight = '5px';
  // controlText.style.paddingLeft = '5px';
  //controlText.style.paddingRight = '5px';

  //controlText.innerHTML = "<img src='/assets/my_location.svg' weight='30px' height='30px'>";

  controlText.innerHTML = "<img src='assets/my_location.svg' weight='30px' height='30px'>";
  controlUI.appendChild(controlText);

  // Setup the click event listeners: simply set the map to Chicago.
  controlUI.addEventListener('click', function () {
    map.setCenter({ lat: lat, lng: lng });
    map.setZoom(zoom)
  });

}

function setLocationMarker(x, y) {
  if (marker) {
    marker.setMap(null)
  }
  marker = new google.maps.Marker({
    position: {
      lat: x,
      lng: y
    },
    map: map,
    //icon: 'img/my_location.svg'
    icon: {
      path: google.maps.SymbolPath.FORWARD_CLOSED_ARROW,
      scale: Math.floor(map.getZoom() / 4)

    },
  });
  //console.log(map.getZoom())
}
function setIcon() {
  //seticon
  var centerControlDiv = document.createElement('div');
  var centerControl = new CenterControl(centerControlDiv, map);
  centerControlDiv.index = 1;
  map.controls[google.maps.ControlPosition.RIGHT_CENTER].push(centerControlDiv);
}

function geoloaction(isFirst) {
  var geosuccess = function (position) {
    var pos = {
      lat: position.coords.latitude,
      lng: position.coords.longitude
    };
    console.log("geolocation found \nlat:" + pos.lat + "\nlng:" + pos.lng)
    lat = pos.lat
    lng = pos.lng

    setLocationMarker(lat, lng);
    if (isFirst) {
      map.setCenter({ lat: lat, lng: lng });
      geoFirst = false;
    }
  }

  var geoError = function (error) {
    console.log(error)
    console.log('Error occurred. Error code: ' + error.code);
    // error.code can be:
    //   0: unknown error
    //   1: permission denied
    //   2: position unavailable (error response from location provider)
    //   3: timed out
  }
  if (navigator.geolocation) {
    navigator.geolocation.watchPosition(geosuccess, geoError);
  } else {
    window.alert("Please check the browser allowing acessing your locational")
  }
}

function getCurrentUserId() {
  var current_user_id = undefined;
  $.ajax({
    type: "POST",
    url: "/api/v0/currentuser",
    dataType: "json",
    data: { authenticity_token: $('meta[name=csrf-token]')[0].content },
    success: function on_succ(result) {
      current_user_id = result.uid;
    },
    error: function (xhr, ajaxOptions, thrownError) {
      console.log("unexpected error: ", thrownError);
    },
    async: false
  });
  return current_user_id;
}

function initMap() {
  //initial Map
  map = new google.maps.Map(document.getElementById('map'), {
    zoom: zoom,
    center: {
      lat: lat,
      lng: lng,
    },
    disableDefaultUI: true,
  });

  document.getElementById('map').style.height = document.getElementsByTagName("main")[0].clientHeight + "px";

  //inital direction service and display
  directionsService = new google.maps.DirectionsService();
  directionsDisplay = new google.maps.DirectionsRenderer();
  directionsDisplay.setMap(map)

  var current_user = getUserInfo(getCurrentUserId());

  if (current_user.roles == 1) {
    isDriver = false;
    initPassenger();
  } else {
    isDriver = true;
    initDriver();
  }

  setIcon();
  geoloaction(geoFirst)
  relocateTimer = window.setInterval(function () { geoloaction(geoFirst); }, relocateTime);
}


function direction(destlat, destlng) {
  var request = {
    origin: { lat: lat, lng: lng },
    destination: { lat: destlat, lng: destlng },
    travelMode: 'DRIVING',
    //avoidTolls: 'true'
  };

  var infowindows = [];
  var markers = [];
  directionsService.route(request, function (result, status) {
    if (status == 'OK') {
      directionsDisplay.setDirections(result);
      dest.distance = result.routes[0].legs[0].distance;
      dest.duration = result.routes[0].legs[0].duration;
      dest.fare = Math.floor(dest.distance.value * distanceFareDegree + dest.duration.value * durationFareDegree);


    }
    else {
      console.log(status);
    }
  });
}

function setPsssengerDirectionInfo() {
  info.style.display = "inline"

  infoDistance.innerHTML = "距離:" + dest.distance.text;
  infoTime.innerHTML = "時間:" + dest.duration.text;
  infoFare.innerHTML = "車費:" + dest.fare + "元"
}

function setAutoComplete() {
  var input = document.getElementById('search')
  var card = document.getElementById('locSearch');

  card.style.display = "inline";
  map.controls[google.maps.ControlPosition.TOP].push(card);
  let width = document.getElementsByClassName('container')[0].clientWidth

  card.style.setProperty("left", 0 + "px", "important")

  var autocomplete = new google.maps.places.Autocomplete(input);
  autocomplete.bindTo('bounds', map)
  autocomplete.setFields(['address_components', 'geometry', 'icon', 'name'])
  /*var markerDest = new google.maps.Marker({
          map: map,
          anchorPoint: new google.maps.Point(0, -29)
        });*/

  autocomplete.addListener('place_changed', function () {

    //markerDest.setVisible(false);
    var place = autocomplete.getPlace();
    if (!place.geometry) {
      // User entered the name of a Place that was not suggested and
      // pressed the Enter key, or the Place Details request failed.
      //window.alert("No details available for input: '" + place.name + "'");
      return;
    }

    // If the place has a geometry, then present it on a map.
    if (place.geometry.viewport) {
      map.fitBounds(place.geometry.viewport);
    } else {
      map.setCenter(place.geometry.location);
      map.setZoom(17);  // Why 17? Because it looks good.
    }
    //markerDest.setPosition(place.geometry.location);
    //markerDest.setVisible(true);
    console.log(place)

    var address = '';
    if (place.address_components) {
      address = [
        (place.address_components[0] && place.address_components[0].short_name || ''),
        (place.address_components[1] && place.address_components[1].short_name || ''),
        (place.address_components[2] && place.address_components[2].short_name || '')
      ].join(' ');
    }
    dest.lat = place.geometry.location.lat();
    dest.lng = place.geometry.location.lng();
    dest.passengerlat = lat;
    dest.passengerlng = lng;
    dest.placeName = place.name;
    window.setTimeout(function () {
      direction(place.geometry.location.lat(), place.geometry.location.lng());
    }, 300)

    window.setTimeout(function () {
      setPsssengerDirectionInfo();
    }, 500)

    //document.getElementById('map').style.height = "50vh";
  });
}

function initPassengerInfo() {
  info = document.getElementById("order")
  infoFare = document.getElementById("farePassenger")
  infoDistance = document.getElementById("distancePassenger")
  infoTime = document.getElementById("timePassenger")
  info.index = 1;

  map.controls[google.maps.ControlPosition.LEFT_BOTTOM].push(info)
}

function initPassenger() {
  initPassengerInfo();

  setAutoComplete();

}

function cancelDest() {
  document.getElementById('search').value = "";
  document.getElementById('datetimepickerDiv').style.display = "none";
  directionsDisplay.set('directions', null);
  info.style.display = "none"
  infoDistance.innerHTML = "";
  infoTime.innerHTML = "";
  infoFare.innerHTML = "";
  map.setCenter({ lat: lat, lng: lng });
  map.setZoom(zoom)
}

function taskrunning() { //if driver accept task call back
  var driverid = '0' // api get driver id
  $.ajax({
    type: "GET",
    url: "/api/v0/tasks/" + taskid.nowid,
    dataType: "json",
    data: null,
    success: function on_succ(result) {
      console.log(result);
      driverid = result.driver_id;
    },
    error: function (xhr, ajaxOptions, thrownError) {
      console.log("unexpected error: ", thrownError);
    },
    async: false
  });
  console.log("driver_id", driverid);

  document.getElementById("driverid").innerHTML = "乘客：" + driverid;
  document.getElementById("destinationTask").innerHTML = dest.placeName
  document.getElementById("distanceTask").innerHTML = dest.distance.text
  document.getElementById("fareTask").innerHTML = dest.fare + '元'

  var ps = document.getElementById("psText").innerHTML // web get driver ps text
  driverReceive();
  taskStatus()

}

function taskStatus() { // api block get driver finish task status
  var status = getTask(taskid.nowid).status;
  // TODO: status definition has changed
  if (status == 1) {
    console.log('waiting for engaging');
    return setTimeout('taskStatus()', 5000); // block stock
  } else if (status == 2) {
    console.log('waiting for finishing');
    return setTimeout('taskStatus()', 5000); // block stock
  } else if (status == 3) {
    console.log('task done');
  }
}

function taskFinish() { //if task done
  $.ajax({
    type: "POST",
    url: "/api/v0/task/engage",
    dataType: "json",
    data: {
      authenticity_token: $('meta[name=csrf-token]')[0].content,
      id: taskid.nowid
    },
    success: function on_succ(result) {
      console.log(result);
    },
    error: function (xhr, ajaxOptions, thrownError) {
      console.log("unexpected error: ", thrownError);
    },
    async: false
  });
  $.ajax({
    type: "POST",
    url: "/api/v0/task/finish",
    dataType: "json",
    data: {
      authenticity_token: $('meta[name=csrf-token]')[0].content,
      id: taskid.nowid
    },
    success: function on_succ(result) {
      console.log(result);
    },
    error: function (xhr, ajaxOptions, thrownError) {
      console.log("unexpected error: ", thrownError);
    },
    async: false
  });
  location.reload();
}

function getUserInfo(uid) {
  var user_info = undefined;
  $.ajax({
    type: "GET",
    url: "/api/v0/users/" + uid,
    dataType: "json",
    data: null,
    success: function on_succ(result) {
      user_info = result;
    },
    error: function (xhr, ajaxOptions, thrownError) {
      console.log("unexpected error: ", thrownError);
    },
    async: false
  });
  return user_info;
}

function getTaskid(task_id) {
  var taskinfo = undefined;
  $.ajax({
    type: "GET",
    url: "/api/v0/next_task",
    dataType: "json",
    data: {id: task_id},
    success: function on_succ(result) {
      taskinfo = result;
    },
    error: function (xhr, ajaxOptions, thrownError) {
      console.log("unexpected error: ", thrownError);
    },
    async: false
  });
  return taskinfo;
}

function getTask(task_id_) {
  var task_ = {
    valid: false,
    dest: undefined,
    username: undefined,
    status: undefined
  };
  $.ajax({
    type: "GET",
    url: "/api/v0/tasks/" + task_id_,
    dataType: "json",
    data: null,
    success: function on_succ(result) {
      task_.valid = true;
      task_.dest = JSON.parse(result.dest);
      task_.username = getUserInfo(result.author_id).username;
      task_.status = result.status;
    },
    error: function (xhr, ajaxOptions, thrownError) {
      console.log("unexpected error: ", thrownError);
    },
    async: false
  });
  console.log("task_", task_);
  return task_;
}

//driver on line
function onlineTask() {
  var taskinfo = getTaskid(taskid.nextid); // first time give 0
  console.log("taskinfo", taskinfo);
  taskid.nowid = taskinfo.task_id;
  taskid.nextid = taskinfo.next_id;

  if (window.rejected_tasks.indexOf(taskid.nowid) != -1 || taskid.nowid == 0) {
    console.log("no task available");
    return setTimeout('onlineTask()', 5000); // fail request or no task
  }

  request = getTask(taskid.nowid);
  if (!request.valid) {
    taskid.nowid = 0;
    taskid.nextid = 0;
    console.log("getTask error");
    //setTimeout('onlineTask()', 5000);
    return setTimeout('onlineTask()', 5000);  // fail request or no task
  }

  dest = request.dest;

  setTimeout((() => onReceiveTask(dest)), 500);

  //done
}

//driver off line
function offlineTask() {
  clearInterval(timesetInterval);
}

//driver get task
function onReceiveTask(dest) {
  console.log(dest);
  task.style.display = "block";
  document.getElementById("taskType").innerHTML = dest.datetimepicker;
  document.getElementById("distDriver").innerHTML = dest.placeName;
  document.getElementById("distanceDriver").innerHTML = dest.distance.text;

  window.setTimeout(function () { directionDrive(dest.lat, dest.lng, dest.passengerlat, dest.passengerlng) }, 300)

  var sec = 30;
  var secHtml = document.getElementById("sec");
  isaccept = false;
  clearInterval(timesetInterval);
  timesetInterval = window.setInterval(function () {

    secHtml.innerHTML = sec + ' 秒';
    if (sec > 0) sec--;
    else {
      clearInterval(timesetInterval);
      if (isaccept == false) {
        rejectTask("time out");
        console.log("auto reject")
        return setTimeout('onlineTask()', 1000); // fail request or no task
      }
      return;
      //return onlineTask();
    }
  }, 1000)


}

// preview route between passenger position and destination
function directionDrive(destlat, destlng, passengerlat, passengerlng) {
  var request = {
    origin: { lat: parseFloat(passengerlat), lng: parseFloat(passengerlng) },
    destination: { lat: parseFloat(destlat), lng: parseFloat(destlng) },
    travelMode: 'DRIVING',
    //avoidTolls: 'true'
  };

  console.log(request)

  var infowindows = [];
  var markers = [];
  directionsService.route(request, function (result, status) {
    if (status == 'OK') {
      directionsDisplay.setDirections(result);
    } else {
      console.log(status);
    }
  });
}

//check api /api/v0/task status task_id = taskid.nowid
function acceptTask() {
  var task_ = getTask(taskid.nowid);
  var status = task_.status;
  console.log("task status", status);
  if (status == 0) {
    console.log("taskid.nowid", taskid.nowid) //set api status = 1; give driver id
    $.ajax({
      type: "POST",
      url: "/api/v0/task/accept",
      dataType: "json",
      data: {
        authenticity_token: $('meta[name=csrf-token]')[0].content,
        id: taskid.nowid
      },
      success: function on_succ(result) {
        console.log(result);
        isaccept = true;
        map.controls[google.maps.ControlPosition.LEFT_BOTTOM].push(document.getElementById('errand'));
        // console.log("task accept");

        // open map  on mobile  app
        document.getElementById("googleMap").href = "https://www.google.com/maps/dir/" + lat + ',' + lng + '/' + dest.passengerlat + ',' + dest.passengerlng + '/' + dest.lat + ',' + dest.lng;

        document.getElementById("userid").innerHTML = "乘客：" + request.username
        document.getElementById("destination").innerHTML = request.dest.placeName
        document.getElementById("distance").innerHTML = request.dest.distance.text
        document.getElementById("fare").innerHTML = request.dest.fare + '元'
        var ps = document.getElementById("psText").innerHTML // web get driver ps text
        taskrunning();
        // TODO: update ps to database
      },
      error: function (xhr, ajaxOptions, thrownError) {
        console.log("unexpected error: ", thrownError);
        rejectTask("task is accepted by other driver");
      },
      async: false
    });
  } else {
    rejectTask("task is accepted by other driver");
    return;
  }
}


function rejectTask(reason) {
  //api reject 婉拒
  $.ajax({
    type: "POST",
    url: "/api/v0/task/reject",
    dataType: "json",
    data: {
      authenticity_token: $('meta[name=csrf-token]')[0].content,
      id: taskid.nowid,
      reason: reason
    },
    success: function on_succ(result) {
      console.log(result);
    },
    error: function (xhr, ajaxOptions, thrownError) {
      console.log(xhr, ajaxOptions, thrownError);
      console.log("unexpected error: ", thrownError);
    },
    async: false
  });

  window.rejected_tasks.push(taskid.nowid);

  //set user view
  directionsDisplay.set('directions', null);
  map.setCenter({ lat: lat, lng: lng });
  map.setZoom(zoom);
  task.style.display = "none";
}

function initDriver() {
  var onlineState = document.getElementById("onlineState");
  var offlineState = document.getElementById("offlineState");
  task = document.getElementById("task");
  if (!isOnline) {
    offlineState.style.display = 'block';
  }
  map.controls[google.maps.ControlPosition.TOP_RIGHT].push(onlineState);
  map.controls[google.maps.ControlPosition.BOTTOM_CENTER].push(offlineState);
  map.controls[google.maps.ControlPosition.LEFT_BOTTOM].push(task);
  taskid = {nowid: 0, nextid: 0};
  window.rejected_tasks = [];
}
