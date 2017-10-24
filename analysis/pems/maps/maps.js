var map = L.map('mapid').setView([37.7, -122], 10);

L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6ImNpejY4NXVycTA2emYycXBndHRqcmZ3N3gifQ.rJcFIG214AriISLbB6B5aw', {
    maxZoom: 18,
    attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
        '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
        'Imagery © <a href="http://mapbox.com">Mapbox</a>',
    id: 'mapbox.streets'
}).addTo(map);

// Working off:
// https://www.w3schools.com/xml/xml_http.asp
var xhttp = new XMLHttpRequest();

// Declaring a global variable
var station;

// TODO: Add popups, legend describing what red and green colors mean.

function plot_circles(station) {
    for (i = 0; i < station.ID.length; i++) {
        L.circle([station.Latitude[i], station.Longitude[i]], 
                {radius: 200, color: station.color[i], fillOpacity: 1})
                    .addTo(map);
    }
}

xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
        station = JSON.parse(xhttp.responseText);
        plot_circles(station);
    }
};

xhttp.open("GET", "station.json", true);
xhttp.send();


// The actual markers
//for (i = 0; i < station.ID.length; i++) {
//
//    L.circle([station.Latitude[i], station.Longitude[i]], 
//            {radius: 10, color: station.color[i], fillOpacity: 1})
//                .addTo(map);
//
//}
