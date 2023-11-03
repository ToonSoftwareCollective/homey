import QtQuick 2.1
import BasicUIControls 1.0
import qb.components 1.0
import FileIO 1.0

Screen {
	id: homeyScreen
	screenTitle: "Homey apparaten"
	
	property bool debugOutput : app.debugOutput
	property int getDevicesInterval :5000
	property string settingsString : ""
	
	FileIO {
		id: homeySettingsFile
		source: "file:////mnt/data/tsc/appData/homey.devices.json"
 	}
	
	onCustomButtonClicked:{
		if (app.homeyConfigScreen2) {
			 app.homeyConfigScreen2.show();
		}
	}
	
	Component.onCompleted: {
		app.clearModels.connect(clearModel);
	}

	function clearModel() {
		homeyModel.clear()
		homeyModel2.clear()
	}
	
	function sleep(milliseconds) {
		var start = new Date().getTime();
		while ((new Date().getTime() - start) < milliseconds )  {
		}
    }
	
	
	function readSettings() {
		if (debugOutput) console.log("*********homey readSettings()")
		try {
			settingsString = String(homeySettingsFile.read());
		} catch(e) {
		}
    }

	onShown: {
		refreshThrobber.visible = true
		readSettings()
		sleep(500)
		getDevicesTimer.running = true
		getUpdatesTimer.running = true
		addCustomTopRightButton("Instellingen")
		if (app.email == "" || app.password == "") {
			if (app.homeyConfigScreen){
				app.homeyConfigScreen.show();
				showPopup();
			}
		}
	}
	
	onHidden: {
		getDevicesTimer.running = false
		getUpdatesTimer.running = false
	}

		
	function showPopup() {
		qdialog.showDialog(qdialog.SizeLarge, qsTr("Informatie"), qsTr("U bent nu doorgestuurd naar het menuscherm omdat nog geen geldige informatie is ingevuld.. <br><br> Check deze gegevens op het menuscherm waar u nu op terecht bent gekomen. ") , qsTr("Sluiten"));
	}
	
	
	function stringToBoolean(inputString) {
        return (inputString === "true") ? true : false;
    }
	
	Text {
		id: screenTip
		text: "Alle (zichtbare) apparaten. Pas dit evt aan in instellingen."
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
	
	IconButton {
		id: refreshButton;
		height: designElements.buttonSize
		iconSource: "qrc:/images/refresh.svg"
		anchors {
			top: parent.top
			right: parent.right
			rightMargin: isNxt? 10:8
			topMargin: 0
		}
		onClicked: {
			getDevices()
		}
	}

   Rectangle {
		id: frame1
		width: isNxt? (parent.width/2 )-15: (parent.width/2 )-12
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
					color: model.available?  "#F0F0F0":"navajowhite"
					Text {
						id: deviceName
						text: (model.zone + " " + model.devicename).substring(0, 35)
						font.pixelSize:  isNxt? 18:14
						font.family: qfont.bold.name
						color: "black"
						anchors {
							verticalCenter: parent.verticalCenter
						}
					}
					OnOffToggle {
						id: switchToggle
						height: isNxt? 35:28
						anchors {
							right: parent.right
							verticalCenter: parent.verticalCenter
							rightMargin: isNxt? 10:8
						}
						isSwitchedOn: stringToBoolean(model.value)
						onSelectedChangedByUser: {
							if (isSwitchedOn) {
								setState("onoff", model.id, true)
							} else {
								setState("onoff",model.id, false)
							}
						}
						visible: (model.available & (model.type2=="toggle"))
					}
					IconButton {
						id: upButton
						height: isNxt? 30:24
						overlayColorUp: "red"
						overlayWhenUp: model.up
						anchors {
							right: parent.right
							verticalCenter: parent.verticalCenter
							rightMargin: isNxt? 10:8
						}
						iconSource: "qrc:/tsc/up.png"
						onClicked: {
							setState("windowcoverings_state",model.id, "up")
						}
						visible: (model.available & (model.type2=="3 button"))
					}
					
					IconButton {
						id: stopButton
						height: isNxt? 30:24
						overlayColorUp: "red"
						overlayWhenUp:(!model.up && !model.down)
						anchors {
							right:upButton.left
							verticalCenter: parent.verticalCenter
							rightMargin: isNxt? 5:4
						}
						iconSource: "qrc:/tsc/stop.png"
						onClicked: {
							setState("windowcoverings_state",model.id, "idle")
						}
						visible: (model.available & (model.type2=="3 button"))
					}

					IconButton {
						id: downButton
						height: isNxt? 30:24
						overlayColorUp: "red"
						overlayWhenUp: model.down
						anchors {
							right:stopButton.left
							verticalCenter: parent.verticalCenter
							rightMargin: isNxt? 5:4
						}
						iconSource: "qrc:/tsc/down.png"
						onClicked: {
							setState("windowcoverings_state",model.id, "down")
						}
						visible: (model.available & (model.type2=="3 button"))
					}		 
				}
            snapMode: GridView.SnapToRow
		}

	}

    Rectangle {
		id: frame2
		width: isNxt? (parent.width/2 )-15: (parent.width/2 )-12
		height: isNxt?  parent.height - 50 :  parent.height - 40
		border.color : "black"
		border.width : 3

		anchors {
			top: parent.top
			left: frame1.right
			leftMargin: isNxt? 10:8
			topMargin: isNxt? 50:40
		}
		
		ListModel {
			id: homeyModel2
		}
		

		GridView {
			id: homeyGrid2
			height: isNxt? frame2.height-80:frame2.height-64
			width: isNxt? frame2.width-10:frame2.width-8
			cellWidth: isNxt? parent.width -10:parent.width -8
			cellHeight: isNxt? 40:32
			
			anchors {
				top: parent.top
				left: parent.left
				leftMargin: isNxt? 10:8
				topMargin:50
			}

			model: homeyModel2
			delegate: 
				Rectangle {
					width: isNxt? parent.width -10:parent.width -8
					height: isNxt? 35:28
					color: model.available?  "#F0F0F0":"navajowhite"
					Text {
						id: deviceName2
						text: (model.zone + " " + model.devicename + " " + model.capaShort).substring(0, (41 - ((model.value + " " +  model.unit).length)))
						font.pixelSize:  isNxt? 18:14
						font.family: qfont.bold.name
						color: "black"
						anchors {
							verticalCenter: parent.verticalCenter
						}
					}
					Text {
						id: deviceValue2
						text: model.available? model.value + " " + model.unit: ""
						font.pixelSize:  isNxt? 18:14
						font.family: qfont.bold.name
						color: "black"
						anchors {
							verticalCenter: parent.verticalCenter
							right: parent.right
							rightMargin: isNxt? 20:16
						}
						visible: (model.type !== "alarm" && model.type !== "heating" && model.type !== "lock")
					}
					
					Rectangle {
						id: alarmIcon
						radius: 10
						width: isNxt? 30:24
						height: isNxt? 30:24
						color: (model.value === "true")? "red":"limegreen"
						anchors {
							verticalCenter: parent.verticalCenter
							right: parent.right
							rightMargin: isNxt? 20:16
						}
						visible: (model.type === "alarm" || model.type === "heating")
					}
					
					Image {
						id: lockImage
						source: (model.value === "true")? "drawables/lock.png": "drawables/unlock.png"
						fillMode: Image.PreserveAspectFit
						width: isNxt? 30:24
						height: isNxt? 30:24
						anchors {
							verticalCenter: parent.verticalCenter
							right: parent.right
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
	
	function listModelSort2() {
        var indexes = new Array(homeyModel2.count);
        for (var i = 0; i < homeyModel2.count; i++) indexes[i] = i;
        indexes.sort(function (indexA, indexB) { return homeyModel2.get(indexA).devicename.localeCompare(homeyModel2.get(indexB).devicename)  } );
        var sorted = 0;
        while (sorted < indexes.length && sorted === indexes[sorted]) sorted++;
        if (sorted === indexes.length) return;
        for (i = sorted; i < indexes.length; i++) {
            var idx = indexes[i];
            homeyModel2.move(idx, homeyModel2.count - 1, 1);
            homeyModel2.insert(idx, { } );
        }
        homeyModel2.remove(sorted, indexes.length - sorted);
    }



    function getDevices(){
        if (debugOutput) console.log("*********Homey Start getDevices()")
        var jwt = app.token
		homeyModel.clear()
		homeyModel2.clear()
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
							//if (debugOutput) console.log(key + " - " + zoneName + " - " + JsonObject[key].name + " - " + JsonObject[key].capabilities);
							if (debugOutput) console.log("*********Homey " + key + " - " + JsonObject[key].zoneName + " - " + JsonObject[key].name + " - " + JsonObject[key].capabilities)
							for (var capa in JsonObject[key].capabilities){
							
								capabilityLong = JsonObject[key].capabilities[capa]

								if(settingsString.indexOf(String(key + "_" + capabilityLong))<0){
									
									capabilityShort = capabilityLong
									capabilityShort = capabilityShort.split("meter_").join("mtr_");
									capabilityShort = capabilityShort.split("measure_").join("meas_");
									capabilityShort = capabilityShort.split("alarm_").join("al_");
									capabilityShort = capabilityShort.split("lock_").join("");
									
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
											homeyModel.append({number: number,id: key , zone:zoneName , type: "onoff" , capa: capabilityLong , capaShort: capabilityShort , devicename: JsonObject[key].name, type2: "toggle", value:String(String(JsonObject[key].capabilitiesObj[capabilityLong].value)), available: isAvailable, up: upState, down: downState})
										
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
											homeyModel.append({number: number,id: key , zone:zoneName, type: "window" , capa: capabilityLong , capaShort: capabilityShort , devicename: JsonObject[key].name, type2: "3 button", value: String(JsonObject[key].capabilitiesObj[capabilityLong].value), available: isAvailable, up: upState, down: downState})
										}
									}

									if (capabilityLong.indexOf("alarm") > -1){
										if (JsonObject[key].capabilitiesObj[capabilityLong] !== undefined){
											if (JsonObject[key].capabilitiesObj[capabilityLong].value !== null){
												homeyModel2.append({number: number,id: key , zone:zoneName, type: "alarm" , capaShort: capabilityShort, capa: capabilityLong, devicename: JsonObject[key].name, value: String(JsonObject[key].capabilitiesObj[capabilityLong].value), unit: units , available: isAvailable})
											}
										}
									}
									
									if (capabilityLong.indexOf("hotWaterState") > -1 || capabilityLong.indexOf("burnerState") > -1){
										if (JsonObject[key].capabilitiesObj[capabilityLong] !== undefined){
											if (JsonObject[key].capabilitiesObj[capabilityLong].value !== null){
												homeyModel2.append({number: number,id: key , zone:zoneName, type: "heating" , capaShort: capabilityShort, capa: capabilityLong, devicename: JsonObject[key].name, value: String(JsonObject[key].capabilitiesObj[capabilityLong].value), unit: units , available: isAvailable})
											}
										}
									}
									
									
									if (capabilityLong.indexOf("locked") > -1){
										if (JsonObject[key].capabilitiesObj[capabilityLong] !== undefined){
											if (JsonObject[key].capabilitiesObj[capabilityLong].value !== null){
												homeyModel2.append({number: number, id: key , zone:zoneName, type: "lock" , capaShort: capabilityShort , capa: capabilityLong, devicename: JsonObject[key].name, value: String(JsonObject[key].capabilitiesObj[capabilityLong].value), unit: units , available: isAvailable})
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
										homeyModel2.append({number: number, id: key , zone:zoneName ,  type: "measure", capaShort: capabilityShort , capa: capabilityLong,  devicename: JsonObject[key].name, value: String(JsonObject[key].capabilitiesObj[capabilityLong].value), unit: units , available: isAvailable})
									}
										
								}
								number++
							}
						}
					}
					
					listModelSort1()
					listModelSort2()
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

    function updateDevices(){
        if (debugOutput) console.log("*********Homey Start updateDevices()")
		refreshThrobber.visible = true
		var jwt = app.token
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
					var JsonString = xhr.responseText
					var JsonObject= JSON.parse(JsonString)
					var key = ""
					var value
					var key2 = ""
					var value2
					var available
					var available2
					
					for (var i = 0; i < homeyModel.count; i++) {
						var item = homeyModel.get(i);
						key = item.id
						var capability = item.capa

						if (JsonObject.hasOwnProperty(key)) {
							var downState = false
							var upState = false
							if (capability === "onoff" && capability.indexOf("windowcoverings") === -1){
								homeyModel.setProperty(i, "value", value)
							}
	
							if (capability.indexOf("windowcoverings_state") > -1){
								var valState = JsonObject[key].capabilitiesObj[capability].value
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
								homeyModel.setProperty(i, "up", upState)
								homeyModel.setProperty(i, "down", downState)
							}
						}
						available = JsonObject[key].available
						homeyModel.setProperty(i, "available", available)							
					}

					for (var i2 = 0; i2 < homeyModel2.count; i2++) {
						var item = homeyModel2.get(i2);
						key2 = item.id
						var capability2 = item.capa

						if (JsonObject.hasOwnProperty(key2)){
							value2 = String(JsonObject[key2].capabilitiesObj[capability2].value)
							available2 = JsonObject[key2].available
							homeyModel2.setProperty(i2, "value", value2)
							homeyModel2.setProperty(i2, "available", available2)
						}
					}
					refreshThrobber.visible = false
                } else {
					refreshThrobber.visible = false
                    if (debugOutput) console.log("*********Homey " + xhr.responseText)
                }
            }
        }
        xhr.send();
    }


    function setState(type,switchId, valSet){
        if (debugOutput) console.log("*********Homey Start getDevices()")
		var jwt = app.token
		
		if (debugOutput) console.log("*********Homey switchId : " + switchId)
        var xhr = new XMLHttpRequest()
        var url = 'https://' + app.cloudid + '.connect.athom.com/api/' + 'manager/devices/device/' + switchId + '/capability/' + type
        if (debugOutput) console.log("*********Homey url : " + url)
		xhr.open("PUT", url, true);
        xhr.setRequestHeader( 'authorization', 'Bearer ' + jwt);
        xhr.setRequestHeader( 'content-type', 'application/json');
        xhr.onreadystatechange = function() { // Call a function when the state changes.
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
                        if (debugOutput) console.log("*********Homey xhr.status: " + xhr.status)
                        if (debugOutput) console.log("*********Homey " + xhr.responseText)
						updateDevices()
                } else {
                    if (debugOutput) console.log("*********Homey xhr.status: " + xhr.status)
                    if (debugOutput) console.log("*********Homey " + xhr.responseText)
                }
            }
        }
        xhr.send(JSON.stringify({ "value": valSet }))
    }
	

	Timer{
		id: getDevicesTimer
		interval: getDevicesInterval
		triggeredOnStart: true
		running: false
		repeat: true
		onTriggered: 
			if(app.tokenOK){
				getDevicesInterval = 300000
				getDevices()
			}else{
				getDevicesInterval = 10000
			}
	}
	
	
	Timer{
		id: getUpdatesTimer
		interval: 10000
		triggeredOnStart: false
		running: false
		repeat: true
		onTriggered: 
			if(app.tokenOK && ( homeyModel.count>0 || homeyModel2.count>0))updateDevices();
	}
	
}
