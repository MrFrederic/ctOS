// LockScreenUi.qml — Pure visual layer for the ctOS lock screen.
//
// Loaded as a child of LockScreen.qml (the true kscreenlocker root).
// All authentication wiring lives in LockScreen.qml.
// This component only bridges authState/userName into MainLayout and
// surfaces unlockRequested/unlockAnimationFinished back to the parent.

import QtQuick

import "components"

Item {
    id: root

    // ── Properties injected by parent LockScreen.qml ─────────────────────────
    property int    authState: 0
    property string userName:  "USER"

    // ── Signals bubbled up to LockScreen.qml ─────────────────────────────────
    signal unlockRequested(string password)
    signal unlockAnimationFinished

    // ── Main layout ───────────────────────────────────────────────────────────
    MainLayout {
        id: mainLayout
        anchors.fill: parent

        authState: root.authState
        userName:  root.userName

        onUnlockRequested:         (pwd) => root.unlockRequested(pwd)
        onUnlockAnimationFinished: root.unlockAnimationFinished()
    }
}
