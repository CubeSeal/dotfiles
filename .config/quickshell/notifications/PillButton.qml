import QtQuick

import "../theme"

// A small themed pill button used for notification actions and the Reply
// trigger. Deliberately MouseArea-based with no QtQuick.Controls ToolTip popup
// (those grab the pointer on a layer-shell surface and swallow the click).
Rectangle {
    id: root
    property string label: ""
    signal clicked()

    implicitHeight: 26
    implicitWidth: btnText.implicitWidth + 20
    radius: 6
    color: hover.hovered ? Qt.rgba(Theme.cyan.r, Theme.cyan.g, Theme.cyan.b, 0.35)
                         : Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, 0.12)
    border.width: 1
    border.color: Qt.rgba(Theme.fg.r, Theme.fg.g, Theme.fg.b, 0.4)

    Text {
        id: btnText
        anchors.centerIn: parent
        text: root.label
        color: Theme.fg
        font.family: Theme.uiFont
        font.pixelSize: 13
    }

    HoverHandler { id: hover }
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
