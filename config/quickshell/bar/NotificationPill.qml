import QtQuick
import QtQuick.Layouts
import "../style"

Rectangle {
    id: root
    color: Theme.background
    radius: Theme.pillRadius
    Layout.fillHeight: true
    Layout.leftMargin: Theme.pillMargin
    implicitWidth: bellLabel.implicitWidth + Theme.pillPadding * 2

    property bool hovered: false

    Text {
        id: bellLabel
        anchors.centerIn: parent
        text: "󰂚"
        color: NotifyState.centerOpen ? Theme.accent : Theme.foreground
        style: root.hovered ? Text.Sunken : Text.Normal
        styleColor: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }

    Rectangle {
        id: badge
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 2
        anchors.rightMargin: 2
        visible: NotifyState.unread > 0
        width: Math.max(12, badgeLabel.implicitWidth + 6)
        height: 12
        radius: 6
        color: Theme.critical

        Text {
            id: badgeLabel
            anchors.centerIn: parent
            text: NotifyState.unread > 99 ? "99+" : NotifyState.unread
            color: "#ffffff"
            font.family: Theme.fontFamily
            font.pixelSize: 8
            font.bold: true
        }
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
        onClicked: NotifyState.toggle()
    }
}
