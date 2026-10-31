// Green status box: GPS off / searching / session finished.
// Tapping it never locks the user out: it starts the GPS or simply closes.
// Copyright (c) 2026 smyhu. MIT License.
import QtQuick 1.1
import "i18n.js" as T

Rectangle {
    id: boxRoot
    property string mode: ""
    signal tapped()
    signal viewLast()
    signal newSession()
    width: parent.width * 0.86
    height: col.height + 36
    radius: 20
    smooth: true
    color: "#2d7707"
    border.color: "#1c4d04"
    border.width: 1

    MouseArea {
        anchors.fill: parent
        onClicked: boxRoot.tapped()
    }

    Column {
        id: col
        anchors.centerIn: parent
        width: parent.width - 36
        spacing: 12
        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: 26
            color: "white"
            text: mode == "off" ? T.t("GPS is not active")
                : mode == "ended" ? T.t("Session finished")
                : T.t("Searching for signal")
        }
        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: 20
            color: "white"
            text: mode == "off" ? T.t("Tap here to start.")
                : mode == "ended" ? T.t("The GPS was stopped to save the battery. What would you like to do?")
                : T.t("%1 satellites in view, %2 in use.", sats.inView.length, sats.inUse.length)
        }
        SignalBars {
            visible: mode == "search"
            width: parent.width
            light: true
            satellites: sats.inView
        }
        Text {
            visible: mode == "search"
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: 18
            color: "#d8f5c0"
            text: T.t("Tap to look around while waiting.")
        }
        Repeater {
            model: mode == "ended" ? 2 : 0
            Rectangle {
                width: parent.width - 40
                height: 56
                radius: 10
                anchors.horizontalCenter: parent.horizontalCenter
                color: "#5bb600"
                Text {
                    anchors.centerIn: parent
                    font.pixelSize: 22
                    color: "white"
                    text: index == 0 ? T.t("View last session") : T.t("Start new session")
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: index == 0 ? boxRoot.viewLast() : boxRoot.newSession()
                }
            }
        }
    }
}
