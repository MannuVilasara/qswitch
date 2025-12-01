import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// pragma ComponentBehavior: Bound

Scope {
    id: root

    // --- THEME CONFIGURATION ---
    property color cBackground: "#1e1e2e" // Darker, bluer background
    property color cSurface: "#313244"    // Slightly lighter surface
    property color cAccent: "#cba6f7"     // Mauve/Purple accent
    property color cText: "#cdd6f4"
    property color cSubText: "#a6adc8"
    property color cBorder: "#45475a"

    // Default colors for flavours
    property var flavourColors: {
        "ii": "#a5b4fc",
        "caelestia": "#6ee7b7",
        "noctalia": "#f9a8d4"
    }
    property color defaultFlavourColor: "#cba6f7"

    // 1. Process Handler (Logic Unchanged)
    Process {
        id: switcher
        command: [] 
        onRunningChanged: {
            if (running) console.log("Executing switch command...")
        }
    }

    // Process to get flavours from config
    Process {
        id: flavourLoader
        command: ["qswitch", "--list"]
        stdout: SplitParser {
            onRead: data => {
                var flavourId = data.trim()
                if (flavourId !== "") {
                    var color = root.flavourColors[flavourId] || root.defaultFlavourColor
                    var name = flavourId.charAt(0).toUpperCase() + flavourId.slice(1)
                    masterModel.append({
                        "name": name,
                        "flavourId": flavourId,
                        "color": color,
                        "desc": name + " Theme"
                    })
                }
            }
        }
        onExited: {
            root.updateFilter()
        }
    }

    function setFlavour(flavour) {
        switcher.command = ["qswitch", flavour]
        switcher.running = true
        // Qt.quit() 
    }

    // --- FILTER LOGIC (Logic Unchanged) ---
    function updateFilter() {
        var searchTerm = searchField.text.toLowerCase()
        displayModel.clear()

        for (var i = 0; i < masterModel.count; i++) {
            var item = masterModel.get(i)
            if (searchTerm === "" || item.name.toLowerCase().includes(searchTerm) || item.desc.toLowerCase().includes(searchTerm)) {
                displayModel.append(item)
            }
        }
        
        if (displayModel.count > 0) {
            flavorList.currentIndex = 0
        }
    }

    // 2. Data Models
    ListModel {
        id: masterModel
        // Will be populated dynamically from config
    }

    ListModel {
        id: displayModel
    }

    Component.onCompleted: {
        flavourLoader.running = true
    }

    // 3. Window Setup
    PanelWindow {
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: "transparent"

        WlrLayershell.keyboardFocus: WlrLayershell.Exclusive
        WlrLayershell.layer: WlrLayershell.Overlay

        // Dim Background
        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: 0.3
            z: -2
        }

        MouseArea {
            anchors.fill: parent
            // onClicked: Qt.quit()
            z: -1 
        }

        // 4. The Launcher Visuals
        Rectangle {
            id: menuRoot
            width: 420 // Slightly wider
            height: 460
            anchors.centerIn: parent

            color: root.cBackground
            radius: 16
            border.color: root.cBorder
            border.width: 1
            clip: true

            // Enhanced Entry Animation
            ParallelAnimation {
                running: true
                NumberAnimation { target: menuRoot; property: "scale"; from: 0.9; to: 1.0; duration: 250; easing.type: Easing.OutExpo }
                NumberAnimation { target: menuRoot; property: "opacity"; from: 0; to: 1.0; duration: 200 }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 16

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    
                    Text {
                        text: "QuickSwitch"
                        color: root.cSubText
                        font.pixelSize: 13
                        font.bold: true
                        font.letterSpacing: 1.2
                        Layout.alignment: Qt.AlignVCenter
                    }

                    Item { Layout.fillWidth: true } // Spacer

                    // Decorative window controls or status could go here
                }

                // --- FLAVOUR LIST ---
                ListView {
                    id: flavorList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 6
                    currentIndex: 0 

                    model: displayModel

                    // Scrollbar for when you add many themes
                    ScrollBar.vertical: ScrollBar {
                        width: 4
                        policy: ScrollBar.AsNeeded
                        contentItem: Rectangle {
                            implicitWidth: 4
                            radius: 2
                            color: root.cSubText
                            opacity: 0.5
                        }
                    }

                    // Smooth list reordering animations
                    add: Transition {
                        NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 200 }
                        NumberAnimation { property: "x"; from: -20; to: 0; duration: 200; easing.type: Easing.OutQuad }
                    }
                    displaced: Transition {
                        NumberAnimation { properties: "y"; duration: 150; easing.type: Easing.OutQuad }
                    }

                    delegate: Rectangle {
                        id: listDelegate
                        width: ListView.view.width
                        height: 64
                        radius: 12
                        
                        property bool isSelected: ListView.isCurrentItem
                        property bool isHovered: mouseArea.containsMouse

                        // Smooth background color transition
                        color: isSelected ? root.cSurface : (isHovered ? Qt.lighter(root.cSurface, 1.5) : "transparent")
                        
                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }

                        // Subtle border for selected item
                        border.color: isSelected ? Qt.alpha(root.cAccent, 0.3) : "transparent"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 16

                            // Icon / Color Indicator
                            Rectangle {
                                Layout.preferredWidth: 40
                                Layout.preferredHeight: 40
                                radius: 20
                                color: "transparent"
                                border.color: model.color 
                                border.width: 2
                                
                                // Removed malformed layer effect that was hiding the icon
                                // layer.enabled: listDelegate.isSelected ...

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: listDelegate.isSelected ? 20 : 16
                                    height: width
                                    radius: width / 2
                                    color: model.color 
                                    opacity: listDelegate.isSelected ? 1.0 : 0.7

                                    Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                                    Behavior on opacity { NumberAnimation { duration: 200 } }
                                }
                            }

                            // Text Info
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    text: model.name
                                    color: listDelegate.isSelected ? "#ffffff" : root.cText
                                    font.pixelSize: 16
                                    font.bold: true
                                }
                                Text {
                                    text: model.desc
                                    color: root.cSubText
                                    font.pixelSize: 13
                                    opacity: 0.8
                                }
                            }

                            // Selection Indicator Arrow
                            Text {
                                text: "↵"
                                color: root.cSubText
                                font.pixelSize: 18
                                opacity: listDelegate.isSelected ? 0.5 : 0
                                Behavior on opacity { NumberAnimation { duration: 150 } }
                                Layout.rightMargin: 8
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

                // --- SEARCH BAR ---
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52
                    color: Qt.darker(root.cBackground, 1.2)
                    radius: 14
                    
                    // Focus Ring
                    border.color: searchField.activeFocus ? root.cAccent : root.cBorder
                    border.width: searchField.activeFocus ? 2 : 1
                    
                    Behavior on border.color { ColorAnimation { duration: 150 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 12

                        Text {
                            text: "🔍"
                            color: searchField.activeFocus ? root.cAccent : root.cSubText
                            font.pixelSize: 16
                            Behavior on color { ColorAnimation { duration: 150 } }
                        }

                        TextField {
                            id: searchField
                            Layout.fillWidth: true
                            background: null
                            color: root.cText
                            font.pixelSize: 15
                            selectedTextColor: root.cBackground
                            selectionColor: root.cAccent
                            placeholderText: 'Type to search themes...'
                            placeholderTextColor: Qt.alpha(root.cSubText, 0.5)
                            focus: true 
                            topPadding: 0; bottomPadding: 0 // Vertically center text better

                            onTextChanged: root.updateFilter()

                            Component.onCompleted: {
                                Qt.callLater(function() { forceActiveFocus() })
                            }

                            // Keyboard Navigation Logic (Unchanged)
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