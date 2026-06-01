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
    implicitHeight: holder.implicitHeight + vpad * 2

    gradient: Gradient {
        GradientStop { position: 0.0; color: Theme.barGradientTop }
        GradientStop { position: 0.6; color: Theme.barGradientTop }
        GradientStop { position: 1.0; color: Theme.barGradientBottom }
    }

    Item {
        id: holder
        anchors.centerIn: parent
        implicitWidth: childrenRect.width
        implicitHeight: childrenRect.height
    }
}
