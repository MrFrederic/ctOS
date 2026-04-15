// Ported from greeter/components/IdentityCard.qml
// Changes: removed qs.* imports; `Settings.*` → local Config / Theme instances.
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    // ---------------------------------------------------------------------------
    Theme  { id: theme  }
    Config { id: config }
    // ---------------------------------------------------------------------------

    component InfoField: Column {
        id: field
        property string label: "FIELD"
        property string value: "VALUE"
        property alias  fieldValueOpacity: fieldValue.opacity

        Text {
            text:  field.label
            color: theme.textPrimaryDim
            font { family: config.fontFamily; pixelSize: 14 }
        }
        Text {
            id: fieldValue
            text:  field.value
            color: theme.textPrimary
            font { family: config.fontFamily; pixelSize: 22; weight: 500 }
        }
    }

    ColumnLayout {
        width:  parent.width * 0.55
        height: parent.height
        spacing: 15

        RowLayout {
            spacing: 10

            InfoField {
                id:    employeeId
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                label: "EMPID ##"
                value: config.fakeIdentity.id
            }
            InfoField {
                id:    employeeClass
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                label: "CLASS"
                value: config.fakeIdentity.class
            }
        }

        InfoField {
            id:    employeeName
            Layout.fillWidth: true
            label: "FULL NAME"
            value: config.fakeIdentity.fullName
        }

        Item { Layout.fillHeight: true }

        Image {
            Layout.bottomMargin: 2
            fillMode: Image.PreserveAspectFit
            source:   "../resources/id-barcode.svg"
            width:    parent.width
        }
    }

    Item {
        id: profilePicture
        width:  parent.height / 5 * 4
        height: parent.height
        anchors.right: parent.right

        Rectangle { anchors.fill: parent; color: '#1effffff' }
        Image {
            source:   "../resources/user.svg"
            opacity:  0.9
            anchors.fill: parent
        }
    }

    SequentialAnimation {
        id: revealAnimation
        running: true  // starts paused immediately; call start() to resume

        // Setup
        PropertyAction { target: root; property: "opacity"; value: 0 }
        PropertyAction { targets: [employeeId, employeeClass, employeeName]; property: "fieldValueOpacity"; value: 0 }

        ScriptAction { script: revealAnimation.pause() }

        // Reveal
        SequentialAnimation {
            NumberAnimation { target: root;        property: "opacity";            to: 1; duration: 150 }
            NumberAnimation { target: employeeId;  property: "fieldValueOpacity";  to: 1; duration: 150 }
            ParallelAnimation {
                NumberAnimation { target: employeeClass; property: "fieldValueOpacity"; to: 1; duration: 150 }
                SequentialAnimation {
                    PauseAnimation  { duration: 50 }
                    NumberAnimation { target: employeeName; property: "fieldValueOpacity"; to: 1; duration: 150 }
                }
            }
        }
    }

    function start() {
        revealAnimation.resume();
    }
}
