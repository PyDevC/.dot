import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import "../style"

Rectangle {
    id: root
    color: Theme.background
    radius: Theme.pillRadius
    Layout.fillHeight: true
    Layout.leftMargin: Theme.pillMargin
    implicitWidth: volumeLabel.implicitWidth + Theme.pillPadding * 2

    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool hasSink: sink != null
    readonly property real volume: hasSink && sink.audio != null ? sink.audio.volume : 0
    readonly property bool muted: hasSink && sink.audio != null ? sink.audio.muted : false
    readonly property int percent: Math.round(volume * 100)

    function slider(percent) {
        const filled = Math.floor(percent / 10)
        let result = ""
        for (let i = 0; i < 10; ++i) result += i < filled ? "▰" : "▱"
        return result
    }

    Text {
        id: volumeLabel
        anchors.centerIn: parent
        text: root.muted ? " MUTED" : " " + root.slider(root.percent) + " " + root.percent + "%"
        color: Theme.foreground
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSize
    }

    MouseArea {
        anchors.fill: parent
        onWheel: {
            const delta = wheel.angleDelta.y > 0 ? 0.05 : -0.05
            root.sink.audio.volume = Math.max(0, Math.min(1, root.volume + delta))
        }
        onClicked: root.sink.audio.muted = !root.muted
    }
}
