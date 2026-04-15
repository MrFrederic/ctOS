// Ported from greeter/components/MainLayout.qml
// Changes:
//   - Removed all qs.* imports
//   - Removed Terminal / TerminalManager (service not available in KDE lock screen)
//   - `AuthManager.state`   → `authState` property (int, from LockScreenUi)
//   - `AuthManager.user`    → `userName` property  (from LockScreenUi)
//   - `Settings.*`          → local Config / Theme instances
//   - Startup animation now begins immediately (no TerminalManager pause gate)
//   - debug shortcuts (F12 / Escape) kept behind `debugMode` property
import QtQuick

Item {
    id: root

    anchors.fill: parent
    focus: true

    // ------- Public API injected by LockScreenUi -------
    property int    authState: 0     // mirrors FieldGroup / LockScreenUi auth state
    property string userName:  "USER"
    signal unlockRequested(string password)

    // ------- Optional debug helpers (safe to leave true during testing) -------
    property bool debugMode: false

    // Emitted when FieldGroup completes its exit animation (auth finished).
    signal unlockAnimationFinished

    // ---------------------------------------------------------------------------
    Theme  { id: theme  }
    Config { id: config }
    // ---------------------------------------------------------------------------

    readonly property real vh: Screen.height / 1080.0

    Keys.onPressed: event => {
        if (event.key === Qt.Key_C && (event.modifiers & Qt.ControlModifier)) {
            event.accepted = true;   // eat Ctrl-C
        }
        if (root.debugMode) {
            switch (event.key) {
            case Qt.Key_F12:
                root.authState = 2;  // simulate Success
                break;
            }
        }
    }

    // ── Background ───────────────────────────────────────────────────────────────
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: "../resources/lock.png"
        fillMode: Image.PreserveAspectCrop
    }

    // ── ctOS splash logo ─────────────────────────────────────────────────────────
    Splash {
        id: splash
        width:  294 * vh
        height: 48  * vh
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter:   root.top
            verticalCenterOffset: root.height * 0.406
        }
    }

    // ── Accent corners (shared, re-anchored during transitions) ─────────────────
    Connections {
        target: accents
        function onFinished() { splash.start(); }
    }

    Accents {
        id: accents
        state: "splash"
        states: [
            State {
                name: "splash"
                AnchorChanges {
                    target: accents
                    anchors { top: splash.top; right: splash.right; bottom: splash.bottom; left: splash.left }
                }
            },
            State {
                name: "field_group"
                AnchorChanges {
                    target: accents
                    anchors { top: fieldGroup.top; right: fieldGroup.right; bottom: fieldGroup.bottom; left: fieldGroup.left }
                }
            }
        ]
        transitions: Transition {
            from: "*"; to: "*"
            AnchorAnimation { duration: 400; easing.type: Easing.InOutCirc }
        }
    }

    // ── Password / user field group ──────────────────────────────────────────────
    FieldGroup {
        id: fieldGroup
        anchors {
            top:              splash.bottom
            topMargin:        50 * vh
            horizontalCenter: root.horizontalCenter
        }
        authState: root.authState
        userName:  root.userName
        onUnlockRequested: (pwd) => root.unlockRequested(pwd)
        // Emit signal up to LockScreenUi rather than mutating the bound property.
        onFinished: root.unlockAnimationFinished()
    }

    // ── Footer disclaimer text ───────────────────────────────────────────────────
    Disclaimer {
        id: disclaimer
        anchors {
            left:      splash.left
            right:     splash.right
            top:       splash.bottom
            topMargin: 25 * vh + 50 * vh + 85 * vh + 15 * vh
            leftMargin: 2
        }
    }

    // ── Top-left clock ───────────────────────────────────────────────────────────
    Time {
        id: timeWidget
        anchors {
            top:        root.top
            left:       root.left
            leftMargin: root.height * 0.05
            topMargin:  root.height * 0.05
        }
    }

    // ── Top-right status panel ───────────────────────────────────────────────────
    Status {
        id: statusWidget
        anchors {
            right:       root.right
            top:         root.top
            rightMargin: (root.height * 0.0375) - statusWidget.barWidth
            topMargin:   root.height * 0.046
        }
    }

    // ── Bottom-right device ID panel ─────────────────────────────────────────────
    DeviceId {
        id: device
        height: root.height * 0.45
        anchors {
            right:        root.right
            bottom:       root.bottom
            rightMargin:  root.height * 0.0375
            bottomMargin: root.height * 0.046
        }
    }

    // ── Startup sequence ─────────────────────────────────────────────────────────
    SequentialAnimation {
        id: startSplash
        running: config.animationsEnabled

        PropertyAction { target: disclaimer; property: "opacity"; value: 0 }

        ScriptAction { script: startSplash.pause() }
        PauseAnimation {}

        ParallelAnimation {
            ScriptAction    { script: accents.start() }
            NumberAnimation { target: disclaimer; property: "opacity"; to: 1; duration: 100; easing.type: Easing.InCubic }
        }
    }

    SequentialAnimation {
        id: startupAnimation
        running: config.animationsEnabled

        // Setup
        PropertyAction { target: splash;     property: "anchors.verticalCenterOffset"; value: root.height / 2 }
        PropertyAction { target: disclaimer; property: "anchors.topMargin"; value: 25 * vh }
        PropertyAction { target: fieldGroup; property: "opacity"; value: 0 }

        ScriptAction { script: startupAnimation.pause() }

        // Slide apart
        ParallelAnimation {
            NumberAnimation { target: splash;     property: "anchors.verticalCenterOffset"; to: root.height * 0.406; duration: 500; easing.type: Easing.InOutCirc }
            NumberAnimation { target: disclaimer; property: "anchors.topMargin"; to: 25 * vh + fieldGroup.anchors.topMargin + 85 * vh + 15 * vh; duration: 500; easing.type: Easing.InOutCirc }
            SequentialAnimation {
                PauseAnimation  { duration: 300 }
                NumberAnimation { target: fieldGroup; property: "opacity"; to: 1; duration: 200; easing.type: Easing.OutExpo }
            }
        }
    }

    // ── Success / exit sequence ───────────────────────────────────────────────────
    SequentialAnimation {
        id: exitAnimation
        running: false   // started explicitly via onAuthStateChanged below

        ScriptAction    { script: accents.state = "field_group" }
        PauseAnimation  { duration: 200 }
        ScriptAction    { script: disclaimer.exit() }
        PauseAnimation  { duration: 200 }
        ScriptAction    { script: fieldGroup.start() }
    }

    onAuthStateChanged: {
        if (authState === 2 /* Success */ && !exitAnimation.running)
            exitAnimation.start();
        const label = ["Ready","Loading","Success","Failed","Finish"][authState] ?? authState;
        console.log("[ctOS] authState →", label);
    }

    // ── Wire Splash → downstream animations ──────────────────────────────────────
    Connections {
        target: splash

        function onProgressBarMidway() {
            timeWidget.start();
            device.start();
            statusWidget.start();
        }

        function onRevealFinished() {
            startupAnimation.resume();
        }
    }

    // ── Begin the entrance sequence once the component is fully loaded ────────────
    Component.onCompleted: {
        if (config.animationsEnabled) {
            startSplash.resume();
        } else {
            // Skip all animations: show everything immediately.
            accents.animate = false;
            accents.start();
        }
    }
}
