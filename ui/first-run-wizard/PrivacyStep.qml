/*
 * Privacy Step Component
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    property color accentColor: "#6C8CFF"
    property color textColor: "#E5E7EB"
    property color surfaceColor: "#101317"
    
    signal privacyModeChanged(bool enabled)
    signal installFlatpaksChanged(bool enabled)
    signal updateNotificationsChanged(bool enabled)
    
    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(450, parent.width - 64)
        spacing: 24
        
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Customize Your Experience"
            font.pixelSize: 24
            font.weight: Font.DemiBold
            color: textColor
        }
        
        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: 400
            text: "Choose your preferences — all settings can be changed later"
            font.pixelSize: 14
            color: Qt.rgba(1, 1, 1, 0.6)
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
        
        Item { height: 8 }
        
        // Privacy Settings
        Rectangle {
            Layout.fillWidth: true
            height: privacyColumn.height + 24
            radius: 12
            color: surfaceColor
            
            ColumnLayout {
                id: privacyColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 12
                spacing: 16
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        
                        Text {
                            text: "Privacy Mode"
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: textColor
                        }
                        
                        Text {
                            text: "Disable telemetry and tracking (recommended)"
                            font.pixelSize: 11
                            color: Qt.rgba(1, 1, 1, 0.5)
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                    
                    Switch {
                        id: privacySwitch
                        checked: true
                        
                        onCheckedChanged: privacyModeChanged(checked)
                    }
                }
            }
        }
        
        // Optional Extras
        Rectangle {
            Layout.fillWidth: true
            height: extrasColumn.height + 24
            radius: 12
            color: surfaceColor
            
            ColumnLayout {
                id: extrasColumn
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 12
                spacing: 16
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        
                        Text {
                            text: "Install Popular Flatpaks"
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: textColor
                        }
                        
                        Text {
                            text: "Add Flathub and install commonly used apps"
                            font.pixelSize: 11
                            color: Qt.rgba(1, 1, 1, 0.5)
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                    
                    Switch {
                        id: flatpaksSwitch
                        checked: true
                        
                        onCheckedChanged: installFlatpaksChanged(checked)
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(1, 1, 1, 0.1)
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        
                        Text {
                            text: "Enable Update Notifications"
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: textColor
                        }
                        
                        Text {
                            text: "Get notified about system and app updates"
                            font.pixelSize: 11
                            color: Qt.rgba(1, 1, 1, 0.5)
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                    
                    Switch {
                        id: updatesSwitch
                        checked: true
                        
                        onCheckedChanged: updateNotificationsChanged(checked)
                    }
                }
            }
        }
        
        // Info note
        Rectangle {
            Layout.fillWidth: true
            height: infoRow.height + 16
            radius: 8
            color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.1)
            
            RowLayout {
                id: infoRow
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8
                
                Text {
                    text: "ℹ️"
                    font.pixelSize: 14
                }
                
                Text {
                    Layout.fillWidth: true
                    text: "All settings can be changed anytime in System Settings"
                    font.pixelSize: 11
                    color: Qt.rgba(1, 1, 1, 0.7)
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
