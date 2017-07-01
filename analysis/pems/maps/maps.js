var map = L.map('mapid').setView([37.7, -122], 10);

L.tileLayer('https://api.tiles.mapbox.com/v4/{id}/{z}/{x}/{y}.png?access_token=pk.eyJ1IjoibWFwYm94IiwiYSI6ImNpejY4NXVycTA2emYycXBndHRqcmZ3N3gifQ.rJcFIG214AriISLbB6B5aw', {
    maxZoom: 18,
    attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors, ' +
        '<a href="http://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, ' +
        'Imagery © <a href="http://mapbox.com">Mapbox</a>',
    id: 'mapbox.streets'
}).addTo(map);

// From https://github.com/pointhi/leaflet-color-markers
var violetIcon = new L.Icon({
  iconUrl: 'https://cdn.rawgit.com/pointhi/leaflet-color-markers/master/img/marker-icon-violet.png'
  , iconSize: [13, 21]
  , iconAnchor: [6, 21],
});

var orangeIcon = new L.Icon({
  iconUrl: 'https://cdn.rawgit.com/pointhi/leaflet-color-markers/master/img/marker-icon-orange.png'
  , iconSize: [13, 21]
  , iconAnchor: [6, 21],
});

var greenIcon = new L.Icon({
  iconUrl: 'https://cdn.rawgit.com/pointhi/leaflet-color-markers/master/img/marker-icon-green.png'
  , iconSize: [13, 21]
  , iconAnchor: [6, 21],
});


for (i = 0; i < station.ID.length; i++) {
    if (station.cluster[i] == 1) {
        L.marker([station.Latitude[i], station.Longitude[i]], {icon: violetIcon}).addTo(map);
    }
    if (station.cluster[i] == 2) {
        L.marker([station.Latitude[i], station.Longitude[i]], {icon: orangeIcon}).addTo(map);
    }
    if (station.cluster[i] == 3) {
        L.marker([station.Latitude[i], station.Longitude[i]], {icon: greenIcon}).addTo(map);
    }
}
