pragma Singleton

import Quickshell
import QtQuick

// Central theme: the exact colours/fonts the previous waybar + mako + walker +
// hyprlock configs used, so the quickshell shell looks identical.
Singleton {
    id: root

    // --- Bar (was waybar style.css) ---
    readonly property color barFg: "#D1CEC4"
    readonly property color barGradientTop: "#271D20"
    readonly property color barGradientBottom: "#422d20"
    readonly property int   barRadius: 5
    readonly property int   barHeight: 38
    // Fixed height for every bar pill so the three sections match regardless of
    // their content (icon glyphs vs text differ in natural height).
    readonly property int   pillHeight: 28
    readonly property string barFont: "EB Garamond 08"
    readonly property string symbolFont: "Symbols Nerd Font"
    readonly property int   barFontSize: 18

    // Accent colours pulled from the waybar module <span> colours.
    readonly property color accentLauncher: "#3F64D3"
    readonly property color accentReboot:   "#A6783F"
    readonly property color accentPower:    "#608E76"
    readonly property color accentCharge:   "#76946A"
    readonly property color accentMuted:    "#E82424"
    readonly property color accentWifi:     "#C5C9C5"
    readonly property color accentEth:      "#6A9589"
    readonly property color workspaceInactive: "#888888"

    // --- Kanagawa (was mako + walker) ---
    readonly property color bg:       "#1F1F28"
    readonly property color fg:       "#DCD7BA"
    readonly property color border:   "#dcd7ba"
    readonly property color cyan:     "#7AA89F"
    readonly property color magenta:  "#f38ba8"
    readonly property string uiFont:  "Atkinson Hyperlegible Next"
    readonly property int   panelRadius: 10
    readonly property int   panelBorder: 2

    // --- Lock screen (was hyprlock.conf) ---
    readonly property color lockFg:      "#D1CEC4"
    readonly property color lockInner:   "#1F1F28"   // used at b3 (~70%) alpha
    readonly property color lockSuccess: "#76946A"
    readonly property color lockFail:    "#E82424"
}
