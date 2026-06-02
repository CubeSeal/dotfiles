import QtQuick
import QtQuick.Layouts

import "../theme"
import "../services"

// niri/workspaces: "{value} {icon}", focused/default icons are book glyphs.
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

        // Number (EB Garamond) and book glyph (Symbols Nerd Font) are separate
        // Text items: QML's font.family is a single family, so the old
        // "EB Garamond 08, Symbols Nerd Font" string didn't resolve — it fell
        // back to a default font that was both taller (25px vs 18px, throwing
        // off the pill heights) and missing the Nerd book glyphs. The delegate
        // is a MouseArea (a plain Row inside) so it isn't a layout-managed item
        // carrying anchors.
        MouseArea {
            id: ws
            required property var modelData
            readonly property color tint: modelData.isFocused ? Theme.barFg
                                                              : Theme.workspaceInactive
            implicitWidth: row.implicitWidth
            implicitHeight: row.implicitHeight
            cursorShape: Qt.PointingHandCursor
            onClicked: Niri.focusWorkspace(ws.modelData.idx)

            Row {
                id: row
                spacing: 4

                Text {
                    text: ws.modelData.name ? ws.modelData.name : ws.modelData.idx
                    color: ws.tint
                    font.family: Theme.barFont
                    font.pixelSize: Theme.barFontSize
                    font.bold: true
                }
                Text {
                    // open book U+EDE2 (focused) / closed book U+F02D (default).
                    // fromCharCode keeps the source pure-ASCII so the glyphs
                    // can't be dropped by tooling.
                    text: ws.modelData.isFocused ? String.fromCharCode(0xEDE2)
                                                 : String.fromCharCode(0xF02D)
                    color: ws.tint
                    font.family: Theme.symbolFont
                    font.pixelSize: Theme.barFontSize
                }
            }
        }
    }
}
