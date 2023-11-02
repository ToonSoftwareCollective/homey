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
		id: titleText
		text: "Homey"
		anchors {
			baseline: parent.top
			baselineOffset: Math.round(30 * verticalScaling)
			horizontalCenter: parent.horizontalCenter
		}
		font {
			family: qfont.regular.name
			pixelSize: qfont.tileTitle
		}
		color: dimmableColors.tileTitleColor
	}

	
	Image {
		id: homeyImage
		source: "drawables/homey.png"
		fillMode: Image.PreserveAspectFit
		height: isNxt? 100:80
		width: isNxt? 100:80
		anchors.centerIn: parent
		
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