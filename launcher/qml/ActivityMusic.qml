import QtQuick 2.3
import QtQuick.Controls 1.2
import "."
import "music"

Activity {
    id: activityMusic

    property Component player: MusicPlayer {
        width: controlBounds.width
        height: controlBounds.height
    }

    property Component lister: MusicListView {
        width: controlBounds.width
        height: controlBounds.height
    }

    property bool playerVisible: false

    control: playerVisible ? player : lister

    //
    // Toolbar buttons
    //

    DarkButton {
        id: playButton
        inToolbar: true
        anchors.bottom: parent.bottom
        height: Style.toolbar.height
        iconScale: .7
        iconSource: "qrc:/images/play"
        hasSecondIcon: true
        secondIcon: "qrc:/images/pause"

        x: availableToolBarWidth / 2 + toolbarHeight + 30

        disableAutoMgr: true
        onClicked: {
            if(currentState == 0)
                soundManager.resumeMusic()
            else
                soundManager.pauseMusic()
        }

        currentState: soundManager.isPlaying ? 1 : 0
    }

    DarkButton {
        id: previousButton
        inToolbar: true
        anchors.bottom: parent.bottom
        height: Style.toolbar.height
        iconScale: .7
        iconSource: "qrc:/images/skip_previous"

        x: playButton.x - 95

        onClicked: soundManager.previousMusic()
    }

    DarkButton {
        id: nextButton
        inToolbar: true
        anchors.bottom: parent.bottom
        height: Style.toolbar.height
        iconScale: .7
        iconSource: "qrc:/images/skip_next"

        x: playButton.x + 95

        onClicked: soundManager.nextMusic()
    }

    DarkButton {
        id: randomButton
        inToolbar: true
        anchors.bottom: parent.bottom
        height: Style.toolbar.height
        iconScale: .7
        iconSource: "qrc:/images/shuffle"

        checkable: true
        disableAutoMgr: true

        x: playButton.x + 2 * 95

        onClicked: soundManager.setRandom(checked)
        currentState: soundManager.random ? 0 : 1
    }

    DarkButton {
        id: repeatButton
        inToolbar: true
        anchors.bottom: parent.bottom
        height: Style.toolbar.height
        iconScale: .7
        iconSource: "qrc:/images/repeat"

        checkable: true
        hasSecondIcon: true
        secondIcon: "qrc:/images/repeat_one"

        x: playButton.x - 2 * 95

        disableAutoMgr: true
        onClicked: soundManager.setRepeatMode((currentState + 1) % 3)
        Connections {
            target: soundManager
            onRepeatModeChanged: {
                repeatButton.currentState = soundManager.repeatMode
                repeatButton.updateCheckedState()
            }
        }
    }

    DarkButton {
        id: chooseButton
        inToolbar: true
        anchors.bottom: parent.bottom
        height: Style.toolbar.height
        iconScale: .7
        iconSource: "qrc:/images/music"

        checkable: true
        x: playButton.x - 3.5 * 95

        enabled: soundManager.started

        disableAutoMgr: true
        Component.onCompleted: {
            if(soundManager.isPlayerVisible()) {
                currentState = 0
                updateCheckedState()
                playerVisible = true
            } else {
                currentState = 1
                updateCheckedState()
                playerVisible = false
            }
        }
        onClicked: {
            if(playerVisible) {
                currentState = 1
                checked = true
                playerVisible = false
            } else {
                currentState = 0
                checked = false
                playerVisible = true
            }
        }
    }

    Component.onDestruction: {
        soundManager.setPlayerVisibility(playerVisible)
    }
}