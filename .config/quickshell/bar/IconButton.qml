import QtQuick
import QtQuick.Controls

import "../theme"

// A single clickable glyph (the waybar custom/* modules: launcher, reboot,
// power, autorotate).
Text {
    id: root
    property string glyph: ""
    property color glyphColor: Theme.barFg
    property string tooltip: ""
    signal clicked()

    text: glyph
    color: glyphColor
    font.family: Theme.symbolFont
    font.pixelSize: Theme.barFontSize
    verticalAlignment: Text.AlignVCenter

    HoverHandler { id: hover }
    ToolTip.visible: root.tooltip.length > 0 && hover.hovered
    ToolTip.text: root.tooltip

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
