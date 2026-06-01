pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Niri integration. Quickshell ships native Hyprland bindings but nothing for
// niri, so we read `niri msg --json event-stream` and maintain workspace +
// focused-window state ourselves. Actions are fired with niri msg.
Singleton {
    id: root

    // Workspaces sorted by idx: { id, idx, name, output, isActive, isFocused }.
    property var workspaces: []
    // Focused window.
    property string focusedTitle: ""
    property string focusedAppId: ""

    // window id -> { title, appId } for resolving focus changes.
    property var _windows: ({})
    property int _focusedId: -1

    function _refreshFocused(): void {
        const w = root._windows[root._focusedId];
        root.focusedTitle = w ? (w.title || "") : "";
        root.focusedAppId = w ? (w.appId || "") : "";
    }

    function _handle(ev): void {
        if (ev.WorkspacesChanged) {
            const ws = ev.WorkspacesChanged.workspaces.map(w => ({
                id: w.id, idx: w.idx, name: w.name, output: w.output,
                isActive: w.is_active, isFocused: w.is_focused,
            }));
            ws.sort((a, b) => a.idx - b.idx);
            root.workspaces = ws;
        } else if (ev.WorkspaceActivated) {
            const id = ev.WorkspaceActivated.id;
            const focused = ev.WorkspaceActivated.focused;
            // Find the output of the activated workspace.
            let output = "";
            const copy = root.workspaces.map(w => Object.assign({}, w));
            for (const w of copy) if (w.id === id) output = w.output;
            for (const w of copy) {
                if (w.output === output) w.isActive = (w.id === id);
                if (focused) w.isFocused = (w.id === id);
            }
            root.workspaces = copy;
        } else if (ev.WindowsChanged) {
            const map = {};
            for (const w of ev.WindowsChanged.windows) {
                map[w.id] = { title: w.title, appId: w.app_id };
                if (w.is_focused) root._focusedId = w.id;
            }
            root._windows = map;
            root._refreshFocused();
        } else if (ev.WindowOpenedOrChanged) {
            const w = ev.WindowOpenedOrChanged.window;
            const map = root._windows;
            map[w.id] = { title: w.title, appId: w.app_id };
            root._windows = map;
            if (w.is_focused) root._focusedId = w.id;
            root._refreshFocused();
        } else if (ev.WindowClosed) {
            const map = root._windows;
            delete map[ev.WindowClosed.id];
            root._windows = map;
            if (ev.WindowClosed.id === root._focusedId) root._focusedId = -1;
            root._refreshFocused();
        } else if (ev.WindowFocusChanged) {
            root._focusedId = ev.WindowFocusChanged.id === null ? -1 : ev.WindowFocusChanged.id;
            root._refreshFocused();
        }
    }

    // --- actions ---
    function focusWorkspace(idx): void {
        Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", String(idx)]);
    }

    // Port of .config/waybar/toggle-rotation.sh: cycle the first output's
    // transform normal -> 90 -> 180 -> 270 -> normal.
    function cycleRotation(): void {
        const script =
            'o=$(niri msg outputs | head -n1 | sed "s/.*(\\(.*\\)).*/\\1/");' +
            't=$(niri msg outputs | awk -F": " "/Transform/ {print \\$2}" | grep -Po "^(\\d|\\w)+" | head -n1);' +
            'case "$t" in normal) n=90;; 90) n=180;; 180) n=270;; *) n=normal;; esac;' +
            'niri msg output "$o" transform "$n"';
        Quickshell.execDetached(["sh", "-c", script]);
    }

    Process {
        running: true
        command: ["niri", "msg", "--json", "event-stream"]
        stdout: SplitParser {
            onRead: line => {
                const t = line.trim();
                if (t.length === 0) return;
                try {
                    root._handle(JSON.parse(t));
                } catch (e) {
                    // Ignore non-JSON / unexpected lines.
                }
            }
        }
    }
}
