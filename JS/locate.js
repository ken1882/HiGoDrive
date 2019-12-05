var map, marker, directionsService, directionsDisplay, info;
var zoom = 17, lat = 25.1506194, lng = 121.7760687;
var relocateTimer, relocateTime = 10000, postLocationTimer, postTime = 8000;
var durationFareDegree = 0.1
var distanceFareDegree = 0.01
var infoFare, infoDistance, infoTime;
var isDriver = true;
var geoFirst = true;

var dest = {
  lng: "",
  lat: "",
  distance: "",
  duration: "",
  helment: "",
  raincoat: "",
  datetimepicker: ""
}

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
  controlText.innerHTML = "<img src='img/my_location.svg' weight='30px' height='30px'>";
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
      console.log(dest);
      setInfo();
    }
    else {
      console.log(status);
    }
  });
}

function setInfo() {
  info.style.display = "inline"
  infoDistance.innerHTML = "距離:" + dest.distance.text;
  infoTime.innerHTML = "時間:" + dest.duration.text;
  infoFare.innerHTML = "車費:" + Math.floor(dest.distance.value * distanceFareDegree + dest.duration.value * durationFareDegree) + "元"
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

    window.setTimeout(function () { direction(place.geometry.location.lat(), place.geometry.location.lng()) }, 300)
    //document.getElementById('map').style.height = "50vh";
  });

}

function initPassengerInfo() {
  info = document.getElementById("order")
  infoFare = document.getElementById("fare")
  infoDistance = document.getElementById("distance")
  infoTime = document.getElementById("time")
  info.index = 1;

  map.controls[google.maps.ControlPosition.LEFT_BOTTOM].push(info)
}

function initPassenger() {
  setAutoComplete();
  initPassengerInfo();
}

function initDriver() {
  var onlineState = document.getElementById("onlineState");
  var offlineState = document.getElementById("offlineState");
  var task = document.getElementById("task");

  map.controls[google.maps.ControlPosition.TOP_RIGHT].push(onlineState);
  map.controls[google.maps.ControlPosition.BOTTOM_CENTER].push(offlineState);
  map.controls[google.maps.ControlPosition.LEFT_BOTTOM].push(task);
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

  if (isDriver) {
    initDriver();
  } else {
    initPassenger();
  }

  setIcon();
  geoloaction(geoFirst)
  relocateTimer = window.setInterval(function () { geoloaction(geoFirst); }, relocateTime);



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
