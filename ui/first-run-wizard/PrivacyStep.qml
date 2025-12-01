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
    
    signal telemetryChanged(bool enabled)
    signal restrictedChanged(bool enabled)
    
    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(450, parent.width - 64)
        spacing: 24
        
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Privacy & Extras"
            font.pixelSize: 24
            font.weight: Font.DemiBold
            color: textColor
        }
        
        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: 400
            text: "Configure privacy settings and optional features"
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
                
                Text {
                    text: "Privacy"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: accentColor
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        
                        Text {
                            text: "Send usage statistics"
                            font.pixelSize: 14
                            color: textColor
                        }
                        
                        Text {
                            text: "Help improve AetherOS by sending anonymous usage data"
                            font.pixelSize: 11
                            color: Qt.rgba(1, 1, 1, 0.5)
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                    
                    Switch {
                        id: telemetrySwitch
                        checked: false
                        
                        onCheckedChanged: telemetryChanged(checked)
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
                
                Text {
                    text: "Optional Extras"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: accentColor
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        
                        Text {
                            text: "Install restricted codecs"
                            font.pixelSize: 14
                            color: textColor
                        }
                        
                        Text {
                            text: "Enable playback of MP3, H.264, and other media formats"
                            font.pixelSize: 11
                            color: Qt.rgba(1, 1, 1, 0.5)
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }
                    
                    Switch {
                        id: restrictedSwitch
                        checked: false
                        
                        onCheckedChanged: restrictedChanged(checked)
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
                    text: "These settings can be changed later in System Settings"
                    font.pixelSize: 11
                    color: Qt.rgba(1, 1, 1, 0.7)
                    wrapMode: Text.WordWrap
                }
            }
        }
    }
}
