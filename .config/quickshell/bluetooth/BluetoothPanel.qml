import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Bluetooth

import "../theme"
import "../state"
import "../notifications"   // PillButton

// Quick-connect Bluetooth dropdown, toggled from the bar bluetooth icon. Same
// overlay shape as WifiPanel. Bluetooth is native via Quickshell.Bluetooth, so
// no shelling out: adapter toggle + per-device connect/disconnect. Pairing a new
// device is out of scope and hands off to overskride.
PanelWindow {
    id: win
    // Stay mapped through the fade-out so the exit animation can play.
    property bool shouldShow: Globals.bluetoothOpen
    visible: shouldShow || panel.opacity > 0
    color: "transparent"

    anchors { top: true; bottom: true; left: true; right: true }
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    // Mouse-only, no text entry: never take keyboard focus. This also lets a
    // click on the bar icon close the pane on the first click (with OnDemand,
    // niri eats the first click just to focus the surface).
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var devices: {
        const list = Bluetooth.devices ? Bluetooth.devices.values : [];
        return list.filter(d => d.paired);
    }

    MouseArea {
        anchors.fill: parent
        onClicked: Globals.closeBluetooth()
    }

    Rectangle {
        id: panel
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: Theme.barHeight + 2
        anchors.rightMargin: 12
        width: 320
        implicitHeight: col.implicitHeight + 24
        radius: Theme.panelRadius
        color: Theme.bg
        border.width: Theme.panelBorder
        border.color: Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.7)

        // Fade + slide-down on open, reversed on close.
        opacity: win.shouldShow ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.animDuration; easing.type: Theme.animEasing } }
        transform: Translate {
            y: win.shouldShow ? 0 : -8
            Behavior on y { NumberAnimation { duration: Theme.animDuration; easing.type: Theme.animEasing } }
        }

        MouseArea { anchors.fill: parent }

        ColumnLayout {
            id: col
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: "Bluetooth"
                    color: Theme.fg
                    font.family: Theme.uiFont
                    font.pixelSize: 16
                    font.bold: true
                }
                PillButton {
                    visible: win.adapter !== null
                    label: (win.adapter && win.adapter.enabled) ? "On" : "Off"
                    onClicked: if (win.adapter) win.adapter.enabled = !win.adapter.enabled
                }
            }

            Text {
                Layout.fillWidth: true
                visible: win.adapter === null || win.devices.length === 0
                text: win.adapter === null ? "No adapter" : "No paired devices"
                color: Theme.fg
                opacity: 0.7
                font.family: Theme.uiFont
                font.pixelSize: 13
            }

            Repeater {
                model: win.devices
                Rectangle {
                    id: row
                    required property var modelData
                    Layout.fillWidth: true
                    implicitHeight: 30
                    radius: 6
                    color: rowHover.hovered ? Qt.rgba(Theme.cyan.r, Theme.cyan.g, Theme.cyan.b, 0.25)
                                            : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 6
                        anchors.rightMargin: 6
                        spacing: 8

                        Text {   // check on connected devices
                            Layout.preferredWidth: 14
                            text: row.modelData.connected ? String.fromCharCode(0xF00C) : ""
                            color: Theme.cyan
                            font.family: Theme.symbolFont
                            font.pixelSize: 13
                        }
                        Text {
                            Layout.fillWidth: true
                            text: row.modelData.name
                            color: Theme.fg
                            font.family: Theme.uiFont
                            font.pixelSize: 14
                            elide: Text.ElideRight
                        }
                        Text {   // battery if reported
                            visible: row.modelData.batteryAvailable
                            text: {
                                const b = row.modelData.battery;
                                return Math.round((b <= 1 ? b * 100 : b)) + "%";
                            }
                            color: Theme.fg
                            opacity: 0.6
                            font.family: Theme.uiFont
                            font.pixelSize: 12
                        }
                    }

                    HoverHandler { id: rowHover }
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (row.modelData.connected)
                                row.modelData.disconnect();
                            else
                                row.modelData.connect();
                        }
                    }
                }
            }

            PillButton {
                Layout.fillWidth: true
                label: "Pair new… (overskride)"
                onClicked: {
                    Quickshell.execDetached(["overskride"]);
                    Globals.closeBluetooth();
                }
            }
        }
    }
}
