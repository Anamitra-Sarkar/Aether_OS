/*
 * Welcome Step Component
 * AetherOS First-Run Wizard - Welcome page
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
        
        // Logo with glow effect
        Item {
            Layout.alignment: Qt.AlignHCenter
            width: 140
            height: 140
            
            // Glow background
            Rectangle {
                anchors.centerIn: parent
                width: 130
                height: 130
                radius: 65
                color: "transparent"
                border.color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.3)
                border.width: 2
            }
            
            Rectangle {
                anchors.centerIn: parent
                width: 110
                height: 110
                radius: 55
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.3) }
                    GradientStop { position: 1.0; color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.1) }
                }
                
                Text {
                    anchors.centerIn: parent
                    text: "✨"
                    font.pixelSize: 52
                }
            }
        }
        
        // Title with subtle animation
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Welcome to AetherOS"
            font.pixelSize: 32
            font.weight: Font.Bold
            color: textColor
            
            // Subtle fade-in effect
            opacity: 0
            Component.onCompleted: {
                opacity = 1
            }
            Behavior on opacity {
                NumberAnimation { duration: 500; easing.type: Easing.OutCubic }
            }
        }
        
        // Version badge
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: versionText.width + 24
            height: 28
            radius: 14
            color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.2)
            
            Text {
                id: versionText
                anchors.centerIn: parent
                text: "Version 1.0 RC"
                font.pixelSize: 12
                color: accentColor
            }
        }
        
        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: 450
            text: "Let's personalize your system in just a few quick steps."
            font.pixelSize: 15
            color: Qt.rgba(1, 1, 1, 0.7)
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
            lineHeight: 1.4
        }
        
        Item { height: 24 }
        
        // Feature highlights
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 40
            
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
                title: "Secure"
                accentColor: parent.parent.accentColor
            }
            
            FeatureItem {
                icon: "🛠️"
                title: "Powerful"
                accentColor: parent.parent.accentColor
            }
        }
    }
}
