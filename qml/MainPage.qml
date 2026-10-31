// GPS Info for Nokia N9 - main page.
// Panel order follows the classic GPS status layout: data from the GPS unit,
// satellite data with sky plot, average data with accuracy and position plot, map.
// The status box never blocks the page: tap it (or the dark area) to look around.
// Copyright (c) 2026 smyhu. MIT License.
import QtQuick 1.1
import com.nokia.meego 1.1
import QtMobility.location 1.2
import QtMobility.sensors 1.2
import "i18n.js" as T
import "geo.js" as Geo

Page {
    id: mainPage
    orientationLock: PageOrientation.LockPortrait
    tools: mainTools

    property color fg: theme.inverted ? "white" : "black"
    property color green: "#2d7707"
    property color greenLight: "#5bb600"

    // session state
    property bool gpsOn: false
    property bool fix: false
    property bool ended: false
    property bool dismissed: false
    property int samples: 0
    property real sumLat: 0
    property real sumLon: 0
    property real sumAlt: 0
    property int nAlt: 0
    property real sumSpeed: 0
    property int nSpeed: 0
    property real sumH: 0
    property int nH: 0
    property real sumV: 0
    property int nV: 0
    property real avgLat: 0       // updated once per sample (no half-updated values)
    property real avgLon: 0
    property variant lastPoints: []
    property variant lastStamp
    property int noFixSeconds: 0
    property bool started: false
    property double startTime: 0
    property int ttff: -1          // time to first fix, seconds

    // last known position (for the map before the first fix)
    property real knownLat: parseFloat(helper.setting("lastLat", "0"))
    property real knownLon: parseFloat(helper.setting("lastLon", "0"))
    property bool known: helper.setting("lastLat", "") != ""

    // which status box is due: "" | "off" | "search" | "ended"
    property string box: !gpsOn ? (ended ? "ended" : "off") : (!fix ? "search" : "")
    onBoxChanged: if (box == "off" || box == "ended") dismissed = false

    function hemi(v, isLat) {
        return Geo.coord(v, appWindow.notation, isLat ? T.t("N") : T.t("E"), isLat ? T.t("S") : T.t("W"))
    }
    function len(m) { return Geo.length(m, appWindow.units) }
    function speed1(ms) {
        return appWindow.units == "imperial" ? (ms * 3.28084).toFixed(1) + " ft/s" : ms.toFixed(1) + " m/s"
    }
    function speed2(ms) {
        return appWindow.units == "imperial" ? (ms * 2.2369363).toFixed(1) + " mph" : (ms * 3.6).toFixed(1) + " km/h"
    }
    function method(m) {
        if (m == PositionSource.SatellitePositioningMethod) return T.t("Satellite")
        if (m == PositionSource.NonSatellitePositioningMethod) return T.t("Network")
        if (m == PositionSource.AllPositioningMethods) return T.t("Satellite and network")
        return T.t("Not available")
    }

    function resetSession() {
        samples = 0; avgLat = 0; avgLon = 0; sumLat = 0; sumLon = 0; sumAlt = 0; nAlt = 0; sumSpeed = 0; nSpeed = 0
        sumH = 0; nH = 0; sumV = 0; nV = 0; lastPoints = []; fix = false; noFixSeconds = 0
        sats.clear()
    }
    function startGps() {
        ended = false
        dismissed = false
        sessionTimer.stop()
        gpsOn = true
        startTime = new Date().getTime()
        ttff = -1
        pos.active = true
        sats.start()
    }
    function stopGps() {
        gpsOn = false
        pos.active = false
        sats.stop()
        fix = false
    }
    function newSession() {
        stopGps()
        resetSession()
        startGps()
    }

    onStatusChanged: {
        if (status == PageStatus.Active && !started) {
            started = true
            if (appWindow.gpsOnStart) startGps()
        }
    }

    PositionSource {
        id: pos
        updateInterval: 1000
        active: false
    }

    Compass {
        id: compass
        active: Qt.application.active
    }
    property real heading: compass.reading ? compass.reading.azimuth : 0
    property real calibration: compass.reading ? compass.reading.calibrationLevel : 0

    // sample the receiver once a second
    Timer {
        interval: 1000
        repeat: true
        running: mainPage.gpsOn
        onTriggered: {
            var p = pos.position
            if (!(p.latitudeValid && p.longitudeValid) || p.timestamp == lastStamp) {
                if (++noFixSeconds > 10) fix = false
                return
            }
            lastStamp = p.timestamp
            noFixSeconds = 0
            var lat = p.coordinate.latitude, lon = p.coordinate.longitude
            if (!fix && samples == 0 && appWindow.autoStop) sessionTimer.restart()
            fix = true
            if (ttff < 0) ttff = Math.round((new Date().getTime() - startTime) / 1000)
            sumLat += lat; sumLon += lon
            samples++
            avgLat = sumLat / samples
            avgLon = sumLon / samples
            if (p.altitudeValid) { sumAlt += p.coordinate.altitude; nAlt++ }
            if (p.speedValid) { sumSpeed += p.speed; nSpeed++ }
            if (p.horizontalAccuracyValid) { sumH += p.horizontalAccuracy; nH++ }
            if (p.verticalAccuracyValid) { sumV += p.verticalAccuracy; nV++ }
            var pts = []
            for (var i = Math.max(0, lastPoints.length - 4); i < lastPoints.length; i++) pts.push(lastPoints[i])
            pts.push({"lat": lat, "lon": lon})
            lastPoints = pts
            if (samples == 1 || samples % 30 == 0) {
                helper.setSetting("lastLat", "" + avgLat)
                helper.setSetting("lastLon", "" + avgLon)
            }
            if (samples == 1) map.centre(avgLat, avgLon, 16)
        }
    }

    // stop after 5 minutes of fixes (battery), like the classic apps
    Timer {
        id: sessionTimer
        interval: 300000
        onTriggered: { stopGps(); ended = true }
    }

    // ------------------------------------------------------------------ page
    Rectangle { anchors.fill: parent; color: theme.inverted ? "black" : "white" }

    Flickable {
        id: flick
        anchors.fill: parent
        contentHeight: column.height + 40
        flickableDirection: Flickable.VerticalFlick
        clip: true

        Column {
            id: column
            x: 10
            y: 20
            width: flick.width - 20
            spacing: 10

            // status strip: shown while there is no fix; tap to open the status box
            Rectangle {
                visible: box != ""
                width: parent.width
                height: stripText.paintedHeight + 20
                radius: 10
                color: mainPage.green
                Text {
                    id: stripText
                    anchors.centerIn: parent
                    width: parent.width - 30
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                    font.pixelSize: 20
                    color: "white"
                    text: box == "off" ? T.t("GPS is off. Tap here to start.")
                        : box == "ended" ? T.t("Session finished. Tap here for options.")
                        : T.t("Searching: %1 satellites in view, %2 in use", sats.inView.length, sats.inUse.length)
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: { if (box == "off") startGps(); else dismissed = false }
                }
            }

            Header { text: T.t("Data from GPS unit") }
            DataRow { label: T.t("Active signal"); value: fix ? T.t("Yes") : T.t("No") }
            DataRow {
                label: T.t("Time to first fix")
                value: ttff >= 0 ? ttff + " s" : (gpsOn ? T.t("waiting…") : "–")
            }
            DataRow { label: T.t("Source"); value: gpsOn ? method(pos.positioningMethod) : "–" }
            DataRow { label: T.t("Latitude"); value: pos.position.latitudeValid ? hemi(pos.position.coordinate.latitude, true) : "–" }
            DataRow { label: T.t("Longitude"); value: pos.position.longitudeValid ? hemi(pos.position.coordinate.longitude, false) : "–" }
            DataRow { label: T.t("Altitude"); value: pos.position.altitudeValid ? len(pos.position.coordinate.altitude) : "–" }
            DataRow { label: T.t("Speed"); value: pos.position.speedValid ? speed1(pos.position.speed) : "–" }
            DataRow { label: T.t("Speed"); value: pos.position.speedValid ? speed2(pos.position.speed) : "–" }
            DataRow {
                label: T.t("Time")
                value: pos.position.latitudeValid ? Qt.formatDateTime(pos.position.timestamp, "yyyy-MM-dd  hh:mm:ss") : "–"
            }

            Item { width: 1; height: 20 }
            Header { text: T.t("Satellite data") }
            DataRow { label: T.t("Valid samples"); value: samples }
            DataRow { label: T.t("Satellites in view"); value: sats.inView.length }
            DataRow { label: T.t("Satellites in use"); value: sats.inUse.length }
            SignalBars { width: parent.width; satellites: sats.inView }
            SkyPlot {
                anchors.horizontalCenter: parent.horizontalCenter
                satellites: sats.inView
                heading: mainPage.heading
            }

            Item { width: 1; height: 20 }
            Header { text: T.t("Average data") }
            DataRow { label: T.t("Avg latitude"); value: samples > 0 ? hemi(avgLat, true) : "–" }
            DataRow { label: T.t("Avg longitude"); value: samples > 0 ? hemi(avgLon, false) : "–" }
            DataRow { label: T.t("Avg altitude"); value: nAlt > 0 ? len(sumAlt / nAlt) : "–" }
            DataRow { label: T.t("Avg speed"); value: nSpeed > 0 ? speed1(sumSpeed / nSpeed) : "–" }
            DataRow { label: T.t("Avg speed"); value: nSpeed > 0 ? speed2(sumSpeed / nSpeed) : "–" }
            DataRow {
                labelWidth: 260
                label: T.t("Horizontal accuracy")
                value: pos.position.horizontalAccuracyValid ? len(pos.position.horizontalAccuracy) : "–"
            }
            AccuracyBar {
                width: parent.width
                current: pos.position.horizontalAccuracyValid ? pos.position.horizontalAccuracy : -1
                average: nH > 0 ? sumH / nH : -1
            }
            DataRow {
                labelWidth: 260
                label: T.t("Vertical accuracy")
                value: pos.position.verticalAccuracyValid ? len(pos.position.verticalAccuracy) : "–"
            }
            AccuracyBar {
                width: parent.width
                current: pos.position.verticalAccuracyValid ? pos.position.verticalAccuracy : -1
                average: nV > 0 ? sumV / nV : -1
            }
            DataRow {
                labelWidth: 260
                label: T.t("Compass calibration")
                value: compass.reading ? Math.round(calibration * 100) + " %" : "–"
            }
            ScatterPlot {
                anchors.horizontalCenter: parent.horizontalCenter
                points: lastPoints
                lat0: avgLat
                lon0: avgLon
                units: appWindow.units
            }

            Item { width: 1; height: 10 }
            Rectangle {
                width: parent.width
                height: mapTitle.height + map.height + mapHint.height + 30
                radius: 5
                border.width: 1
                border.color: "#444444"
                color: theme.inverted ? "#222222" : "#d3d3d3"
                Text {
                    id: mapTitle
                    x: 10; y: 5
                    text: samples > 0 ? T.t("Map of average position") : T.t("Map of last known position")
                    font.pixelSize: 22
                    color: mainPage.fg
                }
                MapView {
                    id: map
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: mapTitle.bottom
                    anchors.topMargin: 8
                    // the map is centred once (first fix / last known position) and on tap,
                    // not every second - otherwise tiles keep being re-requested
                    Component.onCompleted: centre(knownLat, knownLon, known ? 16 : 2)
                    hasPosition: samples > 0 || known
                    source: parseInt(helper.setting("mapSource", "0"))
                    onSourceChanged: helper.setSetting("mapSource", "" + source)
                    onTapped: if (samples > 0) centre(avgLat, avgLon, zoom); else if (known) centre(knownLat, knownLon, zoom)
                }
                Text {
                    id: mapHint
                    x: 10
                    width: parent.width - 20 - mapBytes.width
                    anchors.top: map.bottom
                    anchors.topMargin: 5
                    text: T.t("Tap the map to centre it on your position")
                    wrapMode: Text.WordWrap
                    font.pixelSize: 18
                    color: "#818181"
                }
                Text {
                    id: mapBytes
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.top: map.bottom
                    anchors.topMargin: 5
                    text: "↓ " + map.size(tiles.bytes)
                    font.pixelSize: 18
                    color: tiles.pending > 0 ? "#7fcf3a" : "#818181"
                }
            }
        }
    }

    ScrollDecorator { flickableItem: flick }

    // ------------------------------------------------------------ status box
    Rectangle {
        id: dim
        anchors.fill: parent
        color: "black"
        opacity: boxShown ? 0.7 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 200 } }
        property bool boxShown: box != "" && !dismissed
        MouseArea {
            anchors.fill: parent
            onClicked: dismissed = true
        }
    }

    StatusBox {
        anchors.centerIn: parent
        visible: dim.boxShown
        mode: box
        onTapped: {
            if (box == "off") startGps()
            else dismissed = true
        }
        onViewLast: dismissed = true
        onNewSession: mainPage.newSession()
    }

    // ------------------------------------------------------------ menus
    Menu {
        id: shareMenu
        visualParent: pageStack
        MenuLayout {
            MenuItem {
                text: T.t("Copy average position")
                enabled: samples > 0
                onClicked: helper.copy(hemi(avgLat, true) + ", " + hemi(avgLon, false))
            }
            MenuItem {
                text: T.t("Copy as decimal degrees")
                enabled: samples > 0
                onClicked: helper.copy(Geo.plain(avgLat) + ", " + Geo.plain(avgLon))
            }
            MenuItem {
                text: T.t("Copy OpenStreetMap link")
                enabled: samples > 0
                onClicked: helper.copy("https://www.openstreetmap.org/?mlat=" + Geo.plain(avgLat) + "&mlon=" + Geo.plain(avgLon) + "#map=17/" + Geo.plain(avgLat) + "/" + Geo.plain(avgLon))
            }
            MenuItem {
                text: T.t("Open position in Maps")
                enabled: samples > 0
                onClicked: Qt.openUrlExternally("geo:" + Geo.plain(avgLat) + "," + Geo.plain(avgLon))
            }
        }
    }

    Menu {
        id: settingsMenu
        visualParent: pageStack
        MenuLayout {
            MenuItem {
                text: appWindow.units == "metric" ? T.t("Use imperial units") : T.t("Use metric units")
                onClicked: appWindow.units = (appWindow.units == "metric" ? "imperial" : "metric")
            }
            MenuItem {
                text: appWindow.notation == "degrees" ? T.t("Use decimal notation") : T.t("Use degrees notation")
                onClicked: appWindow.notation = (appWindow.notation == "degrees" ? "decimal" : "degrees")
            }
            MenuItem {
                text: appWindow.darkTheme ? T.t("Use light theme") : T.t("Use dark theme")
                onClicked: appWindow.darkTheme = !appWindow.darkTheme
            }
            MenuItem {
                text: T.t("Startup settings")
                onClicked: pageStack.push(Qt.resolvedUrl("IntroPage.qml"))
            }
        }
    }

    ToolBarLayout {
        id: mainTools
        ToolIcon {
            platformIconId: "toolbar-back"
            anchors.left: parent.left
            onClicked: Qt.quit()
        }
        ToolIcon {
            platformIconId: "toolbar-refresh"
            onClicked: newSession()
        }
        ToolIcon {
            platformIconId: "toolbar-settings"
            onClicked: settingsMenu.status == DialogStatus.Closed ? settingsMenu.open() : settingsMenu.close()
        }
        ToolIcon {
            platformIconId: "toolbar-share"
            onClicked: shareMenu.status == DialogStatus.Closed ? shareMenu.open() : shareMenu.close()
        }
        ToolIcon {
            platformIconId: "toolbar-view-menu"
            onClicked: pageStack.push(Qt.resolvedUrl("InfoPage.qml"))
        }
    }
}
