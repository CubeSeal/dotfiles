import QtQuick
import QtQuick.Layouts

import "../theme"
import "../services"

// niri/workspaces: "{value} {icon}", focused icon "", default "".
RowLayout {
    id: root
    spacing: 8

    // The output (connector name) this bar is on. niri numbers workspaces
    // per-output from 1, so showing every output's workspaces on every bar
    // produces duplicate numbers ("1 1 2"). Filter to this bar's output; fall
    // back to showing all if the name doesn't match any (name-scheme mismatch).
    property string output: ""
    readonly property var shown: {
        if (output === "") return Niri.workspaces;
        const m = Niri.workspaces.filter(w => w.output === output);
        return m.length > 0 ? m : Niri.workspaces;
    }

    Repeater {
        model: root.shown

        Text {
            required property var modelData
            text: (modelData.name ? modelData.name : modelData.idx)
                  + "  " + (modelData.isFocused ? "" : "")
            color: modelData.isFocused ? Theme.barFg : Theme.workspaceInactive
            font.family: Theme.barFont + ", " + Theme.symbolFont
            font.pixelSize: Theme.barFontSize
            font.bold: true

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Niri.focusWorkspace(modelData.idx)
            }
        }
    }
}
