pragma Singleton

import Quickshell

// Shell-wide UI state shared between the bar, launcher and the IPC handlers in
// shell.qml (so the niri keybinds and the bar buttons toggle the same thing).
Singleton {
    id: root

    property bool barVisible: true
    property bool launcherOpen: false

    function toggleBar(): void { root.barVisible = !root.barVisible; }
    function toggleLauncher(): void { root.launcherOpen = !root.launcherOpen; }
    function closeLauncher(): void { root.launcherOpen = false; }
}
