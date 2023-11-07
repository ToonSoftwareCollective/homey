import QtQuick 2.1
import qb.components 1.0


Tile {
	id: homeyTile0
	
	property bool debugOutput : app.debugOutput

	property int tileNR: 0
	
    property string available : app.tilesJSON[tileNR].available
	property string capaShort : app.tilesJSON[tileNR].capaShort
	property string devicename : app.tilesJSON[tileNR].devicename
	property string down : app.tilesJSON[tileNR].down
	property string up : app.tilesJSON[tileNR].up
	property string key : app.tilesJSON[tileNR].key
	property string type : app.tilesJSON[tileNR].type
	property string unit : app.tilesJSON[tileNR].unit
	property string value : app.tilesJSON[tileNR].value
    property string zone : app.tilesJSON[tileNR].zone
	property string devflow : app.tilesJSON[tileNR].devflow
    property string flowname : app.tilesJSON[tileNR].flowname
	
	property bool dimState: screenStateController.dimmedColors

	
	MouseArea {
		anchors.fill: parent
		onClicked: {
			if (app.homeyFavoritesScreen){	
			app.homeyFavoritesScreen.show();
		}
		}
	}

	Component.onCompleted: {
		app.homeyUpdated.connect(updateTile);
	}
	
	onVisibleChanged: {
        if (visible) {
			app.tile0visible = true
			if (debugOutput) console.log("*********Homey app.tile0visible = true")
        }else{
			app.tile0visible = false
			if (debugOutput) console.log("*********Homey app.tile0visible = false")
		}
    }
	
	function stringToBoolean(inputString) {
        return (inputString === "true") ? true : false;
    }
	

	function updateTile() {
		if (debugOutput) console.log("*********Homey Start updateTile()")
		try {
			available = app.tilesJSON[tileNR].available
			capaShort = app.tilesJSON[tileNR].capaShort
			devicename = app.tilesJSON[tileNR].devicename
			down = app.tilesJSON[tileNR].down
			up = app.tilesJSON[tileNR].up
			key = app.tilesJSON[tileNR].key
			type = app.tilesJSON[tileNR].type
			unit = app.tilesJSON[tileNR].unit
			value = app.tilesJSON[tileNR].value
			zone = app.tilesJSON[tileNR].zone
			flowname = app.tilesJSON[tileNR].flowname
			devflow = app.tilesJSON[tileNR].devflow
		} catch(e) {
		}
	}

	Text {
		id: titleText
		text: "Homey"
		anchors {
			baseline: parent.top
			baselineOffset: Math.round(30 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.tileTitle
		}
		color: dimmableColors.tileTitleColor
	}


	Text {
		id: deviceName
		text: (zone + " " + devicename).substring(0, 41)
		font.pixelSize:  isNxt? 22:17
		font.family: qfont.bold.name
		color : dimState?  dimmableColors.clockTileColor : colors.clockTileColor
		anchors {
			top: titleText.bottom
			horizontalCenter: parent.horizontalCenter
		}
		visible: (devflow == "device")
	}
	
	Text {
		id: flowName
		text: (flowname).substring(0, 41)
		font.pixelSize:  isNxt? 22:17
		font.family: qfont.bold.name
		color : dimState?  dimmableColors.clockTileColor : colors.clockTileColor
		anchors {
			top: titleText.bottom
			horizontalCenter: parent.horizontalCenter
		}
		visible: (devflow == "flow")
	}
	
	Text {
		id: deviceName2
		text: (type !== "measure")? "":(capaShort).substring(0, 41)
		font.pixelSize:  isNxt? 18:14
		font.family: qfont.bold.name
		color : dimState?  dimmableColors.clockTileColor : colors.clockTileColor
		anchors {
			top: deviceName.bottom
			horizontalCenter: parent.horizontalCenter
		}
	}
	
	Text {
		id: deviceValue
		text: available? value + " " + unit: ""
		font.pixelSize:  isNxt? 40:32
		font.family: qfont.bold.name
		color : dimState?  dimmableColors.clockTileColor : colors.clockTileColor
		anchors {
			top: deviceName2.bottom
			horizontalCenter: parent.horizontalCenter
		}
		visible: (type === "measure" && devflow == "device")
	}
	
	Rectangle {
		id: alarmIcon
		radius: 10
		width: isNxt? 50:40
		height: isNxt? 50:40
		color: (value === "true")? "red":"limegreen"
		anchors {
			top: deviceName2.bottom
			horizontalCenter: parent.horizontalCenter
		}
		visible: ((type === "alarm" || type === "heating") && devflow == "device")
	}
	
	Image {
		id: lockImage
		source:   dimState? (value === "true")? "drawables/lock_60_white.png": "drawables/unlock_60_white.png" : (value === "true")? "drawables/lock_60_black.png": "drawables/unlock_60_black.png"
		fillMode: Image.PreserveAspectFit
		width: isNxt? 50:40
		height: isNxt? 50:40
		anchors {
			top: deviceName2.bottom
			horizontalCenter: parent.horizontalCenter
		}
		visible: ((type === "lock") && devflow == "device")
	}
	
	Rectangle {
		id: backRectangle
		radius: 10
		width: isNxt? 140:112
		height: isNxt? 100:80
		color: "transparent"
		anchors {
			top: deviceName2.bottom
			horizontalCenter: parent.horizontalCenter
			topMargin: -25
		}
		MouseArea {
			anchors.fill: parent
			onClicked: {
			}
		}
		visible: switchToggle.visible
	}
	
	OnOffToggle {
		id: switchToggle
		height: isNxt? 50:40
		
		sliderWidth: 100
		sliderHeight: 50
		knobWidth: sliderHeight*0.8
	
		anchors {
			top: deviceName2.bottom
			horizontalCenter: parent.horizontalCenter
		}
		isSwitchedOn: stringToBoolean(value)
		onSelectedChangedByUser: {
			if (isSwitchedOn) {
				app.setState("onoff", key, true)
			} else {
				app.setState("onoff",key, false)
			}
		}
		visible: ((type=="onoff") && devflow == "device")
	}
	
	IconButton {
		id: stopButton
		height: isNxt? 50:40
		overlayColorUp: "red"
		overlayWhenUp:(!up && !down)
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: deviceName2.bottom
		}
		iconSource: "qrc:/tsc/stop.png"
		onClicked: {
			app.setState("windowcoverings_state",key, "idle")
		}
		visible: ((type=="window") && devflow == "device")
	}
	
	IconButton {
		id: upButton
		height: isNxt? 50:40
		overlayColorUp: "red"
		overlayWhenUp: up
		anchors {
			left: stopButton.right
			top: deviceName2.bottom
			leftMargin: isNxt? 10:8
		}
		iconSource: "qrc:/tsc/up.png"
		onClicked: {
			app.setState("windowcoverings_state",key, "up")
		}
		visible: ((type=="window") && devflow == "device")
	}

	IconButton {
		id: downButton
		height: isNxt? 50:40
		overlayColorUp: "red"
		overlayWhenUp: down
		anchors {
			right:stopButton.left
			top: deviceName2.bottom
			rightMargin: isNxt? 10:8
		}
		iconSource: "qrc:/tsc/down.png"
		onClicked: {
			app.setState("windowcoverings_state",key, "down")
		}
		visible: ((type=="window") && devflow == "device")
	}
	

	StandardButton {
		id: startButton
		text: "Start"
		height: isNxt? 80:64
		anchors {
			top: deviceName2.bottom
			horizontalCenter: parent.horizontalCenter
		}
		onClicked: {
			app.tiggerflow(key)
		}
		visible: (available && devflow == "flow")
	}
}

