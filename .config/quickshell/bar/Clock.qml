import QtQuick
import Quickshell

import "../theme"

// waybar clock: " {:%I:%M %p, %a. %d %b.} " (12h time + abbreviated day/date).
Text {
    id: root
    SystemClock { id: clock; precision: SystemClock.Minutes }
    text: Qt.formatDateTime(clock.date, "hh:mm AP, ddd. dd MMM.")
    color: Theme.barFg
    font.family: Theme.barFont
    font.pixelSize: Theme.barFontSize
}
