// Ported from greeter/components/FieldGroup.qml
// Changes:
//   - Removed all qs.* imports
//   - `AuthManager.state`   → `authState` property (int, passed from parent)
//   - `AuthManager.respond` → `unlockRequested(string)` signal (wired in LockScreenUi)
//   - `AuthManager.user`    → `userName` property (passed from parent)
//   - `Settings.*`          → local Config / Theme instances
//
// Auth state constants (mirror LockScreenUi.AuthState):
//   0 = Ready | 1 = Loading | 2 = Success | 3 = Failed | 4 = Finish
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: fieldGroup

    // ------- Public API -------
    signal finished
    signal unlockRequested(string password)

    // Injected by parent (LockScreenUi.qml)
    property int    authState: 0
    property string userName:  "USER"

    // ---------------------------------------------------------------------------
    Theme  { id: theme  }
    Config { id: config }
    // ---------------------------------------------------------------------------

    readonly property real vh: Screen.height / 1080.0

    width:   294 * vh
    spacing: 0

    // ── User row ────────────────────────────────────────────────────────────────
    RowLayout {
        id: userRow
        spacing: 5
        transform: [ Translate { id: userRowTranslate } ]

        Image {
            id: barcode
            Layout.preferredHeight: 10
            fillMode: Image.PreserveAspectCrop
            source: "../resources/barcode.svg"
        }

        Typewriter {
            id: userText
            color:       theme.textPrimary
            initialText: fieldGroup.userName.toUpperCase()
            font {
                pixelSize: 14
                family:    config.fontFamily
            }
        }
    }

    // ── Password field ───────────────────────────────────────────────────────────
    PasswordField {
        id: passwordField

        property int progressPercentage: 0

        // Enabled only while idle; disabled during auth and after success.
        enabled: fieldGroup.authState === 0

        Layout.fillWidth:       true
        Layout.preferredHeight: 40 * vh
        Layout.alignment:       Qt.AlignCenter

        color: {
            switch (fieldGroup.authState) {
            case 1:  return theme.textPrimaryDim;   // Loading
            case 2:  return theme.success;           // Success
            case 4:  return theme.success;           // Finish
            case 3:  return theme.error;             // Failed
            default: return theme.textPrimary;       // Ready
            }
        }

        z: 5

        onAccepted: {
            if (fieldGroup.authState === 0)
                fieldGroup.unlockRequested(passwordField.text);
        }

        Component.onCompleted: {
            passwordField.forceActiveFocus();
        }

        // Progress fill bar (shown during loading animation)
        Rectangle {
            id: progress
            anchors.fill: parent
            color: theme.ctosGray
            transform: Scale {
                id: progressScale
                xScale: passwordField.progressPercentage / 100
            }
        }

        // Loading percentage readout
        Text {
            id: progressValue
            text: passwordField.progressPercentage.toString().padStart(2, "0")
            anchors { top: parent.bottom; topMargin: 5 * vh; right: parent.right }
            color:   theme.textPrimaryDim
            font { pixelSize: 14; family: config.fontFamily; weight: 500 }
            opacity: 0
        }

        // Loading description label
        Text {
            id: progressDescription
            text: "INITIALIZING" + ".".repeat(fieldGroup.dotCount)
            anchors { top: parent.bottom; topMargin: 5 * vh; left: parent.left }
            color: theme.textPrimaryDimmer
            font { pixelSize: 14; family: config.fontFamily }
            opacity: 0
        }

        background: Rectangle {
            id: passwordFieldBg
            color: theme.background
            border { color: theme.ctosGray; width: 2 }
        }

        transform: Scale { id: passwordFieldScale }
    }

    // ── Login / submit button ────────────────────────────────────────────────────
    Rectangle {
        id: loginButton
        Layout.preferredHeight: 26 * vh
        Layout.preferredWidth:  parent.width * 0.38
        Layout.alignment:       Qt.AlignRight
        color: theme.ctosGray
        transform: [
            Scale   { id: loginScale;    origin.x: loginButton.width; origin.y: 0 },
            Translate { id: loginTranslate }
        ]

        Text {
            id: loginText
            text:    "LOGIN"
            visible: fieldGroup.authState !== 1
            color:   theme.background
            anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
            font { pixelSize: 14; family: config.fontFamily }
        }

        Spinner {
            active: fieldGroup.authState === 1
            anchors { horizontalCenter: loginButton.horizontalCenter; verticalCenter: loginButton.verticalCenter }
        }

        // Clicking the button also submits the password.
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (fieldGroup.authState === 0)
                    fieldGroup.unlockRequested(passwordField.text);
            }
        }
    }

    // ── Exit / success animation ─────────────────────────────────────────────────
    SequentialAnimation {
        id: animation

        PauseAnimation { duration: 200 }

        ScriptAction { script: passwordField.text = "" }

        ParallelAnimation {
            NumberAnimation { targets: [userRow, loginText]; property: "opacity"; duration: 150; to: 0 }
            NumberAnimation { target: loginScale; property: "yScale"; to: 0; duration: 275; easing.type: Easing.OutCubic }
        }

        ParallelAnimation {
            ColorAnimation {
                target: passwordFieldBg; property: "border.color"
                to: theme.secondary; duration: 200
            }
            NumberAnimation {
                target: passwordField; property: "Layout.preferredHeight"
                to: 4 * vh; duration: 300; easing.type: Easing.OutCubic
            }
            SequentialAnimation {
                PauseAnimation { duration: 150 }
                NumberAnimation { targets: [progressDescription, progressValue]; property: "opacity"; to: 1; duration: 150 }
                ScriptAction    { script: textSpinner.start() }
            }
        }

        PauseAnimation { duration: 400 }
        NumberAnimation { target: passwordField; property: "progressPercentage"; to: 40;  duration: 1000; easing.type: Easing.InSine }
        PauseAnimation  { duration: 300 }
        NumberAnimation { target: passwordField; property: "progressPercentage"; to: 100; duration: 300;  easing.type: Easing.InSine }

        onFinished: fieldGroup.finished()
    }

    property int dotCount: 0

    SequentialAnimation {
        id: textSpinner
        loops: Animation.Infinite
        NumberAnimation { target: fieldGroup; property: "dotCount"; from: 1; to: 3; duration: 900 }
    }

    // ── Authentication failure: flash red then reset ─────────────────────────────
    SequentialAnimation {
        id: failAnimation
        running: false

        PauseAnimation  { duration: 600 }
        // authState will be reset to Ready by parent after the visual delay
        ScriptAction { script: { passwordField.text = ""; passwordField.forceActiveFocus(); } }
    }

    // Watch for incoming auth-state changes.
    onAuthStateChanged: {
        if (authState === 3) {  // Failed
            failAnimation.start();
        }
    }

    function start() {
        animation.start();
    }
}
