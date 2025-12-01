/*
 * User Setup Step Component
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    property color accentColor: "#6C8CFF"
    property color textColor: "#E5E7EB"
    property color surfaceColor: "#101317"
    property alias userName: nameField.text
    
    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(400, parent.width - 64)
        spacing: 24
        
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Create Your Account"
            font.pixelSize: 24
            font.weight: Font.DemiBold
            color: textColor
        }
        
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Enter your name to personalize your experience"
            font.pixelSize: 14
            color: Qt.rgba(1, 1, 1, 0.6)
        }
        
        Item { height: 16 }
        
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Text {
                text: "Full Name"
                font.pixelSize: 12
                color: Qt.rgba(1, 1, 1, 0.6)
            }
            
            TextField {
                id: nameField
                Layout.fillWidth: true
                placeholderText: "Enter your name"
                font.pixelSize: 14
                color: textColor
                
                background: Rectangle {
                    implicitHeight: 48
                    radius: 10
                    color: surfaceColor
                    border.color: nameField.activeFocus ? accentColor : Qt.rgba(1, 1, 1, 0.2)
                    border.width: nameField.activeFocus ? 2 : 1
                    
                    Behavior on border.color {
                        ColorAnimation { duration: 150 }
                    }
                }
            }
        }
        
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            Text {
                text: "Computer Name"
                font.pixelSize: 12
                color: Qt.rgba(1, 1, 1, 0.6)
            }
            
            TextField {
                id: hostnameField
                Layout.fillWidth: true
                text: "aetheros"
                placeholderText: "Computer name"
                font.pixelSize: 14
                color: textColor
                
                background: Rectangle {
                    implicitHeight: 48
                    radius: 10
                    color: surfaceColor
                    border.color: hostnameField.activeFocus ? accentColor : Qt.rgba(1, 1, 1, 0.2)
                    border.width: hostnameField.activeFocus ? 2 : 1
                    
                    Behavior on border.color {
                        ColorAnimation { duration: 150 }
                    }
                }
            }
        }
    }
}
