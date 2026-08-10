import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../style"

Rectangle {
    id: root
    color: Theme.background
    radius: Theme.pillRadius
    Layout.fillHeight: true
    Layout.leftMargin: Theme.pillMargin
    implicitWidth: trayRow.implicitWidth + Theme.pillPadding * 2

    RowLayout {
        id: trayRow
        anchors.centerIn: parent
        spacing: Theme.traySpacing

        Repeater {
            model: SystemTray.items

            delegate: Item {
                id: trayItem
                required property var modelData

                implicitWidth: Theme.trayIconSize
                implicitHeight: Theme.trayIconSize
                Layout.alignment: Qt.AlignVCenter

                IconImage {
                    anchors.centerIn: parent
                    implicitSize: Theme.trayIconSize
                    source: {
                        const raw = trayItem.modelData.icon
                        if (!raw) return ""
                        if (raw.startsWith("data:")) return raw
                        if (raw.includes("://")) return raw
                        if (raw.startsWith("/")) return "file://" + raw
                        return "image://icon/" + raw
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onClicked: (mouse) => {
                        if (trayItem.modelData.hasMenu) trayMenu.open()
                        else if (mouse.button === Qt.RightButton) trayItem.modelData.secondaryActivate()
                        else trayItem.modelData.activate()
                    }
                }

                QsMenuAnchor {
                    id: trayMenu
                    menu: trayItem.modelData.menu
                    anchor.item: trayItem
                }
            }
        }
    }
}
