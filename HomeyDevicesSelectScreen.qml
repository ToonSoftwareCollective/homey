import QtQuick 2.1
import BasicUIControls 1.0
import qb.components 1.0
import FileIO 1.0

Screen {
	id: homeyScreen
	screenTitle: "Homey kies apparaten"
	
	property bool debugOutput : app.debugOutput
	property int getDevicesInterval :5000
	property string settingsString : ""
	property string settingsFavString : ""
	
	property variant devicesArray : []
	property variant devicesFavArray : []
	
	
	FileIO {
		id: homeySettingsFile
		source: "file:////mnt/data/tsc/appData/homey.devices.json"
 	}
	
	FileIO {
		id: homeySettingsFavFile
		source: "file:////mnt/data/tsc/appData/homey.favorites.json"
 	}
	
	onCustomButtonClicked:{
		saveSettings()
	}
	
	Component.onCompleted: {
		app.clearModels.connect(clearModel);
	}

	function clearModel() {
		homeyModel.clear()
	}
	
	function readSettings() {
		if (debugOutput) console.log("*********homey readSettings()")
		try {
			settingsString = String(homeySettingsFile.read());
		} catch(e) {
		}
		try {
			settingsFavString = String(homeySettingsFavFile.read());
		} catch(e) {
		}
    }
	
	function sleep(milliseconds) {
		var start = new Date().getTime();
		while ((new Date().getTime() - start) < milliseconds )  {
		}
    }
	
	onShown: {
		readyText.visible = false
		readSettings()
		refreshThrobber.visible = true
		sleep(500)
		addCustomTopRightButton("Opslaan");
		getDevices()
	}
	

	function stringToBoolean(inputString) {
        return (inputString === "true") ? true : false;
    }
	

	Text {
		id: screenTip
		text: "Geef in dit scherm aan welke apparaten favoriet zijn en welke zichtbaar moeten zijn."
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
	
	Text {
		id: visibleName
		text: "Zichtbaar"
		font.pixelSize:  isNxt? 18:14
		font.family: qfont.bold.name
		color: "black"
		anchors {
			right: parent.right
			rightMargin: isNxt? 10:8
			top: parent.top
			topMargin: 0
		}
	}
	
	StandardCheckBox {
		id: checkBoxAllDev
		height: isNxt? 40:32
		width: isNxt? 40:32
		anchors {
			right: frame1.right
			rightMargin: isNxt? 25:20
			top: visibleName.bottom
		}
		backgroundColor: colors.graphCheckboxTextBackground
		squareBackgroundColor:  "#FFFFFF"
		squareSelectedColor: colors.graphCheckboxSquare
		squareUnselectedColor: squareSelectedColor
		fontColorSelected: colors.cbText
		squareRadius: isNxt? 18:14
		smallSquareRadius: isNxt? 16:13
		squareOffset: 0
		spacing: Math.round(3 * horizontalScaling)
		leftMargin: Math.round(1 * horizontalScaling)
		rightMargin: 0
		checkMarkStartXOffset: isNxt? 3:3
		checkMarkStartYOffset: isNxt? 6:5
		fontFamilySelected: qfont.regular.name
		fontPixelSize: isNxt? 60:48
		topClickMargin: isNxt? 10:8
		bottomClickMargin: isNxt? 10:8
		selected : false
		onSelectedChanged: { 
			if (selected) {
				for (var i = 0; i < homeyModel.count; i++) {
					var item = homeyModel.get(i);
					homeyModel.setProperty(i, "checked", true)
				}
			} else {
				for (var i = 0; i < homeyModel.count; i++) {
					var item = homeyModel.get(i);
					homeyModel.setProperty(i, "checked", false)
				}
			}
		}
	}
	
	Text {
		id: favName
		text: "Favoriet"
		font.pixelSize:  isNxt? 18:14
		font.family: qfont.bold.name
		color: "black"
		anchors {
			right: visibleName.left
			rightMargin: isNxt? 10:8
			top: parent.top
			topMargin: 0
		}
	}
	
	StandardCheckBox {
		id: checkBoxAllFav
		height: isNxt? 40:32
		width: isNxt? 40:32
		anchors {
			right: checkBoxAllDev.left
			rightMargin: isNxt? 30:24
			top: favName.bottom
		}
		backgroundColor: colors.graphCheckboxTextBackground
		squareBackgroundColor:  "#FFFFFF"
		squareSelectedColor: colors.graphCheckboxSquare
		squareUnselectedColor: squareSelectedColor
		fontColorSelected: colors.cbText
		squareRadius: isNxt? 18:14
		smallSquareRadius: isNxt? 16:13
		squareOffset: 0
		spacing: Math.round(3 * horizontalScaling)
		leftMargin: Math.round(1 * horizontalScaling)
		rightMargin: 0
		checkMarkStartXOffset: isNxt? 3:3
		checkMarkStartYOffset: isNxt? 6:5
		fontFamilySelected: qfont.regular.name
		fontPixelSize: isNxt? 60:48
		topClickMargin: isNxt? 10:8
		bottomClickMargin: isNxt? 10:8
		selected : false
		onSelectedChanged: { 
			if (selected) {
				for (var i = 0; i < homeyModel.count; i++) {
					var item = homeyModel.get(i);
					homeyModel.setProperty(i, "checkedfav", true)
				}
			} else {
				for (var i = 0; i < homeyModel.count; i++) {
					var item = homeyModel.get(i);
					homeyModel.setProperty(i, "checkedfav", false)
				}
			}
		}
	}
	

   Rectangle {
		id: frame1
		width: isNxt? (parent.width )-15: (parent.width )-12
		height: isNxt? parent.height - 85 :parent.height - 40
		border.color : "black"
		border.width : 3

		anchors {
			top: checkBoxAllDev.bottom
			left: parent.left
			leftMargin: isNxt? 10:8
			topMargin: isNxt? 10:8
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
					
					StandardCheckBox {
						id: checkBox
						height: isNxt? 40:32
						width: isNxt? 40:32
						anchors {
							right: parent.right
							rightMargin: isNxt? 10:8
						}
						backgroundColor: colors.graphCheckboxTextBackground
						squareBackgroundColor:  "#FFFFFF"
						squareSelectedColor: colors.graphCheckboxSquare
						squareUnselectedColor: squareSelectedColor
						fontColorSelected: colors.cbText
						squareRadius: isNxt? 18:14
						smallSquareRadius: isNxt? 16:13
						squareOffset: 0
						spacing: Math.round(3 * horizontalScaling)
						leftMargin: Math.round(1 * horizontalScaling)
						rightMargin: 0
						checkMarkStartXOffset: isNxt? 3:3
						checkMarkStartYOffset: isNxt? 6:5
						fontFamilySelected: qfont.regular.name
						fontPixelSize: isNxt? 60:48
						topClickMargin: isNxt? 10:8
						bottomClickMargin: isNxt? 10:8
						selected : model.checked
						onSelectedChanged: {
							if (selected) {
								model.checked = true
								if (debugOutput) console.log("*********Homey homeyModel checked : " + model.checked)
							} else {
								model.checked = false
								if (debugOutput) console.log("*********Homey homeyModel checked : " + model.checked)
							}
						}
					}
					
					StandardCheckBox {
						id: checkBoxFav
						height: isNxt? 40:32
						width: isNxt? 40:32
						anchors {
							right: checkBox.left
							rightMargin: isNxt? 30:24
						}
						backgroundColor: colors.graphCheckboxTextBackground
						squareBackgroundColor:  "#FFFFFF"
						squareSelectedColor: colors.graphCheckboxSquare
						squareUnselectedColor: squareSelectedColor
						fontColorSelected: colors.cbText
						squareRadius: isNxt? 18:14
						smallSquareRadius: isNxt? 16:13
						squareOffset: 0
						spacing: Math.round(3 * horizontalScaling)
						leftMargin: Math.round(1 * horizontalScaling)
						rightMargin: 0
						checkMarkStartXOffset: isNxt? 3:3
						checkMarkStartYOffset: isNxt? 6:5
						fontFamilySelected: qfont.regular.name
						fontPixelSize: isNxt? 60:48
						topClickMargin: isNxt? 10:8
						bottomClickMargin: isNxt? 10:8
						selected : model.checkedfav
						onSelectedChanged: { 
							if (selected) {
								model.checkedfav = true
								if (debugOutput) console.log("*********Homey homeyModel checkedfav : " + model.checkedfav)
							} else {
								model.checkedfav = false
								if (debugOutput) console.log("*********Homey homeyModel checkedfav : " + model.checkedfav)
							}
						}
					}
					
					Text {
						id: switchToggle
						text: "Aan/Uit"
						font.pixelSize:  isNxt? 18:14
						font.family: qfont.bold.name
						color: "black"
						anchors {
							right: checkBoxFav.left
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
							right: checkBoxFav.left
							verticalCenter: parent.verticalCenter
							rightMargin: isNxt? 20:16
						}
						visible: (model.available & (model.type2=="3 button"))
					}
				
					
					Text {
						id: deviceValue2
						text: model.available? model.value + " " + model.unit: ""
						font.pixelSize:  isNxt? 18:14
						font.family: qfont.bold.name
						color: "black"
						anchors {
							verticalCenter: parent.verticalCenter
							right: checkBoxFav.left
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
							right: checkBoxFav.left
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
							right: checkBoxFav.left
							rightMargin: isNxt? 20:16
						}
						visible: ((model.type === "lock"))
					}
				}
            snapMode: GridView.SnapToRow
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
	
	Text {
		id: readyText
		text: "Opgeslagen"
		font.pixelSize:  isNxt? 32:26
		font.family: qfont.bold.name
		color: "black"
		anchors {
			horizontalCenter: parent.horizontalCenter
			top: refreshThrobber.bottom
			topMargin: 10
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
					var checked = false
					var checkedfav = false

					for (var key in JsonObject) {
						if (JsonObject.hasOwnProperty(key)) {
							var zoneName = ""
							isAvailable = JsonObject[key].available
							if (debugOutput) console.log("*********Homey " + key + " - " + JsonObject[key].zoneName + " - " + JsonObject[key].name + " - " + JsonObject[key].capabilities)
							for (var capa in JsonObject[key].capabilities){
							
								if (debugOutput) console.log("*********Homey checked" + checked)
							
								capabilityLong = JsonObject[key].capabilities[capa]
								
								if(settingsString.indexOf(String(key + "_" + capabilityLong))>-1){
									checked = false
								}else{
									checked = true
								}
								
								if(settingsFavString.indexOf(String(key + "_" + capabilityLong))>-1){
									checkedfav = false
								}else{
									checkedfav = true
								}

								capabilityShort = capabilityLong
								if (debugOutput) console.log("*********Homey short   " + capabilityShort);
							
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
										homeyModel.append({checked: checked , checkedfav: checkedfav, number: number,id: key , zone:zoneName , type: "onoff" , capa: capabilityLong , capaShort: capabilityShort , devicename: JsonObject[key].name, type2: "toggle", value:String(String(JsonObject[key].capabilitiesObj[capabilityLong].value)), available: isAvailable, up: upState, down: downState})
									
									}

									if (capabilityLong.indexOf("windowcoverings_state") > -1){
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
										homeyModel.append({checked: checked , checkedfav: checkedfav,number: number,id: key , zone:zoneName, type: "window" , capa: capabilityLong , capaShort: capabilityShort , devicename: JsonObject[key].name, type2: "3 button", value: String(JsonObject[key].capabilitiesObj[capabilityLong].value), available: isAvailable, up: upState, down: downState})
									}
								}

                                if (capabilityLong.indexOf("alarm") > -1){
									if (JsonObject[key].capabilitiesObj[capabilityLong] !== undefined){
										if (JsonObject[key].capabilitiesObj[capabilityLong].value !== null){
											homeyModel.append({checked: checked, checkedfav: checkedfav ,number: number,id: key , zone:zoneName, type: "alarm" , capaShort: capabilityShort, capa: capabilityLong, devicename: JsonObject[key].name, value: String(JsonObject[key].capabilitiesObj[capabilityLong].value), unit: units , available: isAvailable})
										}
									}
								}
								
								if (capabilityLong.indexOf("hotWaterState") > -1 || capabilityLong.indexOf("burnerState") > -1){
									if (JsonObject[key].capabilitiesObj[capabilityLong] !== undefined){
										if (JsonObject[key].capabilitiesObj[capabilityLong].value !== null){
											homeyModel.append({checked: checked, checkedfav: checkedfav ,number: number,id: key , zone:zoneName, type: "heating" , capaShort: capabilityShort, capa: capabilityLong, devicename: JsonObject[key].name, value: String(JsonObject[key].capabilitiesObj[capabilityLong].value), unit: units , available: isAvailable})
										}
									}
								}
								
								
								if (capabilityLong.indexOf("locked") > -1){
									if (JsonObject[key].capabilitiesObj[capabilityLong] !== undefined){
										if (JsonObject[key].capabilitiesObj[capabilityLong].value !== null){
											homeyModel.append({checked: checked, checkedfav: checkedfav ,number: number, id: key , zone:zoneName, type: "lock" , capaShort: capabilityShort , capa: capabilityLong, devicename: JsonObject[key].name, value: String(JsonObject[key].capabilitiesObj[capabilityLong].value), unit: units , available: isAvailable})
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
									homeyModel.append({checked: checked, checkedfav: checkedfav ,number: number, id: key , zone:zoneName ,  type: "measure", capaShort: capabilityShort , capa: capabilityLong,  devicename: JsonObject[key].name, value: String(JsonObject[key].capabilitiesObj[capabilityLong].value), unit: units , available: isAvailable})
								}
							}
							number++
						}
					}
					
					listModelSort1()
					refreshThrobber.visible = false
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
	
	function saveSettings() {
		if (debugOutput) console.log("*********homey saveDeviceSettings()")
		refreshThrobber.visible = true
		devicesArray = []
		devicesFavArray = []
		for (var i = 0; i < homeyModel.count; i++) {
			var item = homeyModel.get(i);
			if (debugOutput) console.log("*********homey saveDeviceSettings() item.checked : " + item.checked)
			if (item.checked === false){
				devicesArray.push(item.id + "_" + item.capa)
			}
			if (item.checkedfav === false){
				devicesFavArray.push(item.id + "_" + item.capa)
			}
		}
		homeySettingsFile.write(JSON.stringify(devicesArray));
		homeySettingsFavFile.write(JSON.stringify(devicesFavArray));
		if (debugOutput) console.log("*********homey saveSettings() file saved")
		readyText.visible = true
		throbberTimer.running = true
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
}
