import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.private.mpris as Mpris
import org.kde.kirigami as Kirigami
import org.kde.plasma.workspace.dbus as DBus
import "components" as Components

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation
    implicitWidth: 360
    implicitHeight: 136
    Layout.preferredWidth: 360
    Layout.preferredHeight: 136
    Layout.minimumWidth: 360
    Layout.minimumHeight: 136
    Layout.maximumWidth: 360
    Layout.maximumHeight: 136
    readonly property string edgeGroup: "right"
    readonly property bool edgeVisible: edgeGroupState.properties.RightVisible ?? true
    opacity: edgeVisible ? 1 : 0

    Behavior on opacity {
        NumberAnimation { duration: 300; easing.type: Easing.InOutCubic }
    }

    DBus.Properties {
        id: edgeGroupState
        busType: DBus.BusType.Session
        service: "org.nothingos.EdgeGroups"
        path: "/EdgeGroups"
        iface: "org.nothingos.EdgeGroups"
    }

    function reportEdgeHover(hovered) {
        DBus.SessionBus.asyncCall({
            service: "org.nothingos.EdgeGroups",
            path: "/EdgeGroups",
            iface: "org.nothingos.EdgeGroups",
            member: "SetHovered",
            arguments: [root.edgeGroup, String(plasmoid.id), hovered],
            signature: "ssb"
        })
    }

    HoverHandler {
        onHoveredChanged: root.reportEdgeHover(hovered)
    }

    Component.onDestruction: root.reportEdgeHover(false)

    Components.NothingColors {
        id: nColors
        themeMode: plasmoid.configuration.themeMode
        useSystemAccent: plasmoid.configuration.useSystemAccent
    }

    // MPRIS2 Model
    Mpris.Mpris2Model {
        id: mpris2Model
    }

    // Media properties
    readonly property string track: mpris2Model.currentPlayer?.track ?? ""
    readonly property string artist: mpris2Model.currentPlayer?.artist ?? ""
    readonly property string album: mpris2Model.currentPlayer?.album ?? ""
    readonly property string albumArt: mpris2Model.currentPlayer?.artUrl ?? ""
    readonly property string playerIdentity: mpris2Model.currentPlayer?.identity ?? ""
    readonly property int playbackStatus: mpris2Model.currentPlayer?.playbackStatus ?? 0
    readonly property bool isPlaying: root.playbackStatus === Mpris.PlaybackStatus.Playing
    readonly property bool canGoPrevious: mpris2Model.currentPlayer?.canGoPrevious ?? false
    readonly property bool canGoNext: mpris2Model.currentPlayer?.canGoNext ?? false
    readonly property bool canPlay: mpris2Model.currentPlayer?.canPlay ?? false
    readonly property bool canPause: mpris2Model.currentPlayer?.canPause ?? false
    readonly property real length: mpris2Model.currentPlayer?.length ?? 0

    // Tracked position property that updates during playback
    property real position: 0

    // Sync position from MPRIS when it changes
    Connections {
        target: mpris2Model.currentPlayer
        function onPositionChanged() {
            root.position = mpris2Model.currentPlayer?.position ?? 0
        }
    }

    // Track position during playback
    Timer {
        id: positionTimer
        interval: 250 // Update every 250ms for smooth progress
        running: root.isPlaying && root.length > 0
        repeat: true
        onTriggered: {
            // Increment position by the interval time (in microseconds)
            if (root.position < root.length) {
                root.position += interval * 1000
            }
        }
    }

    // Reset position when track changes
    onTrackChanged: {
        root.position = mpris2Model.currentPlayer?.position ?? 0
    }

    // Sync position when playback starts/stops
    onIsPlayingChanged: {
        root.position = mpris2Model.currentPlayer?.position ?? 0
    }

    // Control functions
    function togglePlaying() {
        if (mpris2Model.currentPlayer) {
            mpris2Model.currentPlayer.PlayPause();
        }
    }

    function next() {
        if (mpris2Model.currentPlayer) {
            mpris2Model.currentPlayer.Next();
        }
    }

    function previous() {
        if (mpris2Model.currentPlayer) {
            mpris2Model.currentPlayer.Previous();
        }
    }

    fullRepresentation: Item {
        Layout.preferredWidth: 360
        Layout.preferredHeight: 136
        Layout.minimumWidth: 360
        Layout.minimumHeight: 136
        Layout.maximumWidth: 360
        Layout.maximumHeight: 136

        Components.WidePlayer {
            anchors.fill: parent
            colors: nColors
            albumArt: root.albumArt
            track: root.track
            artist: root.artist
            position: root.position
            length: root.length
            isPlaying: root.isPlaying
            canGoPrevious: root.canGoPrevious
            canGoNext: root.canGoNext
            canPlay: root.canPlay
            canPause: root.canPause

            onPreviousClicked: root.previous()
            onNextClicked: root.next()
            onPlayPauseClicked: root.togglePlaying()
        }
    }
}
