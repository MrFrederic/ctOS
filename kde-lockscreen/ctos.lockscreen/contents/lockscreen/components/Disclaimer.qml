// Ported from greeter/components/Disclaimer.qml
// Changes: removed qs.* imports; Theme and Config resolved via local instances.
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: disclaimer

    spacing: 8

    // ---------------------------------------------------------------------------
    Theme  { id: theme  }
    Config { id: config }
    // ---------------------------------------------------------------------------

    Image {
        id: icon
        source: "../resources/tesseract.svg"
        Layout.alignment:       Qt.AlignTop
        Layout.preferredWidth:  32
        Layout.preferredHeight: 32
    }

    property string lineOneText:    "Property of Blume Corp. All usage is"
    property int    lineOneCharsShown: lineOneText.length
    property string lineTwoText:    "subject to Sentinel Active Monitoring."
    property int    lineTwoCharsShown: lineTwoText.length

    ColumnLayout {
        id: text
        Layout.fillWidth: true

        Text {
            Layout.fillWidth: true
            color: theme.ctosGray
            font.pixelSize: 11
            font.family:    config.fontFamily
            fontSizeMode:   Text.Fit
            minimumPixelSize: 1
            text: disclaimer.lineOneText.substring(0, disclaimer.lineOneCharsShown)
        }

        Text {
            Layout.fillWidth: true
            color: theme.ctosGray
            font.pixelSize: 11
            font.family:    config.fontFamily
            fontSizeMode:   Text.Fit
            minimumPixelSize: 1
            text: disclaimer.lineTwoText.substring(0, disclaimer.lineTwoCharsShown)
        }
    }

    SequentialAnimation {
        id: hideAnimation

        ParallelAnimation {
            NumberAnimation { target: disclaimer; property: "lineTwoCharsShown"; to: 0; duration: 300; easing.type: Easing.InQuart }
            SequentialAnimation {
                PauseAnimation { duration: 50 }
                NumberAnimation { target: disclaimer; property: "lineOneCharsShown"; to: 0; duration: 300; easing.type: Easing.InQuart }
            }
        }
        PauseAnimation { duration: 25 }
        NumberAnimation { target: icon; property: "opacity"; to: 0; duration: 25 }
    }

    function exit() {
        hideAnimation.start();
    }
}
