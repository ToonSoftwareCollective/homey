import QtQuick 2.1

import qb.components 1.0
import qb.base 1.0

SystrayIcon {
	id: mediaSystrayIcon
//	visible: app.showHomeyIcon
	posIndex: 9000
	property string objectName: "homeySystray"

	onClicked: {
		if (app.homeyFavoritesScreen){	
			app.homeyFavoritesScreen.show();
		}
	}


	Image {
		id: imgNewMessage
		anchors.centerIn: parent
		source: "qrc:/tsc/LightbulbSystrayIcon.png"
	}
}

//created by Harmen Bartelink, modified by Toonz