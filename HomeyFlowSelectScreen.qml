import QtQuick 2.1
import BasicUIControls 1.0
import qb.components 1.0
import FileIO 1.0

Screen {
	id: homeyScreen
	screenTitle: "Homey"
	
	property bool debugOutput : app.debugOutput
	property int getDevicesInterval :5000
	property string settingsString : ""
	property variant devicesArray : []
	
	
	FileIO {
		id: homeySettingsFile
		source: "file:////mnt/data/tsc/appData/homey.flows.json"
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
		getflows()
	}
	

	function stringToBoolean(inputString) {
        return (inputString === "true") ? true : false;
    }
	
	Text {
		id: screenTip
		text: "Geef in dit scherm aan welke flows zichtbaar moeten zijn."
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
	

   Rectangle {
		id: frame1
		width: isNxt? (parent.width)-15: (parent.width)-12
		height: isNxt? parent.height - 85 :parent.height - 68
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
					color: model.enabled?  "#F0F0F0":"navajowhite"
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
					var isEnabled = true
					var name = ""
					var checked = false

					for (var key in JsonObject) {
						if (JsonObject.hasOwnProperty(key)) {
						
							if(settingsString.indexOf(String(key))>-1){
								checked = false
							}else{
								checked = true
							}
								
							name = JsonObject[key].name
							isEnabled = JsonObject[key].enabled
							homeyModel.append({id: key , checked: checked, flowname: name, enabled: isEnabled})
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
        xhr.send();
    }
	
	function saveSettings() {
		if (debugOutput) console.log("*********homey saveDeviceSettings()")
		refreshThrobber.visible = true
		devicesArray = []
		for (var i = 0; i < homeyModel.count; i++) {
			var item = homeyModel.get(i);
			if (debugOutput) console.log("*********homey saveDeviceSettings() item.checked : " + item.checked)
			if (item.checked === false){
				devicesArray.push(item.id)
			}
		}
		homeySettingsFile.write(JSON.stringify(devicesArray));
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
