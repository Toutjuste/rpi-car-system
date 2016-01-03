/*
 * This file is part of RPI Car System.
 * Copyright (c) 2016 Fabien Caylus <toutjuste13@gmail.com>
 *
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import "."

CheckBox {
    style: CheckBoxStyle {
        indicator: Rectangle {
            border.width: 2
            border.color: control.checked ? Style.button.checkedOverlayColor : Style.progressBar.borderColor
            radius: 5
            color: "#F2111111"
            implicitWidth: 40
            implicitHeight: 40

            StyledText {
                visible: control.checked
                font.family: awesomeFont.name
                anchors.margins: 2
                anchors.fill: parent
                fontSizeMode: Text.Fit
                font.pixelSize: 100
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                text: "\uf00c"
            }
        }

        background: Rectangle {
            color: "transparent"
            height: control.height
            width: control.width
        }

        label: StyledText {
            text: control.text
            font.pixelSize: control.height * .6
            //font.bold: true
        }

        spacing: 15
    }
}
