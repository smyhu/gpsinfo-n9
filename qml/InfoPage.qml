// Help and About.
// Copyright (c) 2026 smyhu. MIT License.
import QtQuick 1.1
import com.nokia.meego 1.1
import "i18n.js" as T

Page {
    id: info
    orientationLock: PageOrientation.LockPortrait
    tools: ToolBarLayout {
        ToolIcon {
            platformIconId: "toolbar-back"
            anchors.left: parent.left
            onClicked: pageStack.pop()
        }
    }
    property color fg: theme.inverted ? "white" : "black"

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
            spacing: 16
            Row {
                spacing: 20
                Image { source: "gpsinfo-n9.png"; width: 80; height: 80 }
                Column {
                    spacing: 6
                    Text { text: "GPS Info"; font.pixelSize: 40; color: info.fg }
                    Text { text: T.t("for Nokia N9, version %1", helper.version); font.pixelSize: 18; color: "#818181" }
                }
            }
            SectionLabel { text: T.t("How to use it") }
            Repeater {
                model: [
                    T.t("The refresh button starts a new session: the GPS is switched on and the averages start from zero."),
                    T.t("While the phone is searching for satellites, a green box shows their signal. Tap it to look around the application while waiting."),
                    T.t("The sky plot shows satellites by direction and height above the horizon (centre = straight up). Bright, larger circles are used for the position. The plot turns with the compass; the N mark points north."),
                    T.t("Averages are counted from valid readings, not from time. The accuracy bars show the last reading (bar) and the average (dot) on a 0–50 m scale."),
                    T.t("The position plot shows the last 5 readings around the average position (red dot). R is the radius of the outer ring."),
                    T.t("Tap the map name to change the map, use − and + to zoom. Maps need an internet connection; some use HTTPS and need the TLS 1.2 update."),
                    T.t("The share button copies the average position or opens it in the Maps application.")
                ]
                Text {
                    width: col.width
                    wrapMode: Text.WordWrap
                    font.pixelSize: 20
                    color: info.fg
                    text: "• " + modelData
                }
            }
            SectionLabel { text: T.t("Faster first fix") }
            Text {
                width: col.width; wrapMode: Text.WordWrap; font.pixelSize: 20; color: info.fg
                text: T.t("All applications use the same positioning service of the phone, so this application cannot make the GPS itself faster. The first fix is quicker outdoors, with mobile data on (assisted GPS) and shortly after another fix.")
            }
            SectionLabel { text: T.t("Your privacy") }
            Text {
                width: col.width; wrapMode: Text.WordWrap; font.pixelSize: 20; color: info.fg
                text: T.t("Your position stays on the phone. The application does not send, store or share it. Only the map tiles for the area around you are downloaded from the selected map server.")
            }
            SectionLabel { text: T.t("About") }
            Text {
                width: col.width; wrapMode: Text.WordWrap; font.pixelSize: 20; color: info.fg
                text: T.t("Designed and written by Claude (Anthropic) together with smyhu for the Nokia N9.")
            }
            Text {
                width: col.width; wrapMode: Text.WordWrap; font.pixelSize: 18; color: "#818181"
                text: T.t("Inspired by the layout of GPS MeeFo by DV8 Creations; all code and graphics are new.") + "\n" +
                      "MIT License, © 2026 smyhu.\n" +
                      T.t("Maps: © OpenStreetMap contributors (OSM France, OpenTopoMap, CyclOSM), © Esri.")
            }
            Item { width: 1; height: 10 }
        }
    }
    ScrollDecorator { flickableItem: fl }
}
