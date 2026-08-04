/*
    SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2017 The Qt Company Ltd.
    SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>

    SPDX-License-Identifier: LGPL-3.0-only OR GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami
import org.kde.desktop.private as Private
import org.kde.qqc2desktopstyle.private as StylePrivate

T.Slider {
    id: controlRoot

    Kirigami.Theme.colorSet: Kirigami.Theme.Button

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    baselineOffset: background ? background.y + background.baselineOffset : 0

    hoverEnabled: true

    handle: Private.DefaultSliderHandle {
        control: controlRoot

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "#f25e70"
            border.color: "#303030"
            border.width: 1
        }
    }

    snapMode: T.Slider.SnapOnRelease

    background: StylePrivate.StyleItem {
        control: controlRoot
        elementType: "slider"
        sunken: controlRoot.pressed

        minimum: 0
        maximum: 100000
        step: 100000 * (controlRoot.stepSize / (controlRoot.to - controlRoot.from))
        value: 100000 * controlRoot.position

        horizontal: controlRoot.orientation === Qt.Horizontal
        enabled: controlRoot.enabled
        hasFocus: controlRoot.activeFocus
        hover: controlRoot.hovered
        activeControl: controlRoot.stepSize > 0 && controlRoot.Kirigami.StyleHints.tickMarkStepSize >= 0 ? "ticks" : ""

        properties: {
            "tickMarkStepSize": 100000 * (controlRoot.Kirigami.StyleHints.tickMarkStepSize / (controlRoot.to - controlRoot.from))
        }

        MouseArea {
            property int wheelDelta: 0

            anchors {
                fill: parent
                leftMargin: controlRoot.leftPadding
                rightMargin: controlRoot.rightPadding
            }
            LayoutMirroring.enabled: false

            acceptedButtons: Qt.NoButton

            onWheel: wheel => {
                const lastValue = controlRoot.value
                const delta = (wheel.angleDelta.y || -wheel.angleDelta.x) * (wheel.inverted ? -1 : 1)
                wheelDelta += delta;
                while (wheelDelta >= 120) {
                    wheelDelta -= 120;
                    controlRoot.increase();
                }
                while (wheelDelta <= -120) {
                    wheelDelta += 120;
                    controlRoot.decrease();
                }
                if (lastValue !== controlRoot.value) {
                    controlRoot.moved();
                }
            }
        }
    }
}
