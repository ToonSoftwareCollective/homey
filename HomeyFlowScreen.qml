import QtQuick 2.1
import BasicUIControls 1.0
import qb.components 1.0

Screen {
	id: homeyScreen
	screenTitle: "Homey"
	
	property bool debugOutput : app.debugOutput
	property int getFlowsInterval :5000
	
	onCustomButtonClicked:{
		if (app.homeyConfigScreen) {
			 app.needReboot = false
			 app.homeyConfigScreen.show();
		}
	}
	
	Component.onCompleted: {
		app.clearModels.connect(clearModel);
	}

	function clearModel() {
		homeyModel.clear()
	}
	
	
	onShown: {
		refreshThrobber.visible = true
		getFlowsTimer.running = true;
		addCustomTopRightButton("Instellingen");
		if (app.email == "" || app.password == "") {
			if (app.homeyConfigScreen){
				app.homeyConfigScreen.show();
				showPopup();
			}
		}
	}
	
	function showPopup() {
		qdialog.showDialog(qdialog.SizeLarge, qsTr("Informatie"), qsTr("U bent nu doorgestuurd naar het menuscherm omdat nog geen geldige informatie is ingevuld.. <br><br> Check deze gegevens op het menuscherm waar u nu op terecht bent gekomen. ") , qsTr("Sluiten"));
	}
	
	onHidden: {
		app.warning=""
		getFlowsTimer.running = false
	}

	
	function stringToBoolean(inputString) {
        return (inputString === "true") ? true : false;
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
					color: model.enabled? "yellow":"navajowhite"
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
		id: warningToken
		text: app.warning
		font.pixelSize:  32
		font.family: qfont.bold.name
		color: "black"
		anchors {
			bottom: GridView.top
			bottomMargin: 2
			horizontalCenter: parent.horizontalCenter
		}
		visible: (app.warning!=="")
	}
	
	function sortModel(){
		var n;
		var i;
		for (n=0; n < homeyModel.count; n++){
			for (i=n+1; i < homeyModel.count; i++){
				if (homeyModel.get(n).devicename> homeyModel.get(i).devicename)
				{
					homeyModel.move(i, n, 1);
					n=0;
				}
			}
		}
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
							name = JsonObject[key].name
							isEnabled = JsonObject[key].enabled
							homeyModel.append({id: key , flowname: name, enabled: isEnabled})
						}
					}
					sortModel()
					refreshThrobber.visible = false
                } else {
					if (debugOutput) console.log("*********Homey xhr.status: " + xhr.status)
                    if (debugOutput) console.log("*********Homey " + xhr.responseText)
					refreshThrobber.visible = false
					if (debugOutput) console.log("*********Homey getting new Token")
					app.warning = "Fout, ververs tokens vanuit refreshtoken"
					app.refreshToken()
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
