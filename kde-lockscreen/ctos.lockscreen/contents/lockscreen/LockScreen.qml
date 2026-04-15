// LockScreen.qml — KDE Plasma/Shell lock screen entry point
//
// kscreenlocker_greet loads this file (role: lockscreenmainscript).
// It is a thin root Item that exposes the "magical" properties and signals
// that kscreenlocker_greet sets/reads via QQmlProperty, then delegates all
// visual work to LockScreenUi.
//
// Context properties injected by kscreenlocker_greet:
//   kscreenlocker_userName  (string)        — logged-in user's display name
//   kscreenlocker_userImage (string)        — path to user's face icon
//   authenticator           (PamAuthenticators) — PAM authentication object
//   org_kde_plasma_screenlocker_greeter_interfaceVersion (int == 2)
//
// Authenticator API (PamAuthenticators, Plasma 6):
//   authenticator.startAuthenticating()   — begin the PAM conversation
//   authenticator.respond(password)       — send password to PAM
//   signal succeeded()                    — auth succeeded
//   signal failed(kind)                   — auth failed (kind==0 → interactive)
//   signal promptChanged(prompt)          — PAM is asking for input
//
// Magic properties kscreenlocker_greet writes via QQmlProperty:
//   locked                 — whether the screen is actually locked
//   viewVisible            — true when the greeter window is fully shown
//   suspendToRamSupported  — whether suspend is available
//   suspendToDiskSupported — whether hibernate is available
//
// Magic signals kscreenlocker_greet connects to:
//   suspendToRam()
//   suspendToDisk()
import QtQuick

import "components"

Item {
    id: root

    // ── Magic properties (written by kscreenlocker_greet) ─────────────────────
    property bool viewVisible:           false
    property bool suspendToRamSupported:  false
    property bool suspendToDiskSupported: false

    // ── Magic signals (connected by kscreenlocker_greet) ──────────────────────
    signal suspendToRam()
    signal suspendToDisk()

    // ── Auth state ────────────────────────────────────────────────────────────
    readonly property int stateReady:   0
    readonly property int stateLoading: 1
    readonly property int stateSuccess: 2
    readonly property int stateFailed:  3
    readonly property int stateFinish:  4

    property int authState: stateReady

    // ── User identity ─────────────────────────────────────────────────────────
    property string userName: {
        if (typeof kscreenlocker_userName !== "undefined" && kscreenlocker_userName !== "")
            return kscreenlocker_userName;
        return "USER";
    }

    // ── KDE authenticator wiring ──────────────────────────────────────────────
    Connections {
        target: typeof authenticator !== "undefined" ? authenticator : null
        ignoreUnknownSignals: true

        function onSucceeded() {
            root.authState = root.stateSuccess;
        }

        // kind == 0 → interactive (password); non-zero → fingerprint/smartcard
        function onFailed(kind) {
            if (kind === 0) {
                root.authState = root.stateFailed;
                failResetTimer.restart();
            }
            // Non-interactive failures (fingerprint/smartcard) are silent — we
            // just wait for the password field or the next NFC/fingerprint attempt.
        }

        // PAM is prompting for input (e.g. password prompt text)
        function onPromptChanged(msg) {
            // If PAM is prompting and we are in Loading state, nothing to do
            // — the user's respond() call is already in flight.
        }

        // Grace lock ended — screen locked for real now
        function onGraceLockedChanged() {
            if (typeof authenticator !== "undefined" && !authenticator.graceLocked) {
                root.authState = root.stateReady;
            }
        }
    }

    // Reset Failed → Ready after a short visual delay.
    Timer {
        id: failResetTimer
        interval: 900
        onTriggered: {
            if (root.authState === root.stateFailed)
                root.authState = root.stateReady;
        }
    }

    // Testing-mode fake unlock (no real authenticator injected).
    Timer {
        id: testUnlockTimer
        interval: 1200
        onTriggered: root.authState = root.stateSuccess
    }

    // ── Visual UI ─────────────────────────────────────────────────────────────
    LockScreenUi {
        id: ui
        anchors.fill: parent

        authState: root.authState
        userName:  root.userName

        // Password submitted via the PasswordField or Login button.
        onUnlockRequested: (password) => {
            if (typeof authenticator !== "undefined") {
                root.authState = root.stateLoading;
                authenticator.respond(password);
            } else {
                // --testing mode: simulate unlock after a delay.
                root.authState = root.stateLoading;
                testUnlockTimer.restart();
            }
        }

        // FieldGroup exit animation done → quit the greeter process to close the window.
        onUnlockAnimationFinished: {
            root.authState = root.stateFinish;
            console.log("[ctOS] Lock screen unlock sequence complete.");
            Qt.quit();
        }
    }

    // Start the PAM conversation immediately so it is ready when the user types.
    Component.onCompleted: {
        if (typeof authenticator !== "undefined") {
            authenticator.startAuthenticating();
        }
        root.forceActiveFocus();
    }
}
