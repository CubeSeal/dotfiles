import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pam

import "../theme"

// Replaces hyprlock via the ext-session-lock protocol. Engaged by
// `qs ipc call lock lock` (see shell.qml IpcHandler + wm/hibernation.nix).
//
// Note: hyprlock used a blurred screenshot background (path = screenshot).
// This uses a solid Kanagawa background to keep the lock reliable; a blurred
// ScreencopyView can be layered in later once the lock is confirmed working.
Scope {
    id: root
    property alias locked: sessionLock.locked
    property string errorText: ""

    PamContext {
        id: pam
        config: "quickshell"
        onResponseRequiredChanged: {
            if (responseRequired) respond(root.password);
        }
        onCompleted: result => {
            if (result === PamResult.Success) {
                root.errorText = "";
                root.password = "";
                sessionLock.locked = false;
            } else {
                root.errorText = "Authentication failed";
                root.password = "";
            }
        }
    }

    property string password: ""

    WlSessionLock {
        id: sessionLock
        locked: false

        WlSessionLockSurface {
            id: surface
            color: Theme.bg

            Column {
                anchors.centerIn: parent
                spacing: 24

                SystemClock { id: clock; precision: SystemClock.Seconds }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDateTime(clock.date, "h:mm AP")
                    color: Theme.lockFg
                    font.family: Theme.barFont
                    font.pixelSize: 113
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDateTime(clock.date, "dddd, dd MMMM yyyy")
                    color: Theme.lockFg
                    font.family: Theme.barFont
                    font.pixelSize: 23
                }

                // Password input field (hyprlock input-field: 15% x 4%,
                // outline 3, rounding 10, inner #1F1F28b3, outer #D1CEC4).
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: surface.width * 0.15
                    height: surface.height * 0.04
                    radius: 10
                    color: Qt.rgba(Theme.lockInner.r, Theme.lockInner.g, Theme.lockInner.b, 0.7)
                    border.width: 3
                    border.color: root.errorText.length > 0 ? Theme.lockFail
                                  : pam.active ? Theme.lockSuccess : Theme.lockFg

                    TextField {
                        id: passwordField
                        anchors.fill: parent
                        anchors.margins: 4
                        echoMode: TextInput.Password
                        placeholderText: "Input password..."
                        color: Theme.lockFg
                        font.family: Theme.barFont
                        font.pixelSize: 18
                        horizontalAlignment: TextInput.AlignHCenter
                        background: null
                        enabled: !pam.active

                        onTextChanged: root.password = text
                        onAccepted: if (!pam.active && text.length > 0) pam.active = true
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: root.errorText.length > 0
                    text: root.errorText
                    color: Theme.lockFail
                    font.family: Theme.barFont
                    font.pixelSize: 16
                }
            }

            Component.onCompleted: passwordField.forceActiveFocus()
        }

        onLockedChanged: {
            if (locked) {
                root.password = "";
                root.errorText = "";
            }
        }
    }
}
