import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    spacing: 0

    Battery {}
    Memory {}
    Network {}
    Bluetooth {}
    NotificationPill {}
}
