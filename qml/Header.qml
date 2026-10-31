import QtQuick 1.1
// grey rounded section header
Rectangle {
    property alias text: t.text
    width: parent.width
    height: 45
    radius: 10
    smooth: true
    color: theme.inverted ? "#222222" : "#d3d3d3"
    Text {
        id: t
        anchors.centerIn: parent
        font.pixelSize: 22
        color: theme.inverted ? "white" : "black"
    }
}
