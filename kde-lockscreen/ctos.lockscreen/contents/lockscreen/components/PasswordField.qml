// Ported from greeter/components/PasswordField.qml
// Changes: removed `import qs.common`; no other logic changes needed.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls

TextField {
    id: passwordField

    property alias rem: cursorMetrics.width

    font {
        pixelSize:     16
        letterSpacing: 5
    }

    echoMode:          TextInput.Password
    passwordCharacter: "█"

    TextMetrics {
        id: cursorMetrics
        font: passwordField.font
        text: "▁"
    }

    leftPadding:  8
    rightPadding: cursorMetrics.width + 6  // prevents cursor from clipping border

    cursorDelegate: Text {
        id: cursor

        color: passwordField.color
        font:  passwordField.font
        text:  "▁"

        Timer {
            id: blinkDelayTimer
            interval: 500
            onTriggered: blinkAnimation.running = true
        }

        Connections {
            target: passwordField

            function onEnabledChanged() {
                if (passwordField.enabled) {
                    blinkDelayTimer.running = true;
                } else {
                    blinkDelayTimer.running  = false;
                    blinkAnimation.running   = false;
                    cursor.opacity           = 0;
                }
            }

            function onTextEdited() {
                blinkDelayTimer.restart();
                blinkAnimation.running = false;
                cursor.opacity         = 1;
            }
        }

        SequentialAnimation on opacity {
            id: blinkAnimation
            loops: Animation.Infinite

            NumberAnimation { from: 1; to: 1; duration: 500 }
            NumberAnimation { from: 1; to: 0; duration: 300 }
            NumberAnimation { from: 0; to: 0; duration: 300 }
        }
    }

    Component.onDestruction: {
        // Gracefully release focus before the QML scene is torn down.
        passwordField.focus = false;
    }
}
