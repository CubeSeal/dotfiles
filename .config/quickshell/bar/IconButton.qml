import QtQuick

import "../theme"

// A single clickable glyph (the waybar custom/* modules: launcher, reboot,
// power, autorotate).
//
// NOTE: we deliberately do NOT use QtQuick.Controls ToolTip here. On a
// layer-shell bar its popup grabs the pointer and its press-outside-close
// swallows the first click, so the button appears dead (you hover -> tooltip
// shows -> click is consumed closing the popup instead of reaching the
// MouseArea). The `tooltip` property is kept for callers / future use.
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
    // waybar padded each custom module ("  ", " 󱓞 "); give the bare glyphs the
    // same breathing room so they aren't squished together.
    leftPadding: 4
    rightPadding: 4

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
