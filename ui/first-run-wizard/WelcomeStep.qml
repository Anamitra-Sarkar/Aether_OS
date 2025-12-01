/*
 * Welcome Step Component
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    property color accentColor: "#6C8CFF"
    property color textColor: "#E5E7EB"
    
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 24
        
        // Logo placeholder
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 120
            height: 120
            radius: 60
            color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.2)
            
            Text {
                anchors.centerIn: parent
                text: "✨"
                font.pixelSize: 48
            }
        }
        
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Welcome to AetherOS"
            font.pixelSize: 28
            font.weight: Font.DemiBold
            color: textColor
        }
        
        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: 400
            text: "A beautiful, fast, and privacy-focused desktop experience. Let's get you set up in just a few steps."
            font.pixelSize: 14
            color: Qt.rgba(1, 1, 1, 0.7)
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
        
        Item { height: 20 }
        
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 32
            
            FeatureItem {
                icon: "🎨"
                title: "Beautiful"
                accentColor: parent.parent.accentColor
            }
            
            FeatureItem {
                icon: "⚡"
                title: "Fast"
                accentColor: parent.parent.accentColor
            }
            
            FeatureItem {
                icon: "🔒"
                title: "Private"
                accentColor: parent.parent.accentColor
            }
        }
    }
}
