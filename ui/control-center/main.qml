/*
 * AetherOS Control Center
 * Quick Settings Panel for Desktop
 * 
 * This QML application provides quick access to common system settings:
 * - Wi-Fi toggle
 * - Bluetooth toggle
 * - Night Light toggle
 * - Volume slider
 * - Brightness slider
 * - Power profile selection
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: root
    width: 360
    height: 480
    visible: true
    title: "Control Center"
    
    // Design tokens
    readonly property color accentColor: "#6C8CFF"
    readonly property color accentSecondary: "#7AE7C7"
    readonly property color bgDark: "#0F1720"
    readonly property color surfaceDark: "#101317"
    readonly property color textColor: "#E5E7EB"
    readonly property int animDuration: 150
    
    color: bgDark
    
    // Animation easing
    readonly property var animEasing: Easing.OutCubic
    
    Rectangle {
        anchors.fill: parent
        color: bgDark
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16
            
            // Header
            RowLayout {
                Layout.fillWidth: true
                
                Text {
                    text: "Control Center"
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                    color: textColor
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: Qt.formatTime(new Date(), "hh:mm")
                    font.pixelSize: 14
                    color: Qt.rgba(1, 1, 1, 0.6)
                }
            }
            
            // Quick Toggles Grid
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 12
                columnSpacing: 12
                
                // Wi-Fi Toggle
                QuickToggle {
                    id: wifiToggle
                    Layout.fillWidth: true
                    title: "Wi-Fi"
                    subtitle: wifiToggle.checked ? "Connected" : "Off"
                    iconSource: "network-wireless"
                    checked: true
                    accentColor: root.accentColor
                    onToggled: {
                        // Call nmcli to toggle Wi-Fi
                        console.log("Wi-Fi toggled:", checked)
                    }
                }
                
                // Bluetooth Toggle
                QuickToggle {
                    id: btToggle
                    Layout.fillWidth: true
                    title: "Bluetooth"
                    subtitle: btToggle.checked ? "On" : "Off"
                    iconSource: "bluetooth"
                    checked: false
                    accentColor: root.accentColor
                    onToggled: {
                        console.log("Bluetooth toggled:", checked)
                    }
                }
                
                // Night Light Toggle
                QuickToggle {
                    id: nightLightToggle
                    Layout.fillWidth: true
                    title: "Night Light"
                    subtitle: nightLightToggle.checked ? "On" : "Off"
                    iconSource: "weather-clear-night"
                    checked: false
                    accentColor: "#FFB347"
                    onToggled: {
                        console.log("Night Light toggled:", checked)
                    }
                }
                
                // Do Not Disturb Toggle
                QuickToggle {
                    id: dndToggle
                    Layout.fillWidth: true
                    title: "Focus"
                    subtitle: dndToggle.checked ? "On" : "Off"
                    iconSource: "notifications-disabled"
                    checked: false
                    accentColor: root.accentSecondary
                    onToggled: {
                        console.log("DND toggled:", checked)
                    }
                }
            }
            
            // Volume Slider
            ControlSlider {
                Layout.fillWidth: true
                title: "Volume"
                iconSource: "audio-volume-high"
                value: 75
                accentColor: root.accentColor
                onValueChanged: {
                    console.log("Volume:", value)
                }
            }
            
            // Brightness Slider
            ControlSlider {
                Layout.fillWidth: true
                title: "Brightness"
                iconSource: "brightness-high"
                value: 80
                accentColor: root.accentSecondary
                onValueChanged: {
                    console.log("Brightness:", value)
                }
            }
            
            // Power Profile
            Rectangle {
                Layout.fillWidth: true
                height: 60
                radius: 12
                color: surfaceDark
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12
                    
                    Text {
                        text: "⚡"
                        font.pixelSize: 20
                    }
                    
                    Text {
                        text: "Power Mode"
                        font.pixelSize: 14
                        color: textColor
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    ComboBox {
                        id: powerModeCombo
                        model: ["Balanced", "Performance", "Power Saver"]
                        currentIndex: 0
                        
                        background: Rectangle {
                            implicitWidth: 120
                            implicitHeight: 36
                            radius: 8
                            color: Qt.rgba(1, 1, 1, 0.1)
                            border.color: accentColor
                            border.width: 1
                        }
                        
                        contentItem: Text {
                            text: powerModeCombo.currentText
                            color: textColor
                            font.pixelSize: 12
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                        
                        onCurrentIndexChanged: {
                            console.log("Power mode:", currentText)
                        }
                    }
                }
            }
            
            Item { Layout.fillHeight: true }
            
            // Settings Button
            Button {
                Layout.fillWidth: true
                Layout.preferredHeight: 44
                text: "All Settings"
                
                background: Rectangle {
                    radius: 10
                    color: accentColor
                    
                    Behavior on color {
                        ColorAnimation { duration: animDuration }
                    }
                }
                
                contentItem: Text {
                    text: parent.text
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: "white"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                onClicked: {
                    // Open system settings using D-Bus or command line
                    // In KDE, systemsettings5 is launched via command
                    console.log("Opening System Settings...")
                    // This requires a Process component or platform-specific launcher
                    // For now, log the action - real implementation would use:
                    // Qt.createQmlObject('import QtQuick 2.15; Process { ... }')
                    // or the org.kde.plasma.components Process type
                }
            }
        }
    }
}
