import QtQuick 2.1
import qb.components 1.0


Tile {
	id: homeyTile6
	
	property bool debugOutput : app.debugOutput

	property int tileNR: 6
	
    property string available : app.tilesJSON[tileNR].available
	property string capaShort : app.tilesJSON[tileNR].capaShort
	property string devicename : app.tilesJSON[tileNR].devicename
	property bool 	down : app.tilesJSON[tileNR].down
	property bool 	up : app.tilesJSON[tileNR].up
	property string key : app.tilesJSON[tileNR].key
	property string type : app.tilesJSON[tileNR].type
	property string unit : app.tilesJSON[tileNR].unit
	property string value : app.tilesJSON[tileNR].value
    property string zone : app.tilesJSON[tileNR].zone
	property string devflow : app.tilesJSON[tileNR].devflow
    property string flowname : app.tilesJSON[tileNR].flowname
	property real mbTop : app.tilesJSON[tileNR].mbTop
    property real mbBottom : app.tilesJSON[tileNR].mbDown
	
	property bool dimState: screenStateController.dimmedColors


	onClicked: {
		if (app.homeyFavoritesScreen){	
			app.homeyFavoritesScreen.show();
		}
	}


	Component.onCompleted: {
		app.homeyUpdated.connect(updateTile);
	}
	
	onVisibleChanged: {
        if (visible) {
			app.tile6visible = true
			if (debugOutput) console.log("*********Homey app.tile6visible = true")
        }else{
			app.tile6visible = false
			if (debugOutput) console.log("*********Homey app.tile6visible = false")
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
			mbTop = app.tilesJSON[tileNR].mbTop
			mbBottom = app.tilesJSON[tileNR].mbDown
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
		text: (type !== "measure")? "":(capaShort.replace(/measure_|meter_/g, "")).substring(0, 41)
		font.pixelSize:  isNxt? 18:14
		font.family: qfont.bold.name
		color : dimState?  dimmableColors.clockTileColor : colors.clockTileColor
		anchors {
			top: deviceName.bottom
			horizontalCenter: parent.horizontalCenter
		}
	}

/////////MEASURE AND METER/////////////////////////////////////////	
	
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

/////////ALARM/////////////////////////////////////////	
	
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
	
/////////LOCK/////////////////////////////////////////	
	
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


/////////ON OFF TOGGLE/////////////////////////////////////////	

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

/////////SCREENS/////////////////////////////////////////	
	
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

/////////FLOW/////////////////////////////////////////		

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
	
/////////MOTION BLINDS/////////////////////////////////////////	
	
	Rectangle {
		id: backRectangleMB
		radius: isNxt? 30:24
		width: isNxt? 250:200
		height: isNxt? 120:96
		color: "transparent"
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: deviceName.bottom
		}
		MouseArea {
			anchors.fill: parent
			onClicked: {
			}
		}
		visible: (type === "motionblind" && devflow == "device")
	}
	
	
	Text {
		id: topText
		text: available? mbTop*100 + " %" : ""
		font.pixelSize:  isNxt? 20:16
		font.family: qfont.bold.name
		color : dimState?  dimmableColors.clockTileColor : colors.clockTileColor
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: deviceName.bottom
			topMargin: isNxt? 6:5
		}
		visible: (type === "motionblind" && devflow == "device")
	}
	
	IconButton {
		id: upButtonTop
		height: isNxt? 30:24
		overlayColorUp: "red"
		overlayWhenUp: up
		anchors {
			right:upButtonMB.left
			rightMargin: 10
			top: deviceName.bottom
			topMargin: isNxt? 6:5
		}
		iconSource: "qrc:/tsc/up.png"
		onClicked: {
			app.setState("windowcoverings_set.top",key, (mbTop + 0.10))
		}
		visible: ((type=="motionblind") && devflow == "device")
	}

	IconButton {
		id: downButtonTop
		height: isNxt? 30:24
		overlayColorUp: "red"
		overlayWhenUp: down
		anchors {
			left:downButtonMB.right
			leftMargin: 10
			top: deviceName.bottom
			topMargin: isNxt? 6:5
		}
		iconSource: "qrc:/tsc/down.png"
		onClicked: {
			app.setState("windowcoverings_set.top",key, (mbTop - 0.10))
		}
		visible: ((type=="motionblind") && devflow == "device")
	}
	
	IconButton {
		id: stopButtonMB
		height: isNxt? 30:24
		overlayColorUp: "red"
		overlayWhenUp:(!up && !down)
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: downButtonTop.bottom
			topMargin: isNxt? 6:5
		}
		iconSource: "qrc:/tsc/stop.png"
		onClicked: {
			app.setState("windowcoverings_state",key, "idle")
		}
		visible: ((type=="motionblind") && devflow == "device")
	}
	
	IconButton {
		id: upButtonMB
		height: isNxt? 30:24
		overlayColorUp: "red"
		overlayWhenUp: up
		anchors {
			left: stopButtonMB.right
			top: downButtonTop.bottom
			leftMargin: isNxt? 60:48
			topMargin: isNxt? 6:5
		}
		iconSource: "qrc:/tsc/up.png"
		onClicked: {
			app.setState("windowcoverings_state",key, "up")
		}
		visible: ((type=="motionblind") && devflow == "device")
	}

	IconButton {
		id: downButtonMB
		height: isNxt? 30:24
		overlayColorUp: "red"
		overlayWhenUp: down
		anchors {
			right:stopButtonMB.left
			top: downButtonTop.bottom
			topMargin: isNxt? 6:5
			rightMargin: isNxt?  60:48
		}
		iconSource: "qrc:/tsc/down.png"
		onClicked: {
			app.setState("windowcoverings_state",key, "down")
		}
		visible: ((type=="motionblind") && devflow == "device")
	}
	
	

	Text {
		id: bottomText
		text: available? mbBottom*100 + " %" : ""
		font.pixelSize:  isNxt? 20:16
		font.family: qfont.bold.name
		color : dimState?  dimmableColors.clockTileColor : colors.clockTileColor
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: downButtonMB.bottom
			topMargin: isNxt? 6:5
		}
		visible: (type === "motionblind" && devflow == "device")
	}
	
	IconButton {
		id: upButtonBottom
		height: isNxt? 30:24
		overlayColorUp: "red"
		overlayWhenUp: up
		anchors {
			right:upButtonMB.left
			rightMargin: 10
			top: downButtonMB.bottom
			topMargin: isNxt? 6:5
		}
		iconSource: "qrc:/tsc/up.png"
		onClicked: {
			app.setState("windowcoverings_set.bottom",key, (mbBottom + 0.10))
		}
		visible: ((type=="motionblind") && devflow == "device")
	}

	IconButton {
		id: downButtonBottom
		height: isNxt? 30:24
		overlayColorUp: "red"
		overlayWhenUp: down
		anchors {
			left:downButtonMB.right
			leftMargin: 10
			top: downButtonMB.bottom
			topMargin: isNxt? 6:5
		}
		iconSource: "qrc:/tsc/down.png"
		onClicked: {
			app.setState("windowcoverings_set.bottom",key, (mbBottom - 0.10))
		}
		visible: ((type=="motionblind") && devflow == "device")
	}
		
}

