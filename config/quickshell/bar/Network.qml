import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking
import "../style"

Rectangle {
    id: root
    color: Theme.background
    radius: Theme.pillRadius
    Layout.fillHeight: true
    Layout.leftMargin: Theme.pillMargin
    implicitWidth: netLabel.implicitWidth + Theme.pillPadding * 2

    property bool hovered: false
    property string tooltipText: ""

    readonly property var wifiDevice: {
        const devices = Networking.devices.values
        for (let i = 0; i < devices.length; ++i) {
            if (devices[i].type === DeviceType.Wifi) return devices[i]
        }
        return null
    }

    function activeWifiNetwork(device) {
        const networks = device.networks.values
        for (let i = 0; i < networks.length; ++i) {
            if (networks[i].connected) return networks[i]
        }
        return null
    }

    function wifiIcon(strength) {
        const icons = ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"]
        let index = 0
        if (strength > 80) index = 4
        else if (strength > 60) index = 3
        else if (strength > 40) index = 2
        else if (strength > 20) index = 1
        return icons[index]
    }

    function stateText() {
        if (!Networking.wifiEnabled) return { glyph: "󰸭", tooltip: "Networking disabled" }

        const devices = Networking.devices.values
        for (let i = 0; i < devices.length; ++i) {
            const device = devices[i]
            if (device.connected) {
                if (device.type === DeviceType.Wifi) {
                    const net = activeWifiNetwork(device)
                    const strength = net != null ? Math.round(net.signalStrength * 100) : 0
                    const ssid = net != null ? net.name : ""
                    return { glyph: wifiIcon(strength), tooltip: ssid + " (" + strength + "%)" }
                }
                if (device.type === DeviceType.Ethernet) {
                    return { glyph: "󰲝", tooltip: "Ethernet" }
                }
            }
        }

        return { glyph: "󰲜", tooltip: "Disconnected" }
    }

    function onNetworkClicked(net) {
        if (net.connected) {
            net.disconnect()
            menu.visible = false
            return
        }
        if (net.known || net.security === WifiSecurityType.Open || net.security === WifiSecurityType.Owe) {
            net.connect()
            menu.visible = false
            return
        }
        pskTarget = net
        passwordRow.height = 32
        pskField.forceActiveFocus()
    }

    Text {
        id: netLabel
        anchors.centerIn: parent
        text: root.stateText().glyph
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

    property var pskTarget: null

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
                id: wifiHeader
                width: menuContent.width
                height: 30
                color: Qt.rgba(255, 255, 255, 0.06)
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Wi-Fi"
                    color: Theme.foregroundInactive
                    font.bold: true
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                }
                Text {
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: Networking.wifiEnabled ? "󰖪" : "󰖩"
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        Networking.wifiEnabled = !Networking.wifiEnabled
                        menu.visible = false
                    }
                }
            }

            Rectangle {
                id: wifiHint
                width: menuContent.width
                height: root.wifiDevice == null ? 28 : (Networking.wifiEnabled ? 0 : 28)
                color: "transparent"
                Text {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    text: root.wifiDevice == null ? "No Wi-Fi adapter" : "Wi-Fi disabled"
                    color: Theme.foregroundInactive
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                }
            }

            ListView {
                id: networkList
                width: menuContent.width
                height: Math.min(networkList.contentHeight, 300)
                clip: true
                visible: root.wifiDevice != null && Networking.wifiEnabled
                model: root.wifiDevice != null ? root.wifiDevice.networks.values : []

                delegate: Rectangle {
                    width: networkList.width
                    height: 28
                    color: hover.containsMouse ? Qt.rgba(255, 255, 255, 0.08) : "transparent"

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.wifiIcon(Math.round(modelData.signalStrength * 100))
                        color: modelData.connected ? Theme.foreground : Theme.foregroundInactive
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                    }
                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 32
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - 60
                        text: modelData.name
                        elide: Text.ElideRight
                        color: modelData.connected ? Theme.foreground : Theme.foregroundInactive
                        font.family: Theme.fontFamily
                        font.pixelSize: 13
                    }
                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.connected ? "󰄲" : (modelData.known ? "󰄭" : "󰄯")
                        color: Theme.foreground
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                    }
                    MouseArea {
                        id: hover
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.onNetworkClicked(modelData)
                    }
                }
            }

            Rectangle {
                id: passwordRow
                width: menuContent.width
                height: 0
                color: Qt.rgba(255, 255, 255, 0.04)
                clip: true
                TextInput {
                    id: pskField
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - 60
                    echoMode: TextInput.Password
                    color: Theme.foreground
                    font.family: Theme.fontFamily
                    font.pixelSize: 13
                    onAccepted: connectButton.clicked()
                }
                Rectangle {
                    id: connectButton
                    anchors.right: parent.right
                    anchors.rightMargin: 6
                    anchors.verticalCenter: parent.verticalCenter
                    width: 40
                    height: 22
                    radius: 2
                    color: Theme.foreground
                    Text {
                        anchors.centerIn: parent
                        text: "OK"
                        color: Theme.background
                        font.family: Theme.fontFamily
                        font.pixelSize: 12
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (root.pskTarget != null && pskField.text.length > 0) {
                                root.pskTarget.connectWithPsk(pskField.text)
                            }
                            pskField.text = ""
                            passwordRow.height = 0
                            menu.visible = false
                        }
                    }
                }
            }
        }
    }
}
