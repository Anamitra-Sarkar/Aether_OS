/*
 * AetherOS Updater v1.0 RC
 * Simple update management UI
 * 
 * Features:
 * - Shows APT and Flatpak update counts
 * - Buttons to update all, security only, or open Discover
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: root
    width: 500
    height: 400
    visible: true
    title: "Aether Updater"
    
    // Design tokens
    readonly property color accentColor: "#6C8CFF"
    readonly property color accentSecondary: "#7AE7C7"
    readonly property color bgDark: "#0F1720"
    readonly property color surfaceDark: "#101317"
    readonly property color textColor: "#E5E7EB"
    readonly property color textMuted: "#9CA3AF"
    readonly property int animDuration: 150
    
    // Update counts (would be populated by script)
    property int aptUpdates: 0
    property int aptSecurity: 0
    property int flatpakUpdates: 0
    property bool isChecking: false
    property bool isUpdating: false
    
    color: bgDark
    
    Rectangle {
        anchors.fill: parent
        color: bgDark
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 20
            
            // Header
            RowLayout {
                Layout.fillWidth: true
                
                Text {
                    text: "🔄"
                    font.pixelSize: 28
                }
                
                Text {
                    text: "Aether Updater"
                    font.pixelSize: 24
                    font.weight: Font.Bold
                    color: textColor
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: isChecking ? "Checking..." : "Refresh"
                    enabled: !isChecking && !isUpdating
                    onClicked: {
                        isChecking = true
                        // In real implementation, run aether-updates.sh json
                        console.log("Checking for updates...")
                        // Simulate check completion
                        checkTimer.start()
                    }
                    
                    background: Rectangle {
                        radius: 8
                        color: Qt.rgba(1, 1, 1, 0.1)
                    }
                    contentItem: Text {
                        text: parent.text
                        color: textColor
                        font.pixelSize: 12
                    }
                }
            }
            
            // Update summary cards
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 100
                radius: 12
                color: surfaceDark
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 20
                    spacing: 40
                    
                    // APT updates
                    Column {
                        spacing: 4
                        
                        Text {
                            text: "📦 APT Packages"
                            font.pixelSize: 14
                            color: textMuted
                        }
                        
                        Text {
                            text: aptUpdates > 0 ? aptUpdates + " update(s)" : "Up to date"
                            font.pixelSize: 20
                            font.weight: Font.Medium
                            color: aptUpdates > 0 ? accentColor : accentSecondary
                        }
                        
                        Text {
                            text: aptSecurity > 0 ? aptSecurity + " security" : ""
                            font.pixelSize: 11
                            color: "#FF6B6B"
                            visible: aptSecurity > 0
                        }
                    }
                    
                    // Separator
                    Rectangle {
                        width: 1
                        Layout.fillHeight: true
                        color: Qt.rgba(1, 1, 1, 0.1)
                    }
                    
                    // Flatpak updates
                    Column {
                        spacing: 4
                        
                        Text {
                            text: "📱 Flatpak Apps"
                            font.pixelSize: 14
                            color: textMuted
                        }
                        
                        Text {
                            text: flatpakUpdates > 0 ? flatpakUpdates + " update(s)" : "Up to date"
                            font.pixelSize: 20
                            font.weight: Font.Medium
                            color: flatpakUpdates > 0 ? accentColor : accentSecondary
                        }
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    // Total
                    Column {
                        spacing: 4
                        
                        Text {
                            text: "Total"
                            font.pixelSize: 14
                            color: textMuted
                        }
                        
                        Text {
                            text: (aptUpdates + flatpakUpdates) + ""
                            font.pixelSize: 28
                            font.weight: Font.Bold
                            color: (aptUpdates + flatpakUpdates) > 0 ? textColor : accentSecondary
                        }
                    }
                }
            }
            
            // Action buttons
            Text {
                text: "Actions"
                font.pixelSize: 14
                color: textMuted
                Layout.topMargin: 8
            }
            
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                rowSpacing: 12
                columnSpacing: 12
                
                // Update All
                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    enabled: !isUpdating && (aptUpdates + flatpakUpdates) > 0
                    
                    background: Rectangle {
                        radius: 10
                        color: accentColor
                        opacity: parent.enabled ? 1.0 : 0.5
                    }
                    
                    contentItem: RowLayout {
                        spacing: 8
                        Item { Layout.fillWidth: true }
                        Text {
                            text: isUpdating ? "Updating..." : "Update All"
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: "white"
                        }
                        Item { Layout.fillWidth: true }
                    }
                    
                    onClicked: {
                        console.log("Starting full update...")
                        // Would open terminal with: sudo apt update && sudo apt upgrade -y && flatpak update -y
                    }
                }
                
                // Security Updates Only
                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    enabled: !isUpdating && aptSecurity > 0
                    
                    background: Rectangle {
                        radius: 10
                        color: "#FF6B6B"
                        opacity: parent.enabled ? 1.0 : 0.5
                    }
                    
                    contentItem: RowLayout {
                        spacing: 8
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "Security Only"
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: "white"
                        }
                        Item { Layout.fillWidth: true }
                    }
                    
                    onClicked: {
                        console.log("Starting security update...")
                        // Would run: aether-security-update.sh install
                    }
                }
                
                // Open Discover
                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    
                    background: Rectangle {
                        radius: 10
                        color: Qt.rgba(1, 1, 1, 0.1)
                    }
                    
                    contentItem: RowLayout {
                        spacing: 8
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "Open Discover"
                            font.pixelSize: 14
                            color: textColor
                        }
                        Item { Layout.fillWidth: true }
                    }
                    
                    onClicked: {
                        console.log("Opening Discover...")
                        // Would run: plasma-discover --mode update
                    }
                }
                
                // Open Terminal
                Button {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    
                    background: Rectangle {
                        radius: 10
                        color: Qt.rgba(1, 1, 1, 0.1)
                    }
                    
                    contentItem: RowLayout {
                        spacing: 8
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "Open Terminal"
                            font.pixelSize: 14
                            color: textColor
                        }
                        Item { Layout.fillWidth: true }
                    }
                    
                    onClicked: {
                        console.log("Opening terminal for manual update...")
                        // Would run: konsole -e "sudo apt update && sudo apt upgrade"
                    }
                }
            }
            
            Item { Layout.fillHeight: true }
            
            // Last checked
            Text {
                text: "Last checked: Just now"
                font.pixelSize: 11
                color: textMuted
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
    
    // Timer to simulate check completion
    Timer {
        id: checkTimer
        interval: 1500
        onTriggered: {
            isChecking = false
            // Simulate finding some updates
            aptUpdates = Math.floor(Math.random() * 10)
            aptSecurity = Math.floor(Math.random() * 3)
            flatpakUpdates = Math.floor(Math.random() * 5)
            console.log("Check complete:", aptUpdates, "APT,", flatpakUpdates, "Flatpak")
        }
    }
    
    Component.onCompleted: {
        // Initial check on launch
        isChecking = true
        checkTimer.start()
    }
}
