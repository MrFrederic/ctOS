// Ported from greeter/components/Status.qml
// Changes:
//   - Removed `import Quickshell.Services.UPower`
//   - Battery data sourced from Plasma PowerManagement DataEngine via
//     `org.kde.plasma.plasma5support`. Falls back to hardcoded config values
//     when the engine is unavailable (e.g., during `kscreenlocker_greet --testing`).
//   - `Settings.*` → local Config / Theme instances.
import QtQuick
import QtQuick.Layouts

// Plasma 5-compat DataSource (available in both Plasma 5 and Plasma 6 via plasma5support).
import org.kde.plasma.plasma5support 2.0 as P5Support

Surface {
    id: root

    margins:      18
    barColor:     Qt.darker(theme.textPrimaryDimmer, 2)
    topMargin:    14
    bottomMargin: 14

    // ---------------------------------------------------------------------------
    Theme  { id: theme  }
    Config { id: config }
    // ---------------------------------------------------------------------------

    // PowerManagement data engine.
    P5Support.DataSource {
        id: pmSource
        engine:           "powermanagement"
        connectedSources: ["Battery", "AC Adapter"]
        onSourceAdded: (source) => { connectSource(source) }
    }

    // Derive battery values from the DataEngine; fall back to config fake values.
    readonly property var   batteryData:       pmSource.data["Battery"]       ?? null
    readonly property var   acData:            pmSource.data["AC Adapter"]    ?? null
    readonly property bool  hasBattery:        batteryData ? (batteryData["Has Battery"] ?? false) : false
    readonly property int   batteryPercentage: hasBattery ? Math.round(batteryData["Percent"] ?? 0) : -1
    readonly property bool  isCharging:        acData     ? (acData["Plugged in"]        ?? false) : false

    // Human-readable charge state label.
    readonly property string chargeLabel: {
        if (!hasBattery)    return config.fakeStatus.env;
        if (isCharging)     return `${batteryPercentage}% ↑`;
        return `${batteryPercentage}%`;
    }

    // ---------------------------------------------------------------------------

    component InfoField: ColumnLayout {
        id: field
        property string label: "FIELD"
        property string value: "VALUE"
        property alias  fieldValueOpacity: fieldValue.opacity

        Text {
            text:  field.label
            color: theme.textPrimaryDim
            font { family: config.fontFamily; pixelSize: 12 }
        }
        Text {
            id: fieldValue
            text:  field.value
            color: theme.textPrimary
            font { family: config.fontFamily; pixelSize: 18; weight: 500 }
        }
    }

    ColumnLayout {
        spacing: 10

        RowLayout {
            spacing: 30

            InfoField {
                Layout.fillWidth: true
                label: hasBattery ? "BATTERY" : "ENV"
                value: chargeLabel
            }
            InfoField {
                Layout.fillWidth: true
                label: "NODE"
                value: config.fakeStatus.node
            }
        }
    }
}
