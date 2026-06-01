import QtQuick
import QtQuick.Layouts
import Quickshell.Services.UPower

import "../theme"

// waybar battery: " <icon> {capacity}/100 ". Charging shows 󰂄, otherwise one
// of 󱊡 󱊢 󱊣 by charge level. Icon coloured, number in barFg.
RowLayout {
    id: root
    spacing: 4

    readonly property var dev: UPower.displayDevice
    // UPower.percentage is a 0..1 fraction in quickshell (guard in case a build
    // reports 0..100).
    readonly property int capacity: dev
        ? Math.round(dev.percentage <= 1 ? dev.percentage * 100 : dev.percentage)
        : 0
    readonly property bool charging: dev && dev.state === UPowerDeviceState.Charging

    Text {
        text: {
            if (root.charging) return "󰂄";
            if (root.capacity >= 66) return "󱊣";
            if (root.capacity >= 33) return "󱊢";
            return "󱊡";
        }
        color: root.charging ? Theme.accentCharge : Theme.accentPower
        font.family: Theme.symbolFont
        font.pixelSize: Theme.barFontSize
    }

    Text {
        text: root.capacity + "/100"
        color: Theme.barFg
        font.family: Theme.barFont
        font.pixelSize: Theme.barFontSize
    }
}
