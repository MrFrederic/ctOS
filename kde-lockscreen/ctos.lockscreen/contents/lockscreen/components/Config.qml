// Replaces greeter/config/Settings.qml — no Quickshell, no file I/O.
// All values are hardcoded defaults; edit here to customise the theme.
// Instantiate once as `Config { id: config }` in each component that uses it.
import QtQuick

QtObject {
    // Font used throughout the UI. Must be installed on the system.
    readonly property string fontFamily: "JetBrainsMono Nerd Font"

    // Set to false to disable all reveal/transition animations.
    readonly property bool animationsEnabled: true

    // Fake identity card data shown on the right panel.
    readonly property var fakeIdentity: ({
        "id":       "ADM-843",
        "class":    "L5_PROV",
        "fullName": "Blume Admin"
    })

    // Fake status data shown on the status panel.
    readonly property var fakeStatus: ({
        "env":  "Workstation",
        "node": "109.389.013.301"
    })
}
