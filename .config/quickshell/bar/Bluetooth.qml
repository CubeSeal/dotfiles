import QtQuick
import Quickshell
import Quickshell.Bluetooth

import "../theme"
import "../state"

// waybar bluetooth: icon only when idle; icon + battery "{pct}/100" for a
// connected device that reports battery; icon + device name otherwise.
// On-click toggles the Bluetooth quick-connect dropdown.
Item {
    id: root
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    readonly property var dev: {
        const list = Bluetooth.devices ? Bluetooth.devices.values : [];
        for (const d of list)
            if (d.connected) return d;
        return null;
    }

    Row {
        id: row
        spacing: 4

        Text {
            text: ""
            color: Theme.accentLauncher
            font.family: Theme.symbolFont
            font.pixelSize: Theme.barFontSize
        }

        Text {
            visible: root.dev !== null
            text: {
                if (!root.dev) return "";
                if (root.dev.batteryAvailable)
                    return Math.round((root.dev.battery <= 1 ? root.dev.battery * 100 : root.dev.battery)) + "/100";
                return root.dev.name;
            }
            color: Theme.barFg
            font.family: Theme.barFont
            font.pixelSize: Theme.barFontSize
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Globals.toggleBluetooth()
    }
}
