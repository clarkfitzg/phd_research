// In retrospect it would be more natural to store the JSON as an array,
// with each element containing a dictionary

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

// global variables
var station;
var lat_eps = 2e-3;
var long_eps = 3e-3;
var ndigs = 8;

function one_circle(i) {
    var lat = station.Latitude[i];
    var lon = station.Longitude[i];
    // switch seems to only move one direction, leaving the other fixed.
    switch (station.Dir[i]) {
        case "N":
            lon += long_eps;
            break;
        case "E":
            lat -= lat_eps;
            break;
        case "S":
            lon -= long_eps;
            break;
        case "W":
            lat += lat_eps;
    }

    var circle = L.circle([lat, lon],
            {radius: 200, color: station.color[i], fillOpacity: 1})
            .addTo(map);
    
    var info = ["Cluster: " + station.cluster[i]
        , "ID: " + station.ID[i]
        , "Freeway: " + station.Fwy[i] + " " + station.Dir[i]
        , ""
        , "Free flow intercept: " + station.free_intercept[i].toFixed(ndigs)
        , "Free flow slope: " + station.free_slope[i].toFixed(ndigs)
        , "Congested intercept: " + station.congested_intercept[i].toFixed(ndigs)
        , "Congested slope: " + station.congested_slope[i].toFixed(ndigs)
        ];

    circle.bindPopup(info.join("<br>")).openPopup();
}


function plot_circles(station) {
    for (i = 0; i < station.ID.length; i++) {
        one_circle(i)
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
