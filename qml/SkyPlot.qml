// Sky plot: satellites by azimuth/elevation, rotated by the compass heading.
// Copyright (c) 2026 smyhu. MIT License.
import QtQuick 1.1

Image {
    id: sky
    property variant satellites: []
    property real heading: 0          // compass azimuth in degrees
    property int c: 230
    property int r: 210               // radius of the horizon ring
    width: 460
    height: 460
    smooth: true
    source: theme.inverted ? "radar-dark.png" : "radar-light.png"

    // north marker on the horizon ring
    Item {
        x: sky.c + (sky.r + 2) * Math.sin(-sky.heading * Math.PI / 180) - 20
        y: sky.c - (sky.r + 2) * Math.cos(-sky.heading * Math.PI / 180) - 20
        width: 40; height: 40
        z: 3
        Image {
            anchors.fill: parent
            source: "north.png"
            rotation: -sky.heading
            smooth: true
        }
    }

    Repeater {
        model: sky.satellites
        Rectangle {
            property bool ok: modelData.azimuth >= 0 && modelData.elevation >= 0
            property real a: (modelData.azimuth - sky.heading) * Math.PI / 180
            property real d: sky.r * (90 - Math.max(0, Math.min(90, modelData.elevation))) / 90
            visible: ok
            width: modelData.used ? 40 : 32
            height: width
            radius: width / 2
            smooth: true
            z: modelData.used ? 2 : 1
            x: sky.c + d * Math.sin(a) - width / 2
            y: sky.c - d * Math.cos(a) - height / 2
            color: modelData.used ? "#7fcf3a" : (theme.inverted ? "#2c5a12" : "#9fc88a")
            border.width: 2
            border.color: modelData.used ? "#e7ffcd" : (theme.inverted ? "#4c7a32" : "#6f9a5a")
            Text {
                anchors.centerIn: parent
                text: modelData.prn
                font.pixelSize: modelData.used ? 19 : 16
                font.bold: modelData.used
                color: modelData.used ? "#102000" : (theme.inverted ? "#e7ffcd" : "#102000")
            }
        }
    }
}
