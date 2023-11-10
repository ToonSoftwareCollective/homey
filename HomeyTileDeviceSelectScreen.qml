import QtQuick 2.1
import BasicUIControls 1.0
import qb.components 1.0
import FileIO 1.0

Screen {
	id: homeyScreen
	screenTitle: (app.calledFromTile === 99)? "Homey kies apparaat voor nieuwe tegel " : "Homey kies apparaat voor tegel " + app.calledFromTile
	
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
		getDevices()
	}

	function stringToBoolean(inputString) {
        return (inputString === "true") ? true : false;
    }
	

	Text {
		id: screenTip
		text: "Kies welk apparaat op de tegel moet komen"
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
						id: deviceName
						text: (model.zone + " " + model.devicename + " " + model.capa).substring(0, 50)
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
								devicesTileArray.push({devflow: "device" , id: app.calledFromTile , keycapa: String(model.id + "_" + model.capa), key: model.id ,zone: model.zone, type:model.type, capa:model.capa, capaShort: model.capaShort, devicename: model.devicename, value: model.value, available:model.available , up: model.up, down: model.down, unit: model.unit, flowname: "", mbTop: model.mbTop , mbDown: model.mbDown})
							}else{
								devicesTileArray[app.calledFromTile] = ({devflow: "device" , id: app.calledFromTile , keycapa: String(model.id + "_" + model.capa), key: model.id ,zone: model.zone, type:model.type, capa:model.capa, capaShort: model.capaShort, devicename: model.devicename, value: model.value, available:model.available , up: model.up, down: model.down, unit: model.unit, flowname: "", mbTop: model.mbTop , mbDown: model.mbDown})
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
					
					Text {
						id: switchToggle
						text: "Aan/Uit"
						font.pixelSize:  isNxt? 18:14
						font.family: qfont.bold.name
						color: "black"
						anchors {
							right: startButton.left
							verticalCenter: parent.verticalCenter
							rightMargin: isNxt? 20:16
						}
						visible: (model.available & (model.type2=="toggle"))
					}
					
					Text {
						id: upButton
						text: "3-knops"
						font.pixelSize:  isNxt? 18:14
						font.family: qfont.bold.name
						color: "black"
						anchors {
							right: startButton.left
							verticalCenter: parent.verticalCenter
							rightMargin: isNxt? 20:16
						}
						visible: (model.available & (model.type2=="3 button"))
					}
					
					Text {
						id: mbButton
						text: "motionblind"
						font.pixelSize:  isNxt? 18:14
						font.family: qfont.bold.name
						color: "black"
						anchors {
							right: startButton.left
							verticalCenter: parent.verticalCenter
							rightMargin: isNxt? 20:16
						}
						visible: (model.available & (model.type2=="motionblind"))
					}
				
					
					Text {
						id: deviceValue2
						text: model.available? model.value + " " + model.unit: ""
						font.pixelSize:  isNxt? 18:14
						font.family: qfont.bold.name
						color: "black"
						anchors {
							verticalCenter: parent.verticalCenter
							right: startButton.left
							rightMargin: isNxt? 20:16
						}
						visible: (model.type== "measure")
					}
					
					Rectangle {
						id: alarmIcon
						radius: 10
						width: isNxt? 30:24
						height: isNxt? 30:24
						color: (model.value === "true")? "red":"limegreen"
						anchors {
							verticalCenter: parent.verticalCenter
							right: startButton.left
							rightMargin: isNxt? 20:16
						}
						visible: ((model.type === "alarm" || model.type === "heating"))
					}
					
					Image {
						id: lockImage
						source: (model.value === "true")? "drawables/lock.png": "drawables/unlock.png"
						fillMode: Image.PreserveAspectFit
						width: isNxt? 30:24
						height: isNxt? 30:24
						anchors {
							verticalCenter: parent.verticalCenter
							right: startButton.left
							rightMargin: isNxt? 20:16
						}
						visible: ((model.type === "lock"))
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
        indexes.sort(function (indexA, indexB) { return homeyModel.get(indexA).devicename.localeCompare(homeyModel.get(indexB).devicename)  } );
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

    function getDevices(){
        if (debugOutput) console.log("*********Homey Start getDevices()")
		refreshThrobber.visible = true
        var jwt = app.token
		homeyModel.clear()
		if (debugOutput) console.log("*********Homey Bearer : " + jwt)
        var xhr = new XMLHttpRequest()

		if (app.testurl){
			var url = 'file:///root/homey.txt'
		}else{
			var url = 'https://' + app.cloudid + '.connect.athom.com/api/' + 'manager/devices/device'
		}
        xhr.open("GET", url, true);
        xhr.setRequestHeader( 'authorization', 'Bearer ' + jwt);
        xhr.setRequestHeader( 'content-type', 'application/json');
        xhr.onreadystatechange = function() { // Call a function when the state changes.
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
					if (debugOutput) console.log("*********Homey " + "xhr.status: " + xhr.status)
					//if (debugOutput) console.log("*********Homey " + xhr.responseText)

					var JsonString = xhr.responseText
					var JsonObject= JSON.parse(JsonString)
					var units = ""
					var capabilityLong = ""
					var capabilityShort = ""
					var isAvailable = true
					var capabilityShort = ""
					var number = 0

					for (var key in JsonObject) {
						if (JsonObject.hasOwnProperty(key)) {
							var zoneName = ""
							isAvailable = JsonObject[key].available
							//if (debugOutput) console.log("*********Homey " + key + " - " + JsonObject[key].zoneName + " - " + JsonObject[key].name + " - " + JsonObject[key].capabilities)
							
							for (var capa in JsonObject[key].capabilities){
								capabilityLong = JsonObject[key].capabilities[capa]

								capabilityShort = capabilityLong
								//if (debugOutput) console.log("*********Homey short   " + capabilityShort);
							
								if(JsonObject[key].hasOwnProperty("zoneName") && JsonObject[key].zoneName !== 'undefined' && JsonObject[key].zoneName !== null){
									zoneName = JsonObject[key].zoneName
								}else{
									zoneName = ""
								}
								
								if (JsonObject[key].capabilitiesObj[capabilityLong] !== undefined){
									if(JsonObject[key].capabilitiesObj[capabilityLong].units !== undefined & JsonObject[key].capabilitiesObj[capabilityLong].units !== null){
										units = JsonObject[key].capabilitiesObj[capabilityLong].units
									}else{
										units = ""
									}
								}else{
									units = ""
								}
								
								var downState = false
								var upState = false
								
								if (capabilityLong.indexOf("onoff") > -1 || capabilityLong.indexOf("windowcoverings") > -1){
									if (capabilityLong === "onoff" && capabilityLong.indexOf("windowcoverings") === -1){
										homeyModel.append({number: number,id: key , zone:zoneName , type: "onoff" , capa: capabilityLong , capaShort: capabilityShort , devicename: JsonObject[key].name, type2: "toggle", value:String(String(JsonObject[key].capabilitiesObj[capabilityLong].value)), unit: units, available: isAvailable, up: upState, down: downState, mbDown: 0 ,mbTop:0})
									
									}

									if (capabilityLong.indexOf("windowcoverings_state") > -1 && JsonObject[key].driverId.indexOf("motionblinds") <0){
										var valState = JsonObject[key].capabilitiesObj["windowcoverings_state"].value
										switch (valState) {
											case "up":
												upState = true
												downState = false
												break
											case "idle":
												upState = false
												downState = false
												break
											case "down":
												upState = false
												downState = true
												break
											default:
												upState = false
												downState = false
												break
										}
										homeyModel.append({number: number,id: key , zone:zoneName, type: "window" , capa: capabilityLong , capaShort: capabilityShort , devicename: JsonObject[key].name, type2: "3 button", value: String(JsonObject[key].capabilitiesObj[capabilityLong].value), unit: units, available: isAvailable, up: upState, down: downState, mbDown: 0 ,mbTop:0})
									}

									if (app.motionblinds && JsonObject[key].driverId.indexOf("motionblinds") > -1 && capabilityLong.indexOf("windowcoverings_state") > -1){
										var valStateMain = JsonObject[key].capabilitiesObj[capabilityLong].value
										switch (valStateMain) {
											case "up":
												upState = true
												downState = false
												break
											case "idle":
												upState = false
												downState = false
												break
											case "down":
												upState = false
												downState = true
												break
											default:
												upState = false
												downState = false
												break
										}
										var mbTop = JsonObject[key].capabilitiesObj["windowcoverings_set.top"].value
										var mbDown = JsonObject[key].capabilitiesObj["windowcoverings_set.bottom"].value
										homeyModel.append({number: number,id: key , zone:zoneName, type: "motionblind" , capa: capabilityLong , capaShort: capabilityShort , devicename: JsonObject[key].name, type2: "motionblind", value: String(JsonObject[key].capabilitiesObj[capabilityLong].value), unit: units, available: isAvailable, up: upState, down: downState, mbDown: mbDown ,mbTop:mbTop})
									}

								}

                                if (capabilityLong.indexOf("alarm") > -1){
									if (JsonObject[key].capabilitiesObj[capabilityLong] !== undefined){
										if (JsonObject[key].capabilitiesObj[capabilityLong].value !== null){
											homeyModel.append({number: number,id: key , zone:zoneName, type: "alarm" , capaShort: capabilityShort, capa: capabilityLong, devicename: JsonObject[key].name, value: String(JsonObject[key].capabilitiesObj[capabilityLong].value), unit: units , available: isAvailable, up: upState, down: downState, mbDown: 0 ,mbTop:0})
										}
									}
								}
								
								if (capabilityLong.indexOf("hotWaterState") > -1 || capabilityLong.indexOf("burnerState") > -1){
									if (JsonObject[key].capabilitiesObj[capabilityLong] !== undefined){
										if (JsonObject[key].capabilitiesObj[capabilityLong].value !== null){
											homeyModel.append({number: number,id: key , zone:zoneName, type: "heating" , capaShort: capabilityShort, capa: capabilityLong, devicename: JsonObject[key].name, value: String(JsonObject[key].capabilitiesObj[capabilityLong].value), unit: units , available: isAvailable, up: upState, down: downState, mbDown: 0 ,mbTop:0})
										}
									}
								}
								
								
								if (capabilityLong.indexOf("locked") > -1){
									if (JsonObject[key].capabilitiesObj[capabilityLong] !== undefined){
										if (JsonObject[key].capabilitiesObj[capabilityLong].value !== null){
											homeyModel.append({number: number, id: key , zone:zoneName, type: "lock" , capaShort: capabilityShort , capa: capabilityLong, devicename: JsonObject[key].name, value: String(JsonObject[key].capabilitiesObj[capabilityLong].value), unit: units , available: isAvailable, up: upState, down: downState, mbDown: 0 ,mbTop:0})
										}
									}
								}
									
								if (capabilityLong.indexOf("meter_water") > -1 ||
									capabilityLong.indexOf("measure_water") > -1  ||
									capabilityLong.indexOf("measure_temperature") > -1  ||
									capabilityLong.indexOf("measure_co") > -1   ||
									capabilityLong.indexOf("measure_co2") > -1   ||
									capabilityLong.indexOf("measure_pm25") > -1   ||
									capabilityLong.indexOf("measure_pressure") > -1   ||
									capabilityLong.indexOf("measure_noise") > -1   ||
									capabilityLong.indexOf("measure_rain") > -1   ||
									capabilityLong.indexOf("measure_wind_strength") > -1  ||
									capabilityLong.indexOf("measure_wind_angle") > -1   ||
									capabilityLong.indexOf("measure_battery") > -1   ||
									capabilityLong.indexOf("measure_power") > -1   ||
									capabilityLong.indexOf("measure_voltage") > -1   ||
									capabilityLong.indexOf("measure_current") > -1   ||
									capabilityLong.indexOf("measure_humidity") > -1   ||
									capabilityLong.indexOf("meter_gas") > -1   ||
									capabilityLong.indexOf("measure_luminance") > -1   || 
									capabilityLong.indexOf("meter_rain") > -1   ||
									capabilityLong.indexOf("target_temperature") > -1   ||
									capabilityLong.indexOf("temperature_state") > -1   ||
									capabilityLong.indexOf("programState") > -1   ||
									capabilityLong.indexOf("meter_power") > -1
								){
									homeyModel.append({number: number, id: key , zone:zoneName ,  type: "measure", capaShort: capabilityShort , capa: capabilityLong,  devicename: JsonObject[key].name, value: String(JsonObject[key].capabilitiesObj[capabilityLong].value), unit: units , available: isAvailable, up: upState, down: downState, mbDown: 0 ,mbTop:0})
								}
							}
							number++
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
        xhr.send()
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
