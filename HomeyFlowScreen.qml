import QtQuick 2.1
import BasicUIControls 1.0
import qb.components 1.0
import FileIO 1.0

Screen {
	id: homeyScreen
	screenTitle: "Homey flows"
	
	property bool debugOutput : app.debugOutput
	property int getFlowsInterval :5000
	property string settingsString : ""
	
	onCustomButtonClicked:{
		if (app.homeyConfigScreen2) {
			 app.homeyConfigScreen2.show();
		}
	}
	
	FileIO {
		id: homeySettingsFile
		source: "file:////mnt/data/tsc/appData/homey.flows.json"
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
	
	onShown: {
		refreshThrobber.visible = true
		readSettings()
		getFlowsTimer.running = true;
		addCustomTopRightButton("Instellingen");
	}
	
	function showPopup() {
		qdialog.showDialog(qdialog.SizeLarge, qsTr("Informatie"), qsTr("U bent nu doorgestuurd naar het menuscherm omdat nog geen geldige informatie is ingevuld.. <br><br> Check deze gegevens op het menuscherm waar u nu op terecht bent gekomen. ") , qsTr("Sluiten"));
	}
	
	onHidden: {
		getFlowsTimer.running = false
	}

	
	function stringToBoolean(inputString) {
        return (inputString === "true") ? true : false;
    }
	
	Text {
		id: screenTip
		text: "Alle (zichtbare) flows. Pas dit evt aan in instellingen."
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
			getflows()
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
					StandardButton {
						id: unlockButton
						text: "Trigger flow"
						height: isNxt? 35:28
						visible:  model.enabled
						anchors {
							right: parent.right
							verticalCenter: parent.verticalCenter
							rightMargin: isNxt? 10:8
						}
						onClicked: {
							tiggerflow(model.id);
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
		text: app.warning
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
					
					for (var key in JsonObject) {
						if (JsonObject.hasOwnProperty(key)) {
							if(settingsString.indexOf(String(key))<0){
								name = JsonObject[key].name
								isEnabled = JsonObject[key].enabled
								homeyModel.append({id: key , flowname: name, enabled: isEnabled})
							}
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


    function tiggerflow(flowid){
        if (debugOutput) console.log("*********Homey Start getDevices()")
		var jwt = app.token

		if (debugOutput) console.log("*********Homey flowId : " + flowid)
        var xhr = new XMLHttpRequest()
        var url = 'https://' + app.cloudid + '.connect.athom.com/api/' + 'manager/flow/flow/' + flowid + '/trigger'
        if (debugOutput) console.log("*********Homey url : " + url)
		xhr.open("POST", url, true);
        xhr.setRequestHeader( 'authorization', 'Bearer ' + jwt);
        xhr.setRequestHeader( 'content-type', 'application/json');
        xhr.onreadystatechange = function() { // Call a function when the state changes.
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
					if (debugOutput) console.log("xhr.status: " + xhr.status)
					if (debugOutput) console.log(xhr.responseText)
                } else {
                    if (debugOutput) console.log("*********Homey xhr.status: " + xhr.status)
                    if (debugOutput) console.log("*********Homey " + xhr.responseText)
                }
            }
        }
        xhr.send()
    }
	


	Timer{
		id: getFlowsTimer
		interval: getFlowsInterval
		triggeredOnStart: true
		running: false
		repeat: true
		onTriggered: 
			if(app.tokenOK){
				getFlowsInterval = 300000
				getflows()
			}else{
				getFlowsInterval = 10000
			}
	}

	
}
