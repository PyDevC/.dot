import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import "../style"

Rectangle {
    id: root
    color: Theme.background
    radius: Theme.pillRadius
    Layout.fillHeight: true
    Layout.leftMargin: Theme.pillMargin
    implicitWidth: btLabel.implicitWidth + Theme.pillPadding * 2

    property bool hovered: false

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool hasAdapter: adapter != null
    property var pairingDevice: null

    function anyConnected() {
        if (!hasAdapter) return false
        const devices = adapter.devices.values
        for (let i = 0; i < devices.length; ++i) {
            if (devices[i].connected) return true
        }
        return false
    }

    function iconGlyph() {
        if (!hasAdapter || !adapter.enabled) return "󰂲"
        if (anyConnected()) return "󰂱"
        return "󰂯"
    }

    function deviceGlyph(icon) {
        if (icon == null) return "󰂯"
        if (icon.includes("audio")) return "󰋋"
        if (icon.includes("input") || icon.includes("mouse") || icon.includes("keyboard")) return "󰊠"
        if (icon.includes("phone")) return "󰏲"
        if (icon.includes("computer")) return "󰍹"
        return "󰂯"
    }

    function deviceName(dev) {
        return dev.name !== "" ? dev.name : dev.deviceName
    }

    function deviceState(dev) {
        if (dev.connected) return "󰄲 Connected"
        if (dev.pairing) return "󰄉 Pairing..."
        if (dev.paired) return "󰄭 Paired"
        return ""
    }

    function toggleDevice(dev) {
        if (dev.connected) {
            dev.disconnect()
            menu.visible = false
            return
        }
        if (dev.paired) {
            dev.connect()
            menu.visible = false
            return
        }
        root.pairingDevice = dev
        dev.pair()
        pairingTimer.restart()
    }

    function sendFile(dev) {
        const addr = dev.address
        sendProc.command = ["bluetooth-sendto", "--device", addr]
        sendProc.startDetached()
        menu.visible = false
    }

    function toggleScan() {
        if (!root.hasAdapter) return
        if (scanProc.running) {
            scanProc.running = false
        } else {
            scanProc.command = ["bluetoothctl", "--timeout", "12", "scan", "on"]
            scanProc.running = true
        }
    }

    function receiveFile() {
        obexProc.command = ["/usr/libexec/bluetooth/obexd", "-a", "-r", "Downloads"]
        obexProc.startDetached()
        menu.visible = false
    }

    Text {
        id: btLabel
        anchors.centerIn: parent
        text: root.iconGlyph()
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
        onClicked: {
            if (menu.visible) menu.visible = false
            else {
                menu.anchor.updateAnchor()
                menu.visible = true
            }
        }
    }

    Process { id: sendProc }
    Process { id: obexProc }

    Process {
        id: scanProc
    }

    Timer {
        id: pairingTimer
        interval: 2000
        repeat: false
        onTriggered: {
            if (root.pairingDevice != null && root.pairingDevice.paired) {
                root.pairingDevice.connect()
            }
            root.pairingDevice = null
        }
    }

    PopupWindow {
        id: menu
        visible: false
        grabFocus: true
        color: Theme.background
        implicitWidth: 260
        implicitHeight: menuContent.childrenRect.height
        onClosed: menu.visible = false

        anchor {
            item: root
            edges: { bottom: true; left: true }
            gravity: { top: true; left: true }
        }

        Column {
            id: menuContent
            anchors.fill: parent
            spacing: 0
            clip: true

            Item {
                width: menuContent.width
                height: 2
            }

            Rectangle {
                id: btHeader
                width: menuContent.width
                height: 30
                color: Qt.rgba(255, 255, 255, 0.06)
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Bluetooth"
                    color: Theme.foregroundInactive
                    font.bold: true
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                }
                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.hasAdapter && root.adapter.enabled ? "󰂯" : "󰂲"
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (root.hasAdapter) {
                            root.adapter.enabled = !root.adapter.enabled
                        }
                        menu.visible = false
                    }
                }
            }

            Rectangle {
                id: btHint
                width: menuContent.width
                height: !root.hasAdapter || !root.adapter.enabled ? 28 : 0
                color: "transparent"
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.hasAdapter ? "Bluetooth disabled" : "No Bluetooth adapter"
                    color: Theme.foregroundInactive
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                }
            }

            Rectangle {
                id: scanRow
                width: menuContent.width
                height: root.hasAdapter && root.adapter.enabled ? 28 : 0
                color: hover.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : "transparent"
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: scanProc.running ? "󰄉  Scanning..." : "󰍉  Scan for devices"
                    color: Theme.foregroundInactive
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                }
                MouseArea {
                    id: hover
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.toggleScan()
                }
            }

            ListView {
                id: deviceList
                width: menuContent.width
                height: Math.min(deviceList.contentHeight, 300)
                clip: true
                visible: root.hasAdapter && root.adapter.enabled
                model: root.hasAdapter ? root.adapter.devices.values : []

                delegate: Rectangle {
                    width: deviceList.width
                    height: 28
                    color: rowHover.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : "transparent"

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.deviceGlyph(modelData.icon)
                        color: modelData.connected ? Theme.foreground : Theme.foregroundInactive
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                    }
                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 32
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 130
                        text: root.deviceName(modelData)
                        elide: Text.ElideRight
                        color: modelData.connected ? Theme.foreground : Theme.foregroundInactive
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                    }
                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 36
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.deviceState(modelData)
                        color: Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                    }
                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 12
                        anchors.verticalCenter: parent.verticalCenter
                        text: "󰓥"
                        color: Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                    }
                    MouseArea {
                        id: sendBtn
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.bottom: parent.bottom
                        width: 28
                        hoverEnabled: true
                        onClicked: root.sendFile(modelData)
                    }
                    MouseArea {
                        id: rowHover
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.toggleDevice(modelData)
                    }
                }
            }

            Rectangle {
                id: receiveRow
                width: menuContent.width
                height: root.hasAdapter && root.adapter.enabled ? 28 : 0
                color: receiveHover.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : "transparent"
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰶫  Receive file"
                    color: Theme.foregroundInactive
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                }
                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: "→ ~/Downloads"
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: 12
                }
                MouseArea {
                    id: receiveHover
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.receiveFile()
                }
            }
        }
    }
}
