// Small tile map (3x3 tiles of 256 px) centred on a position.
// Copyright (c) 2026 smyhu. MIT License.
import QtQuick 1.1
import "i18n.js" as T

Item {
    id: map
    width: 420
    height: 420
    clip: true

    property real lat: 0
    property real lon: 0
    property bool hasPosition: false
    property int zoom: 16
    property real n: Math.pow(2, zoom)
    property real tx: (lon + 180) / 360 * n
    property real ty: (1 - Math.log(Math.tan(lat * Math.PI / 180) + 1 / Math.cos(lat * Math.PI / 180)) / Math.PI) / 2 * n
    property int bx: Math.floor(tx) - 1
    property int by: Math.floor(ty) - 1
    property int half: width / 2
    // tile servers that work without a key (2026); {z} {x} {y}
    property variant sources: [
        ["OSM France", "https://a.tile.openstreetmap.fr/osmfr/{z}/{x}/{y}.png", "© OpenStreetMap contributors"],
        ["Esri Street", "https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}", "© Esri"],
        ["OpenTopoMap", "http://a.tile.opentopomap.org/{z}/{x}/{y}.png", "© OpenStreetMap, SRTM | OpenTopoMap"],
        ["CyclOSM", "http://a.tile-cyclosm.openstreetmap.fr/cyclosm/{z}/{x}/{y}.png", "© OpenStreetMap contributors | CyclOSM"]
    ]
    property int source: 0
    signal tapped()

    property bool ready: false        // no tiles until the first centre()
    function centre(la, lo, z) {
        ready = false
        zoom = z
        lat = la
        lon = lo
        ready = true
    }

    function size(b) {
        if (b < 1024 * 1024) return Math.round(b / 1024) + " kB"
        return (b / 1024 / 1024).toFixed(1) + " MB"
    }

    function localTile(kx, ky, rev) {
        var u = tile(kx, ky)
        return u == "" ? "" : tiles.local(u)
    }

    function tile(kx, ky) {
        var x = ((kx % n) + n) % n
        if (!ready || ky < 0 || ky >= n) return ""
        return sources[source][1].replace("{z}", zoom).replace("{x}", x).replace("{y}", ky)
    }

    Rectangle { anchors.fill: parent; color: "#d8d4cc" }

    Item {
        x: map.half - (map.tx - map.bx) * 256
        y: map.half - (map.ty - map.by) * 256
        Repeater {
            model: 9
            Image {
                x: (index % 3) * 256
                y: Math.floor(index / 3) * 256
                width: 256
                height: 256
                // tiles are downloaded by the native TileCache and shown from files
                source: map.localTile(map.bx + index % 3, map.by + Math.floor(index / 3), tiles.revision)
            }
        }
    }

    // position marker
    Rectangle {
        visible: map.hasPosition
        x: map.half - width / 2
        y: map.half - height / 2
        width: 22; height: 22; radius: 11
        color: "#e02020"
        border.color: "white"
        border.width: 3
    }

    MouseArea {
        anchors.fill: parent
        onClicked: map.tapped()
    }

    // map source button
    Rectangle {
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 8
        width: srcName.width + 24
        height: 56
        radius: 8
        color: srcArea.pressed ? "#5bb600" : "#cc222222"
        Text {
            id: srcName
            anchors.centerIn: parent
            text: map.sources[map.source][0]
            color: "white"
            font.pixelSize: 22
        }
        MouseArea {
            id: srcArea
            anchors.fill: parent
            onClicked: map.source = (map.source + 1) % map.sources.length
        }
    }

    // zoom buttons
    Row {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 8
        spacing: 8
        Repeater {
            model: ["−", "+"]
            Rectangle {
                width: 56; height: 56; radius: 8
                color: zoomArea.pressed ? "#5bb600" : "#cc222222"
                Text {
                    anchors.centerIn: parent
                    text: modelData
                    color: "white"
                    font.pixelSize: 36
                }
                MouseArea {
                    id: zoomArea
                    anchors.fill: parent
                    onClicked: {
                        if (index == 1 && map.zoom < 19) map.zoom++
                        if (index == 0 && map.zoom > 2) map.zoom--
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: attribution.width + 8
        height: attribution.height + 4
        color: "#bbffffff"
        Text {
            id: attribution
            anchors.centerIn: parent
            text: map.sources[map.source][2]
            font.pixelSize: 14
            color: "#333333"
        }
    }

    Rectangle {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30
        width: loadingText.width + 30
        height: loadingText.height + 16
        radius: 8
        color: "#99000000"
        visible: tiles.pending > 0
        Text {
            id: loadingText
            anchors.centerIn: parent
            text: T.t("Loading map") + "  " + map.size(tiles.bytes)
            color: "white"
            font.pixelSize: 22
        }
    }
}
