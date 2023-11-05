import QtQuick 2.1
import qb.components 1.0


Tile {
	id: homeyTile4
	
	property bool debugOutput : app.debugOutput
	property int tileNR: 3
	
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
			app.tile4visible = true
			if (debugOutput) console.log("*********Homey app.tile4visible = true")
        }else{
			app.tile4visible = false
			if (debugOutput) console.log("*********Homey app.tile4visible = false")
		}
    }
	
	function stringToBoolean(inputString) {
        return (inputString === "true") ? true : false;
    }


	
	function updateTile() {
		if (debugOutput) console.log("*********Homey Start updateTile()")
		if( app.tilesJSON){
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
		color: "black"
		anchors {
			top: titleText.bottom
			horizontalCenter: parent.horizontalCenter
		}
	}
	
	Text {
		id: deviceName2
		text: (type !== "measure")? "":(capaShort).substring(0, 41)
		font.pixelSize:  isNxt? 18:14
		font.family: qfont.bold.name
		color: "black"
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
		color: "black"
		anchors {
			top: deviceName2.bottom
			horizontalCenter: parent.horizontalCenter
		}
		visible: (type === "measure")
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
		visible: ((type === "alarm" || type === "heating"))
	}
	
	Image {
		id: lockImage
		source: (value === "true")? "drawables/lock.png": "drawables/unlock.png"
		fillMode: Image.PreserveAspectFit
		width: isNxt? 50:40
		height: isNxt? 50:40
		anchors {
			top: deviceName2.bottom
			horizontalCenter: parent.horizontalCenter
		}
		visible: ((type === "lock"))
	}
	
	OnOffToggle {
		id: switchToggle
		height: isNxt? 50:40
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
		visible: ((type=="onoff"))
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
		visible: ((type=="window"))
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
		visible: ((type=="window"))
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
		visible: ((type=="window"))
	}
}
