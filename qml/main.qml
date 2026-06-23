import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Window {
    id: mainWindow
    width: 1440
    height: 900
    visible: true
    title: qsTr("LEN ANTI-DRONE SYSTEM - TMMR CONTROLLER")
    color: "#1a1f2e" // Dark slate background matching your UI

    // --- DATA MODEL FOR MULTIPLE TRACKS ---
    // This model stores a list of all active targets.
    ListModel {
        id: activeTracksModel
    }

    // --- NETWORK BRIDGE ---
    Connections {
        target: udpNetworkBackend
        function onTrackUpdated(trackData) {
            var trackId = trackData.track_number;
            var geo = trackData.geospatial;
            var pos = trackData.position;
            var targetClass = trackData.classification;

            // Simple scaling: mapping meters to pixels (adjust this ratio as needed)
            var scaleFactor = 0.02; 
            
            var trackExists = false;

            // Search the model to see if this track already exists
            for (var i = 0; i < activeTracksModel.count; i++) {
                if (activeTracksModel.get(i).trackId === trackId) {
                    // Update existing track
                    activeTracksModel.setProperty(i, "xOffset", geo.x_meters * scaleFactor);
                    activeTracksModel.setProperty(i, "yOffset", -geo.y_meters * scaleFactor);
                    activeTracksModel.setProperty(i, "range", pos.range_meters);
                    trackExists = true;
                    break;
                }
            }

            // If it's a new track, append it to the model to spawn a new marker
            if (!trackExists) {
                console.log("New Track Detected: " + trackId);
                activeTracksModel.append({
                    "trackId": trackId,
                    "targetClass": targetClass,
                    "xOffset": geo.x_meters * scaleFactor,
                    "yOffset": -geo.y_meters * scaleFactor,
                    "range": pos.range_meters
                });
            }
        }
    }

    // --- MAIN DASHBOARD LAYOUT ---
    ColumnLayout {
        anchors.fill: parent
        spacing: 10
        anchors.margins: 10

        // TOP SECTION (Panels + Radar)
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumHeight: 400 // Force bspwm to respect the top section

            // 1. LEFT PANEL (System Status)
            Rectangle {
                Layout.preferredWidth: 250
                Layout.minimumWidth: 200 // Prevent side panel collapse
                Layout.fillHeight: true
                color: "#232a3f"
                radius: 4
                border.color: "#3a4563"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    Text { text: "SYSTEM STATUS"; color: "#a0aabf"; font.pixelSize: 12; font.bold: true }
                    Rectangle { Layout.fillWidth: true; height: 40; color: "#1a1f2e"; Text { anchors.centerIn: parent; text: "TMMR : ONLINE"; color: "#00ffcc" } }
                    Rectangle { Layout.fillWidth: true; height: 40; color: "#1a1f2e"; Text { anchors.centerIn: parent; text: "Radio DF: OFFLINE"; color: "#00aaff" } }
                    Rectangle { Layout.fillWidth: true; height: 40; color: "#1a1f2e"; Text { anchors.centerIn: parent; text: "OPTRONIC: OFFLINE"; color: "#00aaff" } }
                    Item { Layout.fillHeight: true } 
                }
            }

            // 2. CENTER PANEL (Radar View)
            Rectangle {
                id: radarCanvas
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.minimumWidth: 400 // Guard the main radar canvas
                color: "#121621"
                radius: 4
                border.color: "#3a4563"
                clip: true

                // Radar Rings
                Repeater {
                    model: 4
                    Rectangle {
                        width: (index + 1) * 150
                        height: width
                        radius: width / 2
                        color: "transparent"
                        border.color: "#2a354f"
                        border.width: 1
                        anchors.centerIn: parent
                    }
                }

                // Center Site Marker
                Rectangle {
                    width: 10; height: 10; radius: 5; color: "#00ffcc"
                    anchors.centerIn: parent
                }

                // DYNAMIC MULTI-TRACK DISPLAY
                Repeater {
                    model: activeTracksModel
                    Item {
                        x: (radarCanvas.width / 2) + xOffset - (width / 2)
                        y: (radarCanvas.height / 2) + yOffset - (height / 2)
                        width: 80; height: 40
                        Behavior on x { PropertyAnimation { duration: 500 } }
                        Behavior on y { PropertyAnimation { duration: 500 } }

                        Rectangle {
                            id: targetIcon
                            width: 12; height: 12; color: "transparent"; border.color: "#ff3333"; border.width: 2
                            anchors.top: parent.top
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        Column {
                            anchors.top: targetIcon.bottom
                            anchors.topMargin: 2
                            anchors.horizontalCenter: parent.horizontalCenter
                            Text { text: "ID: " + trackId; color: "#ff3333"; font.pixelSize: 10; font.bold: true }
                            Text { text: Math.round(range) + "m"; color: "#ffffff"; font.pixelSize: 9 }
                        }
                    }
                }
            }

            // 3. RIGHT PANEL (Selected Target)
            Rectangle {
                Layout.preferredWidth: 250
                Layout.minimumWidth: 200 // Prevent side panel collapse
                Layout.fillHeight: true
                color: "#232a3f"
                radius: 4
                border.color: "#3a4563"
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    Text { text: "SELECTED TARGET"; color: "#a0aabf"; font.pixelSize: 12; font.bold: true }
                    Item { Layout.fillHeight: true }
                }
            }
        }

        // BOTTOM SECTION (Track List / Event Log)
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
            Layout.minimumHeight: 200 // Lock the bottom section height
            Layout.maximumHeight: 250 // Prevent it from aggressively expanding upward
            spacing: 10

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#232a3f"
                radius: 4
                border.color: "#3a4563"
                Text { anchors.margins: 10; anchors.top: parent.top; anchors.left: parent.left; text: "TRACK LIST"; color: "#a0aabf"; font.bold: true; font.pixelSize: 12 }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#232a3f"
                radius: 4
                border.color: "#3a4563"
                Text { anchors.margins: 10; anchors.top: parent.top; anchors.left: parent.left; text: "EVENT LOG"; color: "#a0aabf"; font.bold: true; font.pixelSize: 12 }
            }
        }
    }
}