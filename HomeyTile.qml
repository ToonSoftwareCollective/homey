import QtQuick 2.1
import BasicUIControls 1.0
import qb.components 1.0

Tile {
	id: homeyTile
	

	onClicked: {
		if (app.homeyFavoritesScreen){	
			app.homeyFavoritesScreen.show();
		}
	}
	
	Text {
		id: tileTitle
		anchors {
			baseline: parent.top
			baselineOffset: isNxt? 30:24
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.tileTitle
		}
		color: !dimState? "black" : "white"
		text: "Homey"
	}
	
	Image {
			id: homeyImage
			source: "drawables/homey.png"
			fillMode: Image.PreserveAspectFit
			height: isNxt? 110:88
			width: isNxt? 110:88
			anchors {
				horizontalCenter: parent.horizontalCenter
				verticalCenter: parent.verticalCenter
				//top: tileTitle.bottom
				//topMargin: isNxt? 20:16
			}
			
			RotationAnimation {
				id: rotateAnimation
				target: homeyImage
				property: "rotation"
				from: 0
				to: 360
				duration: 20000
				loops: Animation.Infinite
				running: app.tokenOK
			}
		}



}