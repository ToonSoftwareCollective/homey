//
// Homey by by oepi-loepi
//

import QtQuick 2.1
import qb.components 1.0
import qb.base 1.0;
import ScreenStateController 1.0
import FileIO 1.0
import "HomeyTokenFunctions.js" as HomeyTokenFunctions


App {
	id: root
	
	property bool 	debugOutput: false
	property bool 	testurl: false
	
	property url 	tileUrl :  "HomeyTile.qml"
	property HomeyConfigScreen homeyConfigScreen
	property url 	homeyConfigScreenUrl : "HomeyConfigScreen.qml"
	property url    trayUrl : "MediaTray.qml";
	property SystrayIcon mediaTray2
	property url 	homeyScreenUrl : "HomeyScreen.qml"
	property HomeyScreen homeyScreen	
	property url 	homeyFlowScreenUrl : "HomeyFlowScreen.qml"
	property HomeyFlowScreen homeyFlowScreen	
	property url 	homeyDevicesSelectScreenUrl : "HomeyDevicesSelectScreen.qml"
	property HomeyDevicesSelectScreen homeyDevicesSelectScreen
	property url 	homeyFavoritesScreenUrl : "HomeyFavoritesScreen.qml"
	property HomeyFavoritesScreen homeyFavoritesScreen
	property url 	homeyFlowSelectScreenUrl : "HomeyFlowSelectScreen.qml"
	property HomeyFlowSelectScreen homeyFlowSelectScreen

	property HomeyConfigScreen2 homeyConfigScreen2
	property url 	homeyConfigScreen2Url : "HomeyConfigScreen2.qml"

	
	property url 	thumbnailIcon: "qrc:/tsc/LightBulbOn.png"
	
	
	property bool 	tokenOK: false
		
	property string email : ''
    property string password : ''
    property string client_id : '5a8d4ca6eb9f7a2c9d6ccf6d'
    property string client_secret  :  'e3ace394af9f615857ceaa61b053f966ddcfb12a'
    property string redirect_url  :  'http://localhost'
    property string cloudid  : ''
    property string token  : ''
	property string rftoken : ''
	property string actoken : ''
	property string warning: ''
	property bool   needReboot: false
	
	signal clearModels()
	

	property variant settings : {
		"email" : "",
		"password" : "",
		"client_id" : "",
		"client_secret" : "",
		"redirect_url" : "",
		"cloudid" : "",
		"rftoken" : "",
		"actoken" : "",
		"token" : ""
	}
	
	FileIO {
		id: homeySettingsFile
		source: "file:///mnt/data/tsc/homey.userSettings.json"
 	}
	
	
	function init() {
		registry.registerWidget("screen", homeyScreenUrl, this, "homeyScreen");
		registry.registerWidget("tile", tileUrl, this, null, {thumbLabel: qsTr("Homey"), thumbIcon: thumbnailIcon, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: "center"});
		registry.registerWidget("screen", homeyConfigScreenUrl, this, "homeyConfigScreen");
		registry.registerWidget("screen", homeyConfigScreen2Url, this, "homeyConfigScreen2");
		registry.registerWidget("screen", homeyFlowScreenUrl, this, "homeyFlowScreen");
		registry.registerWidget("screen", homeyDevicesSelectScreenUrl, this, "homeyDevicesSelectScreen");
		registry.registerWidget("screen", homeyFlowSelectScreenUrl, this, "homeyFlowSelectScreen");
		registry.registerWidget("screen", homeyFavoritesScreenUrl, this, "homeyFavoritesScreen");
	}
	
	Component.onCompleted: {
		readSettings();
		if(token==""){
			sleep(1000);
			getNewToken();
			if (!tokenOK){
				sleep(5000);
				getNewToken();
			}
		}else{
			if (debugOutput) console.log("*********homey token found:" + token)
			HomeyTokenFunctions.checkToken();
		}
	}
	

	function sleep(milliseconds) {
      var start = new Date().getTime();
      while ((new Date().getTime() - start) < milliseconds )  {
      }
    }


	function readSettings() {
		if (debugOutput) console.log("*********homey readSettings()")
		try {
			var settingsString = homeySettingsFile.read();
			settings = JSON.parse(settingsString);
			if (settings['email']) email = (settings['email']);
			if (settings['password']) password = (settings['password']);
			if (settings['homeyWarningShown']) homeyWarningShown = (settings['homeyWarningShown'] == "true");
			if (settings['client_id']) client_id = (settings['client_id']);
			if (settings['client_secret']) client_secret = (settings['client_secret']);
			if (settings['cloudid']) cloudid = (settings['cloudid']);
			if (settings['redirect_url']) redirect_url = (settings['redirect_url']);
			if (settings['token']) token = (settings['token']);
			if (settings['rftoken']) rftoken = (settings['rftoken']);
			if (settings['actoken']) actoken = (settings['actoken']);

		} catch(e) {
		}
		sleep(1000);
    }
	
	function saveSettings() {
		if (debugOutput) console.log("*********homey saveSettings()")

		settings["email"] = email;
		settings["password"] = password;
		settings["client_id"] = client_id;
		settings["cloudid"] = cloudid;
		settings["client_secret"] = client_secret;
		settings["redirect_url"] = redirect_url;
		settings["token"] = token;
		settings["rftoken"] = rftoken;
		settings["actoken"] = actoken;

		homeySettingsFile.write(JSON.stringify(settings));
		if (debugOutput) console.log("*********homey saveSettings() file saved")
	}
	
	function getNewToken() {
		if (debugOutput) console.log("*********homey getNewToken()")
		HomeyTokenFunctions.getNewToken();
	}
	
	
	function refreshToken() {
		if (debugOutput) console.log("*********homey refreshToken()")
		if(actoken!="" && rftoken!=""){
			HomeyTokenFunctions.step5(actoken, rftoken)
		}else{
			HomeyTokenFunctions.getNewToken();
		}
	}
	
	function clearData() {
		warning = "Een ogenblik..."
		tokenOK = false
		token= ""
		rftoken = ""
		actoken = ""
		clearModels()
	}
	
}