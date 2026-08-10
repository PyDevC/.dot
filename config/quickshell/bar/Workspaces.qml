import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "../style"

RowLayout {
    id: root
    spacing: 0

    Repeater {
        model: Hyprland.workspaces

        delegate: Rectangle {
            id: pill
            required property var modelData

            visible: modelData.toplevels.values.length > 0 || modelData.active
            color: Theme.background
            radius: 0
            Layout.fillHeight: true
            implicitWidth: label.implicitWidth + Theme.workspacePadding * 2

            Text {
                id: label
                anchors.centerIn: parent
                text: modelData.id
                color: modelData.active ? Theme.foreground : Theme.foregroundInactive
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontSize
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                anchors.fill: parent
                onClicked: modelData.activate()
            }
        }
    }
}
