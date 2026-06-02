pragma Singleton

import Quickshell

// Shell-wide UI state shared between the bar, launcher and the IPC handlers in
// shell.qml (so the niri keybinds and the bar buttons toggle the same thing).
Singleton {
    id: root

    property bool barVisible: true
    property bool launcherOpen: false
    property bool wifiOpen: false
    property bool bluetoothOpen: false

    function toggleBar(): void { root.barVisible = !root.barVisible; }

    // Only one popup at a time: opening one closes the launcher and the other.
    function _closePopups(): void {
        root.launcherOpen = false;
        root.wifiOpen = false;
        root.bluetoothOpen = false;
    }
    function toggleLauncher(): void { const v = !root.launcherOpen; root._closePopups(); root.launcherOpen = v; }
    function closeLauncher(): void { root.launcherOpen = false; }
    function toggleWifi(): void { const v = !root.wifiOpen; root._closePopups(); root.wifiOpen = v; }
    function closeWifi(): void { root.wifiOpen = false; }
    function toggleBluetooth(): void { const v = !root.bluetoothOpen; root._closePopups(); root.bluetoothOpen = v; }
    function closeBluetooth(): void { root.bluetoothOpen = false; }
}
