/*
 * Theme Card Component
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    
    property string title: "Theme"
    property bool isSelected: false
    property color bgColor: "#0F1720"
    property color fgColor: "#E5E7EB"
    property color accentColor: "#6C8CFF"
    
    signal clicked()
    
    width: 160
    height: 180
    radius: 16
    color: Qt.rgba(1, 1, 1, 0.05)
    border.color: isSelected ? accentColor : Qt.rgba(1, 1, 1, 0.1)
    border.width: isSelected ? 2 : 1
    
    Behavior on border.color {
        ColorAnimation { duration: 150 }
    }
    
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12
        
        // Preview
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 8
            color: bgColor
            
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4
                
                // Title bar preview
                Rectangle {
                    Layout.fillWidth: true
                    height: 8
                    radius: 4
                    color: Qt.rgba(fgColor.r, fgColor.g, fgColor.b, 0.2)
                }
                
                // Content preview
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 4
                    color: Qt.rgba(fgColor.r, fgColor.g, fgColor.b, 0.1)
                    
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 6
                        spacing: 4
                        
                        Rectangle {
                            Layout.fillWidth: true
                            height: 6
                            radius: 3
                            color: accentColor
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredWidth: parent.width * 0.7
                            height: 4
                            radius: 2
                            color: Qt.rgba(fgColor.r, fgColor.g, fgColor.b, 0.3)
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredWidth: parent.width * 0.5
                            height: 4
                            radius: 2
                            color: Qt.rgba(fgColor.r, fgColor.g, fgColor.b, 0.2)
                        }
                        
                        Item { Layout.fillHeight: true }
                    }
                }
                
                // Dock preview
                Rectangle {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: parent.width * 0.8
                    height: 10
                    radius: 5
                    color: Qt.rgba(fgColor.r, fgColor.g, fgColor.b, 0.15)
                }
            }
        }
        
        // Label
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: title
                font.pixelSize: 14
                font.weight: Font.Medium
                color: fgColor
            }
            
            Item { Layout.fillWidth: true }
            
            Rectangle {
                width: 18
                height: 18
                radius: 9
                color: isSelected ? accentColor : "transparent"
                border.color: isSelected ? accentColor : Qt.rgba(1, 1, 1, 0.3)
                border.width: 2
                
                Rectangle {
                    anchors.centerIn: parent
                    width: 8
                    height: 8
                    radius: 4
                    color: "white"
                    visible: isSelected
                }
            }
        }
    }
}
