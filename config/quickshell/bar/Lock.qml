import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../style"

Rectangle {
    id: root
    color: Theme.background
    radius: Theme.pillRadius
    Layout.fillHeight: true
    Layout.leftMargin: Theme.pillMargin
    implicitWidth: lockLabel.implicitWidth + Theme.pillPadding * 2

    property bool hovered: false

    Text {
        id: lockLabel
        anchors.centerIn: parent
        text: ""
        color: Theme.foreground
        style: root.hovered ? Text.Sunken : Text.Normal
        styleColor: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.pillRadius
        color: "transparent"
        border.width: 1
        border.color: Theme.foreground
        opacity: root.hovered ? 0.5 : 0
        visible: root.hovered
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: root.hovered = true
        onExited: root.hovered = false
        onClicked: lockProc.startDetached()
    }

    Process {
        id: lockProc
        command: ["sh", "-c", "(sleep 0.5s; hyprlock) & disown"]
    }
}
