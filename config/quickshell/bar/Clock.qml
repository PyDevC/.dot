import Quickshell
import QtQuick
import QtQuick.Layouts
import "../style"

Rectangle {
    id: root
    color: Theme.background
    radius: Theme.pillRadius
    Layout.fillHeight: true
    Layout.leftMargin: Theme.pillMargin
    implicitWidth: timeLabel.implicitWidth + Theme.pillPadding * 2

    SystemClock {
        id: systemClock
        precision: SystemClock.Minutes
    }

    function kolkataTime() {
        const now = systemClock.date
        const kolkata = new Date(now.getTime() + (5 * 60 + 30) * 60000)
        const hours = String(kolkata.getUTCHours()).padStart(2, "0")
        const minutes = String(kolkata.getUTCMinutes()).padStart(2, "0")
        return hours + ":" + minutes
    }

    Text {
        id: timeLabel
        anchors.centerIn: parent
        text: root.kolkataTime()
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }
}
