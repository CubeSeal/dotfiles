import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

import "../theme"

// waybar wireplumber: " <icon> {volume}/100 ", muted shows  + "Muted".
RowLayout {
    id: root
    spacing: 4

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var audio: sink ? sink.audio : null
    readonly property bool muted: audio ? audio.muted : false
    readonly property int volume: audio ? Math.round(audio.volume * 100) : 0

    // Keep the sink's audio properties bound/live.
    PwObjectTracker { objects: root.sink ? [root.sink] : [] }

    Text {
        text: {
            if (root.muted) return "";
            if (root.volume >= 66) return "";
            if (root.volume >= 33) return "";
            return "";
        }
        color: root.muted ? Theme.accentMuted : "#A6783F"
        font.family: Theme.symbolFont
        font.pixelSize: Theme.barFontSize
    }

    Text {
        text: root.muted ? "Muted" : (root.volume + "/100")
        color: Theme.barFg
        font.family: Theme.barFont
        font.pixelSize: Theme.barFontSize
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: if (root.audio) root.audio.muted = !root.audio.muted
        onWheel: wheel => {
            if (!root.audio) return;
            const step = 0.05;
            const delta = wheel.angleDelta.y > 0 ? step : -step;
            root.audio.volume = Math.max(0, Math.min(1, root.audio.volume + delta));
        }
    }
}
