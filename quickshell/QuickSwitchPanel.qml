import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick.Effects

// pragma ComponentBehavior: Bound

Scope {
    id: root

    // --- CATPPUCCIN MOCHA THEME ---
    property color cBase: "#1e1e2e"
    property color cMantle: "#181825"
    property color cCrust: "#11111b"
    property color cSurface0: "#313244"
    property color cSurface1: "#45475a"
    property color cSurface2: "#585b70"
    property color cOverlay0: "#6c7086"
    property color cText: "#cdd6f4"
    property color cSubtext0: "#a6adc8"
    property color cSubtext1: "#bac2de"
    property color cLavender: "#b4befe"
    property color cMauve: "#cba6f7"
    property color cPink: "#f5c2e7"
    property color cRosewater: "#f5e0dc"

    // Default colors for flavours (can be extended)
    property var flavourColors: {
        "ii": "#51debd",        // II green
        "caelestia": "#a6e3a1", // Green
        "noctalia": "#a9aefe",  // Noctalia purple
        "aurora": "#fab387",    // Peach
        "midnight": "#cba6f7",  // Mauve
        "ocean": "#94e2d5"      // Teal
    }
    property color defaultFlavourColor: "#b4befe"
    
    // Icons path for flavours (empty string means no icon, use color fallback)
    property string iconsBasePath: "/etc/xdg/quickshell/qswitch/icons/"
    property var flavourIcons: {
        "ii": "ii.svg",
        "noctalia": "noctalia.svg",
        "caelestia": "pacman.svg"
    }
    
    // Current running flavour
    property string currentFlavour: ""

    // 1. Process Handler (Logic Unchanged)
    Process {
        id: switcher
        command: [] 
        onRunningChanged: {
            if (running) console.log("Executing switch command...")
        }
        onExited: {
            // Refresh current flavour after switching
            currentFlavourLoader.running = true
        }
    }

    // Process to get current running flavour
    Process {
        id: currentFlavourLoader
        command: ["qswitch", "--current"]
        stdout: SplitParser {
            onRead: data => {
                root.currentFlavour = data.trim()
            }
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
        currentFlavourLoader.running = true
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

        // Dim Background with blur-like gradient
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.alpha(root.cCrust, 0.7) }
                GradientStop { position: 1.0; color: Qt.alpha(root.cCrust, 0.85) }
            }
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
            width: 500
            height: 480
            anchors.centerIn: parent

            color: root.cBase
            radius: 20
            border.color: Qt.alpha(root.cSurface1, 0.5)
            border.width: 1
            clip: true

            // Subtle inner glow effect
            Rectangle {
                anchors.fill: parent
                anchors.margins: 1
                radius: 19
                color: "transparent"
                border.color: Qt.alpha(root.cLavender, 0.05)
                border.width: 1
            }

            // Enhanced Entry Animation
            ParallelAnimation {
                running: true
                NumberAnimation { target: menuRoot; property: "scale"; from: 0.92; to: 1.0; duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
                NumberAnimation { target: menuRoot; property: "opacity"; from: 0; to: 1.0; duration: 250; easing.type: Easing.OutQuart }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 20

                // Header with gradient accent
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    spacing: 14
                    
                    // Arch Linux Logo
                    Rectangle {
                        Layout.preferredWidth: 42
                        Layout.preferredHeight: 42
                        radius: 12
                        color: Qt.alpha(root.cSurface0, 0.5)
                        
                        Image {
                            anchors.centerIn: parent
                            width: 32
                            height: 32
                            source: "file://" + root.iconsBasePath + "arch.svg"
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                        }
                    }
                    
                    Column {
                        spacing: 4
                        Layout.alignment: Qt.AlignVCenter
                        
                        Text {
                            text: "QuickSwitch"
                            color: root.cText
                            font.pixelSize: 18
                            font.bold: true
                            font.letterSpacing: 0.5
                        }
                        Text {
                            text: "Select a theme to apply"
                            color: root.cSubtext0
                            font.pixelSize: 12
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // Close hint
                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        radius: 8
                        color: root.cSurface0
                        
                        Text {
                            anchors.centerIn: parent
                            text: "⎋"
                            color: root.cSubtext0
                            font.pixelSize: 16
                        }
                        
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: Qt.quit()
                            onEntered: parent.color = root.cSurface1
                            onExited: parent.color = root.cSurface0
                        }
                    }
                }

                // Divider
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: root.cSurface0
                }

                // --- FLAVOUR LIST ---
                ListView {
                    id: flavorList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 200
                    clip: true
                    spacing: 10
                    currentIndex: 0 

                    model: displayModel

                    ScrollBar.vertical: ScrollBar {
                        width: 6
                        policy: ScrollBar.AsNeeded
                        contentItem: Rectangle {
                            implicitWidth: 6
                            radius: 3
                            color: root.cSurface2
                            opacity: 0.6
                        }
                        background: Rectangle {
                            implicitWidth: 6
                            radius: 3
                            color: root.cSurface0
                            opacity: 0.3
                        }
                    }

                    add: Transition {
                        ParallelAnimation {
                            NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 250; easing.type: Easing.OutQuart }
                            NumberAnimation { property: "x"; from: -30; to: 0; duration: 300; easing.type: Easing.OutBack }
                        }
                    }
                    displaced: Transition {
                        NumberAnimation { properties: "y"; duration: 200; easing.type: Easing.OutQuart }
                    }

                    delegate: Rectangle {
                        id: listDelegate
                        width: ListView.view.width
                        height: 72
                        radius: 14
                        
                        property bool isSelected: ListView.isCurrentItem
                        property bool isHovered: mouseArea.containsMouse
                        property color itemColor: model.color
                        property bool isActive: model.flavourId === root.currentFlavour
                        property string flavourIcon: root.flavourIcons[model.flavourId] || ""
                        property bool hasIcon: flavourIcon !== ""

                        color: {
                            if (isActive) return Qt.alpha(itemColor, 0.25)
                            if (isSelected) return Qt.alpha(itemColor, 0.15)
                            if (isHovered) return Qt.alpha(root.cSurface0, 0.6)
                            return "transparent"
                        }
                        
                        Behavior on color { ColorAnimation { duration: 180; easing.type: Easing.OutQuart } }

                        border.color: isActive ? Qt.alpha(itemColor, 0.6) : (isSelected ? Qt.alpha(itemColor, 0.4) : "transparent")
                        border.width: isActive ? 2 : (isSelected ? 2 : 0)
                        
                        Behavior on border.width { NumberAnimation { duration: 150 } }

                        // Glow effect for selected item
                        Rectangle {
                            visible: listDelegate.isSelected || listDelegate.isActive
                            anchors.fill: parent
                            anchors.margins: -2
                            radius: 16
                            color: "transparent"
                            border.color: Qt.alpha(listDelegate.itemColor, listDelegate.isActive ? 0.3 : 0.2)
                            border.width: 4
                            z: -1
                            
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                        }

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 16
                            anchors.rightMargin: 16
                            spacing: 16

                            // Icon or color indicator
                            Rectangle {
                                Layout.preferredWidth: 48
                                Layout.preferredHeight: 48
                                radius: 12
                                color: Qt.alpha(listDelegate.itemColor, 0.15)
                                border.color: Qt.alpha(listDelegate.itemColor, 0.3)
                                border.width: 1

                                // SVG Icon (shown when icon exists)
                                Image {
                                    id: flavourIconImage
                                    anchors.centerIn: parent
                                    width: listDelegate.isSelected ? 40 : 36
                                    height: width
                                    source: listDelegate.hasIcon ? "file://" + root.iconsBasePath + listDelegate.flavourIcon : ""
                                    visible: listDelegate.hasIcon
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                    
                                    Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                                }

                                // Color fallback (shown when no icon)
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: listDelegate.isSelected ? 28 : 24
                                    height: width
                                    radius: 8
                                    visible: !listDelegate.hasIcon
                                    
                                    gradient: Gradient {
                                        orientation: Gradient.Vertical
                                        GradientStop { position: 0.0; color: Qt.lighter(listDelegate.itemColor, 1.2) }
                                        GradientStop { position: 1.0; color: listDelegate.itemColor }
                                    }
                                    
                                    Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                                    
                                    // Pulse animation for selected
                                    SequentialAnimation on scale {
                                        running: listDelegate.isSelected && !listDelegate.hasIcon
                                        loops: Animation.Infinite
                                        NumberAnimation { to: 1.1; duration: 800; easing.type: Easing.InOutQuad }
                                        NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
                                    }
                                }
                                
                                // Pulse animation for icon
                                SequentialAnimation on scale {
                                    running: listDelegate.isSelected && listDelegate.hasIcon
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 1.05; duration: 800; easing.type: Easing.InOutQuad }
                                    NumberAnimation { to: 1.0; duration: 800; easing.type: Easing.InOutQuad }
                                }
                            }

                            // Text Info
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 6
                                
                                RowLayout {
                                    spacing: 8
                                    
                                    Text {
                                        text: model.name
                                        color: listDelegate.isActive ? root.cText : (listDelegate.isSelected ? root.cText : root.cSubtext1)
                                        font.pixelSize: 16
                                        font.bold: true
                                        font.letterSpacing: 0.3
                                        
                                        Behavior on color { ColorAnimation { duration: 150 } }
                                    }
                                    
                                    // Active badge
                                    Rectangle {
                                        visible: listDelegate.isActive
                                        width: activeLabel.width + 12
                                        height: 20
                                        radius: 10
                                        color: Qt.alpha(listDelegate.itemColor, 0.3)
                                        border.color: Qt.alpha(listDelegate.itemColor, 0.5)
                                        border.width: 1
                                        
                                        Text {
                                            id: activeLabel
                                            anchors.centerIn: parent
                                            text: "Active"
                                            color: listDelegate.itemColor
                                            font.pixelSize: 10
                                            font.bold: true
                                            font.letterSpacing: 0.5
                                        }
                                    }
                                }
                                
                                Text {
                                    text: model.desc
                                    color: root.cSubtext0
                                    font.pixelSize: 13
                                    opacity: listDelegate.isSelected || listDelegate.isActive ? 0.9 : 0.7
                                    
                                    Behavior on opacity { NumberAnimation { duration: 150 } }
                                }
                            }

                            // Selection indicator with animation
                            Rectangle {
                                Layout.preferredWidth: 36
                                Layout.preferredHeight: 36
                                radius: 10
                                color: listDelegate.isActive ? Qt.alpha(listDelegate.itemColor, 0.3) : (listDelegate.isSelected ? Qt.alpha(listDelegate.itemColor, 0.2) : "transparent")
                                opacity: listDelegate.isSelected || listDelegate.isHovered || listDelegate.isActive ? 1 : 0
                                
                                Behavior on opacity { NumberAnimation { duration: 150 } }
                                Behavior on color { ColorAnimation { duration: 150 } }
                                
                                Text {
                                    anchors.centerIn: parent
                                    text: listDelegate.isActive ? "✓" : "→"
                                    color: listDelegate.isActive ? listDelegate.itemColor : (listDelegate.isSelected ? listDelegate.itemColor : root.cSubtext0)
                                    font.pixelSize: listDelegate.isActive ? 16 : 18
                                    font.bold: true
                                    
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
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
                    color: root.cMantle
                    radius: 14
                    
                    border.color: searchField.activeFocus ? root.cLavender : root.cSurface0
                    border.width: searchField.activeFocus ? 2 : 1
                    
                    Behavior on border.color { ColorAnimation { duration: 200 } }
                    Behavior on border.width { NumberAnimation { duration: 150 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 12

                        Text {
                            text: "⌕"
                            color: searchField.activeFocus ? root.cLavender : root.cOverlay0
                            font.pixelSize: 20
                            font.bold: true
                            
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }

                        TextField {
                            id: searchField
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            background: null
                            color: root.cText
                            font.pixelSize: 15
                            selectedTextColor: root.cBase
                            selectionColor: root.cLavender
                            placeholderText: 'Search themes...'
                            placeholderTextColor: root.cOverlay0
                            focus: true 
                            topPadding: 0
                            bottomPadding: 0

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
                        
                        // Keyboard shortcut hints
                        Row {
                            spacing: 8
                            visible: !searchField.text
                            
                            Rectangle {
                                width: 26
                                height: 26
                                radius: 6
                                color: root.cSurface0
                                Text {
                                    anchors.centerIn: parent
                                    text: "↑"
                                    color: root.cSubtext0
                                    font.pixelSize: 13
                                }
                            }
                            Rectangle {
                                width: 26
                                height: 26
                                radius: 6
                                color: root.cSurface0
                                Text {
                                    anchors.centerIn: parent
                                    text: "↓"
                                    color: root.cSubtext0
                                    font.pixelSize: 13
                                }
                            }
                            Rectangle {
                                width: 26
                                height: 26
                                radius: 6
                                color: root.cSurface0
                                Text {
                                    anchors.centerIn: parent
                                    text: "↵"
                                    color: root.cSubtext0
                                    font.pixelSize: 13
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}