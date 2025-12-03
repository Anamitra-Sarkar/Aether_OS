import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: root
    width: 400
    height: 500
    visible: true
    title: "Aether Quick Actions"
    
    // Design tokens
    readonly property color backgroundColor: "#F6F8FA"
    readonly property color surfaceColor: "#FFFFFF"
    readonly property color accentColor: "#6C8CFF"
    readonly property color textColor: "#1A202C"
    readonly property color secondaryTextColor: "#718096"
    readonly property int cornerRadius: 10
    readonly property int animDuration: 150
    
    // Dark mode detection
    readonly property bool darkMode: false // TODO: Detect system theme
    
    color: darkMode ? "#0F1720" : backgroundColor
    
    // Remove default window frame for custom styling
    flags: Qt.Window | Qt.WindowCloseButtonHint | Qt.WindowMinimizeButtonHint
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20
        
        // Header
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 5
            
            Label {
                text: "Quick Actions"
                font.pixelSize: 24
                font.bold: true
                color: root.textColor
            }
            
            Label {
                text: "Quickly access common system tools"
                font.pixelSize: 13
                color: root.secondaryTextColor
            }
        }
        
        // Actions Grid
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 2
            rowSpacing: 15
            columnSpacing: 15
            
            ActionButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: "Control Center"
                description: "System settings"
                icon: "⚙️"
                onClicked: {
                    Qt.openUrlExternally("file:///usr/share/applications/aether-control-center.desktop")
                }
            }
            
            ActionButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: "Health Check"
                description: "System diagnostics"
                icon: "❤️"
                onClicked: {
                    Qt.openUrlExternally("file:///usr/bin/konsole?args=-e,/usr/share/aetheros/scripts/aether-health.sh")
                }
            }
            
            ActionButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: "Diagnostics"
                description: "Full system check"
                icon: "🔍"
                onClicked: {
                    Qt.openUrlExternally("file:///usr/bin/konsole?args=-e,/usr/share/aetheros/scripts/aether-diagnostics.sh")
                }
            }
            
            ActionButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: "Timeshift"
                description: "System backups"
                icon: "💾"
                onClicked: {
                    Qt.openUrlExternally("file:///usr/bin/timeshift-launcher")
                }
            }
            
            ActionButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: "Logs Folder"
                description: "View system logs"
                icon: "📋"
                onClicked: {
                    Qt.openUrlExternally("file://" + Qt.resolvedUrl("~/.local/share/aetheros/logs/").toString().replace("file://", ""))
                }
            }
            
            ActionButton {
                Layout.fillWidth: true
                Layout.fillHeight: true
                title: "Updates"
                description: "Check for updates"
                icon: "🔄"
                onClicked: {
                    Qt.openUrlExternally("file:///usr/share/applications/aether-updater.desktop")
                }
            }
        }
        
        // Footer
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            
            Item { Layout.fillWidth: true }
            
            Button {
                text: "Close"
                onClicked: root.close()
                
                background: Rectangle {
                    color: parent.hovered ? Qt.lighter(root.surfaceColor, 0.95) : root.surfaceColor
                    border.color: "#E2E8F0"
                    border.width: 1
                    radius: root.cornerRadius
                    
                    Behavior on color {
                        ColorAnimation { duration: root.animDuration }
                    }
                }
                
                contentItem: Text {
                    text: parent.text
                    color: root.textColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}

// Action Button Component
component ActionButton: Rectangle {
    id: button
    
    property string title: ""
    property string description: ""
    property string icon: ""
    signal clicked()
    
    color: button.hovered ? Qt.lighter(root.accentColor, 1.9) : root.surfaceColor
    border.color: button.hovered ? root.accentColor : "#E2E8F0"
    border.width: 2
    radius: root.cornerRadius
    
    property bool hovered: false
    
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onEntered: button.hovered = true
        onExited: button.hovered = false
        onClicked: button.clicked()
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 15
        spacing: 8
        
        Label {
            text: button.icon
            font.pixelSize: 32
            Layout.alignment: Qt.AlignHCenter
        }
        
        Label {
            text: button.title
            font.pixelSize: 15
            font.bold: true
            color: root.textColor
            Layout.alignment: Qt.AlignHCenter
        }
        
        Label {
            text: button.description
            font.pixelSize: 12
            color: root.secondaryTextColor
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
        
        Item { Layout.fillHeight: true }
    }
    
    Behavior on color {
        ColorAnimation { duration: root.animDuration }
    }
    
    Behavior on border.color {
        ColorAnimation { duration: root.animDuration }
    }
}
