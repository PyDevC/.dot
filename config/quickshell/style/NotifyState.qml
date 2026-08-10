pragma Singleton
import QtQuick

QtObject {
    property bool centerOpen: false
    property int unread: 0

    function toggle() {
        centerOpen = !centerOpen
        if (centerOpen) unread = 0
    }

    function open() {
        centerOpen = true
        unread = 0
    }

    function close() {
        centerOpen = false
    }

    function notify() {
        if (!centerOpen) unread++
    }
}
