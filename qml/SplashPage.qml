import QtQuick 1.1
import com.nokia.meego 1.1
import "i18n.js" as T

Page {
    orientationLock: PageOrientation.LockPortrait
    Rectangle {
        anchors.fill: parent
        color: "black"
        Column {
            anchors.centerIn: parent
            spacing: 18
            Image {
                source: "gpsinfo-n9.png"
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: "GPS Info"
                font.pixelSize: 40
                color: "white"
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: T.t("Loading…") + "  v" + helper.version
                font.pixelSize: 18
                color: "#9a9a9a"
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }
    }
}
