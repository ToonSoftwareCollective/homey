import QtQuick 2.1
import BasicUIControls 1.0
import qb.components 1.0
import FileIO 1.0

Screen {
	id: homeyTilesSelectScreen

	screenTitle: "Homey tegels"
	hasCancelButton: true
	
	property bool debugOutput : app.debugOutput
	property variant devicesTileArray : []
	property int tileNumber : 0
	property string settingsTileString : ""
	
	FileIO {
		id: appFile;	
		source: "file:///HCBv2/qml/apps/homey/HomeyApp.qml"
	}
	
	FileIO {
		id: generalTileFile;	
		source: "file:///HCBv2/qml/apps/homey/HomeyGeneralTile.qml"
	}

	FileIO {
		id: homeySettingsTileFile
		source: "file:////mnt/data/tsc/appData/homey.tilesjson.json"
 	}
	
	FileIO {
		id: homeySettingsTileFile2
		source: "file:////mnt/data/tsc/appData/homey.tilesjsoncopy.json"
 	}
	
	function showPopup() {
		qdialog.showDialog(qdialog.SizeLarge, qsTr("Informatie"), qsTr("In dit scherm kun je maximaal " + app.maxTiles + " tegels aanmaken. Kies per tegel voor een flow of voor een apparaat. Na te hebben gekozen klik je vervolgens op Opslaan en herstarten. Na het herstarten zijn de tegels beschikbaar om te installeren op een lege tegel.") , qsTr("Sluiten"));
	}
	

	function readSettings() {
		if (debugOutput) console.log("*********homey readSettings()")
		try {
			var settingsTileString = String(homeySettingsTileFile2.read());
			if (debugOutput) console.log("*********Homey settingsTileString" + settingsTileString)
			devicesTileArray = JSON.parse(settingsTileString)
			
			for(var i in devicesTileArray){
				if (debugOutput) console.log("*********Homey devicesTileArray[i]" + devicesTileArray[i])
				 homeyModel.append(devicesTileArray[i])
			}
			refreshThrobber.visible = false
		} catch(e) {
		}
    }
	
	function copySettings() {
		if (debugOutput) console.log("*********homey copySettings()")
		try {
			var settingsTileStringOrginal = String(homeySettingsTileFile.read())
			homeySettingsTileFile2.write(settingsTileStringOrginal)
			app.tileSettingsCopied = true
		} catch(e) {
		}
    }
	
	
	onCustomButtonClicked:{
		saveSettings()
	}
	
	onCanceled:{
		if (debugOutput) console.log("*********homey tile set cancelled")
		app.tileSettingsCopied = false
	}

	onShown: {
	    addCustomTopRightButton("Opslaan en herstarten")
		readyTextRectangle.visible = false
		refreshThrobber.visible = true
		homeyModel.clear()
		if (!app.tileSettingsCopied){
			copySettings()
		}
		readSettings()
	}
	
	StandardButton {
		id: infoButton
		text: "?"
		height: isNxt? 40:32
		anchors {
			right: parent.right
			rightMargin: isNxt? 25:20
			bottom: frame1.top
			bottomMargin: isNxt? 10:8
		}
		onClicked: {
			showPopup();
		}
	}
	
	Rectangle {
		id: frame1
		width: isNxt? (parent.width)-15: (parent.width)-12
		height: isNxt? parent.height - 50:parent.height - 40
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
					color: "#F0F0F0"
					
					StandardButton {
						id: minusButton
						text: "-"
						height: isNxt? 35:28
						anchors {
							verticalCenter: parent.verticalCenter
						}
						onClicked: {
							app.calledFromTile = model.id
							devicesTileArray[index] = ({devflow: "leeg" , id: app.calledFromTile , keycapa: "", key: "" ,zone: "", type:"", capa:"", capaShort: "", devicename: "Niet in gebruik", value: "", available:false , up: false, down: false, unit: "", flowname: "", mbDown: 0 ,mbTop:0})
							if (debugOutput) console.log("*********homey JSON.stringify(devicesTileArray): " + JSON.stringify(devicesTileArray))
							homeySettingsTileFile2.write(JSON.stringify(devicesTileArray));
							app.refreshTiles()
							if (debugOutput) console.log("*********homey saveSettings() file saved")
							homeyModel.clear()
							readSettings()
							readyText.text = "Opgeslagen"
							readyText.visible = true
							throbberTimer.running = true
						}
					}
								
					Text {
						id: deviceNR
						text: index
						font.pixelSize:  isNxt? 18:14
						font.family: qfont.bold.name
						color: "black"
						anchors {
							left: minusButton.right
							verticalCenter: parent.verticalCenter
							leftMargin: isNxt? 18:14
						}
					}
					
					Text {
						id: typeName
						text: (model.devflow === "device")? "dev" : (model.devflow === "flow")? "flow" : " "
						font.pixelSize:  isNxt? 18:14
						font.family: qfont.bold.name
						color: "black"
						anchors {
							left: deviceNR.right
							leftMargin : isNxt? 18:14
							verticalCenter: parent.verticalCenter
						}
					}
					
					
					Text {
						id: deviceName
						text: (model.zone + " " + model.devicename + " " + model.capa).substring(0, 50)
						font.pixelSize:  isNxt? 18:14
						font.family: qfont.bold.name
						color: "black"
						anchors {
							left: deviceNR.right
							leftMargin : isNxt? 80:64
							verticalCenter: parent.verticalCenter
						}
						visible: (model.devflow === "device")
					}


					Text {
						id: flowName
						text: (model.devflow === "flow")? (model.flowname).substring(0, 50): ""
						font.pixelSize:  isNxt? 18:14
						font.family: qfont.bold.name
						color: "black"
						anchors {
							left: deviceNR.right
							leftMargin : isNxt? 80:64
							verticalCenter: parent.verticalCenter
						}
						visible: (model.devflow === "flow")
					}
					
					Text {
						id: emptyName
						text: (model.zone + " " + model.devicename + " " + model.capa).substring(0, 50)
						font.pixelSize:  isNxt? 18:14
						font.family: qfont.bold.name
						color: "black"
						anchors {
							left: deviceNR.right
							leftMargin : isNxt? 80:64
							verticalCenter: parent.verticalCenter
						}
						visible: (model.devflow === "leeg")
					}
					
					
					StandardButton {
						id: selectButton
						text: "Kies Apparaat"
						height: isNxt? 35:28
						anchors {
							right: parent.right
							verticalCenter: parent.verticalCenter
							rightMargin: isNxt? 10:8
						}
						onClicked: {
							app.calledFromTile = index
							if (app.homeyTileDeviceSelectScreen){	
								app.homeyTileDeviceSelectScreen.show();
							}
						}
					}
					
					StandardButton {
						id: selectButton2
						text: "Kies Flow"
						height: isNxt? 35:28
						anchors {
							right: selectButton.left
							verticalCenter: parent.verticalCenter
							rightMargin: isNxt? 10:8
						}
						onClicked: {
							app.calledFromTile = index
							if (app.homeyTileFlowSelectScreen){	
								app.homeyTileFlowSelectScreen.show();
							}
						}
					}

				}
		}
	}
	
	StandardButton {
		id: addDeviceButton
		text: "Nieuwe apparaat tegel"
		height: isNxt? 45:36
		anchors {
			left: parent.left
			leftMargin: isNxt? 10:8
			bottom: frame1.top
			bottomMargin: 5
		}
		onClicked: {
			app.calledFromTile = 99		
			if (app.homeyTileDeviceSelectScreen){	
				app.homeyTileDeviceSelectScreen.show();
			}
		}
		visible: (devicesTileArray.length<app.maxTiles)
	}
	
	StandardButton {
		id: addFlowButton
		text: "Nieuwe flow tegel"
		height: isNxt? 45:36
		anchors {
			left: addDeviceButton.right
			leftMargin: isNxt? 10:8
			bottom: frame1.top
			bottomMargin: 5
		}
		onClicked: {
			app.calledFromTile = 99		
			if (app.homeyTileFlowSelectScreen){	
				app.homeyTileFlowSelectScreen.show();
			}
		}
		visible: (devicesTileArray.length<app.maxTiles)
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
	
	Timer {
		id: rebootTimer
		interval: 5000
		repeat:false
		running: false
		triggeredOnStart: false
		onTriggered: {
			Qt.quit()
			app.sleep(200)
			Qt.quit()
			app.sleep(200)
			Qt.quit()
		}
    }
	
	function saveSettings() {
		if (debugOutput) console.log("*********homey saveDeviceSettings()")
		refreshThrobber.visible = true
		var settingsTileStringCopy = String(homeySettingsTileFile2.read())
		homeySettingsTileFile.write(settingsTileStringCopy)
		app.tileSettingsCopied = false
		app.refreshTiles()
		app.createTilesFromManualInput(devicesTileArray)
		readyText.text = "Opgeslagen, herstart nodig" + "..." 
		readyTextRectangle.visible = true
		rebootTimer.running = true
	}
}
