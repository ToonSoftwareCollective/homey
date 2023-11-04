import QtQuick 2.1
import BxtClient 1.0
import BasicUIControls 1.0
import qb.components 1.0

Screen {
	id: homeyConfigScreen
	property bool debugOutput : app.debugOutput
	screenTitle: qsTr("Homey account instellingen")

	property string    	tmpemail: app.email
	property string		tmppassword: app.password
	property string		tmphidden: "xxx"
	property string		tmpSavePassWord: app.password
	property string		tmpcloudid: app.cloudid
	property string 	lanIp: "0.0.0.0"
	
	property string		rightButtonText: "Opslaan";

	
	onShown: {
		if (debugOutput) console.log("*********homey configScreen loaded")
		app.warning = ""
		addCustomTopRightButton(rightButtonText)
		userNameLabel.inputText = tmpemail;
		passWordLAbel.inputText = tmphidden
		cloudIdLAbel.inputText = tmpcloudid
		if (debugOutput) console.log("*********homey tmpemail: " + tmpemail)
		if (debugOutput) console.log("*********homey tmppassword " + tmppassword)
		if (debugOutput) console.log("*********homey tmpcloudid " + tmpcloudid)
	}


	onCustomButtonClicked: {
		app.clearData()
		app.email = tmpemail
		app.password = tmpSavePassWord
		app.cloudid=tmpcloudid
		refreshThrobber.visible=true
		app.saveSettings()
		app.sleep(500)
		app.getNewToken()
		refreshThrobber.visible=false
		hide()
	}
	
	
	function saveEmail(text) {
		if (text) {
			tmpemail = text;
		}
	}
	
	function savePassWord(text) {
		if (text) {
			tmpSavePassWord = text;
		}
	}
	
	
	function saveCloudID(text) {
		if (text) {
			tmpcloudid = text;
		}
	}


	Text {
		id: titleText
		anchors {
			left: parent.left
			top: parent.top
			leftMargin: isNxt? 20:16
			topMargin: isNxt? 8 : 6
		}
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		wrapMode: Text.WordWrap
		text: "Configureer hier de instellingen voor Homey"
	}


	HomeyEditTextLabel {
		id: userNameLabel
		height: isNxt ? 35 : 28
		width: isNxt ? 800 : 600
		labelSize: isNxt? 20:16
		inputboxSize: isNxt? 20:16
		leftText: qsTr("Gebruikersnaam voor de Homey app")
		leftTextAvailableWidth:isNxt ? 500 : 400
		anchors {
			left: titleText.left
			top: titleText.bottom
			topMargin: isNxt ? 8 : 6
		}

		onClicked: {
		    rightButtonText= "Opslaan en terug";
			qkeyboard.open("Gebruikersnaam", userNameLabel.inputText, saveEmail)
		}
	}
			

	HomeyEditTextLabel {
		id: passWordLAbel
		height: isNxt ? 35 : 28
		width: isNxt ? 800 : 600
		labelSize: isNxt? 20:16
		inputboxSize: isNxt? 20:16
		leftText: qsTr("Wachtwoord voor de Homey app")
		leftTextAvailableWidth:isNxt ? 500 : 400
		anchors {
			left: titleText.left
			top: userNameLabel.bottom
			topMargin: isNxt ? 8 : 6
		}
		onClicked: {
			rightButtonText= "Opslaan en terug";
			qkeyboard.open("Wachtwoord", tmppassword, savePassWord)
		}
	}
	
	HomeyEditTextLabel {
		id: cloudIdLAbel
		height: isNxt ? 35 : 28
		width: isNxt ? 800 : 600
		labelSize: isNxt? 20:16
		inputboxSize: isNxt? 20:16
		leftText: qsTr("CloudID")
		leftTextAvailableWidth:isNxt ? 500 : 400
		anchors {
			left: titleText.left
			top: passWordLAbel.bottom
			topMargin: isNxt ? 8 : 6
		}
		onClicked: {
			rightButtonText= "Opslaan en terug";
			qkeyboard.open("CloudID", cloudIdLAbel.inputText, saveCloudID)
		}
	}
	
	Text {
		id: tipText
		anchors {
			left: titleText.left
			top: cloudIdLAbel.bottom
			topMargin: isNxt ? 8 : 6
		}
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		width: isNxt? parent.width - 40:parent.width - 32
		wrapMode: Text.WordWrap
		text: "De cloudID kan gevonden worden op https://tools.developer.homey.app/tools/system, achter de url als je inlogt op de homey (via webbrowser) https://my.homey.app/homeys/ of als je in de homey naar de instellingen van de gebruiker gaat. De cloudID bestaat uit cijfers en letters (hoofdlettergevoelig). Een voorbeeld is 61aec0b429b9f7660d41c329"
	}
	
	
	Text {
		id: downloadText
		anchors {
			left: titleText.left
			top: tipText.bottom
			topMargin: isNxt ? 30 : 24
		}
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		width: isNxt? parent.width - 40:parent.width - 32
		wrapMode: Text.WordWrap
		text: "Zorg dat de juiste gegevens zijn ingevuld en dat data wordt opgehaald. Ga dan terug en druk onderstaande knop om een download file aan te maken die kan worden verstuurd. De download bevat gegevens over de configuratie van de Homey en is voor de ontwikkelaar nodig in geval van problemen."
	}	
	
	
	StandardButton {
		id: downloadButton
		text: "Download"
		height: isNxt? 45:36
		anchors {
			left: titleText.left
			top: downloadText.bottom
			topMargin: isNxt ? 8 : 6
		}
		onClicked: {
				getDownload()
		}
	}
	
	Text {
		id: downloadText2
		anchors {
			left: titleText.left
			top: downloadButton.bottom
			topMargin: isNxt ? 16 : 12
		}
		font {
			pixelSize: qfont.bodyText
			family: qfont.regular.name
		}
		width: isNxt? parent.width - 40:parent.width - 32
		wrapMode: Text.WordWrap
		text: ""
		visible: false
	}
	
	
	StandardButton {
		id: removefilesButton
		text: "Verwijder instellingen en Homey files van toon"
		height: isNxt? 45:36
		anchors {
			right: parent.right
			top: downloadButton.top
			rightMargin: isNxt? 20:16
		}
		onClicked: {
			refreshThrobber.visible = true
			app.removeFiles()
			readyText.visible = true
			throbberTimer.running = true
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
	
	
	function sleep(milliseconds) {
      var start = new Date().getTime();
      while ((new Date().getTime() - start) < milliseconds )  {
      }
    }

	
	
	function getDownload(){
        if (debugOutput) console.log("*********Homey Start getDownload()")
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
//					if (debugOutput) console.log("*********Homey " + xhr.responseText)
					var doc = new XMLHttpRequest();
					doc.open("PUT", "file:///var/tmp/homey_log.txt");
					doc.send(xhr.responseText);
					downloadText2.visible = true
					downloadText2.text = "Haal de file op in een browser op : http://" + lanIp + "/homey/homey.download. Stuur deze file op voor debug doeleinden."
					sleep(1000)
					var doc2 = new XMLHttpRequest();
					doc2.open("PUT", "file:///var/tmp/tsc.command");
					doc2.send("external-homey");
					
					lanIp

                } else {
					if (debugOutput) console.log("*********Homey xhr.status: " + xhr.status)
                    if (debugOutput) console.log("*********Homey " + xhr.responseText)
					downloadText2.visible = true
					downloadText2.text= "Fout, waarschijnlijk zijn de inloggegeven niet correct? Eerst invullen. Daarna opslaan en als de toon koppelt dan terug naar dit scherm en downloaden."
                }
            }
        }
        xhr.send();
    }	
	
	
	BxtDiscoveryHandler {
		id : netconDiscoHandler
		deviceType: "hcb_netcon"
		onDiscoReceived: {
			statusNotifyHandler.sourceUuid = deviceUuid;
		}
	}
	
	BxtNotifyHandler {
		id: statusNotifyHandler
		serviceId: "gwif"
		onNotificationReceived : {
			var address = message.getArgument("ipaddress");
			if (address) {
				lanIp = address;
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

	
}
