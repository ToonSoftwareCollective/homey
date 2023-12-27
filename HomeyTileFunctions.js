    
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
		console.log("*********homey checkIfTilesNeeded() started ")
		var appfileString =  appFile.read()
		if (debugOutput) console.log("*********homey appfileString: " + appfileString)
		if(appfileString.indexOf("//LEEG") >-1){
			console.log("*********homey //LEEG found ")
			if(tilesJSON.length>0){
				if (debugOutput) console.log("*********homey tilesJSON.length>0 ")
				HomeyTileFunctions.checkAndCreateTiles(tilesJSON,true)
			}else {
				if (debugOutput) console.log("*********homey tilesJSON.length<1 ")
				appfileString = appfileString.replace('//LEEG','')
				appFile.write(appfileString)
			}
		}else{
			if (debugOutput) console.log("*********homey //LEEG not found ")
			HomeyTileFunctions.checkAndCreateTiles(tilesJSON,false)	
		}
    }
	

	function checkAndCreateTiles(devicesTileArray, isLeeg){
		if (debugOutput) console.log("*********homey checkAndCreateTiles() leeg: " + isLeeg)
		
		var appfileString =  appFile.read()
		var oldappfileString = appfileString

		var n201 = oldappfileString.indexOf('//TILE//') + '//TILE//'.length
		var n202 = oldappfileString.indexOf('//TILE END//',n201)
		var oldWidgetString = oldappfileString.substring(n201, n202)
		if (debugOutput) console.log("*********homey oldWidgetString: " + oldWidgetString)

		if (!isLeeg){
			if (debugOutput) console.log("*********homey checking tiles")
			var needUpdate = false
			for(var i in devicesTileArray){
				if(devicesTileArray[i].devflow !="leeg" ){
					if(oldWidgetString.indexOf("tileUrl" + i + ", this") < 0){
						needUpdate = true
					}
				}
			}
		}
		
		if(needUpdate || isLeeg){
			if (debugOutput) console.log("*********homey creating tiles")
			var tileString0 = ""
			for(var i in devicesTileArray){
				if(devicesTileArray[i].devflow !="leeg"){
					tileString0 += "		registry.registerWidget(\"tile\", tileUrl" + i + ", this, null, {thumbLabel: qsTr(\"Homey_" + i + "\"), thumbIcon: thumbnailIcon, thumbCategory: \"general\", thumbWeight: 30, baseTileWeight: 10, thumbIconVAlignment: \"center\"})\n"
				}
			}
			if (debugOutput) console.log("*********homey tileString0" + tileString0)
			var newappfileString = oldappfileString.substring(0, n201) + "\n" + tileString0 + "\n" + oldappfileString.substring(n202, oldappfileString.length)
			newappfileString = newappfileString.replace('//LEEG','')
			appFile.write(newappfileString)
			if (debugOutput) console.log("*********homey new WidgetSettings saved ")
			if (debugOutput) console.log("*********homey restarting.............. ")
			sleep(500);
			Qt.quit()
		}else{
			if (debugOutput) console.log("*********homey creating tiles not needed")
		}
	
	}
