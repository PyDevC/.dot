import Quickshell
import QtQuick
import "bar"

ShellRoot {
    id: root

    Notifications {}

    Variants {
        model: Quickshell.screens
        delegate: Bar {
            required property var modelData
            screen: modelData
        }
    }
}
