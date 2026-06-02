import Quickshell
import Quickshell.Io

import "state"
import "bar"
import "notifications"
import "launcher"
import "lock"
import "network"
import "bluetooth"

// Root of the quickshell session shell. Replaces waybar (Bar), mako
// (Notifications) and walker (Launcher), and provides the lock screen
// (LockScreen). External triggers (niri keybinds, swayidle) come in via IPC.
ShellRoot {
    Bar {}
    Notifications {}
    Launcher {}
    WifiPanel {}
    BluetoothPanel {}

    LockScreen {
        id: lockScreen
    }

    // niri: Mod+W -> `qs ipc call bar toggle`
    IpcHandler {
        target: "bar"
        function toggle(): void { Globals.toggleBar(); }
    }

    // niri: Mod+D -> `qs ipc call launcher toggle`
    IpcHandler {
        target: "launcher"
        function toggle(): void { Globals.toggleLauncher(); }
    }

    // Optional niri keybinds -> `qs ipc call wifi toggle` / `bluetooth toggle`.
    IpcHandler {
        target: "wifi"
        function toggle(): void { Globals.toggleWifi(); }
    }
    IpcHandler {
        target: "bluetooth"
        function toggle(): void { Globals.toggleBluetooth(); }
    }

    // niri Super+Alt+L and swayidle (wm/hibernation.nix) -> `qs ipc call lock lock`
    // lock() grabs a screenshot first, then engages the lock (see LockScreen).
    IpcHandler {
        target: "lock"
        function lock(): void { lockScreen.lock(); }
    }
}
