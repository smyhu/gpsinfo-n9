// GPS Info for Nokia N9 - application window.
// Copyright (c) 2026 smyhu. MIT License.
import QtQuick 1.1
import com.nokia.meego 1.1
import "i18n.js" as T

PageStackWindow {
    id: appWindow
    showStatusBar: true

    // settings (saved by the native helper in ~/.config/gpsinfo-n9)
    property string units: helper.setting("units", "metric")        // metric | imperial
    property string notation: helper.setting("notation", "degrees") // degrees | decimal
    property bool darkTheme: helper.setting("dark", "true") == "true"
    property bool skipIntro: helper.setting("skipIntro", "false") == "true"
    property bool gpsOnStart: helper.setting("gpsOnStart", "false") == "true"
    property bool autoStop: helper.setting("autoStop", "true") == "true"

    function save(key, value) { helper.setSetting(key, "" + value) }
    onUnitsChanged: save("units", units)
    onNotationChanged: save("notation", notation)
    onDarkThemeChanged: { theme.inverted = darkTheme; save("dark", darkTheme) }
    onSkipIntroChanged: save("skipIntro", skipIntro)
    onGpsOnStartChanged: save("gpsOnStart", gpsOnStart)
    onAutoStopChanged: save("autoStop", autoStop)

    Component.onCompleted: theme.inverted = darkTheme

    initialPage: SplashPage { }

    // one transition only: splash -> intro (back goes on to main) or splash -> main
    Timer {
        interval: 1200
        running: true
        onTriggered: {
            if (skipIntro)
                pageStack.replace(Qt.resolvedUrl("MainPage.qml"))
            else
                pageStack.replace(Qt.resolvedUrl("IntroPage.qml"), { "atStart": true })
        }
    }
}
