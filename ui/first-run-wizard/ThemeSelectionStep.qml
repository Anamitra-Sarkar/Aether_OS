/*
 * Theme Selection Step Component
 */

import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Item {
    property color accentColor: "#6C8CFF"
    property color textColor: "#E5E7EB"
    property color surfaceColor: "#101317"
    property string selectedTheme: "dark"
    
    signal themeSelected(string theme)
    
    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(500, parent.width - 64)
        spacing: 24
        
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Choose Your Theme"
            font.pixelSize: 24
            font.weight: Font.DemiBold
            color: textColor
        }
        
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "Select the appearance that suits you best"
            font.pixelSize: 14
            color: Qt.rgba(1, 1, 1, 0.6)
        }
        
        Item { height: 16 }
        
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 24
            
            // Light Theme Card
            ThemeCard {
                title: "Light"
                isSelected: selectedTheme === "light"
                bgColor: "#F6F8FA"
                fgColor: "#1F2937"
                accentColor: parent.parent.accentColor
                
                onClicked: {
                    selectedTheme = "light"
                    themeSelected("light")
                }
            }
            
            // Dark Theme Card
            ThemeCard {
                title: "Dark"
                isSelected: selectedTheme === "dark"
                bgColor: "#0F1720"
                fgColor: "#E5E7EB"
                accentColor: parent.parent.accentColor
                
                onClicked: {
                    selectedTheme = "dark"
                    themeSelected("dark")
                }
            }
        }
        
        Item { height: 16 }
        
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "You can change this later in Settings"
            font.pixelSize: 12
            color: Qt.rgba(1, 1, 1, 0.4)
        }
    }
}
