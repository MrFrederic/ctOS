// Ported from greeter/components/Time.qml
// Changes:
//   - Removed `import Quickshell` and `import qs.*`
//   - Replaced `SystemClock` with a standard QML `Timer` + JS `new Date()`
//   - `Settings.fontFamily` → `config.fontFamily`
//   - `Settings.animationProfile(...)` → `config.animationsEnabled`
import QtQuick

Item {
    id: root

    // ---------------------------------------------------------------------------
    Theme  { id: theme  }
    Config { id: config }
    // ---------------------------------------------------------------------------

    // Live clock — updates every second using a plain QML Timer.
    property var currentDate: new Date()

    Timer {
        interval: 1000
        running:  true
        repeat:   true
        onTriggered: root.currentDate = new Date()
    }

    Row {
        spacing: 20

        Accents {
            id: accents

            width:  110
            height: 110

            opacityDuration:          200
            translateDuration:        300
            startingHorizontalOffset: -20
            startingVerticalOffset:   -20
            finalHorizontalOffset:     20
            finalVerticalOffset:       20

            Image {
                id: logo
                anchors.fill: parent
                source: "../resources/os-icon.svg"
            }
        }

        Column {
            spacing: 12

            Text {
                id: time

                color: theme.textPrimaryDimmer
                text:  Qt.formatDateTime(root.currentDate, "hh:mm")

                font {
                    pixelSize: 48
                    weight:    100
                    family:    config.fontFamily
                }

                transform: Translate { id: timeTranslate }
            }

            Rectangle {
                id: region

                width:  regionLabel.width + 24
                height: regionLabel.height + 6

                border { color: "#414141"; width: 1 }
                color: "transparent"

                transform: Translate { id: regionTranslate }

                Text {
                    id: regionLabel

                    anchors {
                        verticalCenter:       parent.verticalCenter
                        verticalCenterOffset: 2
                        left:                 parent.left
                        leftMargin:           8
                    }

                    color: "#B1B1B1"
                    text:  Qt.formatDateTime(root.currentDate, "dddd dd MMMM")
                    font {
                        pixelSize: 14
                        family:    config.fontFamily
                        weight:    300
                    }
                }
            }
        }
    }

    // Reveal animation — mirrors the Quickshell original exactly.
    SequentialAnimation {
        id: revealAnimation
        running: config.animationsEnabled

        PropertyAction { targets: [logo, time, region]; property: "opacity"; value: 0 }
        PropertyAction { targets: [timeTranslate, regionTranslate]; property: "y"; value: -10 }

        ScriptAction { script: revealAnimation.pause() }

        PauseAnimation { duration: 100 }

        ParallelAnimation {
            // Logo fade-in
            NumberAnimation { target: logo; property: "opacity"; to: 1; duration: 300; easing.type: Easing.InExpo }

            // Time text
            SequentialAnimation {
                PauseAnimation { duration: 100 }
                ParallelAnimation {
                    NumberAnimation { target: time; property: "opacity"; to: 1; duration: 300; easing.type: Easing.InExpo }
                    NumberAnimation { target: timeTranslate; property: "y"; to: 0; duration: 300; easing.type: Easing.InExpo }
                }
            }

            // Date region
            SequentialAnimation {
                PauseAnimation { duration: 200 }
                ParallelAnimation {
                    NumberAnimation { target: region; property: "opacity"; to: 1; duration: 300; easing.type: Easing.InExpo }
                    NumberAnimation { target: regionTranslate; property: "y"; to: 0; duration: 300; easing.type: Easing.InExpo }
                }
            }
        }
    }

    Connections {
        target: accents
        function onFinished() { revealAnimation.resume(); }
    }

    function start() {
        accents.start();
    }
}
