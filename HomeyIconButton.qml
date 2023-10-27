import QtQuick 2.1

import BasicUIControls 1.0;

StyledButton {
	id: root

	property bool primary: false

	property color colorUp:              colors.ibColorUp
	property color colorUpPrimary:       colors.ibColorUpPrimary
	property color overlayColorUp:       colors.ibOverlayColorUp
	property color borderColorUp:        colors.ibBorderColorUp
	property bool overlayWhenUp: false
	radius: designElements.radius

	leftMargin: 0
	rightMargin: 0
	width: height
	height: 30
	
	state: "up"

	states: [
		State {
			name: "up"
			PropertyChanges { target: root; color: primary ? colorUpPrimary : colorUp}
			PropertyChanges { target: root; overlayColor: overlayColorUp}
			PropertyChanges { target: root; useOverlayColor: overlayWhenUp}
			PropertyChanges { target: root; borderColor: borderColorUp}
		}
	]
}
