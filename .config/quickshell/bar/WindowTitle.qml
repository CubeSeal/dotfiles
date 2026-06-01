import QtQuick

import "../theme"
import "../services"

// niri/window centre module. waybar showed {app_id}, max-length 15, italic.
Text {
    property int maxChars: 15
    text: Niri.focusedAppId.length > maxChars
          ? Niri.focusedAppId.substring(0, maxChars)
          : Niri.focusedAppId
    color: Theme.barFg
    font.family: Theme.barFont
    font.pixelSize: Theme.barFontSize
    font.italic: true
    font.weight: Font.Light
}
