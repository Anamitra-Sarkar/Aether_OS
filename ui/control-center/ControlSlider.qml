/*
 * ControlSlider Component
 * A slider for volume, brightness, etc.
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root
    
    property string title: "Slider"
    property string iconSource: ""
    property int value: 50
    property color accentColor: "#6C8CFF"
    
    signal valueChanged(int value)
    
    height: 56
    radius: 12
    color: "#101317"
    
    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12
        
        Text {
            text: {
                switch(iconSource) {
                    case "audio-volume-high": return "🔊"
                    case "audio-volume-low": return "🔈"
                    case "audio-volume-muted": return "🔇"
                    case "brightness-high": return "☀️"
                    default: return "⚙️"
                }
            }
            font.pixelSize: 18
        }
        
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4
            
            RowLayout {
                Layout.fillWidth: true
                
                Text {
                    text: root.title
                    font.pixelSize: 12
                    color: "#E5E7EB"
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: slider.value + "%"
                    font.pixelSize: 11
                    color: Qt.rgba(1, 1, 1, 0.5)
                }
            }
            
            Slider {
                id: slider
                Layout.fillWidth: true
                from: 0
                to: 100
                value: root.value
                stepSize: 1
                
                background: Rectangle {
                    x: slider.leftPadding
                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                    width: slider.availableWidth
                    height: 4
                    radius: 2
                    color: Qt.rgba(1, 1, 1, 0.2)
                    
                    Rectangle {
                        width: slider.visualPosition * parent.width
                        height: parent.height
                        radius: 2
                        color: accentColor
                    }
                }
                
                handle: Rectangle {
                    x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
                    y: slider.topPadding + slider.availableHeight / 2 - height / 2
                    width: 16
                    height: 16
                    radius: 8
                    color: "white"
                    
                    Rectangle {
                        anchors.centerIn: parent
                        width: 8
                        height: 8
                        radius: 4
                        color: accentColor
                    }
                }
                
                onValueChanged: {
                    root.value = value
                    root.valueChanged(value)
                }
            }
        }
    }
}
