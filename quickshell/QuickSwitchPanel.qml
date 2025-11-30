import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// pragma ComponentBehavior: Bound

Scope {
    id: root

    // 1. Process Handler
    Process {
        id: switcher
        command: [] 
        onRunningChanged: {
            if (running) console.log("Executing switch command...")
        }
    }

    function setFlavour(flavour) {
        switcher.command = ["qswitch", flavour]
        switcher.running = true
        // Qt.quit() 
    }

    // --- FILTER LOGIC ---
    function updateFilter() {
        var searchTerm = searchField.text.toLowerCase()
        displayModel.clear()

        for (var i = 0; i < masterModel.count; i++) {
            var item = masterModel.get(i)
            // Simple includes check for name or desc
            if (searchTerm === "" || item.name.toLowerCase().includes(searchTerm) || item.desc.toLowerCase().includes(searchTerm)) {
                displayModel.append(item)
            }
        }
        
        // Always select the top item when filtering changes
        if (displayModel.count > 0) {
            flavorList.currentIndex = 0
        }
    }

    // 2. Data Models
    ListModel {
        id: masterModel
        ListElement { name: "II"; flavourId: "ii"; color: "#a5b4fc"; desc: "Soft Indigo Theme" }
        ListElement { name: "Caelestia"; flavourId: "caelestia"; color: "#6ee7b7"; desc: "Ethereal Emerald Theme" }
        ListElement { name: "Noctalia"; flavourId: "noctalia"; color: "#f9a8d4"; desc: "Deep Pink Night Theme" }
    }

    ListModel {
        id: displayModel
    }

    Component.onCompleted: updateFilter()

    // 3. Window Setup
    PanelWindow {
        anchors {
            top: true; bottom: true
            left: true; right: true
        }
        color: "transparent"

        WlrLayershell.keyboardFocus: WlrLayershell.Exclusive

        MouseArea {
            anchors.fill: parent
            // onClicked: Qt.quit()
            z: -1 
        }

        // 4. The Launcher Visuals
        Rectangle {
            id: menuRoot
            width: 400
            height: 450
            x: parent ? Math.round((parent.width - width) / 2) : 0
            y: parent ? Math.round((parent.height - height) / 2) : 0

            color: "#1e1e1e"
            radius: 16
            border.color: "#333333"
            border.width: 1
            clip: true

            ParallelAnimation {
                running: true
                NumberAnimation { target: menuRoot; property: "scale"; from: 0.95; to: 1.0; duration: 200; easing.type: Easing.OutBack }
                NumberAnimation { target: menuRoot; property: "opacity"; from: 0; to: 1.0; duration: 150 }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 12

                // Header
                Rectangle {
                    id: headerBar
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    color: "transparent"

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        text: "QuickSwitch"
                        color: "#e6e1e1"
                        font.pixelSize: 14
                    }

                    MouseArea {
                        anchors.fill: parent
                        drag.target: menuRoot
                        drag.axis: Drag.XAndYAxis
                        hoverEnabled: true
                        cursorShape: Qt.OpenHandCursor
                    }
                }

                // --- FLAVOUR LIST ---
                ListView {
                    id: flavorList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 4
                    currentIndex: 0 

                    model: displayModel

                    // FIX: Rectangle is now the root delegate item
                    // This ensures ListView.isCurrentItem attaches correctly
                    delegate: Rectangle {
                        width: ListView.view.width
                        height: 60
                        radius: 10
                        
                        // HIGHLIGHT LOGIC
                        color: ListView.isCurrentItem ? "#2a2a35" : (mouseArea.containsMouse ? "#333333" : "transparent")
                        border.color: ListView.isCurrentItem ? "#6366f1" : "transparent"
                        border.width: ListView.isCurrentItem ? 1 : 0

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 15

                            // Icon
                            Rectangle {
                                Layout.preferredWidth: 36
                                Layout.preferredHeight: 36
                                radius: 18
                                color: "transparent"
                                border.color: model.color // Access model role
                                border.width: 2

                                Rectangle {
                                    anchors.centerIn: parent
                                    implicitWidth: 16; implicitHeight: 16; radius: 8
                                    color: model.color // Access model role
                                    opacity: 0.8
                                }
                            }

                            // Text
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    text: model.name
                                    color: "#ffffff"
                                    font.pixelSize: 15
                                    font.bold: true
                                }
                                Text {
                                    text: model.desc
                                    color: "#888888"
                                    font.pixelSize: 12
                                }
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                flavorList.currentIndex = index
                                root.setFlavour(model.flavourId)
                            }
                        }
                    }
                }

                // --- SEARCH BAR (Bottom) ---
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    color: "#252525"
                    radius: 25
                    border.color: searchField.activeFocus ? "#555555" : "transparent"
                    border.width: 1

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 15
                        anchors.rightMargin: 15
                        spacing: 10

                        Text {
                            text: "🔍"
                            color: "#666666"
                            font.pixelSize: 16
                        }

                        TextField {
                            id: searchField
                            Layout.fillWidth: true
                            background: null
                            color: "white"
                            font.pixelSize: 14
                            placeholderText: 'Type to filter...'
                            placeholderTextColor: "#555555"
                            focus: true 

                            onTextChanged: root.updateFilter()

                            Component.onCompleted: {
                                Qt.callLater(function() { forceActiveFocus() })
                            }

                            Keys.onDownPressed: {
                                flavorList.currentIndex = Math.min(flavorList.currentIndex + 1, flavorList.count - 1)
                            }
                            Keys.onUpPressed: {
                                flavorList.currentIndex = Math.max(flavorList.currentIndex - 1, 0)
                            }
                            Keys.onEnterPressed: triggerSelection()
                            Keys.onReturnPressed: triggerSelection()
                            Keys.onEscapePressed: Qt.quit()

                            function triggerSelection() {
                                if (displayModel.count > 0) {
                                    var item = displayModel.get(flavorList.currentIndex)
                                    if (item) root.setFlavour(item.flavourId)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}