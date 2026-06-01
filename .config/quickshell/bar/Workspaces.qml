import QtQuick
import QtQuick.Layouts

import "../theme"
import "../services"

// niri/workspaces: "{value} {icon}", focused icon "", default "".
RowLayout {
    spacing: 8

    Repeater {
        model: Niri.workspaces

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
