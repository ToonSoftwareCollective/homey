import QtQuick 2.1
import BasicUIControls 1.0
import qb.components 1.0

Screen {
	id: homeyConfigScreen
	property bool debugOutput : app.debugOutput
	screenTitle: qsTr("Homey Instellingen")

	property string    	tmpemail: app.email;
	property string		tmppassword: "xxx";
	property string		tmpSavePassWord: app.password
	property string		tmpcloudid: app.cloudid
	
	property string		rightButtonText: "Opslaan";

	
	onShown: {
		if (debugOutput) console.log("*********homey configScreen loaded")
		addCustomTopRightButton(rightButtonText);
		userNameLabel.inputText = tmpemail;
		passWordLAbel.inputText = tmppassword;
		cloudIdLAbel.inputText = tmpcloudid;
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
	
	
	function savecCloudID(text) {
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
			qkeyboard.open("Wachtwoord", passWordLAbel.inputText, savePassWord)
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
}
