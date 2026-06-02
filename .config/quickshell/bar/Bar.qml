import QtQuick
import QtQuick.Layouts
import Quickshell

import "../theme"
import "../state"
import "../services"

// Top bar, one per screen. Reproduces the waybar layout: three rounded
// gradient sections (left / centre / right).
Variants {
    model: Quickshell.screens

    PanelWindow {
        id: bar
        required property var modelData
        screen: modelData

        visible: Globals.barVisible
        color: "transparent"

        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: Theme.barHeight
        exclusiveZone: visible ? Theme.barHeight : 0

        // --- left: workspaces + the custom buttons ---
        Pill {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 8

            RowLayout {
                spacing: 10
                Workspaces { output: bar.screen ? bar.screen.name : "" }
                IconButton {
                    glyph: ""
                    tooltip: "Rotate screen left"
                    onClicked: Niri.cycleRotation()
                }
                IconButton {
                    glyph: "󱓞"
                    glyphColor: Theme.accentLauncher
                    tooltip: "Launcher"
                    onClicked: Globals.toggleLauncher()
                }
                IconButton {
                    glyph: ""
                    glyphColor: Theme.accentReboot
                    tooltip: "Reboot"
                    onClicked: Quickshell.execDetached(["systemctl", "reboot"])
                }
                IconButton {
                    glyph: ""
                    glyphColor: Theme.accentPower
                    tooltip: "Poweroff"
                    onClicked: Quickshell.execDetached(["systemctl", "poweroff"])
                }
            }
        }

        // --- centre: focused window ---
        Pill {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            WindowTitle {}
        }

        // --- right: status ---
        Pill {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 8

            RowLayout {
                spacing: 10
                Battery {}
                Volume {}
                Bluetooth {}
                Network {}
                Clock {}
            }
        }
    }
}
