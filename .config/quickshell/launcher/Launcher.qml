import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

import "../theme"
import "../state"

// Replaces walker (core scope: applications + run + inline calculator).
// Kanagawa-themed, Atkinson font, 2px border, 10px radius, cyan selection.
PanelWindow {
    id: launcher
    visible: Globals.launcherOpen
    color: "transparent"

    // Full-screen overlay so we can dim + catch click-outside, and take
    // exclusive keyboard focus while open.
    anchors { top: true; bottom: true; left: true; right: true }
    exclusiveZone: 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    property string query: ""
    property string calcResult: ""
    property int selected: 0

    // Build the result list: optional calc row, then matching apps, then a
    // "run" fallback when nothing matches.
    readonly property var results: {
        const out = [];
        if (calcResult.length > 0)
            out.push({ kind: "calc", label: query + " = " + calcResult, payload: calcResult });

        const q = query.trim().toLowerCase();
        const apps = DesktopEntries.applications.values
            .filter(a => !a.noDisplay
                && (q.length === 0 || a.name.toLowerCase().includes(q)))
            .sort((a, b) => a.name.localeCompare(b.name))
            .slice(0, 8);
        for (const a of apps)
            out.push({ kind: "app", label: a.name, payload: a });

        if (apps.length === 0 && q.length > 0)
            out.push({ kind: "run", label: "Run: " + query, payload: query });
        return out;
    }

    function close(): void { Globals.closeLauncher(); }

    function activate(): void {
        const item = results[selected];
        if (!item) { close(); return; }
        if (item.kind === "app") item.payload.execute();
        else if (item.kind === "run") Quickshell.execDetached(["sh", "-c", item.payload]);
        else if (item.kind === "calc") Quickshell.execDetached(["wl-copy", item.payload]);
        close();
    }

    onVisibleChanged: {
        if (visible) {
            query = "";
            selected = 0;
            field.forceActiveFocus();
        }
    }

    // Inline calculator: run qalc when the query looks like an expression.
    Timer {
        id: calcDebounce
        interval: 150
        onTriggered: {
            const q = launcher.query.trim();
            if (q.length >= 1 && /[0-9]/.test(q) && /[-+*/^()%]/.test(q)) {
                calcProc.command = ["qalc", "-t", q];
                calcProc.running = true;
            } else {
                launcher.calcResult = "";
            }
        }
    }
    Process {
        id: calcProc
        stdout: StdioCollector {
            onStreamFinished: launcher.calcResult = text.trim()
        }
    }

    // Transparent click-catcher so clicking outside the panel closes the launcher.
    MouseArea {
        anchors.fill: parent
        onClicked: launcher.close()
    }

    Rectangle {
        id: panel
        anchors.centerIn: parent
        width: 600
        height: 420
        radius: Theme.panelRadius
        color: Theme.bg
        border.width: Theme.panelBorder
        border.color: Theme.fg

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 10

            TextField {
                id: field
                Layout.fillWidth: true
                placeholderText: "Search…"
                color: Theme.fg
                placeholderTextColor: Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, 0.5)
                font.family: Theme.uiFont
                font.pixelSize: 18
                background: Rectangle {
                    color: "transparent"
                    border.width: 1
                    border.color: Theme.fg
                    radius: 6
                }
                onTextChanged: {
                    launcher.query = text;
                    launcher.selected = 0;
                    calcDebounce.restart();
                }
                Keys.onDownPressed:
                    launcher.selected = Math.min(launcher.selected + 1, launcher.results.length - 1)
                Keys.onUpPressed:
                    launcher.selected = Math.max(launcher.selected - 1, 0)
                Keys.onEscapePressed: launcher.close()
                onAccepted: launcher.activate()
            }

            ListView {
                id: list
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                model: launcher.results
                currentIndex: launcher.selected

                delegate: Rectangle {
                    required property int index
                    required property var modelData
                    width: ListView.view.width
                    height: 38
                    radius: 6
                    color: index === launcher.selected
                           ? Qt.rgba(Theme.cyan.r, Theme.cyan.g, Theme.cyan.b, 0.4)
                           : "transparent"

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        text: modelData.label
                        color: Theme.fg
                        font.family: Theme.uiFont
                        font.pixelSize: 16
                        elide: Text.ElideRight
                        width: parent.width - 24
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: launcher.selected = index
                        onClicked: { launcher.selected = index; launcher.activate(); }
                    }
                }
            }
        }
    }
}
