// Start page with startup settings (shown on start unless skipped).
import QtQuick 1.1
import com.nokia.meego 1.1
import "i18n.js" as T

Page {
    id: intro
    orientationLock: PageOrientation.LockPortrait
    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            anchors.left: parent.left
            onClicked: intro.atStart ? pageStack.replace(Qt.resolvedUrl("MainPage.qml")) : pageStack.pop()
        }
    }
    property color fg: theme.inverted ? "white" : "black"
    property bool atStart: false      // shown at startup (back opens the main page)

    Rectangle { anchors.fill: parent; color: theme.inverted ? "black" : "white" }

    Flickable {
        id: fl
        anchors.fill: parent
        anchors.margins: 20
        contentHeight: col.height
        clip: true
        Column {
            id: col
            width: fl.width
            spacing: 20
            Row {
                spacing: 20
                Image { source: "gpsinfo-n9.png"; width: 80; height: 80 }
                Column {
                    spacing: 6
                    Text { text: "GPS Info"; font.pixelSize: 40; color: intro.fg }
                    Text {
                        text: T.t("for Nokia N9, version %1", helper.version)
                        font.pixelSize: 18; color: "#818181"
                    }
                }
            }
            Text {
                width: parent.width; wrapMode: Text.WordWrap
                text: T.t("Shows what the GPS receiver sees: satellites in view and in use, signal strength, position, accuracy and averages.")
                font.pixelSize: 20; color: intro.fg
            }
            SectionLabel { text: T.t("Application settings") }
            SwitchRow {
                text: T.t("Skip this page on startup")
                checked: appWindow.skipIntro
                onToggled: appWindow.skipIntro = value
            }
            SwitchRow {
                text: T.t("Start the GPS on startup")
                checked: appWindow.gpsOnStart
                onToggled: appWindow.gpsOnStart = value
            }
            SwitchRow {
                text: T.t("Stop the GPS after 5 minutes")
                checked: appWindow.autoStop
                onToggled: appWindow.autoStop = value
            }
            SectionLabel { text: T.t("Your privacy") }
            Text {
                width: parent.width; wrapMode: Text.WordWrap
                font.pixelSize: 18; color: intro.fg
                text: T.t("Your position stays on the phone. The application does not send, store or share it. Only the map tiles for the area around you are downloaded from the selected map server.")
            }
            Item { width: 1; height: 10 }
        }
    }
}
