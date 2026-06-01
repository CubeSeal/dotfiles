import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

import "../theme"

// Replaces mako. Notification server + a top-right stack of Kanagawa toasts.
// mako defaults reproduced: 10s timeout, radius 10, 2px border, Atkinson font.
Scope {
    id: scope

    NotificationServer {
        id: server
        keepOnReload: false
        bodySupported: true
        imageSupported: true
        actionsSupported: true
        onNotification: notif => notif.tracked = true
    }

    PanelWindow {
        // Show on the primary screen (mako showed on the focused output; this
        // is a faithful-enough simplification).
        screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
        color: "transparent"
        anchors { top: true; right: true }
        margins { top: Theme.barHeight + 8; right: 12 }
        implicitWidth: 380
        implicitHeight: Math.max(1, column.implicitHeight)
        exclusiveZone: 0
        visible: server.trackedNotifications.values.length > 0

        ColumnLayout {
            id: column
            anchors.fill: parent
            spacing: 8

            Repeater {
                model: server.trackedNotifications

                Rectangle {
                    id: toast
                    required property var modelData
                    Layout.fillWidth: true
                    implicitHeight: content.implicitHeight + 20
                    radius: Theme.panelRadius
                    color: Theme.bg
                    border.width: Theme.panelBorder
                    border.color: Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.7)

                    ColumnLayout {
                        id: content
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 2

                        Text {
                            Layout.fillWidth: true
                            text: toast.modelData.summary
                            color: Theme.fg
                            font.family: Theme.uiFont
                            font.pixelSize: 15
                            font.bold: true
                            elide: Text.ElideRight
                        }
                        Text {
                            Layout.fillWidth: true
                            visible: toast.modelData.body.length > 0
                            text: toast.modelData.body
                            color: Theme.fg
                            font.family: Theme.uiFont
                            font.pixelSize: 14
                            wrapMode: Text.WordWrap
                            textFormat: Text.MarkupText
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: toast.modelData.dismiss()
                    }

                    Timer {
                        running: true
                        // mako had `ignore-timeout=1` + `default-timeout=10000`,
                        // i.e. ignore whatever the app requests and always expire
                        // after 10s. Match that exactly rather than honouring
                        // modelData.expireTimeout.
                        interval: 10000
                        onTriggered: toast.modelData.expire()
                    }
                }
            }
        }
    }
}
