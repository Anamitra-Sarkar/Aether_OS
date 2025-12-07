/* === AetherOS Calamares Slideshow ===
 *
 * This is displayed during installation to showcase AetherOS features
 */

import QtQuick 2.0
import calamares.slideshow 1.0

Presentation {
    id: presentation

    Timer {
        interval: 5000  // 5 seconds per slide
        running: true
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    // Slide 1: Welcome
    Slide {
        Image {
            id: slide1Background
            source: "slide1-welcome.png"
            width: parent.width
            height: parent.height
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
            
            // Fallback if image not found
            onStatusChanged: {
                if (status == Image.Error) {
                    visible = false
                }
            }
        }
        
        Rectangle {
            width: parent.width
            height: parent.height
            color: slide1Background.status == Image.Error ? "#1a1f2e" : "transparent"
            
            Column {
                anchors.centerIn: parent
                spacing: 20
                visible: slide1Background.status == Image.Error
                
                Text {
                    text: "Welcome to AetherOS"
                    color: "#6cc8ff"
                    font.pixelSize: 48
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "A beautiful, ultra-smooth desktop experience"
                    color: "#ffffff"
                    font.pixelSize: 24
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "Built on Ubuntu 24.04 LTS"
                    color: "#a0a0a0"
                    font.pixelSize: 18
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    // Slide 2: Design & Performance
    Slide {
        Image {
            id: slide2Background
            source: "slide2-design.png"
            width: parent.width
            height: parent.height
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
            
            onStatusChanged: {
                if (status == Image.Error) {
                    visible = false
                }
            }
        }
        
        Rectangle {
            width: parent.width
            height: parent.height
            color: slide2Background.status == Image.Error ? "#1a2332" : "transparent"
            
            Column {
                anchors.centerIn: parent
                spacing: 15
                visible: slide2Background.status == Image.Error
                
                Text {
                    text: "🎨 Beautiful Design & Performance"
                    color: "#6cc8ff"
                    font.pixelSize: 36
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "• Adaptive Blur - Adjusts to your GPU"
                    color: "#ffffff"
                    font.pixelSize: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "• CleanMode - One-click performance boost"
                    color: "#ffffff"
                    font.pixelSize: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "• Auto Performance Profiler - Smart optimization"
                    color: "#ffffff"
                    font.pixelSize: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    // Slide 3: Focus Mode & Intelligence
    Slide {
        Image {
            id: slide3Background
            source: "slide3-focus.png"
            width: parent.width
            height: parent.height
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
            
            onStatusChanged: {
                if (status == Image.Error) {
                    visible = false
                }
            }
        }
        
        Rectangle {
            width: parent.width
            height: parent.height
            color: slide3Background.status == Image.Error ? "#1f2937" : "transparent"
            
            Column {
                anchors.centerIn: parent
                spacing: 15
                visible: slide3Background.status == Image.Error
                
                Text {
                    text: "🧠 Intelligent Desktop Behavior"
                    color: "#6cc8ff"
                    font.pixelSize: 36
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "• Focus Mode - Do Not Disturb made smart"
                    color: "#ffffff"
                    font.pixelSize: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "• Smart Notifications - Context-aware muting"
                    color: "#ffffff"
                    font.pixelSize: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "• Thermal Watch - Heat-aware visuals (NEW in v2.1)"
                    color: "#ffffff"
                    font.pixelSize: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    // Slide 4: Security & Backups
    Slide {
        Image {
            id: slide4Background
            source: "slide4-security.png"
            width: parent.width
            height: parent.height
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
            
            onStatusChanged: {
                if (status == Image.Error) {
                    visible = false
                }
            }
        }
        
        Rectangle {
            width: parent.width
            height: parent.height
            color: slide4Background.status == Image.Error ? "#1a2634" : "transparent"
            
            Column {
                anchors.centerIn: parent
                spacing: 15
                visible: slide4Background.status == Image.Error
                
                Text {
                    text: "🔒 Security & Privacy First"
                    color: "#6cc8ff"
                    font.pixelSize: 36
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "• AetherShield - Per-app sandbox control (NEW in v2.1)"
                    color: "#ffffff"
                    font.pixelSize: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "• Secure Session - Lockdown mode for sensitive tasks"
                    color: "#ffffff"
                    font.pixelSize: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "• AetherVault - Automated backups"
                    color: "#ffffff"
                    font.pixelSize: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "• No Telemetry - Your privacy respected"
                    color: "#ffffff"
                    font.pixelSize: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    // Slide 5: Community & Open Source
    Slide {
        Image {
            id: slide5Background
            source: "slide5-community.png"
            width: parent.width
            height: parent.height
            fillMode: Image.PreserveAspectFit
            anchors.centerIn: parent
            
            onStatusChanged: {
                if (status == Image.Error) {
                    visible = false
                }
            }
        }
        
        Rectangle {
            width: parent.width
            height: parent.height
            color: slide5Background.status == Image.Error ? "#1e293b" : "transparent"
            
            Column {
                anchors.centerIn: parent
                spacing: 20
                visible: slide5Background.status == Image.Error
                
                Text {
                    text: "💚 Open Source & Community"
                    color: "#6cc8ff"
                    font.pixelSize: 36
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "AetherOS is 100% open source"
                    color: "#ffffff"
                    font.pixelSize: 22
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "Built with ❤️ by the community"
                    color: "#ffffff"
                    font.pixelSize: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "github.com/Anamitra-Sarkar/Aether_OS"
                    color: "#6cc8ff"
                    font.pixelSize: 18
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Text {
                    text: "Thank you for choosing AetherOS!"
                    color: "#a0a0a0"
                    font.pixelSize: 16
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
