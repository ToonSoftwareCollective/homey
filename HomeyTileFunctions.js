    
	function switchMode(mode) {
		if (debugOutput) console.log("*********homey  switchMode(" + mode + ")")
  		var xhr = new XMLHttpRequest();
		var url = "file:///qmf/config/config_happ_scsync.xml"
		xhr.open("GET", url, true);
        xhr.onreadystatechange = function() {
            if ( xhr.readyState == XMLHttpRequest.DONE) {
                if (mode == 6) {
                    if ( xhr.responseText.indexOf("<feature>noHeating</feature>") === -1)  {
                        if (debugOutput) console.log("*********homey setup config file for 6 tiles")
                        var newContent
                        newContent =  xhr.responseText
                        newContent = newContent.replace('<features>','<features><feature>noHeating</feature>')
                        var configNew = new XMLHttpRequest();
						var url2 = "file:///qmf/config/config_happ_scsync.xml"
					    configNew.open("PUT", url2);
                        configNew.send(newContent);
					    configNew.close;
                    } else {
                        if (debugOutput) console.log("*********homey  config already fine for 6 tiles, no change needed! ")
                    }
                }
                if (mode == 4) {
                    if (xhr.responseText.indexOf("<feature>noHeating</feature>") != -1)  {
                        if (debugOutput) console.log("*********homey setup config file for 4 tiles")
                        var newContent
                        newContent = xhr.responseText
                        newContent = newContent.replace('<feature>noHeating</feature>','')
                        var configNew = new XMLHttpRequest();
					    var url2 = "file:///qmf/config/config_happ_scsync.xml"
					    configNew.open("PUT", url2);
                        configNew.send(newContent);
					    configNew.close;
                    } else {
                        if (debugOutput) console.log("*********homey config already fine for 4 tiles, no change needed! ")
                    }
                }
			}
		}
        xhr.send();
	}
	
	
	function checkIfTilesNeeded(){
		var appfileString =  appFile.read()
		//if (debugOutput) console.log("*********homey appfileString: " + appfileString)
		if(appfileString.indexOf("//LEEG") >-1){
			if (debugOutput) console.log("*********homey //LEEG found ")
			if(tilesJSON.length>0){
				if (debugOutput) console.log("*********homey tilesJSON.length>0 ")
				HomeyTileFunctions.createTiles(tilesJSON)
				appfileString = appfileString.replace('//LEEG','')
				appFile.write(appfileString)
				if (debugOutput) console.log("*********homey restarting from init() ")
				rebootTimer.running = true
			}else {
				if (debugOutput) console.log("*********homey tilesJSON.length<1 ")
				appfileString = appfileString.replace('//LEEG','')
				appFile.write(appfileString)
			}
		}
    }

	function createTiles(devicesTileArray){
	//This function needs to be last in the app!!!!!!!!!!
		if (debugOutput) console.log("*********homey  createTiles()")
		var tileString0 = ""
		var tileString2 = ""
		var tileString3 = ""
		var tileString4 = "		running: (\n"
		var firsttile = true;
		var tilecounter = 0;


		for(var i in devicesTileArray){
			if(devicesTileArray[i].devflow !="leeg"){
				tileString0 += "		registry.registerWidget(\"tile\", tileUrl" + i + ", this, null, {thumbLabel: qsTr(\"Homey_" + i + "\"), thumbIcon: thumbnailIcon, thumbCategory: \"general\", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: \"center\"})\n"
				tileString2 += "	property url 	tileUrl" + i + " : \"HomeyNr" + i + "Tile.qml\"\n"
				tileString3 += "	property bool 	tile" + i + "visible: false\n"
				if (firsttile){
					firsttile = false;
					tileString4 += "			tile" + i + "visible"
				}else{
					tileString4 += "||\n 			tile" + i + "visible"
				}
				tilecounter ++
			}
		}
		
		tileString4 += ")"
		if (tilecounter==0){tileString4 = "		running: false"}


		var appfileString =  appFile.read()
		//if (debugOutput) console.log("*********toonTemp old appfileString: " + appfileString)
		var oldappfileString = appfileString

		var n201 = oldappfileString.indexOf('//TILE//') + '//TILE//'.length
		var n202 = oldappfileString.indexOf('//TILE END//',n201)
		//if (debugOutput) console.log("*********homey old WidgetSettings: " + oldappfileString.substring(n201, n202))
		var newappfileString = oldappfileString.substring(0, n201) + "\n" + tileString0 + "\n" + oldappfileString.substring(n202, oldappfileString.length)
		
		
		oldappfileString = newappfileString
		n201 = oldappfileString.indexOf('//PROPERTY//') + '//PROPERTY//'.length
		n202 = oldappfileString.indexOf('//PROPERTY END//',n201)
		//if (debugOutput) console.log("*********homey old WidgetSettings: " + oldappfileString.substring(n201, n202))
		newappfileString = oldappfileString.substring(0, n201) + "\n" + tileString2 + "\n" + oldappfileString.substring(n202, oldappfileString.length)

		oldappfileString = newappfileString
		n201 = oldappfileString.indexOf('//VISIBLE//') + '//VISIBLE//'.length
		n202 = oldappfileString.indexOf('//VISIBLE END//',n201)
		//if (debugOutput) console.log("*********homey old WidgetSettings: " + oldappfileString.substring(n201, n202))
		newappfileString = oldappfileString.substring(0, n201) + "\n" + tileString3 + "\n" + oldappfileString.substring(n202, oldappfileString.length)
		
		oldappfileString = newappfileString
		n201 = oldappfileString.indexOf('//TIMER//') + '//TIMER//'.length
		n202 = oldappfileString.indexOf('//TIMER END//',n201)
		//if (debugOutput) console.log("*********homey old WidgetSettings: " + oldappfileString.substring(n201, n202))
		newappfileString = oldappfileString.substring(0, n201) + "\n" + tileString4 + "\n" + oldappfileString.substring(n202, oldappfileString.length)

		appFile.write(newappfileString)
		if (debugOutput) console.log("*********homey new WidgetSettings saved ")
	}
	