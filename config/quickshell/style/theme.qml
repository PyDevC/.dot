pragma Singleton
import QtQuick

QtObject {
    readonly property color foreground: "#9a9c9b"
    readonly property color foregroundInactive: "#ffffff"
    readonly property color background: "#001c03"

    readonly property color accent: "#bb9af7"
    readonly property color critical: "#f7768e"
    readonly property color muted: "#6b726e"

    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 14

    readonly property int barHeight: 28
    readonly property int pillRadius: 3
    readonly property int pillPadding: 7
    readonly property int pillMargin: 2
    readonly property int workspacePadding: 12
    readonly property int trayIconSize: 16
    readonly property int traySpacing: 16
}
