import QtQuick

import "../theme"
import "../state"
import "../services"

// Backlight: " <icon> {percent}/100 ", styled like Battery/Volume. Click
// toggles the brightness slider dropdown; scroll steps the level by 5%.
// Hidden on machines without a backlight (e.g. steambox).
Item {
    id: root
    visible: Brightness.available
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight

    readonly property int level: Brightness.percent

    Row {
        id: row
        spacing: 4

        Text {
            text: {
                if (root.level >= 66) return "󰃠";
                if (root.level >= 33) return "󰃟";
                return "󰃞";
            }
            color: Theme.accentBrightness
            font.family: Theme.symbolFont
            font.pixelSize: Theme.barFontSize
        }

        Text {
            text: root.level + "/100"
            color: Theme.barFg
            font.family: Theme.barFont
            font.pixelSize: Theme.barFontSize
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: Globals.toggleBrightness()
        onWheel: wheel => Brightness.step(wheel.angleDelta.y > 0 ? 5 : -5)
    }
}
