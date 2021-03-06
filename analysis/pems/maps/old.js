// Adds the points to an existing leaflet variable called 'map'

// From https://github.com/pointhi/leaflet-color-markers
var redIcon = new L.Icon({
  iconUrl: 'https://cdn.rawgit.com/pointhi/leaflet-color-markers/master/img/marker-icon-red.png'
  , iconSize: [13, 21]
  , iconAnchor: [6, 21],
});

var greenIcon = new L.Icon({
  iconUrl: 'https://cdn.rawgit.com/pointhi/leaflet-color-markers/master/img/marker-icon-green.png'
  , iconSize: [13, 21]
  , iconAnchor: [6, 21],
});

var violetIcon = new L.Icon({
  iconUrl: 'https://cdn.rawgit.com/pointhi/leaflet-color-markers/master/img/marker-icon-violet.png'
  , iconSize: [13, 21]
  , iconAnchor: [6, 21],
});


var clusterColors = {1: violetIcon, 2: redIcon, 3: greenIcon};


function addMarker(station, i, ndigs = 2) {

    var m = L.marker([station.Latitude[i], station.Longitude[i]]
            , {icon: clusterColors[station.cluster[i]]}).addTo(map);

    var info = ["Cluster: " + station.cluster[i]
        , "ID: " + station.ID[i]
        , "Freeway: " + station.Fwy[i] + " " + station.Dir[i]
        , ""
        , "Free flow intercept: " + station.free_intercept[i].toFixed(ndigs)
        , "Free flow slope: " + station.free_slope[i].toFixed(ndigs)
        , "Congested intercept: " + station.congested_intercept[i].toFixed(ndigs)
        , "Congested slope: " + station.congested_slope[i].toFixed(ndigs)
        ];

    m.bindPopup(info.join("<br>")).openPopup();

}


// Working off:
// https://www.w3schools.com/xml/xml_http.asp
var xhttp = new XMLHttpRequest();

xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
        var station = JSON.parse(xhttp.responseText);
        for (i = 0; i < station.ID.length; i++) {
            addMarker(station, i)
        }
    }
};

xhttp.open("GET", "station.json", true);
xhttp.send();
