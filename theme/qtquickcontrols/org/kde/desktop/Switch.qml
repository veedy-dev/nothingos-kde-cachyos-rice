/*
    SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2017 The Qt Company Ltd.

    SPDX-License-Identifier: LGPL-3.0-only OR GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami
import org.kde.desktop.private as Private

T.Switch {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding,
                            implicitIndicatorWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)
    baselineOffset: contentItem ? contentItem.y + contentItem.baselineOffset : 0

    padding: 1
    spacing: Kirigami.Units.smallSpacing

    hoverEnabled: true

    indicator: Private.SwitchIndicator {
        id: switchIndicator

        x: if (control.contentItem !== null && control.contentItem.width > 0) {
            return control.mirrored ?
                control.width - width - control.rightPadding : control.leftPadding
        } else {
            return control.leftPadding + (control.availableWidth - width) / 2
        }
        y: if (control.contentItem !== null
            && (control.contentItem instanceof Text || control.contentItem instanceof TextEdit)
            && control.contentItem.lineCount > 1) {
            return control.topPadding
        } else {
            return control.topPadding + Math.round((control.availableHeight - height) / 2)
        }
        control: control

        Rectangle {
            anchors.fill: switchIndicator.handle
            visible: control.checked
            radius: width / 2
            color: "#f25e70"
            border.color: "#303030"
            border.width: 1
        }
    }

    Kirigami.MnemonicData.enabled: enabled && visible
    Kirigami.MnemonicData.controlType: Kirigami.MnemonicData.ActionElement
    Kirigami.MnemonicData.label: text
    Shortcut {
        enabled: !(RegExp(/\&[^\&]/).test(control.text))
        sequence: control.Kirigami.MnemonicData.sequence
        onActivated: {
            if (typeof control.animateClick === "function") {
                control.animateClick();
            } else {
                control.toggle();
            }
        }
    }

    contentItem: Label {
        property FontMetrics fontMetrics: FontMetrics {}
        topPadding: Math.max(0, (control.implicitIndicatorHeight - fontMetrics.height) / 2)
        bottomPadding: topPadding
        leftPadding: control.indicator && !control.mirrored ? control.indicator.width + control.spacing : 0
        rightPadding: control.indicator && control.mirrored ? control.indicator.width + control.spacing : 0
        opacity: control.enabled ? 1 : 0.6
        text: control.Kirigami.MnemonicData.richTextLabel
        font: control.font
        color: Kirigami.Theme.textColor
        elide: Text.ElideRight
        wrapMode: Text.Wrap
        visible: control.text
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter

        Accessible.ignored: true
    }
}
