import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

import "../theme"
import "../state"
import "../services"

// Brightness slider dropdown, toggled from the bar brightness icon. Same
// overlay shape as WifiPanel / BluetoothPanel. The slider is hand-rolled
// (Rectangle + MouseArea) rather than QtQuick.Controls, matching the rest of
// the shell's no-Controls approach on layer-shell surfaces.
PanelWindow {
    id: win
    // Stay mapped through the fade-out so the exit animation can play.
    property bool shouldShow: Globals.brightnessOpen
    visible: shouldShow || panel.opacity > 0
    color: "transparent"

    anchors { top: true; bottom: true; left: true; right: true }
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    // Mouse-only, no text entry: never take keyboard focus (see BluetoothPanel).
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    onVisibleChanged: if (visible) Brightness.refresh()

    // Click outside the panel closes it.
    MouseArea {
        anchors.fill: parent
        onClicked: Globals.closeBrightness()
    }

    Rectangle {
        id: panel
        anchors.top: parent.top
        anchors.right: parent.right
        // The bar's exclusive zone already shrinks this overlay to start below
        // the bar, so this is just the small gap under it.
        anchors.topMargin: 2
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
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: "Brightness"
                    color: Theme.fg
                    font.family: Theme.uiFont
                    font.pixelSize: 16
                    font.bold: true
                }
                Text {
                    text: Brightness.percent + "%"
                    color: Theme.fg
                    opacity: 0.7
                    font.family: Theme.uiFont
                    font.pixelSize: 13
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: "󰃞"
                    color: Theme.accentBrightness
                    font.family: Theme.symbolFont
                    font.pixelSize: 16
                }

                // --- slider ---
                Item {
                    id: slider
                    Layout.fillWidth: true
                    implicitHeight: 22

                    readonly property real frac: Brightness.percent / 100

                    Rectangle {   // track
                        id: track
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width
                        height: 6
                        radius: 3
                        color: Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, 0.15)

                        Rectangle {   // fill
                            width: knob.x + knob.width / 2
                            height: parent.height
                            radius: parent.radius
                            color: Theme.accentBrightness
                        }
                    }

                    Rectangle {
                        id: knob
                        width: 16
                        height: 16
                        radius: 8
                        anchors.verticalCenter: parent.verticalCenter
                        x: slider.frac * (slider.width - width)
                        color: Theme.fg
                        border.width: 2
                        border.color: Theme.accentBrightness
                        scale: drag.pressed || knobHover.hovered ? 1.15 : 1
                        Behavior on scale { NumberAnimation { duration: Theme.animDuration } }
                    }

                    HoverHandler { id: knobHover; cursorShape: Qt.PointingHandCursor }
                    MouseArea {
                        id: drag
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        function setFrom(mx): void {
                            const usable = slider.width - knob.width;
                            Brightness.set((mx - knob.width / 2) / usable * 100);
                        }
                        onPressed: mouse => setFrom(mouse.x)
                        onPositionChanged: mouse => { if (pressed) setFrom(mouse.x); }
                        onWheel: wheel => Brightness.step(wheel.angleDelta.y > 0 ? 5 : -5)
                    }
                }

                Text {
                    text: "󰃠"
                    color: Theme.accentBrightness
                    font.family: Theme.symbolFont
                    font.pixelSize: 16
                }
            }
        }
    }
}
