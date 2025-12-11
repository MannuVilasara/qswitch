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
    property color cRed: "#f38ba8"
    property color cYellow: "#f9e2af"

    // Default colors for flavours
    property var flavourColors: {
        "ii": "#51debd",
        "caelestia": "#a6e3a1",
        "noctalia-shell": "#a9aefe",
        "aurora": "#fab387",
        "mannu": "#cba6f7",
        "ocean": "#94e2d5"
    }
    property color defaultFlavourColor: "#b4befe"

    // Icons path
    property string iconsBasePath: Quickshell.shellPath("icons/")
    property var flavourIcons: {
        "ii": "ii.svg",
        "noctalia-shell": "noctalia.svg",
        "caelestia": "pacman.svg",
        "mannu": "mannu.svg"
    }

    property string currentFlavour: ""
    property var flavourInstallStatus: ({})
    property bool showInfoPopup: false

    // 1. Process Handler
    Process {
        id: switcher
        command: []
        onRunningChanged: {
            if (running) console.log("Executing switch command...");
        }
        onExited: currentFlavourLoader.running = true;
    }

    Process {
        id: currentFlavourLoader
        command: ["qswitch", "current"]
        stdout: SplitParser {
            onRead: data => root.currentFlavour = data.trim();
        }
    }

    Process {
        id: flavourLoader
        command: ["qswitch", "list", "--status"]
        stdout: SplitParser {
            onRead: data => {
                var trimmed = data.trim();
                if (trimmed !== "" && trimmed.startsWith("[")) {
                    try {
                        var flavours = JSON.parse(trimmed);
                        for (var i = 0; i < flavours.length; i++) {
                            var f = flavours[i];
                            var flavourId = f.name;
                            var installed = f.installed;
                            var color = root.flavourColors[flavourId] || root.defaultFlavourColor;
                            var name = flavourId.charAt(0).toUpperCase() + flavourId.slice(1);

                            root.flavourInstallStatus[flavourId] = installed;

                            masterModel.append({
                                "name": name,
                                "flavourId": flavourId,
                                "color": color,
                                "desc": name + " Theme",
                                "installed": installed
                            });
                        }
                    } catch (e) {
                        console.log("Failed to parse flavour status JSON:", e);
                    }
                }
            }
        }
        onExited: root.updateFilter();
    }

    function setFlavour(flavour) {
        switcher.command = ["qswitch", "apply", flavour];
        switcher.running = true;
    }

    function updateFilter() {
        var searchTerm = searchField.text.toLowerCase();
        displayModel.clear();

        for (var i = 0; i < masterModel.count; i++) {
            var item = masterModel.get(i);
            if (searchTerm === "" || item.name.toLowerCase().includes(searchTerm) || item.desc.toLowerCase().includes(searchTerm)) {
                displayModel.append(item);
            }
        }
        if (displayModel.count > 0) flavorList.currentIndex = 0;
    }

    ListModel { id: masterModel }
    ListModel { id: displayModel }

    Component.onCompleted: {
        currentFlavourLoader.running = true;
        flavourLoader.running = true;
    }

    // --- FIXED PANEL WINDOW ---
    PanelWindow {
        // Quickshell anchors use specific boolean properties for screen edges
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }
        color: "transparent"

        WlrLayershell.keyboardFocus: WlrLayershell.Exclusive
        WlrLayershell.layer: WlrLayershell.Overlay

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

            Rectangle {
                anchors.fill: parent; anchors.margins: 1; radius: 19
                color: "transparent"; border.color: Qt.alpha(root.cLavender, 0.05); border.width: 1
            }

            ParallelAnimation {
                running: true
                NumberAnimation { target: menuRoot; property: "scale"; from: 0.92; to: 1.0; duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
                NumberAnimation { target: menuRoot; property: "opacity"; from: 0; to: 1.0; duration: 250; easing.type: Easing.OutQuart }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 20

                // --- HEADER ---
                RowLayout {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 48
                    spacing: 14

                    Rectangle {
                        Layout.preferredWidth: 42; Layout.preferredHeight: 42; radius: 12
                        color: Qt.alpha(root.cSurface0, 0.5)
                        Image {
                            anchors.centerIn: parent; width: 32; height: 32
                            source: "file://" + root.iconsBasePath + "arch.svg"
                            fillMode: Image.PreserveAspectFit; smooth: true
                        }
                    }

                    Column {
                        spacing: 4; Layout.alignment: Qt.AlignVCenter
                        Text { text: "QuickSwitch"; color: root.cText; font.pixelSize: 18; font.bold: true; font.letterSpacing: 0.5 }
                        Text { text: "Select a theme to apply"; color: root.cSubtext0; font.pixelSize: 12 }
                    }

                    Item { Layout.fillWidth: true }

                    // Info Button
                    Rectangle {
                        Layout.preferredWidth: 32; Layout.preferredHeight: 32; radius: 8
                        color: infoBtnArea.containsMouse ? root.cSurface1 : root.cSurface0
                        Text {
                            anchors.centerIn: parent; text: "i"
                            color: root.cLavender; font.pixelSize: 18; font.bold: true; font.family: "Monospace"
                        }
                        MouseArea {
                            id: infoBtnArea
                            anchors.fill: parent; hoverEnabled: true
                            onClicked: root.showInfoPopup = true
                        }
                    }

                    // Close Button
                    Rectangle {
                        Layout.preferredWidth: 32; Layout.preferredHeight: 32; radius: 8
                        color: closeBtnArea.containsMouse ? root.cSurface1 : root.cSurface0
                        Text {
                            anchors.centerIn: parent; text: "×"
                            color: root.cSubtext0; font.pixelSize: 18; font.bold: true
                        }
                        MouseArea {
                            id: closeBtnArea
                            anchors.fill: parent; hoverEnabled: true
                            onClicked: Qt.quit()
                        }
                    }
                }

                Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: root.cSurface0 }

                // --- CONTENT AREA ---
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    // 1. Normal List View
                    ListView {
                        id: flavorList
                        anchors.fill: parent
                        clip: true
                        spacing: 10
                        // Show only if there are items to display
                        visible: displayModel.count > 0
                        model: displayModel
                        currentIndex: 0

                        ScrollBar.vertical: ScrollBar {
                            width: 6
                            policy: ScrollBar.AsNeeded
                            contentItem: Rectangle { implicitWidth: 6; radius: 3; color: root.cSurface2; opacity: 0.6 }
                            background: Rectangle { implicitWidth: 6; radius: 3; color: root.cSurface0; opacity: 0.3 }
                        }

                        add: Transition { ParallelAnimation { NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 250; easing.type: Easing.OutQuart } NumberAnimation { property: "x"; from: -30; to: 0; duration: 300; easing.type: Easing.OutBack } } }
                        displaced: Transition { NumberAnimation { properties: "y"; duration: 200; easing.type: Easing.OutQuart } }

                        delegate: Rectangle {
                            id: listDelegate
                            width: ListView.view.width; height: 72; radius: 14
                            property bool isSelected: ListView.isCurrentItem
                            property bool isHovered: mouseArea.containsMouse
                            property color itemColor: model.color
                            property bool isActive: model.flavourId === root.currentFlavour
                            property string flavourIcon: root.flavourIcons[model.flavourId] || ""
                            property bool hasIcon: flavourIcon !== ""
                            property bool isInstalled: model.installed !== undefined ? model.installed : true

                            color: {
                                if (!isInstalled) return Qt.alpha(root.cRed, 0.1);
                                if (isActive) return Qt.alpha(itemColor, 0.25);
                                if (isSelected) return Qt.alpha(itemColor, 0.15);
                                if (isHovered) return Qt.alpha(root.cSurface0, 0.6);
                                return "transparent";
                            }
                            
                            Behavior on color { ColorAnimation { duration: 180; easing.type: Easing.OutQuart } }
                            border.color: isActive ? Qt.alpha(itemColor, 0.6) : (isSelected ? Qt.alpha(itemColor, 0.4) : "transparent")
                            border.width: isActive ? 2 : (isSelected ? 2 : 0)
                            Behavior on border.width { NumberAnimation { duration: 150 } }

                            RowLayout {
                                anchors.fill: parent; anchors.leftMargin: 16; anchors.rightMargin: 16; spacing: 16
                                Rectangle {
                                    Layout.preferredWidth: 48; Layout.preferredHeight: 48; radius: 12
                                    color: Qt.alpha(listDelegate.itemColor, 0.15); border.color: Qt.alpha(listDelegate.itemColor, 0.3); border.width: 1
                                    Image {
                                        visible: listDelegate.hasIcon
                                        anchors.centerIn: parent; width: listDelegate.isSelected ? 40 : 36; height: width
                                        source: listDelegate.hasIcon ? "file://" + root.iconsBasePath + listDelegate.flavourIcon : ""
                                        fillMode: Image.PreserveAspectFit; smooth: true
                                        Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                                    }
                                    Rectangle {
                                        visible: !listDelegate.hasIcon
                                        anchors.centerIn: parent; width: listDelegate.isSelected ? 28 : 24; height: width; radius: 8
                                        color: listDelegate.itemColor
                                        Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
                                    }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true; Layout.alignment: Qt.AlignVCenter; spacing: 6
                                    RowLayout {
                                        spacing: 8
                                        Text { text: model.name; color: listDelegate.isActive ? root.cText : (listDelegate.isSelected ? root.cText : root.cSubtext1); font.pixelSize: 16; font.bold: true }
                                        Rectangle { visible: listDelegate.isActive && listDelegate.isInstalled; width: 50; height: 20; radius: 10; color: Qt.alpha(listDelegate.itemColor, 0.3); Text { anchors.centerIn: parent; text: "Active"; color: listDelegate.itemColor; font.pixelSize: 10; font.bold: true } }
                                        Rectangle { visible: !listDelegate.isInstalled; width: 85; height: 20; radius: 10; color: Qt.alpha(root.cRed, 0.3); Text { anchors.centerIn: parent; text: "Not Installed"; color: root.cRed; font.pixelSize: 10; font.bold: true } }
                                    }
                                    Text { text: model.desc; color: root.cSubtext0; font.pixelSize: 13; opacity: listDelegate.isSelected ? 0.9 : 0.7 }
                                }
                                Text { Layout.preferredWidth: 36; text: listDelegate.isActive ? "✓" : "→"; color: listDelegate.itemColor; font.pixelSize: 18; font.bold: true; horizontalAlignment: Text.AlignHCenter; opacity: listDelegate.isSelected || listDelegate.isHovered || listDelegate.isActive ? 1 : 0 }
                            }
                            MouseArea {
                                id: mouseArea; anchors.fill: parent; hoverEnabled: true; cursorShape: listDelegate.isInstalled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
                                onClicked: { if (listDelegate.isInstalled) { flavorList.currentIndex = index; root.setFlavour(model.flavourId); } }
                            }
                        }
                    }

                    // 2. No Search Results (Master has items, but Display is empty)
                    ColumnLayout {
                        anchors.centerIn: parent
                        visible: displayModel.count === 0 && masterModel.count > 0
                        spacing: 15

                        Text {
                            text: "🤔" 
                            font.pixelSize: 48
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: "No matching themes found"
                            color: root.cText
                            font.pixelSize: 16
                            font.bold: true
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: "Try searching for something else"
                            color: root.cSubtext0
                            font.pixelSize: 13
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    // 3. No Config / No Flavours Found (Master is empty)
                    ColumnLayout {
                        anchors.centerIn: parent
                        // Only show if masterModel is empty and we aren't currently loading data
                        visible: masterModel.count === 0 && !flavourLoader.running 
                        spacing: 20

                        AnimatedImage {
                            Layout.preferredWidth: 128
                            Layout.preferredHeight: 128
                            Layout.alignment: Qt.AlignHCenter
                            source: "file://" + root.iconsBasePath + "confused.gif"
                            fillMode: Image.PreserveAspectFit
                            playing: visible
                        }

                        Text {
                            text: "Did you forget to add the config?"
                            color: root.cText
                            font.pixelSize: 16
                            font.bold: true
                            Layout.alignment: Qt.AlignHCenter
                        }

                        // Example Config Button
                        Rectangle {
                            Layout.preferredWidth: 160
                            Layout.preferredHeight: 40
                            Layout.alignment: Qt.AlignHCenter
                            radius: 10
                            color: cfgBtn.containsMouse ? root.cSurface1 : root.cSurface0
                            border.color: root.cLavender
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "View Example Config"
                                color: root.cLavender
                                font.bold: true
                                font.pixelSize: 13
                            }

                            MouseArea {
                                id: cfgBtn
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Qt.openUrlExternally("https://github.com/MannuVilasara/qswitch/tree/main/example")
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

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 12

                        Text { text: "⌕"; color: searchField.activeFocus ? root.cLavender : root.cOverlay0; font.pixelSize: 20; font.bold: true }

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
                            
                            onTextChanged: root.updateFilter()
                            Component.onCompleted: Qt.callLater(function () { forceActiveFocus(); });

                            Keys.onDownPressed: flavorList.currentIndex = Math.min(flavorList.currentIndex + 1, flavorList.count - 1);
                            Keys.onUpPressed: flavorList.currentIndex = Math.max(flavorList.currentIndex - 1, 0);
                            Keys.onEnterPressed: triggerSelection()
                            Keys.onReturnPressed: triggerSelection()
                            Keys.onEscapePressed: Qt.quit()

                            function triggerSelection() {
                                if (displayModel.count > 0) {
                                    var item = displayModel.get(flavorList.currentIndex);
                                    if (item) root.setFlavour(item.flavourId);
                                }
                            }
                        }
                    }
                }
            }

            // --- INFO POPUP OVERLAY ---
            Rectangle {
                id: infoPopup
                anchors.fill: parent
                color: Qt.alpha(root.cBase, 0.95)
                radius: 20
                z: 100
                visible: root.showInfoPopup
                opacity: visible ? 1 : 0
                
                Behavior on opacity { NumberAnimation { duration: 200 } }

                MouseArea {
                    anchors.fill: parent
                    // Block clicks from going to the layers below
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 20
                    width: parent.width - 60

                    Text {
                        text: "About QuickSwitch"
                        color: root.cMauve
                        font.pixelSize: 24
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: root.cSurface1
                    }

                    Text {
                        text: "Created by MannuVilasara"
                        color: root.cText
                        font.pixelSize: 16
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "If you like this project, please\nconsider giving it a star on GitHub!"
                        color: root.cSubtext0
                        font.pixelSize: 14
                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignHCenter
                    }

                    // GitHub Star Button
                    Rectangle {
                        Layout.preferredWidth: 200
                        Layout.preferredHeight: 45
                        Layout.alignment: Qt.AlignHCenter
                        radius: 12
                        color: starBtn.containsMouse ? root.cLavender : root.cSurface0
                        
                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 10
                            
                            Text {
                                text: "★"
                                color: starBtn.containsMouse ? root.cBase : root.cYellow
                                font.pixelSize: 20
                            }
                            Text {
                                text: "Star on GitHub"
                                color: starBtn.containsMouse ? root.cBase : root.cText
                                font.bold: true
                                font.pixelSize: 14
                            }
                        }

                        MouseArea {
                            id: starBtn
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Qt.openUrlExternally("https://github.com/MannuVilasara/qswitch")
                        }
                    }

                    Item { Layout.preferredHeight: 10 }

                    // Close Info Button
                    Rectangle {
                        Layout.preferredWidth: 100
                        Layout.preferredHeight: 36
                        Layout.alignment: Qt.AlignHCenter
                        radius: 10
                        color: closeInfoBtn.containsMouse ? root.cSurface1 : "transparent"
                        border.color: root.cOverlay0
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "Close"
                            color: root.cOverlay0
                        }

                        MouseArea {
                            id: closeInfoBtn
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.showInfoPopup = false
                        }
                    }
                }
            }
        }
    }
}