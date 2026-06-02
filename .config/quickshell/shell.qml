import Quickshell
import Quickshell.Io

import "state"
import "bar"
import "notifications"
import "launcher"
import "lock"

// Root of the quickshell session shell. Replaces waybar (Bar), mako
// (Notifications) and walker (Launcher), and provides the lock screen
// (LockScreen). External triggers (niri keybinds, swayidle) come in via IPC.
ShellRoot {
    Bar {}
    Notifications {}
    Launcher {}

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

    // niri Super+Alt+L and swayidle (wm/hibernation.nix) -> `qs ipc call lock lock`
    // lock() grabs a screenshot first, then engages the lock (see LockScreen).
    IpcHandler {
        target: "lock"
        function lock(): void { lockScreen.lock(); }
    }
}
