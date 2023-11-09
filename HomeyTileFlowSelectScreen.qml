import QtQuick 2.1
import BasicUIControls 1.0
import qb.components 1.0
import FileIO 1.0

Screen {
	id: homeyTileFlowSelectScreen
	screenTitle: (app.calledFromTile === 99)? "Homey kies flow voor nieuwe tegel " : "Homey kies flow voor tegel " + app.calledFromTile
	
	property bool debugOutput : app.debugOutput
	
	property variant devicesTileArray : []
	property bool starting : true
	property string settingsTileString : ""

	FileIO {
		id: homeySettingsTileFile2
		source: "file:////mnt/data/tsc/appData/homey.tilesjsoncopy.json"
 	}

	
	function readSettings() {
		if (debugOutput) console.log("*********homey readSettings()")
		try {
			settingsTileString = String(homeySettingsTileFile2.read());
			devicesTileArray = JSON.parse(settingsTileString)
			if (debugOutput) console.log("*********homey JSON.stringify(devicesTileArray): " + JSON.stringify(devicesTileArray))
		} catch(e) {
		}
    }
	
	onShown: {
		readyTextRectangle.visible = false
		readSettings()
		getflows()
	}

	function stringToBoolean(inputString) {
        return (inputString === "true") ? true : false;
    }
	

	Text {
		id: screenTip
		text: "Kies flow op de tegel moet komen"
		font.pixelSize:  isNxt? 20:16
		font.family: qfont.bold.name
		color: "black"
		anchors {
			left: parent.left
			leftMargin: isNxt? 10:8
			bottom: frame1.top
			bottomMargin: 5
		}
	}
	
   Rectangle {
		id: frame1
		width: isNxt? (parent.width )-15: (parent.width )-12
		height: isNxt? parent.height - 85 :parent.height - 40
		border.color : "black"
		border.width : 3

		anchors {
			top: parent.top
			left: parent.left
			leftMargin: isNxt? 10:8
			topMargin: isNxt? 50:40
		}

		ListModel {
			id: homeyModel
		}

		GridView {
			id: homeyGrid
			height: isNxt? frame1.height-80 : frame1.height-64
			width: isNxt? frame1.width-10 : frame1.width-8
			cellWidth: isNxt? parent.width -10 : parent.width -8
			cellHeight: isNxt? 40:32
			
			anchors {
				top: parent.top
				left: parent.left
				leftMargin: isNxt? 10:8
				topMargin: isNxt? 50:40
			}

			model: homeyModel
			
			delegate: 
				Rectangle {
					width: isNxt? parent.width -10 : parent.width -8
					height: isNxt? 35:28
					color: model.available?  "#F0F0F0":"navajowhite"
					Text {
						id: flowName
						text: (model.flowname).substring(0, 35)
						font.pixelSize:  isNxt? 18:14
						font.family: qfont.bold.name
						color: "black"
						anchors {
							verticalCenter: parent.verticalCenter
						}
					}
					
					StandardButton {
						id: startButton
						text: "Kies"
						height: isNxt? 35:28
						anchors {
							right: parent.right
							verticalCenter: parent.verticalCenter
							rightMargin: isNxt? 10:8
						}
						onClicked: {
							refreshThrobber.visible = true
							if (debugOutput) console.log("*********homey JSON.stringify(devicesTileArray): " + JSON.stringify(devicesTileArray))
							if (app.calledFromTile === 99){
								devicesTileArray.push({devflow: "flow" , id: app.calledFromTile , keycapa: "", key: model.id ,zone: model.zone, type:"", capa:"", capaShort: "", devicename: "", value: "", available:model.available , up: false, down: false, unit: "", flowname: model.flowname, mbDown: 0 ,mbTop:0})
							}else{
								devicesTileArray[app.calledFromTile] = ({devflow: "flow" , id: app.calledFromTile , keycapa: "", key: model.id ,zone: "", type:"", capa:"", capaShort: "", devicename: "", value: "", available:model.available , up: false, down: false, unit: "", flowname: model.flowname, mbDown: 0 ,mbTop:0})
							}
							if (debugOutput) console.log("*********homey JSON.stringify(devicesTileArray): " + JSON.stringify(devicesTileArray))
							homeySettingsTileFile2.write(JSON.stringify(devicesTileArray));
							app.refreshTiles()
							if (debugOutput) console.log("*********homey saveSettings() file saved")
							readyText.text = "Opgeslagen"
							readyTextRectangle.visible = true
							throbberTimer.running = true
						}
					}
				}	
        }
	}


	Throbber {
		id: refreshThrobber
		width: Math.round(100 * horizontalScaling)
		height: Math.round(100 * verticalScaling)
		anchors {
			verticalCenter: parent.verticalCenter
			horizontalCenter: parent.horizontalCenter
		}
		visible: false
	}
	


	Rectangle {
		id: readyTextRectangle
		width: readyText.width + 20
		height: isNxt? 35:28
		color: "white"
		anchors {
			top: refreshThrobber.bottom
			topMargin: isNxt? 20:16
			horizontalCenter: parent.horizontalCenter
		}
		Text {
			id: readyText
			text: "opgeslagen"
			font.pixelSize:  isNxt? 32:26
			font.family: qfont.bold.name
			color: "black"
			anchors {
			   centerIn: parent
			   verticalCenter: parent.verticalCenter
			}
		}
	}

	function listModelSort1() {
        var indexes = new Array(homeyModel.count);
        for (var i = 0; i < homeyModel.count; i++) indexes[i] = i;
        indexes.sort(function (indexA, indexB) { return homeyModel.get(indexA).flowname.localeCompare(homeyModel.get(indexB).flowname)  } );
        var sorted = 0;
        while (sorted < indexes.length && sorted === indexes[sorted]) sorted++;
        if (sorted === indexes.length) return;
        for (i = sorted; i < indexes.length; i++) {
            var idx = indexes[i];
            homeyModel.move(idx, homeyModel.count - 1, 1);
            homeyModel.insert(idx, { } );
        }
        homeyModel.remove(sorted, indexes.length - sorted);
    }



    function getflows(){
        if (debugOutput) console.log("*********Homey Start getflows()")
		refreshThrobber.visible = true
		var jwt = app.token
		homeyModel.clear()
		if (debugOutput) console.log("*********Homey Bearer : " + jwt)
        var xhr = new XMLHttpRequest()
        var url = 'https://' + app.cloudid + '.connect.athom.com/api/' + 'manager/flow/flow'
        xhr.open("GET", url, true);
        xhr.setRequestHeader( 'authorization', 'Bearer ' + jwt);
        xhr.setRequestHeader( 'content-type', 'application/json');
        xhr.onreadystatechange = function() { // Call a function when the state changes.
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
					if (debugOutput) console.log("*********Homey " + "xhr.status: " + xhr.status)
//					if (debugOutput) console.log("*********Homey " + xhr.responseText)

					var JsonString = xhr.responseText
					var JsonObject= JSON.parse(JsonString)

					for (var key in JsonObject) {
						if (JsonObject.hasOwnProperty(key)) {							
							homeyModel.append({id: key , flowname: JsonObject[key].name, available: JsonObject[key].enabled})
						}
					}
					listModelSort1()
					smallDelayTimer.running=true
                } else {
					if (debugOutput) console.log("*********Homey xhr.status: " + xhr.status)
                    if (debugOutput) console.log("*********Homey " + xhr.responseText)
					refreshThrobber.visible = false
					if (debugOutput) console.log("*********Homey getting new Token")
					app.getNewToken()
                }
            }
        }
        xhr.send();
    }

	Timer{
		id: throbberTimer
		interval: 2000
		triggeredOnStart: false
		running: false
		repeat: false
		onTriggered:
		{
			refreshThrobber.visible = false
			readyText.visible = false
			hide()
		}
	}
	
	Timer{
		id: smallDelayTimer
		interval: 1000
		triggeredOnStart: false
		running: false
		repeat: false
		onTriggered:
		{
			starting = false
			refreshThrobber.visible = false
		}
	}
}
