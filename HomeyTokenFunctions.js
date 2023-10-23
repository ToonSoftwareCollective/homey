    function getNewToken(){
        if (debugOutput) console.log("*********Homey Start getNewToken")
        var body= 'email=' +encodeURIComponent(email) + '&password=' + encodeURIComponent(password) + '&otptoken='
        var xhr = new XMLHttpRequest()
        var url = "https://accounts.athom.com/login"
        xhr.open("POST", url, true);
        xhr.setRequestHeader( 'accept', 'application/json, text/javascript, */*; q=0.01');
        xhr.setRequestHeader( 'content-type', 'application/x-www-form-urlencoded; charset=UTF-8');
        xhr.onreadystatechange = function() { // Call a function when the state changes.
            if (xhr.readyState == XMLHttpRequest.DONE) {
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
                        var JsonString = xhr.responseText
                        var JsonObject= JSON.parse(JsonString)
                        var token = JsonObject.token
                        step2(token);
                } else {
                    if (debugOutput) console.log("*********Homey getNewToken" + "xhr.status: " + xhr.status)
                    if (debugOutput) console.log("*********Homey getNewToken" + xhr.responseText)
					var response = xhr.responseText;
					if (response.indexOf("No resource exists on this endpoint") >-1){
						if (debugOutput) console.log("*********Homey getNewToken wrong username")
						warning = "Foute gebruikersnaam"
					}
					if (response.indexOf("The provided password is not correct") >-1){
						if (debugOutput) console.log("*********Homey getNewToken wrong password")
						warning = "Fout wachtwoord"
					}
					if (response.indexOf("Too many requests") >-1){
						if (debugOutput) console.log("*********Homey getNewToken Too many requests")
						warning = "Te veel aanvragen, probeer later"
					}
                }
            }
        }
        xhr.send(body);
    }

    function step2(token){
        if (debugOutput) console.log("*********Homey Start step2")
        var body= 'email=' +encodeURIComponent(email) + '&password=' + encodeURIComponent(password) + '&otptoken='
        var xhr = new XMLHttpRequest()
        var url = 'https://accounts.athom.com/oauth2/authorise?client_id=' + client_id + '&redirect_uri=' + encodeURIComponent(redirect_url) + '&response_type=code&user_token=' + token
        xhr.open("GET", url, true);
        xhr.setRequestHeader( 'accept', 'application/json, text/javascript, */*; q=0.01');
        xhr.setRequestHeader( 'content-type', 'application/x-www-form-urlencoded; charset=UTF-8');
        xhr.onreadystatechange = function() { // Call a function when the state changes.
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
                        //if (debugOutput) console.log("*********Homey " + "xhr.status: " + xhr.status)
                        //if (debugOutput) console.log("*********Homey " + xhr.responseText)
                        var csrf = xhr.responseText.split("name=\"_csrf\" value=\"").pop().split("\">")[0].trim();
                        if (debugOutput) console.log("*********Homey " + csrf,token)
                        const headers = xhr.getAllResponseHeaders();
                        console.log("*********Homey " + headers)
                        const arr = headers.trim().split(/[\r\n]+/);
                        const headerMap = {};
                        step3(csrf,token);
                } else {
                    if (debugOutput) console.log("*********Homey step2" + "xhr.status: " + xhr.status)
                    if (debugOutput) console.log("*********Homey step2" + xhr.responseText)
                }
            }
        }
        xhr.send();
    }

    function step3(csrf,token){
        if (debugOutput) console.log("*********Homey Start step3")
        var body=  "resource=resource.homey." + cloudid + "&_csrf=" + csrf + "&allow=Allow"
        console.log(body)
        var xhr = new XMLHttpRequest()
        var url = 'https://accounts.athom.com/authorise?client_id=' + client_id +   '&redirect_uri=' + encodeURIComponent(redirect_url) + '&response_type=code&user_token=' + token
        console.log(url)
        xhr.open("POST", url, true);
        xhr.setRequestHeader( 'accept', 'application/json, text/javascript, */*; q=0.01');
        xhr.setRequestHeader( 'content-type', 'application/x-www-form-urlencoded; charset=UTF-8');
        xhr.onreadystatechange = function() { // Call a function when the state changes.
            if (xhr.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
               const headers = xhr.getAllResponseHeaders();
               console.log("*********Homey " + headers)
               const arr = headers.trim().split(/[\r\n]+/);
               const headerMap = {};
               var code
               for(var line in arr){
                 const parts = arr[line].split(': ');
                 if (arr[line].indexOf('location')>-1){code = parts[1].split("=")[1]}
                 const header = parts.shift();
                 const value = parts.join(': ');
                 headerMap[header] = value;
                }
                console.log("*********Homey " + code)
                step4(csrf,token,code)
            }
        }
        xhr.send(body);
    }

    function step4(csrf,token,code){
        if (debugOutput) console.log("*********Homey Start step4")
        var body= 'client_id=' + encodeURIComponent(client_id) +  '&client_secret=' + encodeURIComponent(client_secret) + '&grant_type=authorization_code&code=' + encodeURIComponent(code)
        var xhr = new XMLHttpRequest()
        var url = 'https://api.athom.com/oauth2/token'
        xhr.open("POST", url, true);
        xhr.setRequestHeader( 'accept', 'application/json, text/javascript, */*; q=0.01');
        xhr.setRequestHeader( 'content-type', 'application/x-www-form-urlencoded; charset=UTF-8');
        xhr.onreadystatechange = function() { // Call a function when the state changes.
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
                        //if (debugOutput) console.log("*********Homey " + "xhr.status: " + xhr.status)
                        //if (debugOutput) console.log("*********Homey " + xhr.responseText)
                        var JsonString = xhr.responseText
                        var JsonObject= JSON.parse(JsonString)
                        var accesstoken = JsonObject.access_token
                        if (debugOutput) console.log("*********Homey " + accesstoken)
                        var refreshtoken = JsonObject. refresh_token
						actoken = accesstoken
						rftoken = refreshtoken
                        if (debugOutput) console.log("*********Homey " + refreshtoken)
                        step5(accesstoken, refreshtoken);
                } else {
                    if (debugOutput) console.log("*********Homey step4" + "xhr.status: " + xhr.status)
                    if (debugOutput) console.log("*********Homey step4" + xhr.responseText)
                }
            }
        }
        xhr.send(body);
    }

    function step5(accesstoken, refreshtoken){
        if (debugOutput) console.log("*********Homey Start step5")
        var body= "client_id=5a8d4ca6eb9f7a2c9d6ccf6d&client_secret=" + encodeURIComponent(client_secret) + "&grant_type=refresh_token&refresh_token=" + refreshtoken
        console.log(body)
        var xhr = new XMLHttpRequest()
        var url = 'https://api.athom.com/delegation/token?audience=homey'
        xhr.open("POST", url, true);
        xhr.setRequestHeader( 'authorization', 'Bearer ' + accesstoken);
        xhr.setRequestHeader( 'content-type', 'application/x-www-form-urlencoded; charset=UTF-8');
        xhr.onreadystatechange = function() { // Call a function when the state changes.
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
                        //if (debugOutput) console.log("*********Homey " + "xhr.status: " + xhr.status)
                        //if (debugOutput) console.log("*********Homey " + xhr.responseText)

                        var resp = xhr.responseText
                        var jwt = resp.replace(/['"]/g, '')
                        if (debugOutput) console.log("*********Homey " + jwt)

                        step6(jwt);
                } else {
                    if (debugOutput) console.log("*********Homey step5" + "xhr.status: " + xhr.status)
                    if (debugOutput) console.log("*********Homey step5" + xhr.responseText)
					var response = xhr.responseText;
					warning = "Foute aanvraagtokens, volledig nieuwe aanvraag gestart"
					getNewToken()
                }
            }
        }
        xhr.send(body);
    }


    function step6(jwt){
        if (debugOutput) console.log("*********Homey Start step6")
        var xhr = new XMLHttpRequest()
        var url = 'https://' + cloudid + '.connect.athom.com/api/manager/users/login'
        xhr.open("POST", url, true);
        xhr.setRequestHeader( 'content-type', 'application/json');
        xhr.onreadystatechange = function() { // Call a function when the state changes.
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
                        //if (debugOutput) console.log("*********Homey xhr.status: " + xhr.status)
                        //if (debugOutput) console.log("*********Homey " + xhr.responseText)
                        var resp = xhr.responseText
                        var jwt = resp.replace(/['"]/g, '')
                        if (debugOutput) console.log("*********Homey " + jwt)
						tokenOK = true
						token = jwt
						warning = ""
						saveSettings()
                } else {
                    if (debugOutput) console.log("*********Homey " + "xhr.status: " + xhr.status)
                    if (debugOutput) console.log("*********Homey " + xhr.responseText)
		   var response = xhr.responseText;
		    if (response.indexOf("mesh_node_offline") >-1){
			if (debugOutput) console.log("*********Homey getNewToken mesh_node_offline")
			warning = "Foutieve CloudID ingevoerd"
		    }
                }
            }
        }
        xhr.send(JSON.stringify({"token": jwt}));
    }

    function sleep(milliseconds) {
      var start = new Date().getTime();
      while ((new Date().getTime() - start) < milliseconds )  {
      }
    }
	
	
	
	function checkToken(){
        if (debugOutput) console.log("*********Homey Start checkToken")
		if (debugOutput) console.log("*********Homey Bearer : " + token)
        var xhr = new XMLHttpRequest()
        var url = 'https://' + cloudid + '.connect.athom.com/api/' + 'manager/devices/device'
        xhr.open("GET", url, true);
        xhr.setRequestHeader( 'authorization', 'Bearer ' + token);
        xhr.setRequestHeader( 'content-type', 'application/json');
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200 || xhr.status === 300  || xhr.status === 302) {
					if (debugOutput) console.log("*********Homey " + "xhr.status: " + xhr.status + " : token OK, proceeding")
					tokenOK = true
					warning = ""
                } else {
                    if (debugOutput) console.log("*********Homey " + xhr.responseText)
					if (debugOutput) console.log("*********Homey getting new Token")
					refreshToken()
                }
            }
        }
        xhr.send();
    }

    function sleep(milliseconds) {
      var start = new Date().getTime();
      while ((new Date().getTime() - start) < milliseconds )  {
      }
    }
