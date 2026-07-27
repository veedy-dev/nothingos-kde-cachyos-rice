import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.taskmanager as TaskManager
import org.kde.plasma.plasma5support as P5Support

PlasmoidItem {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    preferredRepresentation: fullRepresentation

    implicitWidth: Math.max(96, desktopInfo.numberOfDesktops * 32)
    implicitHeight: 48
    Layout.minimumWidth: implicitWidth
    Layout.preferredWidth: implicitWidth
    Layout.maximumWidth: implicitWidth

    FontLoader {
        id: ndotFont
        source: Qt.resolvedUrl("../../../com.jaxparrow07.nothingkdewidgets.digitalclock/contents/fonts/ndot.ttf")
    }

    TaskManager.VirtualDesktopInfo {
        id: desktopInfo
    }

    function activateDesktop(desktopId) {
        desktopSwitcher.connectSource(
            "qdbus6 org.nothingos.EdgeGroups /EdgeGroups "
            + "org.nothingos.EdgeGroups.ActivateDesktop "
            + String(desktopId))
    }

    P5Support.DataSource {
        id: desktopSwitcher
        engine: "executable"
        connectedSources: []

        onNewData: (sourceName, data) => {
            disconnectSource(sourceName)
        }
    }

    fullRepresentation: RowLayout {
        id: indicatorRow
        anchors.centerIn: parent
        spacing: 8

        Repeater {
            model: desktopInfo.desktopIds

            delegate: Rectangle {
                id: desktopIndicator
                required property var modelData
                required property int index

                readonly property bool active:
                    String(modelData) === String(desktopInfo.currentDesktop)

                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 26
                Layout.preferredHeight: 26
                radius: 0
                color: "transparent"
                border.width: active ? 0 : 1
                border.color: "#505050"

                Canvas {
                    id: activeCell
                    anchors.fill: parent
                    visible: desktopIndicator.active

                    onPaint: {
                        const context = getContext("2d")
                        context.clearRect(0, 0, width, height)
                        context.globalCompositeOperation = "source-over"
                        context.fillStyle = "#ffffff"
                        context.fillRect(0, 0, width, height)
                        context.globalCompositeOperation = "destination-out"
                        context.font = "18px '" + ndotFont.name + "'"
                        context.textAlign = "center"
                        context.textBaseline = "middle"
                        context.fillText(String(desktopIndicator.index + 1),
                                         width / 2,
                                         height / 2 + 1)
                        context.globalCompositeOperation = "source-over"
                    }

                    onVisibleChanged: requestPaint()
                    Connections {
                        target: ndotFont
                        function onStatusChanged() {
                            activeCell.requestPaint()
                        }
                    }
                }

                Text {
                    anchors.fill: parent
                    text: desktopIndicator.index + 1
                    visible: !desktopIndicator.active
                    color: "#d8d8d8"
                    font.family: ndotFont.name
                    font.pixelSize: 18
                    font.weight: Font.Normal
                    style: Text.Normal
                    renderType: Text.QtRendering
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }

                TapHandler {
                    onTapped: root.activateDesktop(desktopIndicator.modelData)
                }
            }
        }
    }
}
