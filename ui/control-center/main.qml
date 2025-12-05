/*
 * AetherOS Control Center v2.0
 * System Hub with multiple pages for comprehensive system management
 * 
 * Pages:
 * - Overview: System info, quick toggles
 * - Network & Security: Wi-Fi, Bluetooth, Firewall
 * - Appearance: Theme, accent color
 * - Power: Power profiles, battery
 * - Maintenance: Health check, updates, logs
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: root
    width: 700
    height: 550
    visible: true
    title: "Aether Control Center"
    
    // Design tokens
    readonly property color accentColor: "#6C8CFF"
    readonly property color accentSecondary: "#7AE7C7"
    readonly property color bgDark: "#0F1720"
    readonly property color surfaceDark: "#101317"
    readonly property color sidebarColor: "#0A0D12"
    readonly property color textColor: "#E5E7EB"
    readonly property color textMuted: "#9CA3AF"
    readonly property int animDuration: 150
    
    // Links
    readonly property string githubUrl: "https://github.com/Anamitra-Sarkar/Aether_OS"
    
    color: bgDark
    
    // Current page index
    property int currentPage: 0
    
    // Page titles
    readonly property var pageTitles: ["Overview", "Network & Security", "Appearance", "Power & Performance", "Maintenance", "About"]
    readonly property var pageIcons: ["🖥️", "🔒", "🎨", "⚡", "🔧", "ℹ️"]
    
    Rectangle {
        anchors.fill: parent
        color: bgDark
        
        RowLayout {
            anchors.fill: parent
            spacing: 0
            
            // Sidebar
            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: 200
                color: sidebarColor
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8
                    
                    // Header
                    Text {
                        text: "Control Center"
                        font.pixelSize: 18
                        font.weight: Font.Bold
                        color: textColor
                        Layout.bottomMargin: 16
                    }
                    
                    // Navigation items
                    Repeater {
                        model: pageTitles.length
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 44
                            radius: 8
                            color: currentPage === index ? Qt.rgba(1, 1, 1, 0.1) : "transparent"
                            border.color: currentPage === index ? accentColor : "transparent"
                            border.width: 1
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 10
                                
                                Text {
                                    text: pageIcons[index]
                                    font.pixelSize: 16
                                }
                                
                                Text {
                                    text: pageTitles[index]
                                    font.pixelSize: 13
                                    color: currentPage === index ? textColor : textMuted
                                    Layout.fillWidth: true
                                }
                            }
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: currentPage = index
                            }
                            
                            Behavior on color {
                                ColorAnimation { duration: animDuration }
                            }
                        }
                    }
                    
                    Item { Layout.fillHeight: true }
                    
                    // Version info
                    Rectangle {
                        Layout.fillWidth: true
                        height: 60
                        radius: 8
                        color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.15)
                        border.color: Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.3)
                        border.width: 1
                        
                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 2
                            
                            Text {
                                text: "AetherOS v1.1"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                                color: textColor
                            }
                            
                            Text {
                                text: "Quality of Life Update"
                                font.pixelSize: 10
                                color: textMuted
                            }
                        }
                    }
                }
            }
            
            // Main content area
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: bgDark
                
                StackLayout {
                    anchors.fill: parent
                    anchors.margins: 24
                    currentIndex: currentPage
                    
                    // Page 0: Overview
                    ColumnLayout {
                        spacing: 20
                        
                        Text {
                            text: "System Overview"
                            font.pixelSize: 24
                            font.weight: Font.Bold
                            color: textColor
                        }
                        
                        // System info grid
                        GridLayout {
                            columns: 2
                            rowSpacing: 16
                            columnSpacing: 16
                            Layout.fillWidth: true
                            
                            // OS Info Card
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 100
                                radius: 12
                                color: surfaceDark
                                
                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 4
                                    
                                    Text {
                                        text: "Operating System"
                                        font.pixelSize: 12
                                        color: textMuted
                                    }
                                    Text {
                                        text: "AetherOS v1.1"
                                        font.pixelSize: 16
                                        font.weight: Font.Medium
                                        color: textColor
                                    }
                                    Text {
                                        text: "A beautiful, privacy-focused Linux desktop"
                                        font.pixelSize: 10
                                        color: accentColor
                                        wrapMode: Text.WordWrap
                                    }
                                    Text {
                                        text: "Based on Ubuntu 24.04 LTS"
                                        font.pixelSize: 10
                                        color: textMuted
                                    }
                                }
                            }
                            
                            // Hardware Info Card
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 100
                                radius: 12
                                color: surfaceDark
                                
                                ColumnLayout {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 4
                                    
                                    Text {
                                        text: "Hardware"
                                        font.pixelSize: 12
                                        color: textMuted
                                    }
                                    Text {
                                        text: "CPU / Memory"
                                        font.pixelSize: 16
                                        font.weight: Font.Medium
                                        color: textColor
                                    }
                                    Text {
                                        text: "Run health check for details"
                                        font.pixelSize: 11
                                        color: textMuted
                                    }
                                }
                            }
                        }
                        
                        // Quick toggles
                        Text {
                            text: "Quick Settings"
                            font.pixelSize: 16
                            font.weight: Font.Medium
                            color: textColor
                            Layout.topMargin: 8
                        }
                        
                        GridLayout {
                            Layout.fillWidth: true
                            columns: 4
                            rowSpacing: 12
                            columnSpacing: 12
                            
                            QuickToggle {
                                Layout.fillWidth: true
                                title: "Wi-Fi"
                                subtitle: checked ? "On" : "Off"
                                iconSource: "network-wireless"
                                checked: true
                                accentColor: root.accentColor
                            }
                            
                            QuickToggle {
                                Layout.fillWidth: true
                                title: "Bluetooth"
                                subtitle: checked ? "On" : "Off"
                                iconSource: "bluetooth"
                                checked: false
                                accentColor: root.accentColor
                            }
                            
                            QuickToggle {
                                Layout.fillWidth: true
                                title: "Night Light"
                                subtitle: checked ? "On" : "Off"
                                iconSource: "weather-clear-night"
                                checked: false
                                accentColor: "#FFB347"
                            }
                            
                            QuickToggle {
                                Layout.fillWidth: true
                                title: "Focus"
                                subtitle: checked ? "On" : "Off"
                                iconSource: "notifications-disabled"
                                checked: false
                                accentColor: root.accentSecondary
                                onToggled: function(isChecked) {
                                    // Toggle Focus Mode / Do Not Disturb
                                    // Note: QML cannot directly execute scripts with arguments
                                    // This will be handled by the run.sh wrapper or manual execution
                                    console.log("Focus Mode toggled:", isChecked)
                                }
                            }
                        }
                        
                        Item { Layout.fillHeight: true }
                    }
                    
                    // Page 1: Network & Security
                    ColumnLayout {
                        spacing: 20
                        
                        Text {
                            text: "Network & Security"
                            font.pixelSize: 24
                            font.weight: Font.Bold
                            color: textColor
                        }
                        
                        // Network status
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 80
                            radius: 12
                            color: surfaceDark
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 16
                                
                                Text {
                                    text: "🌐"
                                    font.pixelSize: 24
                                }
                                
                                ColumnLayout {
                                    spacing: 2
                                    Text {
                                        text: "Network Status"
                                        font.pixelSize: 14
                                        font.weight: Font.Medium
                                        color: textColor
                                    }
                                    Text {
                                        text: "Connected"
                                        font.pixelSize: 12
                                        color: accentSecondary
                                    }
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                Button {
                                    text: "Network Settings"
                                    onClicked: console.log("Open network settings")
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
                        }
                        
                        // Firewall status
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 80
                            radius: 12
                            color: surfaceDark
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 16
                                
                                Text {
                                    text: "🛡️"
                                    font.pixelSize: 24
                                }
                                
                                ColumnLayout {
                                    spacing: 2
                                    Text {
                                        text: "Firewall (UFW)"
                                        font.pixelSize: 14
                                        font.weight: Font.Medium
                                        color: textColor
                                    }
                                    Text {
                                        text: "Active - Deny incoming, Allow outgoing"
                                        font.pixelSize: 12
                                        color: accentSecondary
                                    }
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                Button {
                                    text: "Firewall Settings"
                                    onClicked: console.log("Open gufw")
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
                        }
                        
                        Item { Layout.fillHeight: true }
                    }
                    
                    // Page 2: Appearance
                    ColumnLayout {
                        spacing: 20
                        
                        Text {
                            text: "Appearance"
                            font.pixelSize: 24
                            font.weight: Font.Bold
                            color: textColor
                        }
                        
                        // Theme selection
                        Text {
                            text: "Theme"
                            font.pixelSize: 14
                            color: textMuted
                        }
                        
                        RowLayout {
                            spacing: 16
                            
                            // Dark theme card
                            Rectangle {
                                width: 120
                                height: 80
                                radius: 12
                                color: "#0F1720"
                                border.color: accentColor
                                border.width: 2
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 4
                                    Text {
                                        text: "🌙"
                                        font.pixelSize: 20
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        text: "Dark"
                                        font.pixelSize: 12
                                        color: textColor
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: console.log("Select dark theme")
                                }
                            }
                            
                            // Light theme card
                            Rectangle {
                                width: 120
                                height: 80
                                radius: 12
                                color: "#F6F8FA"
                                border.color: "transparent"
                                border.width: 2
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 4
                                    Text {
                                        text: "☀️"
                                        font.pixelSize: 20
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        text: "Light"
                                        font.pixelSize: 12
                                        color: "#0F1720"
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: console.log("Select light theme")
                                }
                            }
                        }
                        
                        // Auto Theme Schedule
                        Text {
                            text: "Auto Theme Schedule"
                            font.pixelSize: 14
                            color: textMuted
                            Layout.topMargin: 16
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 60
                            radius: 12
                            color: surfaceDark
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 12
                                
                                Text {
                                    text: "🌓"
                                    font.pixelSize: 20
                                }
                                
                                ColumnLayout {
                                    spacing: 2
                                    Layout.fillWidth: true
                                    
                                    Text {
                                        text: "Auto Light/Dark"
                                        font.pixelSize: 14
                                        font.weight: Font.Medium
                                        color: textColor
                                    }
                                    Text {
                                        text: "Light theme in day, dark at night"
                                        font.pixelSize: 11
                                        color: textMuted
                                    }
                                }
                                
                                Switch {
                                    id: autoThemeSwitch
                                    checked: false
                                    onToggled: {
                                        // Note: QML cannot directly execute scripts with arguments
                                        // This will be handled by the run.sh wrapper or manual execution
                                        console.log("Auto Theme Schedule toggled:", checked)
                                    }
                                }
                            }
                        }
                        
                        // Accent color
                        Text {
                            text: "Accent Color"
                            font.pixelSize: 14
                            color: textMuted
                            Layout.topMargin: 16
                        }
                        
                        RowLayout {
                            spacing: 12
                            
                            Repeater {
                                model: ["#6C8CFF", "#7AE7C7", "#FF6B9D", "#FFB347", "#A78BFA", "#34D399"]
                                
                                Rectangle {
                                    width: 36
                                    height: 36
                                    radius: 18
                                    color: modelData
                                    border.color: modelData === "#6C8CFF" ? "white" : "transparent"
                                    border.width: 2
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: console.log("Select accent:", modelData)
                                    }
                                }
                            }
                        }
                        
                        // System Sounds
                        Text {
                            text: "System Sounds"
                            font.pixelSize: 14
                            color: textMuted
                            Layout.topMargin: 16
                        }
                        
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 60
                            radius: 12
                            color: surfaceDark
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 16
                                spacing: 12
                                
                                Text {
                                    text: "🔊"
                                    font.pixelSize: 20
                                }
                                
                                ColumnLayout {
                                    spacing: 2
                                    Layout.fillWidth: true
                                    
                                    Text {
                                        text: "Enable System Sounds"
                                        font.pixelSize: 14
                                        font.weight: Font.Medium
                                        color: textColor
                                    }
                                    Text {
                                        text: "Login, notification, and alert sounds"
                                        font.pixelSize: 11
                                        color: textMuted
                                    }
                                }
                                
                                Switch {
                                    id: systemSoundsSwitch
                                    checked: true
                                    onToggled: {
                                        // Note: QML cannot directly execute scripts with arguments
                                        // This will be handled by the run.sh wrapper or manual execution
                                        console.log("System Sounds toggled:", checked)
                                    }
                                }
                            }
                        }
                        
                        Button {
                            text: "Open Full Appearance Settings"
                            Layout.topMargin: 24
                            onClicked: console.log("Open Plasma appearance settings")
                            background: Rectangle {
                                radius: 8
                                color: accentColor
                            }
                            contentItem: Text {
                                text: parent.text
                                color: "white"
                                font.pixelSize: 13
                            }
                        }
                        
                        Item { Layout.fillHeight: true }
                    }
                    
                    // Page 3: Power & Performance
                    ColumnLayout {
                        spacing: 20
                        
                        Text {
                            text: "Power & Performance"
                            font.pixelSize: 24
                            font.weight: Font.Bold
                            color: textColor
                        }
                        
                        Text {
                            text: "Power Profile"
                            font.pixelSize: 14
                            color: textMuted
                        }
                        
                        RowLayout {
                            spacing: 12
                            
                            // Power Saver
                            Rectangle {
                                width: 130
                                height: 90
                                radius: 12
                                color: surfaceDark
                                border.color: "transparent"
                                border.width: 2
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text {
                                        text: "🔋"
                                        font.pixelSize: 24
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        text: "Power Saver"
                                        font.pixelSize: 12
                                        color: textColor
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }
                            
                            // Balanced
                            Rectangle {
                                width: 130
                                height: 90
                                radius: 12
                                color: surfaceDark
                                border.color: accentColor
                                border.width: 2
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text {
                                        text: "⚖️"
                                        font.pixelSize: 24
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        text: "Balanced"
                                        font.pixelSize: 12
                                        color: textColor
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }
                            
                            // Performance
                            Rectangle {
                                width: 130
                                height: 90
                                radius: 12
                                color: surfaceDark
                                border.color: "transparent"
                                border.width: 2
                                
                                Column {
                                    anchors.centerIn: parent
                                    spacing: 6
                                    Text {
                                        text: "🚀"
                                        font.pixelSize: 24
                                        anchors.horizontalCenter: parent.horizontalCenter
                                    }
                                    Text {
                                        text: "Performance"
                                        font.pixelSize: 12
                                        color: textColor
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                }
                            }
                        }
                        
                        // ZRAM status
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 60
                            Layout.topMargin: 16
                            radius: 12
                            color: surfaceDark
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 16
                                
                                Text {
                                    text: "💾 ZRAM Swap"
                                    font.pixelSize: 14
                                    color: textColor
                                }
                                
                                Item { Layout.fillWidth: true }
                                
                                Text {
                                    text: "Active"
                                    font.pixelSize: 12
                                    color: accentSecondary
                                }
                            }
                        }
                        
                        Item { Layout.fillHeight: true }
                    }
                    
                    // Page 4: Maintenance
                    ColumnLayout {
                        spacing: 20
                        
                        Text {
                            text: "Maintenance"
                            font.pixelSize: 24
                            font.weight: Font.Bold
                            color: textColor
                        }
                        
                        // Action buttons
                        GridLayout {
                            columns: 2
                            rowSpacing: 12
                            columnSpacing: 12
                            Layout.fillWidth: true
                            
                            // Health Check
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 70
                                radius: 12
                                color: surfaceDark
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 12
                                    
                                    Text {
                                        text: "🩺"
                                        font.pixelSize: 20
                                    }
                                    
                                    Column {
                                        Text {
                                            text: "Health Check"
                                            font.pixelSize: 14
                                            font.weight: Font.Medium
                                            color: textColor
                                        }
                                        Text {
                                            text: "Run system diagnostics"
                                            font.pixelSize: 11
                                            color: textMuted
                                        }
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: console.log("Run aether-health.sh")
                                }
                            }
                            
                            // Timeshift
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 70
                                radius: 12
                                color: surfaceDark
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 12
                                    
                                    Text {
                                        text: "📸"
                                        font.pixelSize: 20
                                    }
                                    
                                    Column {
                                        Text {
                                            text: "System Snapshots"
                                            font.pixelSize: 14
                                            font.weight: Font.Medium
                                            color: textColor
                                        }
                                        Text {
                                            text: "Open Timeshift"
                                            font.pixelSize: 11
                                            color: textMuted
                                        }
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: console.log("Open Timeshift")
                                }
                            }
                            
                            // Clean cache
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 70
                                radius: 12
                                color: surfaceDark
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 12
                                    
                                    Text {
                                        text: "🧹"
                                        font.pixelSize: 20
                                    }
                                    
                                    Column {
                                        Text {
                                            text: "Clean Cache"
                                            font.pixelSize: 14
                                            font.weight: Font.Medium
                                            color: textColor
                                        }
                                        Text {
                                            text: "Clear package cache"
                                            font.pixelSize: 11
                                            color: textMuted
                                        }
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: console.log("Run apt clean")
                                }
                            }
                            
                            // Logs
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 70
                                radius: 12
                                color: surfaceDark
                                
                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 12
                                    
                                    Text {
                                        text: "📋"
                                        font.pixelSize: 20
                                    }
                                    
                                    Column {
                                        Text {
                                            text: "View Logs"
                                            font.pixelSize: 14
                                            font.weight: Font.Medium
                                            color: textColor
                                        }
                                        Text {
                                            text: "Open logs folder"
                                            font.pixelSize: 11
                                            color: textMuted
                                        }
                                    }
                                }
                                
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: console.log("Open ~/.local/share/aetheros/logs")
                                }
                            }
                        }
                        
                        Item { Layout.fillHeight: true }
                    }
                    
                    // Page 5: About AetherOS
                    ColumnLayout {
                        spacing: 20
                        
                        // Header
                        ColumnLayout {
                            spacing: 8
                            Layout.alignment: Qt.AlignHCenter
                            
                            Text {
                                text: "About AetherOS"
                                font.pixelSize: 24
                                font.weight: Font.Bold
                                color: textColor
                                Layout.alignment: Qt.AlignHCenter
                            }
                            
                            Text {
                                text: "A beautiful, privacy-focused Linux desktop"
                                font.pixelSize: 13
                                color: textMuted
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }
                        
                        // Version information
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 140
                            Layout.topMargin: 8
                            radius: 12
                            color: surfaceDark
                            
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 12
                                
                                RowLayout {
                                    spacing: 12
                                    Text {
                                        text: "Version"
                                        font.pixelSize: 13
                                        color: textMuted
                                        Layout.preferredWidth: 100
                                    }
                                    Text {
                                        text: "v1.1 (Quality of Life Update)"
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        color: textColor
                                    }
                                }
                                
                                RowLayout {
                                    spacing: 12
                                    Text {
                                        text: "Base"
                                        font.pixelSize: 13
                                        color: textMuted
                                        Layout.preferredWidth: 100
                                    }
                                    Text {
                                        text: "Ubuntu 24.04 LTS (Noble Numbat)"
                                        font.pixelSize: 13
                                        color: textColor
                                    }
                                }
                                
                                RowLayout {
                                    spacing: 12
                                    Text {
                                        text: "Desktop"
                                        font.pixelSize: 13
                                        color: textMuted
                                        Layout.preferredWidth: 100
                                    }
                                    Text {
                                        text: "KDE Plasma 5.27+"
                                        font.pixelSize: 13
                                        color: textColor
                                    }
                                }
                                
                                RowLayout {
                                    spacing: 12
                                    Text {
                                        text: "Kernel"
                                        font.pixelSize: 13
                                        color: textMuted
                                        Layout.preferredWidth: 100
                                    }
                                    Text {
                                        text: "Linux 6.8+ (Ubuntu kernel)"
                                        font.pixelSize: 13
                                        color: textColor
                                    }
                                }
                            }
                        }
                        
                        // Features
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 120
                            radius: 12
                            color: surfaceDark
                            
                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: 20
                                spacing: 8
                                
                                Text {
                                    text: "Key Features"
                                    font.pixelSize: 14
                                    font.weight: Font.Medium
                                    color: textColor
                                }
                                
                                Text {
                                    text: "• Privacy-focused with telemetry disabled by default\n• Optimized performance with ZRAM and system tuning\n• Beautiful custom KDE Plasma theme\n• First-run wizard for easy setup"
                                    font.pixelSize: 12
                                    color: textMuted
                                    lineHeight: 1.5
                                    wrapMode: Text.WordWrap
                                    Layout.fillWidth: true
                                }
                            }
                        }
                        
                        // GitHub button
                        Button {
                            id: githubButton
                            text: "View Project on GitHub"
                            Layout.alignment: Qt.AlignHCenter
                            Layout.topMargin: 8
                            onClicked: {
                                Qt.openUrlExternally(root.githubUrl)
                            }
                            background: Rectangle {
                                radius: 8
                                color: accentColor
                            }
                            contentItem: RowLayout {
                                spacing: 8
                                Text {
                                    text: "🔗"
                                    font.pixelSize: 14
                                }
                                Text {
                                    text: githubButton.text
                                    color: "white"
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                }
                            }
                        }
                        
                        // License
                        Text {
                            text: "Licensed under Apache License 2.0"
                            font.pixelSize: 11
                            color: textMuted
                            Layout.alignment: Qt.AlignHCenter
                            Layout.topMargin: 8
                        }
                        
                        Item { Layout.fillHeight: true }
                    }
                }
            }
        }
    }
}
