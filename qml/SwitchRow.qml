import QtQuick 1.1
import com.nokia.meego 1.1
Item {
    id: row
    property alias text: label.text
    property bool checked: false
    signal toggled(bool value)
    width: parent.width
    height: Math.max(label.paintedHeight, sw.height) + 6
    Text {
        id: label
        anchors.left: parent.left
        anchors.right: sw.left
        anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        wrapMode: Text.WordWrap
        font.pixelSize: 22
        color: theme.inverted ? "white" : "black"
    }
    Switch {
        id: sw
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        checked: row.checked
        onCheckedChanged: if (checked != row.checked) row.toggled(checked)
    }
}
