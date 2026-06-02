pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Wi-Fi state + quick-connect actions via nmcli (Quickshell has no
// NetworkManager binding). Backing store for the Wi-Fi dropdown. Uses the same
// Process + StdioCollector + Timer idiom as services/Niri.qml and the bar poll.
//
// Scope is deliberately "quick connect": list visible networks, toggle the
// radio, connect to saved/open networks and disconnect. Connecting to a secured
// network that has no saved profile needs a password, which is out of scope and
// hands off to `nmtui`.
Singleton {
    id: root

    property bool enabled: true            // radio on
    property string connected: ""          // active SSID ("" if none)
    property string iface: ""              // wifi device, used to disconnect
    // [{ ssid, signal:int, secured:bool, active:bool, saved:bool }], strongest first.
    property var networks: []

    function refresh(): void { poll.running = true; }

    function rescan(): void {
        Quickshell.execDetached(["nmcli", "device", "wifi", "rescan"]);
        refreshSoon.restart();
    }
    function setRadio(on): void {
        Quickshell.execDetached(["nmcli", "radio", "wifi", on ? "on" : "off"]);
        refreshSoon.restart();
    }
    function disconnect(): void {
        if (root.iface.length > 0)
            Quickshell.execDetached(["nmcli", "device", "disconnect", root.iface]);
        refreshSoon.restart();
    }
    // Row click: toggle the active one off, bring up a saved profile, join an
    // open network, or hand a secured-unknown one to nmtui for the password.
    function activate(net): void {
        if (!net)
            return;
        if (net.active)
            root.disconnect();
        else if (net.saved)
            Quickshell.execDetached(["nmcli", "connection", "up", "id", net.ssid]);
        else if (!net.secured)
            Quickshell.execDetached(["nmcli", "device", "wifi", "connect", net.ssid]);
        else
            Quickshell.execDetached(["kitty", "-e", "nmtui"]);
        if (!net.secured || net.saved || net.active)
            refreshSoon.restart();
    }

    function _parse(text): void {
        let section = "";
        let radio = root.enabled;
        let conn = "";
        let dev = "";
        const saved = ({});
        const list = [];
        for (const line of text.split("\n")) {
            if (line === "RADIO:") { section = "radio"; continue; }
            if (line === "DEV:")   { section = "dev";   continue; }
            if (line === "SAVED:") { section = "saved"; continue; }
            if (line === "WIFI:")  { section = "wifi";  continue; }
            if (line.trim().length === 0)
                continue;
            if (section === "radio") {
                radio = (line.trim() === "enabled");
            } else if (section === "dev") {
                const p = line.split(":");        // DEVICE:TYPE:STATE
                if (p.length >= 3 && p[1] === "wifi" && p[2] === "connected")
                    dev = p[0];
                else if (p.length >= 2 && p[1] === "wifi" && dev === "")
                    dev = p[0];
            } else if (section === "saved") {
                const p = line.split(":");        // NAME:TYPE
                if (p.length >= 2 && p[1] === "802-11-wireless")
                    saved[p[0]] = true;
            } else if (section === "wifi") {
                const p = line.split(":");        // IN-USE:SSID:SIGNAL:SECURITY
                if (p.length < 4)
                    continue;
                const inUse = p[0];
                const security = p[p.length - 1];
                const signal = parseInt(p[p.length - 2]) || 0;
                // SSID is everything between; rejoin in case it held a colon.
                const ssid = p.slice(1, p.length - 2).join(":").replace(/\\/g, "");
                if (ssid.length === 0)
                    continue;
                list.push({ ssid: ssid, signal: signal,
                            secured: security.trim().length > 0,
                            active: inUse === "*", saved: false });
            }
        }
        // Mark saved, find the active SSID, dedup by SSID (keep active/strongest).
        const byName = ({});
        for (const n of list) {
            n.saved = !!saved[n.ssid];
            if (n.active)
                conn = n.ssid;
            const ex = byName[n.ssid];
            if (!ex || n.active || n.signal > ex.signal)
                byName[n.ssid] = n;
        }
        const out = Object.keys(byName).map(k => byName[k]);
        out.sort((a, b) => (b.active - a.active) || (b.signal - a.signal));
        root.enabled = radio;
        root.iface = dev;
        root.connected = conn;
        root.networks = out;
    }

    Process {
        id: poll
        command: ["sh", "-c",
            "echo RADIO:; nmcli radio wifi; " +
            "echo DEV:; nmcli -t -f DEVICE,TYPE,STATE device status; " +
            "echo SAVED:; nmcli -t -f NAME,TYPE connection show; " +
            "echo WIFI:; nmcli -t -f IN-USE,SSID,SIGNAL,SECURITY device wifi list"]
        stdout: StdioCollector {
            onStreamFinished: root._parse(text)
        }
    }

    // Periodic refresh (matches the bar's 10s cadence).
    Timer {
        interval: 10000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: poll.running = true
    }
    // Short re-poll after an action so the list reflects the new state.
    Timer {
        id: refreshSoon
        interval: 1200
        onTriggered: poll.running = true
    }
}
