/*
 * AetherOS SDDM Theme - Main QML
 * A modern, clean login screen for AetherOS
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1920
    height: 1080
    
    // Theme colors (Aether palette)
    readonly property color accentColor: "#6C8CFF"
    readonly property color accentSecondary: "#7AE7C7"
    readonly property color bgDark: "#0F1720"
    readonly property color surfaceDark: "#101317"
    readonly property color textPrimary: "#E5E7EB"
    readonly property color textSecondary: "#9CA3AF"
    readonly property color errorColor: "#DA4453"
    
    // Background image
    Image {
        id: background
        anchors.fill: parent
        source: config.background || "/usr/share/backgrounds/aetheros/aetheros-default-dark.png"
        fillMode: Image.PreserveAspectCrop
        
        // Subtle blur for login readability
        layer.enabled: true
        layer.effect: FastBlur {
            radius: 32
            transparentBorder: true
        }
    }
    
    // Dark overlay for better contrast
    Rectangle {
        anchors.fill: parent
        color: "#000000"
        opacity: 0.3
    }
    
    // Clock display (top right)
    ColumnLayout {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 48
        spacing: 4
        
        Text {
            id: timeText
            Layout.alignment: Qt.AlignRight
            font.family: "Inter"
            font.pixelSize: 64
            font.weight: Font.Light
            color: textPrimary
            text: Qt.formatTime(new Date(), "hh:mm")
            
            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: timeText.text = Qt.formatTime(new Date(), "hh:mm")
            }
        }
        
        Text {
            Layout.alignment: Qt.AlignRight
            font.family: "Inter"
            font.pixelSize: 18
            color: textSecondary
            text: Qt.formatDate(new Date(), "dddd, MMMM d, yyyy")
        }
    }
    
    // Main login container
    Rectangle {
        id: loginBox
        anchors.centerIn: parent
        width: 420
        height: loginLayout.implicitHeight + 80
        color: Qt.rgba(16/255, 19/255, 23/255, 0.85)
        radius: 12
        
        // Subtle border
        border.color: Qt.rgba(108/255, 140/255, 255/255, 0.2)
        border.width: 1
        
        // Drop shadow
        layer.enabled: true
        layer.effect: DropShadow {
            transparentBorder: true
            horizontalOffset: 0
            verticalOffset: 8
            radius: 24
            samples: 17
            color: "#40000000"
        }
        
        ColumnLayout {
            id: loginLayout
            anchors.fill: parent
            anchors.margins: 40
            spacing: 24
            
            // Logo
            Image {
                Layout.alignment: Qt.AlignHCenter
                source: "/usr/share/pixmaps/aetheros-logo.svg"
                sourceSize.width: 80
                sourceSize.height: 80
                fillMode: Image.PreserveAspectFit
            }
            
            // Title
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "AetherOS"
                font.family: "Inter"
                font.pixelSize: 24
                font.weight: Font.Medium
                color: textPrimary
            }
            
            // Spacer
            Item { Layout.preferredHeight: 8 }
            
            // Username field
            TextField {
                id: usernameField
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                placeholderText: "Username"
                font.family: "Inter"
                font.pixelSize: 14
                color: textPrimary
                
                background: Rectangle {
                    radius: 10
                    color: Qt.rgba(42/255, 48/255, 56/255, 0.6)
                    border.color: usernameField.activeFocus ? accentColor : Qt.rgba(229/255, 231/255, 235/255, 0.2)
                    border.width: usernameField.activeFocus ? 2 : 1
                    
                    Behavior on border.color {
                        ColorAnimation { duration: 150 }
                    }
                }
                
                onAccepted: passwordField.forceActiveFocus()
            }
            
            // Password field
            TextField {
                id: passwordField
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                placeholderText: "Password"
                echoMode: TextInput.Password
                font.family: "Inter"
                font.pixelSize: 14
                color: textPrimary
                
                background: Rectangle {
                    radius: 10
                    color: Qt.rgba(42/255, 48/255, 56/255, 0.6)
                    border.color: passwordField.activeFocus ? accentColor : Qt.rgba(229/255, 231/255, 235/255, 0.2)
                    border.width: passwordField.activeFocus ? 2 : 1
                    
                    Behavior on border.color {
                        ColorAnimation { duration: 150 }
                    }
                }
                
                onAccepted: loginButton.clicked()
            }
            
            // Error message
            Text {
                id: errorMessage
                Layout.alignment: Qt.AlignHCenter
                visible: text !== ""
                color: errorColor
                font.family: "Inter"
                font.pixelSize: 12
                text: ""
            }
            
            // Login button
            Button {
                id: loginButton
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                text: "Log In"
                
                contentItem: Text {
                    text: loginButton.text
                    font.family: "Inter"
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: "#FFFFFF"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
                
                background: Rectangle {
                    radius: 10
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: loginButton.pressed ? Qt.darker(accentColor, 1.1) : (loginButton.hovered ? Qt.lighter(accentColor, 1.1) : accentColor) }
                        GradientStop { position: 1.0; color: loginButton.pressed ? Qt.darker(accentColor, 1.2) : Qt.darker(accentColor, 1.05) }
                    }
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }
                
                onClicked: {
                    errorMessage.text = ""
                    sddm.login(usernameField.text, passwordField.text, sessionSelector.currentIndex)
                }
            }
            
            // Session selector row
            RowLayout {
                Layout.fillWidth: true
                spacing: 16
                
                Text {
                    text: "Session:"
                    font.family: "Inter"
                    font.pixelSize: 12
                    color: textSecondary
                }
                
                ComboBox {
                    id: sessionSelector
                    Layout.fillWidth: true
                    model: sessionModel
                    textRole: "name"
                    currentIndex: sessionModel.lastIndex
                    
                    delegate: ItemDelegate {
                        width: sessionSelector.width
                        contentItem: Text {
                            text: model.name
                            font.family: "Inter"
                            font.pixelSize: 12
                            color: textPrimary
                        }
                    }
                    
                    background: Rectangle {
                        radius: 6
                        color: Qt.rgba(42/255, 48/255, 56/255, 0.6)
                        border.color: Qt.rgba(229/255, 231/255, 235/255, 0.2)
                        border.width: 1
                    }
                }
            }
        }
    }
    
    // Bottom bar with power buttons
    RowLayout {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 32
        spacing: 24
        
        // Power off button
        Button {
            id: powerOffButton
            implicitWidth: 48
            implicitHeight: 48
            
            contentItem: Text {
                text: "⏻"
                font.pixelSize: 20
                color: powerOffButton.hovered ? textPrimary : textSecondary
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            background: Rectangle {
                radius: 24
                color: powerOffButton.hovered ? Qt.rgba(255, 255, 255, 0.1) : "transparent"
                
                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
            }
            
            onClicked: sddm.powerOff()
            
            ToolTip.visible: hovered
            ToolTip.text: "Power Off"
        }
        
        // Reboot button
        Button {
            id: rebootButton
            implicitWidth: 48
            implicitHeight: 48
            
            contentItem: Text {
                text: "↻"
                font.pixelSize: 20
                color: rebootButton.hovered ? textPrimary : textSecondary
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            background: Rectangle {
                radius: 24
                color: rebootButton.hovered ? Qt.rgba(255, 255, 255, 0.1) : "transparent"
                
                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
            }
            
            onClicked: sddm.reboot()
            
            ToolTip.visible: hovered
            ToolTip.text: "Reboot"
        }
        
        // Suspend button
        Button {
            id: suspendButton
            implicitWidth: 48
            implicitHeight: 48
            visible: sddm.canSuspend
            
            contentItem: Text {
                text: "⏾"
                font.pixelSize: 20
                color: suspendButton.hovered ? textPrimary : textSecondary
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            
            background: Rectangle {
                radius: 24
                color: suspendButton.hovered ? Qt.rgba(255, 255, 255, 0.1) : "transparent"
                
                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
            }
            
            onClicked: sddm.suspend()
            
            ToolTip.visible: hovered
            ToolTip.text: "Suspend"
        }
    }
    
    // Login error handling
    Connections {
        target: sddm
        function onLoginFailed() {
            errorMessage.text = "Invalid username or password"
            passwordField.text = ""
            passwordField.forceActiveFocus()
        }
    }
    
    // Initial focus
    Component.onCompleted: {
        usernameField.forceActiveFocus()
    }
}
