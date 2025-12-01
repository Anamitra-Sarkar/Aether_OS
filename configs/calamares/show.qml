/*
 * AetherOS Calamares Installer Slideshow
 * Displays during installation process
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Presentation {
    id: presentation

    // AetherOS Design Tokens
    readonly property color accentColor: "#6C8CFF"
    readonly property color accentSecondary: "#7AE7C7"
    readonly property color bgDark: "#0F1720"
    readonly property color textPrimary: "#E5E7EB"
    readonly property color textSecondary: "#9CA3AF"

    // Auto-advance slides
    Timer {
        interval: 8000
        running: true
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    // Slide 1: Welcome
    Slide {
        Rectangle {
            anchors.fill: parent
            color: bgDark

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 24

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "✨"
                    font.pixelSize: 64
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Welcome to AetherOS"
                    font.pixelSize: 32
                    font.weight: Font.DemiBold
                    color: textPrimary
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: 500
                    text: "A beautiful, fast, and privacy-focused desktop experience.\nYour system is being installed..."
                    font.pixelSize: 16
                    color: textSecondary
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    // Slide 2: Beautiful Design
    Slide {
        Rectangle {
            anchors.fill: parent
            color: bgDark

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 24

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "🎨"
                    font.pixelSize: 64
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Beautiful Design"
                    font.pixelSize: 28
                    font.weight: Font.DemiBold
                    color: textPrimary
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: 500
                    text: "Enjoy a polished, modern desktop with custom themes, icons, and wallpapers. Switch between light and dark modes anytime."
                    font.pixelSize: 16
                    color: textSecondary
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    // Slide 3: Performance
    Slide {
        Rectangle {
            anchors.fill: parent
            color: bgDark

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 24

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "⚡"
                    font.pixelSize: 64
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Optimized Performance"
                    font.pixelSize: 28
                    font.weight: Font.DemiBold
                    color: textPrimary
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: 500
                    text: "AetherOS is tuned for speed and responsiveness. ZRAM swap, smart caching, and optimized services ensure a smooth experience."
                    font.pixelSize: 16
                    color: textSecondary
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    // Slide 4: Privacy
    Slide {
        Rectangle {
            anchors.fill: parent
            color: bgDark

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 24

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "🔒"
                    font.pixelSize: 64
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Privacy First"
                    font.pixelSize: 28
                    font.weight: Font.DemiBold
                    color: textPrimary
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: 500
                    text: "Your data stays yours. Telemetry is disabled by default, and you have full control over what gets shared."
                    font.pixelSize: 16
                    color: textSecondary
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    // Slide 5: Apps
    Slide {
        Rectangle {
            anchors.fill: parent
            color: bgDark

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 24

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "📦"
                    font.pixelSize: 64
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Your Favorite Apps"
                    font.pixelSize: 28
                    font.weight: Font.DemiBold
                    color: textPrimary
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: 500
                    text: "Firefox, LibreOffice, VLC, and more are pre-installed. Use Discover or Flatpak to add thousands more apps."
                    font.pixelSize: 16
                    color: textSecondary
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    // Slide 6: Almost Done
    Slide {
        Rectangle {
            anchors.fill: parent
            color: bgDark

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 24

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "🚀"
                    font.pixelSize: 64
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "Almost There!"
                    font.pixelSize: 28
                    font.weight: Font.DemiBold
                    color: textPrimary
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: 500
                    text: "Your AetherOS installation is nearly complete. Soon you'll be enjoying your new desktop experience!"
                    font.pixelSize: 16
                    color: textSecondary
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    function goToNextSlide() {
        if (presentation.currentSlide < presentation.count - 1) {
            presentation.currentSlide++
        } else {
            presentation.currentSlide = 0
        }
    }
}
