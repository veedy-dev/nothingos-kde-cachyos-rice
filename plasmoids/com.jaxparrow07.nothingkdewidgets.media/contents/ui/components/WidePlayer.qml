import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Rectangle {
    id: root

    required property QtObject colors
    property string albumArt: ""
    property string track: ""
    property string artist: ""
    property real position: 0
    property real length: 0
    property bool isPlaying: false
    property bool canGoPrevious: false
    property bool canGoNext: false
    property bool canPlay: false
    property bool canPause: false

    signal previousClicked()
    signal nextClicked()
    signal playPauseClicked()

    color: colors.surfaceAlt
    radius: 0
    clip: true

    RowLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 14

        Rectangle {
            Layout.preferredWidth: 112
            Layout.fillHeight: true
            color: root.colors.surface
            radius: 0
            clip: true

            Image {
                anchors.fill: parent
                source: root.albumArt
                fillMode: Image.PreserveAspectCrop
                smooth: true
                visible: root.albumArt !== ""
            }

            Kirigami.Icon {
                anchors.centerIn: parent
                width: 42
                height: 42
                source: "media-optical-audio"
                color: root.colors.textDisabled
                visible: root.albumArt === ""
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 3

            MarqueeText {
                Layout.fillWidth: true
                Layout.preferredHeight: 24
                text: root.track || "No Track"
                fontSize: 17
                bold: true
                textColor: root.colors.textPrimary
            }

            Text {
                Layout.fillWidth: true
                text: root.artist || "Unknown Artist"
                color: root.colors.textPlaceholder
                font.pixelSize: 12
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            ProgressBar {
                Layout.fillWidth: true
                Layout.preferredHeight: 4
                Layout.topMargin: 4
                position: root.position
                length: root.length
                backgroundColor: root.colors.surface
                progressColor: root.colors.textPrimary
            }

            Item { Layout.fillHeight: true }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Item { Layout.fillWidth: true }

                Kirigami.Icon {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    source: "media-skip-backward"
                    color: root.colors.textPrimary
                    opacity: root.canGoPrevious ? 1 : 0.3

                    TapHandler {
                        enabled: root.canGoPrevious
                        onTapped: root.previousClicked()
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 34
                    Layout.preferredHeight: 34
                    color: root.colors.surface
                    radius: 0

                    Kirigami.Icon {
                        anchors.centerIn: parent
                        width: 22
                        height: 22
                        source: root.isPlaying
                            ? "media-playback-pause"
                            : "media-playback-start"
                        color: root.colors.textPrimary
                    }

                    TapHandler {
                        enabled: root.canPlay || root.canPause
                        onTapped: root.playPauseClicked()
                    }
                }

                Kirigami.Icon {
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24
                    source: "media-skip-forward"
                    color: root.colors.textPrimary
                    opacity: root.canGoNext ? 1 : 0.3

                    TapHandler {
                        enabled: root.canGoNext
                        onTapped: root.nextClicked()
                    }
                }
            }
        }
    }
}
