// Last positions around the average position (metres, north up).
// Copyright (c) 2026 smyhu. MIT License.
import QtQuick 1.1
import "geo.js" as Geo

Image {
    id: plot
    property variant points: []       // [{lat, lon}]
    property real lat0: 0
    property real lon0: 0
    property string units: "metric"
    property int c: 230
    property int r: 210
    // auto scale: horizon ring = farthest point * 1.2, at least 5 m
    property real ringMetres: autoScale(points, lat0, lon0)
    function autoScale(pts, la0, lo0) {
        var m = 5
        for (var i = 0; i < pts.length; i++) {
            var x = Geo.dx(pts[i].lon, lo0, la0), y = Geo.dy(pts[i].lat, la0)
            m = Math.max(m, Math.sqrt(x * x + y * y) * 1.2)
        }
        return Math.ceil(m)
    }
    width: 460
    height: 460
    smooth: true
    source: theme.inverted ? "plot-dark.png" : "plot-light.png"

    Repeater {
        model: plot.points
        Rectangle {
            width: 14; height: 14; radius: 7; smooth: true
            color: index == plot.points.length - 1 ? "#e7ffcd" : "#5f9f2a"
            border.color: "#e7ffcd"; border.width: 1
            x: plot.c + Geo.dx(modelData.lon, plot.lon0, plot.lat0) / plot.ringMetres * plot.r - 7
            y: plot.c - Geo.dy(modelData.lat, plot.lat0) / plot.ringMetres * plot.r - 7
        }
    }
    // average position
    Rectangle {
        visible: plot.points.length > 0
        width: 20; height: 20; radius: 10; smooth: true
        x: plot.c - 10; y: plot.c - 10
        color: "#e02020"; border.color: "white"; border.width: 3
    }
    Text {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 6
        text: "R = " + Geo.length(plot.ringMetres, plot.units)
        font.pixelSize: 18
        color: "#818181"
    }
}
