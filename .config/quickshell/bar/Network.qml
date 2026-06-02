import QtQuick
import Quickshell
import Quickshell.Io

import "../theme"
import "../state"

// waybar network module. Quickshell has no NetworkManager binding, so we poll
// nmcli every 10s (waybar's interval). Live up/down bandwidth that waybar put
// in the tooltip is not reproduced; SSID/connection is shown instead.
Item {
    id: root
    implicitWidth: icon.implicitWidth
    implicitHeight: icon.implicitHeight

    property string state: "disconnected"   // "wifi" | "ethernet" | "disconnected"
    property string label: ""

    Text {
        id: icon
        anchors.centerIn: parent
        text: root.state === "wifi" ? "󰤨"
            : root.state === "ethernet" ? ""
            : ""
        color: root.state === "wifi" ? Theme.accentWifi
            : root.state === "ethernet" ? Theme.accentEth
            : "#FF4040"
        font.family: Theme.symbolFont
        font.pixelSize: Theme.barFontSize
    }

    // No hover ToolTip: a QtQuick.Controls ToolTip popup grabs the pointer on a
    // layer-shell surface and swallows the click. The SSID is shown in the
    // dropdown the click opens, so the tooltip is redundant anyway.

    // Click toggles the Wi-Fi quick-connect dropdown.
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Globals.toggleWifi()
    }

    Process {
        id: proc
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                let s = "disconnected";
                let lbl = "Disconnected";
                for (const line of text.split("\n")) {
                    const parts = line.split(":");
                    if (parts.length < 3) continue;
                    const type = parts[0], st = parts[1], conn = parts[2];
                    if (st !== "connected") continue;
                    if (type === "wifi") { s = "wifi"; lbl = conn; break; }
                    if (type === "ethernet") { s = "ethernet"; lbl = conn; break; }
                }
                root.state = s;
                root.label = lbl;
            }
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: proc.running = true
    }
}
