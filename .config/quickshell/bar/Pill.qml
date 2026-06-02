import QtQuick

import "../theme"

// A rounded gradient container matching waybar's per-section background
// (linear-gradient #271D20 -> #422d20, radius 5, padding 2px 6px).
// Put a single laid-out child (e.g. a RowLayout) inside.
Rectangle {
    default property alias data: holder.data
    property int hpad: 6
    property int vpad: 2

    radius: Theme.barRadius
    implicitWidth: holder.implicitWidth + hpad * 2
    // Pills that hold only EB Garamond text (e.g. the centre window title) are
    // shorter than ones holding Nerd Font symbol glyphs, which made the three
    // sections look unevenly padded. Floor every pill's height at the symbol
    // line height so they match regardless of content.
    implicitHeight: Math.max(holder.implicitHeight, symbolMetrics.height) + vpad * 2

    gradient: Gradient {
        GradientStop { position: 0.0; color: Theme.barGradientTop }
        GradientStop { position: 0.6; color: Theme.barGradientTop }
        GradientStop { position: 1.0; color: Theme.barGradientBottom }
    }

    // Symbol-font line height, used as the common height floor above so a
    // text-only pill matches glyph-bearing ones.
    FontMetrics {
        id: symbolMetrics
        font.family: Theme.symbolFont
        font.pixelSize: Theme.barFontSize
    }

    Item {
        id: holder
        anchors.centerIn: parent
        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height
    }
}
