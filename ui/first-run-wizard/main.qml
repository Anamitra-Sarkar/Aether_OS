/*
 * AetherOS First Run Wizard
 * Initial setup for new installations
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

ApplicationWindow {
    id: root
    width: 600
    height: 500
    visible: true
    title: "Welcome to AetherOS"
    
    // Design tokens
    readonly property color accentColor: "#6C8CFF"
    readonly property color accentSecondary: "#7AE7C7"
    readonly property color bgDark: "#0F1720"
    readonly property color surfaceDark: "#101317"
    readonly property color textColor: "#E5E7EB"
    readonly property int animDuration: 220
    
    color: bgDark
    
    // Current step
    property int currentStep: 0
    property int totalSteps: 4
    
    // User preferences
    property string userName: ""
    property string userPassword: ""
    property string selectedTheme: "dark"
    property bool telemetryEnabled: false
    property bool restrictedCodecs: false
    
    Rectangle {
        anchors.fill: parent
        color: bgDark
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 32
            spacing: 24
            
            // Progress indicator
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                
                Repeater {
                    model: totalSteps
                    
                    Rectangle {
                        Layout.fillWidth: true
                        height: 4
                        radius: 2
                        color: index <= currentStep ? accentColor : Qt.rgba(1, 1, 1, 0.2)
                        
                        Behavior on color {
                            ColorAnimation { duration: animDuration }
                        }
                    }
                }
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
                    onTelemetryChanged: root.telemetryEnabled = enabled
                    onRestrictedChanged: root.restrictedCodecs = enabled
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
        console.log("Telemetry:", telemetryEnabled)
        console.log("Restricted codecs:", restrictedCodecs)
        
        // Apply settings by calling the configure script
        // In production, this launches: /usr/share/aetheros/scripts/configure-first-run.sh
        // with appropriate flags based on user selections:
        //   --theme [light|dark]
        //   --privacy (if telemetryEnabled is false)
        //   --restricted (if restrictedCodecs is true)
        //   --all (to complete first-run)
        
        // For now, mark first-run as complete and exit
        // The actual script invocation would be:
        // var process = Qt.createQmlObject('import QtQuick 2.0; import "."', root)
        // process.start("/usr/share/aetheros/scripts/configure-first-run.sh", ["--all"])
        
        Qt.quit()
    }
}
