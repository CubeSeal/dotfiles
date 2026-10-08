pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Screen backlight level via brightnessctl (the same tool the niri/hypr
// brightness keys use). Backing store for the bar brightness module and its
// slider dropdown. Uses the Process + StdioCollector + Timer idiom from
// services/Wifi.qml; sysfs backlight files don't emit change events, so the
// level is polled to pick up changes made by the brightness keys.
Singleton {
    id: root

    property bool available: false
    property int percent: 0        // 0..100

    // Floor so the slider can't black out the panel entirely.
    readonly property int minPercent: 1

    // Coalesce rapid slider drags into one brightnessctl call per tick.
    property int _pending: -1

    function set(p): void {
        const v = Math.max(root.minPercent, Math.min(100, Math.round(p)));
        root.percent = v;
        root._pending = v;
        if (!apply.running)
            apply.start();
    }
    function step(delta): void { root.set(root.percent + delta); }
    function refresh(): void { poll.running = true; }

    // `-m info` prints: device,class,current,percent%,max
    function _parse(text): void {
        const p = text.trim().split(",");
        if (p.length < 5) {
            root.available = false;
            return;
        }
        const cur = parseInt(p[2]);
        const max = parseInt(p[4]);
        root.available = max > 0;
        // Don't fight an in-flight slider drag with a stale reading.
        if (root.available && root._pending < 0 && !apply.running)
            root.percent = Math.round(cur * 100 / max);
    }

    Process {
        id: poll
        command: ["brightnessctl", "--class=backlight", "-m", "info"]
        stdout: StdioCollector {
            onStreamFinished: root._parse(text)
        }
    }

    Timer {
        interval: 2000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: poll.running = true
    }

    Timer {
        id: apply
        interval: 30
        onTriggered: {
            if (root._pending < 0)
                return;
            Quickshell.execDetached(["brightnessctl", "--class=backlight", "-q",
                                     "set", root._pending + "%"]);
            root._pending = -1;
        }
    }
}
