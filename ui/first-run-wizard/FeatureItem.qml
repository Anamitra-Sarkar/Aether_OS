/*
 * Feature Item Component
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ColumnLayout {
    property string icon: ""
    property string title: ""
    property color accentColor: "#6C8CFF"
    
    spacing: 8
    
    Rectangle {
        Layout.alignment: Qt.AlignHCenter
        width: 56
        height: 56
        radius: 12
        color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.15)
        
        Text {
            anchors.centerIn: parent
            text: icon
            font.pixelSize: 24
        }
    }
    
    Text {
        Layout.alignment: Qt.AlignHCenter
        text: title
        font.pixelSize: 12
        color: Qt.rgba(1, 1, 1, 0.8)
    }
}
