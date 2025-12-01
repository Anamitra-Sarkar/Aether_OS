/*
 * QuickToggle Component
 * A toggle button for quick settings
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    
    property string title: "Toggle"
    property string subtitle: "Off"
    property string iconSource: ""
    property bool checked: false
    property color accentColor: "#6C8CFF"
    
    signal toggled(bool checked)
    
    height: 80
    radius: 12
    color: checked ? Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.2) : "#101317"
    border.color: checked ? accentColor : "transparent"
    border.width: 1
    
    Behavior on color {
        ColorAnimation { duration: 150 }
    }
    
    Behavior on border.color {
        ColorAnimation { duration: 150 }
    }
    
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            root.checked = !root.checked
            root.toggled(root.checked)
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 4
        
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: {
                    switch(iconSource) {
                        case "network-wireless": return "📶"
                        case "bluetooth": return "🔵"
                        case "weather-clear-night": return "🌙"
                        case "notifications-disabled": return "🔕"
                        default: return "⚙️"
                    }
                }
                font.pixelSize: 20
            }
            
            Item { Layout.fillWidth: true }
            
            Rectangle {
                width: 8
                height: 8
                radius: 4
                color: root.checked ? accentColor : Qt.rgba(1, 1, 1, 0.2)
                
                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
            }
        }
        
        Item { Layout.fillHeight: true }
        
        Text {
            text: root.title
            font.pixelSize: 14
            font.weight: Font.Medium
            color: "#E5E7EB"
        }
        
        Text {
            text: root.subtitle
            font.pixelSize: 11
            color: Qt.rgba(1, 1, 1, 0.5)
        }
    }
}
