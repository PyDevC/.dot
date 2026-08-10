import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQml.Models
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Wayland
import "../style"

Scope {
    id: root

    property int toastTimeout: 5000

    NotificationServer {
        id: server
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true

        onNotification: n => {
            n.tracked = true
            history.insert(0, {
                "summary": n.summary,
                "body": n.body,
                "appName": n.appName !== "" ? n.appName : (n.desktopEntry !== "" ? n.desktopEntry : "System"),
                "urgency": n.urgency,
                "time": Qt.formatDateTime(new Date(), "hh:mm")
            })
            NotifyState.notify()
        }
    }

    ListModel { id: history }

    IpcHandler {
        target: "notifications"
        property int historyCount: history.count
        property int trackedCount: server.trackedNotifications.values.length
        property bool centerOpen: NotifyState.centerOpen
        function toggle(): void { NotifyState.toggle() }
        function show(): void { NotifyState.open() }
        function hide(): void { NotifyState.close() }
    }

    PanelWindow {
        id: toasts
        visible: !NotifyState.centerOpen
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        anchors { top: true; right: true }
        margins { top: Theme.barHeight + 6; right: 12 }
        implicitWidth: 380
        implicitHeight: Math.max(1, toastsColumn.implicitHeight)

        Column {
            id: toastsColumn
            anchors.fill: parent
            spacing: 10

            Repeater {
                model: server.trackedNotifications

                Rectangle {
                    id: card
                    required property var modelData

                    width: toastsColumn.width
                    radius: 8
                    color: Theme.background
                    border.width: 2
                    border.color: card.modelData.urgency === NotificationUrgency.Critical ? Theme.critical : Theme.accent

                    Timer {
                        interval: root.toastTimeout
                        running: card.modelData.urgency !== NotificationUrgency.Critical
                        onTriggered: card.modelData.dismiss()
                    }

                    RowLayout {
                        id: cardLayout
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Image {
                            id: toastImage
                            visible: source.toString() !== ""
                            width: 36
                            height: 36
                            Layout.alignment: Qt.AlignTop
                            fillMode: Image.PreserveAspectFit
                            source: card.modelData.image.toString() !== ""
                                ? card.modelData.image
                                : (card.modelData.appIcon.toString() !== "" ? card.modelData.appIcon : "")
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                text: card.modelData.summary
                                color: Theme.accent
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            Text {
                                Layout.fillWidth: false
                                visible: card.modelData.body !== ""
                                width: toastsColumn.width - 20 - (toastImage.visible ? 46 : 0)
                                text: card.modelData.body
                                color: Theme.foreground
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 1
                                wrapMode: Text.WordWrap
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: card.modelData.dismiss()
                    }
                }
            }
        }
    }

    PanelWindow {
        id: center
        visible: NotifyState.centerOpen
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        anchors { top: true; right: true }
        margins { top: Theme.barHeight + 6; right: 12 }
        implicitWidth: 380
        implicitHeight: centerColumn.implicitHeight

        Rectangle {
            anchors.fill: parent
            color: Theme.background
            radius: 10
            border { width: 2; color: Theme.accent }

            ColumnLayout {
                id: centerColumn
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        Layout.fillWidth: true
                        text: "Notifications"
                        color: Theme.accent
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontSize + 2
                        font.bold: true
                    }

                    Item {
                        visible: history.count > 0
                        implicitWidth: clearText.implicitWidth
                        implicitHeight: clearText.implicitHeight

                        Text {
                            id: clearText
                            text: "Clear all"
                            color: Theme.critical
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontSize - 1
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: history.clear()
                        }
                    }
                }

                ListView {
                    id: historyList
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(historyList.contentHeight, 400)
                    model: history
                    clip: true
                    spacing: 10

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        background: Rectangle {
                            color: "transparent"
                        }
                        contentItem: Rectangle {
                            implicitWidth: 4
                            radius: 2
                            color: Theme.muted
                            opacity: parent.pressed ? 0.9 : 0.5
                        }
                    }

                    delegate: Item {
                        required property int index
                        required property var modelData

                        property bool expanded: false

                        width: historyList.width
                        height: Math.max(textContent.implicitHeight, metaColumn.implicitHeight) + 20

                        Rectangle {
                            anchors.fill: parent
                            radius: 8
                            color: Qt.rgba(255, 255, 255, 0.06)
                            border { width: 1; color: Theme.muted }
                        }

                        Column {
                            id: textContent
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - metaColumn.width - 30
                            spacing: 2

                            Text {
                                width: textContent.width
                                visible: modelData.appName !== ""
                                text: modelData.appName
                                color: Theme.muted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 2
                                elide: Text.ElideRight
                            }

                            Text {
                                width: textContent.width
                                text: modelData.summary
                                color: Theme.foregroundInactive
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize
                                font.bold: true
                                elide: Text.ElideRight
                            }

                            Text {
                                id: bodyText
                                width: textContent.width
                                visible: modelData.body !== ""
                                text: modelData.body
                                color: Theme.foreground
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 1
                                wrapMode: Text.WordWrap
                                maximumLineCount: expanded ? -1 : 3
                                elide: Text.ElideRight
                            }

                            Text {
                                id: toggleText
                                width: textContent.width
                                visible: modelData.body !== "" && (expanded || bodyText.truncated)
                                text: expanded ? "Show less" : "Show more"
                                color: Theme.accent
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 2
                                font.bold: true

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: expanded = !expanded
                                }
                            }
                        }

                        Item {
                            id: metaColumn
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.top: parent.top
                            anchors.topMargin: 10
                            implicitWidth: Math.max(timeText.implicitWidth, closeText.implicitWidth)
                            implicitHeight: timeText.implicitHeight + closeText.implicitHeight + 8

                            Text {
                                id: timeText
                                anchors.top: parent.top
                                anchors.right: parent.right
                                text: modelData.time
                                color: Theme.muted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize - 2
                            }

                            Text {
                                id: closeText
                                anchors.top: timeText.bottom
                                anchors.topMargin: 8
                                anchors.right: parent.right
                                text: "✕"
                                color: Theme.muted
                                font.family: Theme.fontFamily
                                font.pixelSize: Theme.fontSize

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: history.remove(index)
                                }
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    visible: history.count === 0
                    text: "No notifications"
                    color: Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontSize
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}
