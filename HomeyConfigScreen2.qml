import QtQuick 2.1
import BasicUIControls 1.0
import qb.components 1.0

Screen {
	id: homeyScreen2
	screenTitle: "Homey instellingen"
	
	property bool debugOutput : app.debugOutput
	

	Text {
		id: accountName
		text: "Klik op de knop onder om jouw Homey account te koppelen aan de toon."
		font.pixelSize:  isNxt? 18:14
		font.family: qfont.bold.name
		color: "black"
		anchors {
			left: parent.left
			leftMargin: isNxt? 10:8
			top: parent.top
			topMargin: 0
		}
	}
	
	StandardButton {
		id: accountButton
		text: "Ga naar account instellingen"
		height: isNxt? 45:36
		anchors {
			left: parent.left
			leftMargin: isNxt? 10:8
			top: accountName.bottom
			topMargin: isNxt? 8:6
		}
		onClicked: {
			if (app.homeyConfigScreen){	
				app.homeyConfigScreen.show();
			}
		}
	}

	Text {
		id: deviceName
		text: "Klik op de knop onder om de apparaten te kiezen."
		font.pixelSize:  isNxt? 18:14
		font.family: qfont.bold.name
		color: "black"
		anchors {
			left: parent.left
			leftMargin: isNxt? 10:8
			top: accountButton.bottom
			topMargin: 0
		}
	}
	
	StandardButton {
		id: devicesButton
		text: "Kies apparaten"
		height: isNxt? 45:36
		anchors {
			left: parent.left
			leftMargin: isNxt? 10:8
			top: deviceName.bottom
			topMargin: isNxt? 8:6
		}
		onClicked: {
			if (app.homeyDevicesSelectScreen){	
				app.homeyDevicesSelectScreen.show();
			}
		}
	}
	
	Text {
		id: flowName
		text: "Klik op de knop onder om de flows te kiezen."
		font.pixelSize:  isNxt? 18:14
		font.family: qfont.bold.name
		color: "black"
		anchors {
			left: parent.left
			leftMargin: isNxt? 10:8
			top: devicesButton.bottom
			topMargin: isNxt? 10:8
		}
	}
	
	StandardButton {
		id: flowButton
		text: "Flows"
		height: isNxt? 45:36
		anchors {
			left: parent.left
			leftMargin: isNxt? 10:8
			top: flowName.bottom
			topMargin: isNxt? 8:6
		}
		onClicked: {
			if (app.homeyFlowSelectScreen){	
				app.homeyFlowSelectScreen.show();
			}
		}
	}
}
