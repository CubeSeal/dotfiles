import QtQuick

import "../theme"

// A rounded gradient container matching waybar's per-section background
// (linear-gradient #271D20 -> #422d20, radius 5, padding 2px 6px).
// Put a single laid-out child (e.g. a RowLayout) inside.
//
// Height is fixed to Theme.pillHeight (not content-driven) so all three bar
// sections match even though their content differs in natural height; content
// stays vertically centred via holder's anchors.centerIn.
Rectangle {
    default property alias data: holder.data
    property int hpad: 6

    radius: Theme.barRadius
    implicitWidth: holder.implicitWidth + hpad * 2
    implicitHeight: Theme.pillHeight

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
