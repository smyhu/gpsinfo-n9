import QtQuick 1.1
// one "label  value" line, like in the data lists
Item {
    property alias label: l.text
    property alias value: v.text
    property int labelWidth: 200
    width: parent.width
    height: Math.max(l.paintedHeight, v.paintedHeight)
    Text {
        id: l
        width: parent.labelWidth
        font.pixelSize: 22
        color: "#818181"
        wrapMode: Text.WordWrap
    }
    Text {
        id: v
        x: parent.labelWidth + 5
        width: parent.width - x
        font.pixelSize: 22
        wrapMode: Text.WordWrap
        color: theme.inverted ? "white" : "black"
    }
}
