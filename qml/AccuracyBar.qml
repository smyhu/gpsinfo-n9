// Accuracy scale 0-50 m: bright bar = last reading, dot = average.
// Copyright (c) 2026 smyhu. MIT License.
import QtQuick 1.1

Item {
    id: acc
    property real current: -1
    property real average: -1
    property real maxValue: 50
    height: 26
    Rectangle {
        id: track
        anchors.fill: parent
        anchors.topMargin: 4
        anchors.bottomMargin: 4
        radius: 4
        color: theme.inverted ? "#1d3510" : "#d6e8c8"
        Rectangle {
            visible: acc.current >= 0
            height: parent.height
            radius: 4
            width: Math.max(4, Math.min(acc.maxValue, acc.current) / acc.maxValue * parent.width)
            color: "#7fcf3a"
        }
    }
    Rectangle {
        visible: acc.average >= 0
        width: 14; height: 14; radius: 7; smooth: true
        anchors.verticalCenter: parent.verticalCenter
        x: Math.min(acc.maxValue, acc.average) / acc.maxValue * (acc.width - width)
        color: "#e7ffcd"
        border.color: "#2d7707"; border.width: 2
    }
}
