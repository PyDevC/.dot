import QtQuick
import QtQuick.Layouts
import "../style"

Rectangle {
    id: root
    color: Theme.background
    radius: Theme.pillRadius
    Layout.fillHeight: true
    Layout.leftMargin: Theme.pillMargin
    implicitWidth: batteryLabel.implicitWidth + Theme.pillPadding * 2

    Text {
        id: batteryLabel
        anchors.centerIn: parent
        text: "󰂯"
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }
}
