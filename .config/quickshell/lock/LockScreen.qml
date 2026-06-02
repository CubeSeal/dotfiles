import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam

import "../theme"

// Replaces hyprlock via the ext-session-lock protocol. Engaged by
// `qs ipc call lock lock` -> lock() (see shell.qml IpcHandler + wm/hibernation.nix).
//
// Reproduces hyprlock's blurred-screenshot background (path = screenshot,
// blur_passes = 3): lock() grabs a per-output screenshot with grim *before*
// engaging the lock (once the ext-session-lock is active the compositor only
// shows the lock surface, so an in-surface capture would just grab itself), then
// each surface displays its shot behind a MultiEffect blur. hyprlock's fadeIn is
// reproduced with an opacity animation when the surface appears.
Scope {
    id: root
    property alias locked: sessionLock.locked
    property string errorText: ""

    // Screenshots are written to the user-private runtime dir (tmpfs, mode 700),
    // a new generation each lock so the Image URL changes (avoids QML caching)
    // and stale frames are cleared.
    readonly property string shotDir: Quickshell.env("XDG_RUNTIME_DIR") + "/quickshell-lock"
    property int bgGen: 0
    function shotPath(name: string): string {
        return root.shotDir + "/" + name + "-" + root.bgGen + ".png";
    }

    // Grab every output, then lock once grim has finished writing the files.
    function lock(): void {
        if (sessionLock.locked)
            return;
        root.bgGen += 1;
        let cmds = ["mkdir -p '" + root.shotDir + "'", "rm -f '" + root.shotDir + "'/*.png"];
        for (const s of Quickshell.screens)
            cmds.push("grim -o '" + s.name + "' '" + root.shotPath(s.name) + "'");
        grabber.command = ["sh", "-c", cmds.join("; ")];
        grabber.running = true;
    }

    Process {
        id: grabber
        onExited: (code, status) => { sessionLock.locked = true; }
    }

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

            // Fade the lock in when the surface appears (at lock time).
            property real bgOpacity: 0
            Behavior on bgOpacity {
                NumberAnimation { duration: 500; easing.type: Easing.OutCubic }
            }

            // Static blurred backdrop, baked into ONE cached layer texture so the
            // expensive full-screen blur shader runs once rather than re-running
            // on every rendered frame. Without this, each keystroke in the
            // password field triggers a frame that re-blurs the whole screenshot,
            // which makes typing lag. Animating this item's opacity composites the
            // cached texture — it does not invalidate the layer — so the fade is
            // cheap too.
            Item {
                id: backdrop
                anchors.fill: parent
                opacity: surface.bgOpacity
                layer.enabled: true
                layer.smooth: true

                // Pre-lock screenshot of this output (grabbed by root.lock()),
                // the hidden source for the blur. Synchronous so it is ready on
                // the first frame (the file is on disk before we lock). If grim
                // failed/missing, the blur is empty and the solid surface colour
                // shows through.
                Image {
                    id: shotSrc
                    anchors.fill: parent
                    source: "file://" + root.shotPath(surface.screen.name)
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: false
                    visible: false
                }
                MultiEffect {
                    anchors.fill: parent
                    source: shotSrc
                    autoPaddingEnabled: false
                    blurEnabled: true
                    blur: 1.0
                    blurMax: 64
                }
                // Dim for contrast behind the clock/field, baked into the layer.
                Rectangle {
                    anchors.fill: parent
                    color: Qt.rgba(Theme.bg.r, Theme.bg.g, Theme.bg.b, 0.35)
                }
            }

            Column {
                anchors.centerIn: parent
                spacing: 24
                opacity: surface.bgOpacity

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

            Component.onCompleted: {
                bgOpacity = 1;
                passwordField.forceActiveFocus();
            }
        }

        onLockedChanged: {
            if (locked) {
                root.password = "";
                root.errorText = "";
            }
        }
    }
}
