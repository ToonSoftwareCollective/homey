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
	property int 	maxtiles : 4
	
	property url 	tileUrl : "HomeyTile.qml"
	property url 	tileUrl1 : "HomeyNr1Tile.qml"

	property url 	tileUrl2 : "HomeyNr2Tile.qml"
	property url 	tileUrl3 : "HomeyNr3Tile.qml"
	property url 	tileUrl4 : "HomeyNr4Tile.qml"

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
	property string tileString: ''
	property variant tilesJSON : []

	property bool tile1visible: false
	property bool tile2visible: false
	property bool tile3visible: false
	property bool tile4visible: false
	
	signal clearModels()
	signal homeyUpdated()
	
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
	
	FileIO {
		id: homeySettingsTileFile2
		source: "file:///mnt/data/tsc/appData/homey.tilesjson.json"
 	}
	
	FileIO {
		id: appFile;	
		source: "file:///HCBv2/qml/apps/homey/HomeyApp.qml"
	}
	

	FileIO {
		id: fileList
	}
	

	FileIO {
		id: fileNameIO
	}
	
	function removeFiles(){
        if (debugOutput) console.log("*********Homey Start removeFiles()!")
		var path = "file:///mnt/data/tsc/appData"
		fileList.source = Qt.resolvedUrl(path)
		var filenames = fileList.entryList(["homey*.*"])
		console.log("*********Homey Start filenames: " + filenames)
		for(var i in filenames) {
			console.log("*********Homey Start remove filenames:"  + path + "/" + filenames[i])
			fileNameIO.source = path + "/" + filenames[i]
			fileNameIO.write("")
		}
		homeySettingsFile.write("")
		email = ''
		password = ''
		cloudid  = ''
		token  = ''
		rftoken = ''
		actoken = ''
		tokenOK = false
		warning = "Alle gegevens gewist"
    }
	
	function refreshTiles(){
		if (debugOutput) console.log("*********homey refreshTiles")
		try {
			tileString = homeySettingsTileFile2.read();
			//if (debugOutput) console.log("*********Homey tileString read: " + tileString)
			tilesJSON = JSON.parse(tileString);
		} catch(e) {
		}
	}

	function init() {
		registry.registerWidget("screen", homeyScreenUrl, this, "homeyScreen");
		registry.registerWidget("tile", tileUrl, this, null, {thumbLabel: qsTr("Homey"), thumbIcon: thumbnailIcon, thumbCategory: "general", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: "center"});
//TILE//
//TILE END//		
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
		try {
			tileString = homeySettingsTileFile2.read();
			if (debugOutput) console.log("*********Homey tileString read: " + tileString)
			tilesJSON = JSON.parse(tileString);
		} catch(e) {
		}
		
		sleep(500);
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
		
	function getTiles(){
        if (debugOutput) console.log("*********Homey Start getTiles()")
		if (debugOutput) console.log("*********Homey tileString: " + tileString)
		tileString
        var jwt = token
		if (debugOutput) console.log("*********Homey Bearer : " + jwt)
        var xhr = new XMLHttpRequest()

		if (testurl){
			var url = 'file:///root/homey.txt'
		}else{
			var url = 'https://' + cloudid + '.connect.athom.com/api/' + 'manager/devices/device'
		}
        xhr.open("GET", url, true);
        xhr.setRequestHeader( 'authorization', 'Bearer ' + jwt);
        xhr.setRequestHeader( 'content-type', 'application/json');
        xhr.onreadystatechange = function() { // Call a function when the state changes.
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
					if (debugOutput) console.log("*********Homey " + "xhr.status: " + xhr.status)
					//if (debugOutput) console.log("*********Homey " + xhr.responseText)

					var JsonString = xhr.responseText
					var JsonObject= JSON.parse(JsonString)

					for (var key in JsonObject) {
						if (JsonObject.hasOwnProperty(key)) {
							//if (debugOutput) console.log("*********Homey " + key + " - " + JsonObject[key].zoneName + " - " + JsonObject[key].name + " - " + JsonObject[key].capabilities)
							for (var capa in JsonObject[key].capabilities){
								var capabilityLong = JsonObject[key].capabilities[capa]

								if(tileString.indexOf(String(key + "_" + capabilityLong + "\""))>-1){//de key matched met een key an een tile
									//if (debugOutput) console.log("*********Homey tile match gevonden")
									for (var tileNR in tilesJSON){
										//if (debugOutput) console.log("*********Homey tilesJSON[" + tileNR + "].keycapa" + tilesJSON[tileNR].keycapa)
										if(tilesJSON[tileNR].keycapa === String(key + "_" + capabilityLong)){
											//if (debugOutput) console.log("*********Homey tile gevonden nummer " + tileNR + " : " + String(key + "_" + capabilityLong))
											tilesJSON[tileNR].value = String(JsonObject[key].capabilitiesObj[capabilityLong].value)
											tilesJSON[tileNR].available = JsonObject[key].available
											homeyUpdated()
										}
									}
								}
							}
						}
					}
								
								
                } else {
					if (debugOutput) console.log("*********Homey xhr.status: " + xhr.status)
                    if (debugOutput) console.log("*********Homey " + xhr.responseText)
					if (debugOutput) console.log("*********Homey getting new Token")
					getNewToken()
                }
            }
        }
        xhr.send()
    }
	
	
	function setState(type,switchId, valSet){
        if (debugOutput) console.log("*********Homey Start getDevices()")
		var jwt = token
		
		if (debugOutput) console.log("*********Homey switchId : " + switchId)
        var xhr = new XMLHttpRequest()
        var url = 'https://' + cloudid + '.connect.athom.com/api/' + 'manager/devices/device/' + switchId + '/capability/' + type
        if (debugOutput) console.log("*********Homey url : " + url)
		xhr.open("PUT", url, true);
        xhr.setRequestHeader( 'authorization', 'Bearer ' + jwt);
        xhr.setRequestHeader( 'content-type', 'application/json');
        xhr.onreadystatechange = function() { // Call a function when the state changes.
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
                        if (debugOutput) console.log("*********Homey xhr.status: " + xhr.status)
                        if (debugOutput) console.log("*********Homey " + xhr.responseText)
						updateDevices()
                } else {
                    if (debugOutput) console.log("*********Homey xhr.status: " + xhr.status)
                    if (debugOutput) console.log("*********Homey " + xhr.responseText)
                }
            }
        }
        xhr.send(JSON.stringify({ "value": valSet }))
    }

	Timer {
		id: rebootTimer   //interval to nicely save all and reboot
		interval: 3000
		repeat:false
		running: false
		triggeredOnStart: false
		onTriggered: {
			Qt.quit()
		}
    }

	
	
	Timer{
		id: getDevicesTimer
		interval: 10000
		triggeredOnStart: true
		running: (tile1visible || tile2visible || tile3visible || tile4visible)
		repeat: true
		onTriggered: 
			if(tokenOK){
				getTiles()
			}
	}

}


