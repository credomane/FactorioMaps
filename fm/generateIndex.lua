function fm.generateIndex(data)
    -- generate index.html
    local pathName = "FactorioMaps/" .. data.folderName .. "/index.html"

    local googleKey = ""
    if (data.googleKey ~= nil) and (data.googleKey ~= "") then
        googleKey = "?key=" .. data.googleKey
    end

    local indexText = [[
<!DOCTYPE html>
<html>
<head>
<title>Factorio Maps</title>
<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
<style type="text/css">
    html { height: 100% }
    body { height: 100%; margin: 0px; padding: 0px }
    #map_canvas { height: 100%; z-index: 0; }
    #gmnoprint { width: auto; }
</style>
<!--
    For local use, don't change anything.
    For server use (making it available on a website):
        1. Get a Google Maps API key from https://developers.google.com/maps/documentation/javascript/get-api-key
        2. Add ?key=INSERTAPIKEY to the end of the below script URL
        3. Finally replace INSERTAPIKEY with the API key you obtained in step #1.
-->
<script type="text/javascript" src="https://maps.googleapis.com/maps/api/js]] .. googleKey .. [["></script>
<script>
function CustomMapType() {}

CustomMapType.prototype.tileSize = new google.maps.Size(]] .. data.index.gridSize .. "," .. data.index.gridSize .. [[);
CustomMapType.prototype.minZoom = ]].. data.index.minZoomLevel .. [[;
CustomMapType.prototype.maxZoom = ]].. data.index.maxZoomLevel .. [[;
CustomMapType.prototype.getTile = function(coord, zoom, ownerDocument) {
    var div = ownerDocument.createElement('DIV');
    var baseURL = 'Images/';
    ]]
    --debug set isPNG in right place
    if(data.extension == 2) then
        indexText = indexText .. [[
            if (zoom === ]].. data.index.maxZoomLevel..[[) {
                ext = "png";
            } else {
                ext = "jpg";
            }
            ]]
    elseif(data.extension==3) then
        indexText = indexText .. [[ext = "png";
]]
    else
        indexText = indexText .. [[ext = "jpg";
]]
    end
    indexText = indexText .. [[
    baseURL += zoom + '_' + coord.x + '_' + coord.y + '.' + ext;
    div.style.width = this.tileSize.width + 'px';
    div.style.height = this.tileSize.height + 'px';
    div.style.backgroundImage = 'url(' + baseURL + ')';
    return div;
};

CustomMapType.prototype.name = "Custom";
CustomMapType.prototype.alt = "Tile Coordinate Map Type";
var CustomMap = new CustomMapType();

// bounds of the desired area
var allowedBounds = new google.maps.LatLngBounds(
                                          //This is confusing so:
    new google.maps.LatLng(-85, -179.99), //LatLng(Bottom, Left)
    new google.maps.LatLng(85, 179.99)    //LatLng(Top,Right)
);
var boundLimits = {
    maxLat : allowedBounds.getNorthEast().lat(),
    maxLng : allowedBounds.getNorthEast().lng(),
    minLat : allowedBounds.getSouthWest().lat(),
    minLng : allowedBounds.getSouthWest().lng()
};

var map;

function update_map() {
    checkBounds();
}

// If the map position is out of range, move it back
function checkBounds() {
    center = map.getCenter();
    if (allowedBounds.contains(center)) {
        // still within valid bounds, so save the last valid position
        lastValidCenter = map.getCenter();
        return;
    }
    newLat = lastValidCenter.lat();
    newLng = lastValidCenter.lng();
    if(center.lng() > boundLimits.minLng && center.lng() < boundLimits.maxLng){
        newLng = center.lng();
    }
    if(center.lat() > boundLimits.minLat && center.lat() < boundLimits.maxLat){
        newLat = center.lat();
    }
    map.panTo(new google.maps.LatLng(newLat, newLng));
}

function update_url() {
    var center = map.getCenter();
    var zoom = map.getZoom();
    var href = location.href;

    href = href.split("#")[0] || href;
    window.location.replace(href + '#' + center.lat().toFixed(2) + ',' + center.lng().toFixed(2) + ',' + zoom);
}

function hash_changed() {
    var urlbits = window.location.hash.split('#');
    if(urlbits[1]) {
        locationbits = urlbits[1].split(',');
        map.setCenter({lat: parseFloat(locationbits[0]), lng: parseFloat(locationbits[1])});
        map.setZoom(parseInt(locationbits[2]));
    }
}

if ("onhashchange" in window) {
    window.onhashchange = hash_changed
}

function load() {
    var mapOptions = {
        zoom: ]].. (data.index.minZoomLevel) ..[[,
        // minZoom: ]]..(data.index.minZoomLevel) ..[[,
        // maxZoom: ]].. (data.index.maxZoomLevel == 1 and (data.index.maxZoomLevel - 1) or data.index.maxZoomLevel) ..[[,
        isPng: false,
        mapTypeControl: false,
        streetViewControl: false,
        center: new google.maps.LatLng(]].. 0 ..",".. 0 ..[[),
        mapTypeControlOptions: {
            mapTypeIds: ['custom', google.maps.MapTypeId.ROADMAP],
            style: google.maps.MapTypeControlStyle.DROPDOWN_MENU
        }
    };
    map = new google.maps.Map(document.getElementById("map_canvas"),mapOptions);
    map.mapTypes.set('custom',CustomMap);
    map.setMapTypeId('custom');

    lastValidCenter = map.getCenter();

    hash_changed()

    map.addListener('center_changed', update_map);
    map.addListener('zoom_changed', update_map);

    map.addListener('idle', update_url);

//  addmarker();
//  addoutline();
}

function addmarker() {
    var marker = new google.maps.Marker({
        position: new google.maps.LatLng(85,-180),
        map: map,
    // optimized: false,
        title:"Hello World!"
    });
    var marker = new google.maps.Marker({
        position: new google.maps.LatLng(-85,-180),
        map: map,
    // optimized: false,
        title:"Hello World!"
    });
}

function addoutline() {
    var flightPlanCoordinates = [
    ]]

--    for k,v in pairs(data.index.linesArray) do
--        indexText = indexText .. "new google.maps.LatLng(".. v.lat ..",".. v.lng .."),\r\n"
--    end

        indexText = indexText .. [[
    ];
    var flightPath = new google.maps.Polyline({
      path: flightPlanCoordinates,
      strokeColor: '#FF0000',
    //  strokeOpacity: 1.0,
      strokeWeight: 2
    });

    flightPath.setMap(map);
}
</script>
</head>
<body onload="load()">
<div id="map_canvas" style="background: #1B2D33;"></div>
</body>
</html>
]]

    game.write_file(pathName, indexText, false, data.player_index)

end
