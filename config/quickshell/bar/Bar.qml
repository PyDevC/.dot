import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../style"

PanelWindow {
    id: bar
    property var modelData

    screen: modelData
    anchors {
        top: true
        left: true
        right: true
    }
    aboveWindows: true
    exclusiveZone: implicitHeight
    color: "transparent"

    implicitHeight: Theme.barHeight

    RowLayout {
        id: barRow
        anchors.fill: parent
        spacing: 0

        Workspaces {}

        Item {
            Layout.fillWidth: true
        }

        Clock {}
        Volume {}
        NetGroup {}
        Tray {}
        Lock {}
    }
}
