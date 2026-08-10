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
    implicitWidth: memLabel.implicitWidth + Theme.pillPadding * 2

    property string used: "0.0"

    Process {
        id: memProc
        command: ["sh", "-c",
            "awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf \"%.1f\", (t-a)/1024/1024}' /proc/meminfo"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.used = this.text.trim()
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: memProc.exec(memProc.command)
    }

    Text {
        id: memLabel
        anchors.centerIn: parent
        text: " " + root.used + "G"
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }
}
