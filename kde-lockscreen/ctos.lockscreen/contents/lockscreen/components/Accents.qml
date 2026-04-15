// Ported from common/components/Accents.qml
// Changes:
//   - Removed `import qs.greeter.config`
//   - Resource path updated to sibling `../resources/accent.svg`
//   - `Settings.animationProfile(...)` replaced with local `config.animationsEnabled`
import QtQuick

Item {
    id: root

    signal finished

    default property alias content: container.data

    property bool animate: true
    property int  individualSize: 4

    property int startingHorizontalOffset: 0
    property int startingVerticalOffset:   0
    property int finalHorizontalOffset:    18
    property int finalVerticalOffset:      10

    property int _horizontalOffset: -startingHorizontalOffset - finalHorizontalOffset
    property int _verticalOffset:   -startingVerticalOffset   - finalVerticalOffset

    property int opacityDuration:  50
    property int opacityEasing:    Easing.InCubic
    property int translateDuration: 100
    property int translateEasing:   Easing.InCubic

    // ---------------------------------------------------------------------------
    Config { id: config }
    // ---------------------------------------------------------------------------

    Item {
        id: container
        anchors.fill: parent
    }

    Image {
        id: accentTopLeft
        width:  root.individualSize
        height: root.individualSize
        source: "../resources/accent.svg"
        anchors { left: root.left; leftMargin: root._horizontalOffset; top: root.top; topMargin: root._verticalOffset }
    }
    Image {
        id: accentBotLeft
        width:  root.individualSize
        height: root.individualSize
        source: "../resources/accent.svg"
        rotation: 270
        anchors { left: root.left; leftMargin: root._horizontalOffset; bottom: root.bottom; bottomMargin: root._verticalOffset }
    }
    Image {
        id: accentTopRight
        width:  root.individualSize
        height: root.individualSize
        source: "../resources/accent.svg"
        rotation: 90
        anchors { right: root.right; rightMargin: root._horizontalOffset; top: root.top; topMargin: root._verticalOffset }
    }
    Image {
        id: accentBotRight
        width:  root.individualSize
        height: root.individualSize
        source: "../resources/accent.svg"
        rotation: 180
        anchors { right: root.right; rightMargin: root._horizontalOffset; bottom: root.bottom; bottomMargin: root._verticalOffset }
    }

    ParallelAnimation {
        id: defaultAnimation
        running: config.animationsEnabled

        // Setup
        PropertyAction { targets: [accentTopLeft, accentTopRight, accentBotRight, accentBotLeft]; property: "opacity"; value: 0 }
        PropertyAction { targets: [accentTopLeft, accentBotLeft];  property: "anchors.leftMargin";   value: -root.startingHorizontalOffset }
        PropertyAction { targets: [accentTopRight, accentBotRight]; property: "anchors.rightMargin"; value: -root.startingHorizontalOffset }
        PropertyAction { targets: [accentTopLeft, accentTopRight]; property: "anchors.topMargin";    value: -root.startingVerticalOffset }
        PropertyAction { targets: [accentBotLeft, accentBotRight]; property: "anchors.bottomMargin"; value: -root.startingVerticalOffset }

        ScriptAction { script: defaultAnimation.pause() }

        // Begin
        NumberAnimation { targets: [accentTopLeft, accentTopRight, accentBotRight, accentBotLeft]; property: "opacity"; to: 1; duration: root.opacityDuration; easing.type: root.opacityEasing }
        NumberAnimation { targets: [accentTopLeft, accentBotLeft];  property: "anchors.leftMargin";   to: root._horizontalOffset; duration: root.translateDuration; easing.type: root.translateEasing }
        NumberAnimation { targets: [accentTopLeft, accentTopRight]; property: "anchors.topMargin";    to: root._verticalOffset;   duration: root.translateDuration; easing.type: root.translateEasing }
        NumberAnimation { targets: [accentBotLeft, accentBotRight]; property: "anchors.bottomMargin"; to: root._verticalOffset;   duration: root.translateDuration; easing.type: root.translateEasing }
        NumberAnimation { targets: [accentTopRight, accentBotRight]; property: "anchors.rightMargin"; to: root._horizontalOffset; duration: root.translateDuration; easing.type: root.translateEasing }

        onFinished: root.finished()
    }

    Component.onCompleted: {
        if (!animate) {
            defaultAnimation.resume();
            defaultAnimation.complete();
        }
    }

    function start() {
        defaultAnimation.resume();
    }
}
