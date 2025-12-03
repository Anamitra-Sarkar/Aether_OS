/*
 * AetherOS First Run Wizard
 * Initial setup for new installations
 * v1.0 RC - Final polish and release preparation
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: root
    width: 650
    height: 550
    visible: true
    title: "Welcome to AetherOS"
    
    // Design tokens
    readonly property color accentColor: "#6C8CFF"
    readonly property color accentSecondary: "#7AE7C7"
    readonly property color bgDark: "#0F1720"
    readonly property color surfaceDark: "#101317"
    readonly property color textColor: "#E5E7EB"
    readonly property color textMuted: "#9CA3AF"
    readonly property int animDuration: 220
    
    color: bgDark
    
    // Current step
    property int currentStep: 0
    property int totalSteps: 4
    
    // Step names for progress
    readonly property var stepNames: ["Welcome", "Setup", "Theme", "Privacy"]
    
    // User preferences
    property string userName: ""
    property string userPassword: ""
    property string selectedTheme: "dark"
    property bool privacyMode: true
    property bool installFlatpaks: true
    property bool updateNotifications: true
    
    Rectangle {
        anchors.fill: parent
        color: bgDark
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 32
            spacing: 20
            
            // Enhanced progress indicator with step names
            RowLayout {
                Layout.fillWidth: true
                spacing: 0
                
                Repeater {
                    model: totalSteps
                    
                    RowLayout {
                        spacing: 0
                        Layout.fillWidth: true
                        
                        // Step circle with number
                        Rectangle {
                            width: 32
                            height: 32
                            radius: 16
                            color: index <= currentStep ? accentColor : Qt.rgba(1, 1, 1, 0.1)
                            border.color: index <= currentStep ? accentColor : Qt.rgba(1, 1, 1, 0.2)
                            border.width: 2
                            
                            Text {
                                anchors.centerIn: parent
                                text: index < currentStep ? "✓" : (index + 1)
                                font.pixelSize: index < currentStep ? 14 : 12
                                font.weight: Font.Medium
                                color: index <= currentStep ? "white" : textMuted
                            }
                            
                            Behavior on color {
                                ColorAnimation { duration: animDuration }
                            }
                        }
                        
                        // Connecting line (except after last step)
                        Rectangle {
                            visible: index < totalSteps - 1
                            Layout.fillWidth: true
                            height: 2
                            color: index < currentStep ? accentColor : Qt.rgba(1, 1, 1, 0.1)
                            
                            Behavior on color {
                                ColorAnimation { duration: animDuration }
                            }
                        }
                    }
                }
            }
            
            // Step name
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "Step " + (currentStep + 1) + " of " + totalSteps + " — " + stepNames[currentStep]
                font.pixelSize: 12
                color: textMuted
            }
            
            // Content area
            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: currentStep
                
                // Step 0: Welcome
                WelcomeStep {
                    accentColor: root.accentColor
                    textColor: root.textColor
                }
                
                // Step 1: User Setup
                UserSetupStep {
                    accentColor: root.accentColor
                    textColor: root.textColor
                    surfaceColor: root.surfaceDark
                    onUserNameChanged: root.userName = userName
                }
                
                // Step 2: Theme Selection
                ThemeSelectionStep {
                    accentColor: root.accentColor
                    textColor: root.textColor
                    surfaceColor: root.surfaceDark
                    onThemeSelected: root.selectedTheme = theme
                }
                
                // Step 3: Privacy & Extras
                PrivacyStep {
                    accentColor: root.accentColor
                    textColor: root.textColor
                    surfaceColor: root.surfaceDark
                    onPrivacyModeChanged: root.privacyMode = enabled
                    onInstallFlatpaksChanged: root.installFlatpaks = enabled
                    onUpdateNotificationsChanged: root.updateNotifications = enabled
                }
            }
            
            // Navigation buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Button {
                    text: "Back"
                    visible: currentStep > 0
                    Layout.preferredWidth: 100
                    Layout.preferredHeight: 44
                    
                    background: Rectangle {
                        radius: 10
                        color: Qt.rgba(1, 1, 1, 0.1)
                        border.color: Qt.rgba(1, 1, 1, 0.2)
                        border.width: 1
                    }
                    
                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 14
                        color: textColor
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    
                    onClicked: {
                        if (currentStep > 0) currentStep--
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                Button {
                    text: currentStep === totalSteps - 1 ? "Finish" : "Continue"
                    Layout.preferredWidth: 120
                    Layout.preferredHeight: 44
                    
                    background: Rectangle {
                        radius: 10
                        color: accentColor
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
                        if (currentStep < totalSteps - 1) {
                            currentStep++
                        } else {
                            // Finish setup
                            finishSetup()
                        }
                    }
                }
            }
        }
    }
    
    function finishSetup() {
        console.log("Setup complete!")
        console.log("User:", userName)
        console.log("Theme:", selectedTheme)
        console.log("Privacy Mode:", privacyMode)
        console.log("Install Flatpaks:", installFlatpaks)
        console.log("Update Notifications:", updateNotifications)
        
        // Apply settings by calling the configure script
        // In production, this launches: /usr/share/aetheros/scripts/configure-first-run.sh
        // with appropriate flags based on user selections:
        //   --theme [light|dark]
        //   --privacy (if privacyMode is enabled)
        //   --flatpaks (if installFlatpaks is enabled)
        //   --updates (if updateNotifications is enabled)
        //   --all (to complete first-run)
        
        // For now, mark first-run as complete and exit
        // The actual script invocation would be:
        // var process = Qt.createQmlObject('import QtQuick 2.0; import "."', root)
        // process.start("/usr/share/aetheros/scripts/configure-first-run.sh", ["--all"])
        
        Qt.quit()
    }
}
