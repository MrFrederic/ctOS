// Ported from greeter/components/Surface.qml
// Changes: removed qs.* imports; `Settings.animationProfile(...)` → `config.animationsEnabled`.
import QtQuick

Item {
    id: root

    property color barColor: theme.ctosGray

    default property alias contentWrapper: contentTarget.data
    property alias margins: contentTarget.anchors.margins

    property int topMargin:    margins
    property int leftMargin:   margins
    property int rightMargin:  margins
    property int bottomMargin: margins

    width:  contentWrapper.width
    height: contentWrapper.height

    property int barWidth: 3

    // ---------------------------------------------------------------------------
    Theme  { id: theme  }
    Config { id: config }
    // ---------------------------------------------------------------------------

    Item {
        id: contentWrapper
        clip: true
        height: contentTarget.childrenRect.height + (contentTarget.anchors.margins * 2)
        width:  contentTarget.childrenRect.width  + (contentTarget.anchors.margins * 2)

        transform: Scale {
            id: contentScale
            xScale:   1
            origin.x: contentWrapper.width / 2
        }

        Item {
            id: contentTarget

            transform: Scale {
                origin.x: contentTarget.width / 2
                xScale:   1 / contentScale.xScale
            }

            width:  childrenRect.width
            height: childrenRect.height

            anchors {
                centerIn: parent
                topMargin:    root.topMargin
                rightMargin:  root.rightMargin
                bottomMargin: root.bottomMargin
                leftMargin:   root.leftMargin
            }
        }
    }

    Rectangle {
        id: left
        anchors { right: center.left; top: center.top; bottom: center.bottom }
        color: root.barColor
        width: root.barWidth
        transform: [
            Scale {
                id: leftScale
                origin.y: left.height / 2
            },
            Translate {
                id: leftTranslate
                x: config.animationsEnabled ? (center.width / 2) : 0
            }
        ]
    }

    Rectangle {
        id: right
        anchors { left: center.right; top: center.top; bottom: center.bottom }
        color: root.barColor
        width: root.barWidth
        transform: [
            Scale {
                id: rightScale
                origin.y: right.height / 2
            },
            Translate {
                id: rightTranslate
                x: config.animationsEnabled ? -(center.width / 2) : 0
            }
        ]
    }

    Rectangle {
        id: center
        anchors.fill: contentWrapper
        color: '#14ffffff'
        transform: Scale {
            id: centerScale
            origin.x: center.width / 2
            xScale:   1
        }
    }

    SequentialAnimation {
        id: revealAnimation
        running: config.animationsEnabled

        // Setup
        PropertyAction { targets: [leftScale, rightScale];   property: "yScale"; value: 0 }
        PropertyAction { targets: [centerScale, contentScale]; property: "xScale"; value: 0 }

        ScriptAction { script: revealAnimation.pause() }

        // Begin
        ParallelAnimation {
            NumberAnimation { targets: [leftScale, rightScale]; property: "yScale"; to: 1; duration: 320; easing.type: Easing.InOutCirc }
        }
        PauseAnimation { duration: 200 }
        ParallelAnimation {
            NumberAnimation { targets: [leftTranslate, rightTranslate]; property: "x"; to: 0; duration: 400; easing.type: Easing.OutQuint }
            NumberAnimation { targets: [centerScale, contentScale];     property: "xScale"; to: 1; duration: 400; easing.type: Easing.OutQuint }
        }
    }

    function start() {
        revealAnimation.resume();
    }
}
