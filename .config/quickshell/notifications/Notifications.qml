import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications

import "../theme"

// Replaces mako. Notification server + a top-right stack of Kanagawa toasts.
// mako defaults reproduced: 10s timeout, radius 10, 2px border, Atkinson font.
// Adds notification actions and inline reply (e.g. KDE Connect SMS): a "Reply"
// button reveals a text field; revealing it cancels the 10s auto-dismiss so a
// reply isn't lost, while untouched toasts still expire at 10s.
Scope {
    id: scope

    NotificationServer {
        id: server
        keepOnReload: false
        bodySupported: true
        imageSupported: true
        actionsSupported: true
        inlineReplySupported: true   // advertise reply capability to senders
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

        // Take keyboard focus only when the surface is clicked (e.g. tapping
        // Reply), so the reply field can receive typing without stealing focus
        // from the focused app just by appearing.
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

        ColumnLayout {
            id: column
            anchors.fill: parent
            spacing: 8

            Repeater {
                model: server.trackedNotifications

                Rectangle {
                    id: toast
                    required property var modelData
                    property bool replying: false

                    // The "default" action is invoked by clicking the body, not
                    // shown as a button; drop it and any label-less actions so
                    // they don't render as empty (clickable-but-dead) pills.
                    readonly property var shownActions:
                        modelData.actions.filter(a => a.identifier !== "default"
                                                      && a.text.length > 0)
                    readonly property var defaultAction: {
                        const d = modelData.actions.filter(a => a.identifier === "default");
                        return d.length > 0 ? d[0] : null;
                    }

                    Layout.fillWidth: true
                    implicitHeight: content.implicitHeight + 20
                    radius: Theme.panelRadius
                    color: Theme.bg
                    border.width: Theme.panelBorder
                    border.color: Qt.rgba(Theme.border.r, Theme.border.g, Theme.border.b, 0.7)

                    // Click the body to invoke the default action (e.g. focus
                    // the app) if there is one, else just dismiss. Sits behind
                    // the content so action/reply controls stay clickable (plain
                    // text passes clicks through).
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (toast.defaultAction)
                                toast.defaultAction.invoke();
                            toast.modelData.dismiss();
                        }
                    }

                    ColumnLayout {
                        id: content
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 6

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

                        // Action buttons (from the sender) + Reply trigger.
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 6
                            visible: toast.shownActions.length > 0
                                     || toast.modelData.hasInlineReply

                            Repeater {
                                model: toast.shownActions
                                PillButton {
                                    required property var modelData
                                    label: modelData.text
                                    onClicked: modelData.invoke()
                                }
                            }

                            PillButton {
                                visible: toast.modelData.hasInlineReply && !toast.replying
                                label: "Reply"
                                onClicked: {
                                    toast.replying = true;
                                    replyField.forceActiveFocus();
                                }
                            }

                            Item { Layout.fillWidth: true }
                        }

                        // Inline reply field (revealed by the Reply button).
                        TextField {
                            id: replyField
                            Layout.fillWidth: true
                            visible: toast.replying
                            placeholderText: toast.modelData.inlineReplyPlaceholder.length > 0
                                             ? toast.modelData.inlineReplyPlaceholder
                                             : "Reply…"
                            color: Theme.fg
                            font.family: Theme.uiFont
                            font.pixelSize: 14
                            background: Rectangle {
                                color: "transparent"
                                radius: 6
                                border.width: 1
                                border.color: Theme.cyan
                            }
                            onAccepted: {
                                if (text.length > 0) {
                                    toast.modelData.sendInlineReply(text);
                                    toast.modelData.dismiss();
                                }
                            }
                            Keys.onEscapePressed: {
                                toast.replying = false;
                                text = "";
                            }
                        }
                    }

                    // Auto-dismiss after 10s (mako ignore-timeout=1 +
                    // default-timeout=10000). Pauses while replying so the draft
                    // isn't lost; resumes/expires if the user backs out (Esc).
                    Timer {
                        running: !toast.replying
                        interval: 10000
                        onTriggered: toast.modelData.expire()
                    }
                }
            }
        }
    }
}
