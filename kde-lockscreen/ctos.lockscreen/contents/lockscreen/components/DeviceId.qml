// Ported from greeter/components/DeviceId.qml
// Changes: removed qs.* imports; `Settings.*` → local Config / Theme instances.
import QtQuick
import QtQuick.Layouts

Row {
    id: root

    // ---------------------------------------------------------------------------
    Theme  { id: theme  }
    Config { id: config }
    // ---------------------------------------------------------------------------

    readonly property real vh: Screen.height / 1080.0

    ColumnLayout {
        id: aside
        transform: Translate { id: asideTranslate }
        anchors { top: parent.top; topMargin: 5 * root.vh; bottom: parent.bottom }
        width: 35 * root.vh

        Image {
            id: tesseract
            source: "../resources/tesseract.svg"
            Layout.preferredHeight: deviceText.width + 2
            Layout.preferredWidth:  deviceText.width + 2
            transform: Translate { id: tesseractTranslate }
        }
        Item { Layout.fillHeight: true }
        Image {
            id: deviceText
            source: "../resources/device-text.svg"
            Layout.bottomMargin: 5
            Layout.topMargin:    20 * root.vh
            Layout.fillHeight:   true
            fillMode: Image.PreserveAspectFit
            transform: Translate { id: deviceTextTranslate }
        }
        Rectangle {
            id: borderRect
            height: 3
            Layout.fillWidth: true
            color: theme.textPrimaryDim
        }
    }

    Image {
        id: barcode
        z: 3
        anchors { top: parent.top; bottom: parent.bottom }
        fillMode: Image.PreserveAspectFit
        source: "../resources/device-barcode.svg"
    }

    SequentialAnimation {
        id: revealAnimation
        running: config.animationsEnabled

        // Setup
        PropertyAction { targets: [barcode, borderRect];          property: "opacity"; value: 0 }
        PropertyAction { targets: [tesseract, deviceText];        property: "opacity"; value: 0 }
        PropertyAction { targets: [tesseractTranslate, deviceTextTranslate]; property: "x"; value: 10 }

        ScriptAction { script: revealAnimation.pause() }

        // Reveal
        NumberAnimation { targets: [barcode, borderRect]; property: "opacity"; to: 1; duration: 300; easing.type: Easing.InBounce }

        ParallelAnimation {
            NumberAnimation { target: tesseract;       property: "opacity"; to: 1; duration: 300; easing.type: Easing.InExpo }
            NumberAnimation { target: tesseractTranslate; property: "x";   to: 0; duration: 300; easing.type: Easing.InExpo }
        }
        ParallelAnimation {
            NumberAnimation { target: deviceText;          property: "opacity"; to: 1; duration: 300; easing.type: Easing.InExpo }
            NumberAnimation { target: deviceTextTranslate; property: "x";      to: 0; duration: 300; easing.type: Easing.InExpo }
        }
    }

    function start() {
        revealAnimation.resume();
    }
}
