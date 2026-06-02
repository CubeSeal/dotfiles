import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import "../theme"
import "../state"
import "../services"
import "../notifications"   // PillButton

// Quick-connect Wi-Fi dropdown, toggled from the bar network icon. Same overlay
// shape as launcher/Launcher.qml (transparent full-screen PanelWindow + a
// click-catcher that closes on click-outside), but the panel is anchored
// top-right under the bar like the notification toasts. State + actions come
// from the Wifi singleton; this is display + click wiring only.
PanelWindow {
    id: win
    visible: Globals.wifiOpen
    color: "transparent"

    anchors { top: true; bottom: true; left: true; right: true }
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    // Click-driven, no text entry — don't steal focus from the focused app.
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    onVisibleChanged: if (visible) { Wifi.refresh(); Wifi.rescan(); }

    // Click outside the panel closes it.
    MouseArea {
        anchors.fill: parent
        onClicked: Globals.closeWifi()
    }

    Rectangle {
        id: panel
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: Theme.barHeight + 8
        anchors.rightMargin: 12
        width: 320
        implicitHeight: col.implicitHeight + 24
        radius: Theme.panelRadius
        color: Theme.bg
        border.width: Theme.panelBorder
        border.color: Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.7)

        // Swallow clicks so they don't fall through to the close handler.
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
                    text: "Wi-Fi"
                    color: Theme.fg
                    font.family: Theme.uiFont
                    font.pixelSize: 16
                    font.bold: true
                }
                PillButton {
                    label: Wifi.enabled ? "On" : "Off"
                    onClicked: Wifi.setRadio(!Wifi.enabled)
                }
            }

            Text {
                Layout.fillWidth: true
                visible: Wifi.networks.length === 0
                text: Wifi.enabled ? "No networks found" : "Wi-Fi is off"
                color: Theme.fg
                opacity: 0.7
                font.family: Theme.uiFont
                font.pixelSize: 13
            }

            Repeater {
                model: Wifi.networks
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

                        Text {   // check on the active network
                            Layout.preferredWidth: 14
                            text: row.modelData.active ? String.fromCharCode(0xF00C) : ""
                            color: Theme.cyan
                            font.family: Theme.symbolFont
                            font.pixelSize: 13
                        }
                        Text {
                            Layout.fillWidth: true
                            text: row.modelData.ssid
                            color: Theme.fg
                            font.family: Theme.uiFont
                            font.pixelSize: 14
                            elide: Text.ElideRight
                        }
                        Text {   // lock if secured
                            visible: row.modelData.secured
                            text: String.fromCharCode(0xF023)
                            color: Theme.fg
                            opacity: 0.8
                            font.family: Theme.symbolFont
                            font.pixelSize: 12
                        }
                        Text {   // signal %
                            text: row.modelData.signal + "%"
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
                        onClicked: Wifi.activate(row.modelData)
                    }
                }
            }

            PillButton {
                Layout.fillWidth: true
                label: "Advanced… (nmtui)"
                onClicked: {
                    Quickshell.execDetached(["kitty", "-e", "nmtui"]);
                    Globals.closeWifi();
                }
            }
        }
    }
}
