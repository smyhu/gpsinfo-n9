// Signal strength (SNR, dB-Hz) of every satellite; satellites in use are bright.
// Copyright (c) 2026 smyhu. MIT License.
import QtQuick 1.1
import "i18n.js" as T

Column {
    id: bars
    property variant satellites: []
    property bool light: false        // white text on green (status box)
    spacing: 4
    Repeater {
        model: bars.satellites
        Item {
            width: bars.width
            height: 28
            Text {
                id: name
                width: 70
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.prn
                horizontalAlignment: Text.AlignRight
                font.pixelSize: 18
                font.bold: modelData.used
                color: bars.light ? "white" : (theme.inverted ? "#e7ffcd" : "#1f4a08")
            }
            Rectangle {
                id: track
                x: 85
                width: parent.width - 85 - 60
                height: 20
                anchors.verticalCenter: parent.verticalCenter
                color: bars.light ? "#36880b" : (theme.inverted ? "#1d3510" : "#d6e8c8")
                Rectangle {
                    height: parent.height
                    width: Math.max(2, Math.min(55, modelData.snr) / 55 * parent.width)
                    color: modelData.used ? "#7fcf3a" : (bars.light ? "#5bb600" : "#3f7a1c")
                }
            }
            Text {
                anchors.left: track.right
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                text: modelData.snr > 0 ? modelData.snr : "–"
                font.pixelSize: 18
                color: bars.light ? "white" : "#818181"
            }
        }
    }
}
