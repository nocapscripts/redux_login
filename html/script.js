













var waitingEnter = false;
var waitingData = false;
var waitingCharData = false;
var selectedChar = null;
var curLuaTime = 0;
var cursorEnabled = false;
var debug = false;
var hoverClick = null;
var charId = {};
var cid = {};
var char = {};







$(function()
{
    listen();

    if (debug){
        $("body").css("background", "url('https://images6.alphacoders.com/553/553248.jpg')")

        openMenu();
        $("*").css("cursor", "auto")
        
        //$("#main").css("display", "block")
        //showCharacterSelect(true);
        //$("#newCharacter").css("display", "block");
    }
})

function sendNuiMessage(data){
    $.post("https://rs_login/nuiMessage", JSON.stringify(data));
}

function receivedNuiMessage(event){
    var data = event.data;

    if (data.date){
        curLuaTime = data.date;
    }

    if (data.open){
        openMenu();
    }

    if (data.close){
        closeMenu();
    }

    if (data.playerdata){
        receivedPlayerData(data);
    }

    if (data.err){
        showError("Error", data.err.msg, true, true);
    }

    if (data.createCharacter){
        createdCharacter(data);
        
    }

    if (data.selectcharacter){
        console.log("trying to select char")
        selectcharacter(charId);
       
    }

    if (data.deleteCharacter){
        deleteCharacter(charId);
        
    }

    if (data.playercharacters){
        receivedCharacterData(data);
    }

    if (data.reload){
        retry(true);
    }
}

function openMenu(){
    clearMenu();

    showCursor(true);
    $("#main").css("display", "block");
    $("#init").css("display", "block");
    $("#changelog").css("display", "block");

    waitingEnter = true;
}

function closeMenu(){
    $("#main").css("display", "none");
    $("#main").hide();
    $("#init").hide();
    $("#changelog").hide();
    closeWindow(null, true);

    clearMenu();

    $.post('https://rs_login/exit', JSON.stringify({}));
   

    sendNuiMessage({close: true});
}

function clearMenu(){
    waitingEnter = false;
    waitingData = false;
    waitingCharData = false;
    charId = null;
    showLoading(false);
    showCursor(false);
    showError(null, null, false, false);
    closeWindow(null, true)
}

function closeWindow(winder, allwinders){
    if (allwinders){
        $(".window").css("display", "none");
        return;
    }

    $("#" + winder).css("display", "none");
}

function showLoading(toggle, msg){
    msg = msg ? msg : "Loading...";

    $("#loading p").html(msg);

    if (toggle){
        $("#loading").css("display", "block");
    }else {
        $("#loading").css("display", "none");
    }
}

function showCursor(toggle){
    if (toggle){
        sendNuiMessage({showcursor: true});
        cursorEnabled = true;
        sendNuiMessage({setcursorloc: {x: 0.5, y: 0.5}});
    } else{
        sendNuiMessage({showcursor: false});
        cursorEnabled = false;
    }
}

function showError(title, msg, killwindows, toggle){
    msg = msg ? msg : "Viga";
    title = title ? title : "Viga";

    if (killwindows){
        closeWindow(null, true);
    }

    showLoading(false)

    $("#error .title").html(title);
    $("#error .errmsg").html(msg);

    if (toggle){
        $("#error").css("display", "block");
        showCursor(true);
    } else{
        $("#error").css("display", "none");
        showCursor(false);
    }
}

function showCharacterSelect(){
    showCursor(true);

    closeWindow(null, true);
    $("#characters").css("display", "flex");
}


function buildCharacterSlots(characters){
    if(debug) {return;}

    $("#characters").html("");
    var slot = 0;
    
    
    for (var k in characters){
        slot++;
        char = characters[k];

        console.log(JSON.stringify(char))
        var chard = char.charinfo
        var money = char.money
        var birth = chard.birthdate
        charId = JSON.stringify(char.citizenid)
        cid = JSON.stringify(char.cid)
        date = birth;
        //console.log(JSON.stringify(date))
        curLuaTime = parseInt(curLuaTime);


        var numSlot = "<div id='" + slot + "' class='slot'>";
        var title = "<div class='title'>" + chard.firstname + "</div><br><br>";
        var name = "<div class='name'><span class='entry'>Nimi:</span><br> " + chard.firstname + " " + chard.lastname + "</div><br><br>";
        var dob = "<div class='dob'><span class='entry'>Sünd:</span><br> " + date + "</div><br><br>";
        var gender = "<div class='gender'><span class='entry'>Sugu:</span><br> " + (chard.gender == 0 ? "Male" : "Female") + "</div><br><br>";
        var phone = "<div class='phone'><span class='entry'>Telefon #:</span><br> " + chard.phone + "</div><br><br>";
        var cash = "<div class='cash'><span class='entry'><br />Sula:</span><br> $" + Number(money.cash).toLocaleString() + "</div><br><br>";
        var bank = "<div class='bank'><span class='entry'>Pank:</span><br> $" + Number(money.bank).toLocaleString() + "</div><br><br>";
        var story = "<div class='story' style='word-wrap: break-word;'><span class='entry'><br/>Taust: </span><br /> " + chard.story + "</div>";
        
        console.log(JSON.stringify(char.citizenid))
        var buttons = "<div class='buttons'><div class='button play' onclick='selectCharacter(" + charId + ");'><div class='verticalAlign'>MÄNGI</div></div><div class='button del' onclick='showDeleteCharacter(" + charId + ");'><div class='verticalAlign'>KUSTUTA</div></div></div>";



        $("#characters").append(numSlot + title + "<div id='cdata' class='scroll'>" + name + dob + gender + phone + cash + bank + story + "</div>" + buttons + "</div>");
    }
    var emptySlots = 3 - slot;
    var count = emptySlots;
    if (emptySlots > 0){
        for (i = emptySlots; i > 0; i--){
            var numSlot = "<div id='slot" + count + "' class='slot'>";
            var title = "<div class='title'>Tühi</div>";
            var cdata = "<div id='cdata' class='scroll'> </div>";
            var buttons = "<div class='buttons'><div class='button' onclick='showCreateCharacter();'><div class='verticalAlign'>Loo tegelane</div></div></div>"
            $("#characters").append(numSlot + title + cdata + buttons + "</div>")
            count--;
        }
    }
}

function selectCharacter(id){
    
   
    closeMenu();
    console.log(id)
    
    sendNuiMessage({selectCharacter: id});
    $.post("https://rs_login/selectchar", JSON.stringify(id));


   // $.post('https://rs_login/exit', JSON.stringify({}));
    

}



function showDeleteCharacter(id, cancel, close){
    if (cancel) {
        charId = null;
        $("#deleteCharacter").css("display", "none");
        return;
    }

    if (close) {
        $("#deleteCharacter").css("display", "none");
        showCharacterSelect(true);
        return;
    }

    closeWindow(null, true);
    charId = id;

    $("#deleteCharacter").css("display", "block");
}

function deleteCharacter(){
    if (!charId || charId == null) {return;}

    sendNuiMessage({deletecharacter: charId});
    $.post("https://rs_login/deletechar", JSON.stringify(charId));


    showDeleteCharacter(null, true);
    showCursor(false);
    showLoading("true", "Kustutad tegelase");

    if (debug) {
        retry(true);
    }
}

function createdCharacter(data){
    if (!debug && data.createCharacter.error){
        showError("Error:", data.createCharacter.msg, true, true)
        return
    }

    closeWindow(null, true);
    showLoading(true, "Kärbime uue tegelase andmeid");
    setTimeout(function(){
        fetchPlayerData();
    }, 200);

    closeMenu();
    
}

function showCreateCharacter(){
    closeWindow(null, true);

    $("#firstname").val("");
    $("#lastname").val("");
    $("#dob").val("");
    $("#gender").val("Male");
    
    $("#newCharacter").css("display", "block");
}

function newCharacterSubmit(){
    var data = {
        newchar: true,
        firstname: $("#firstname").val(),
        lastname: $("#lastname").val(),
        birthdate: $("#dob").val(),
        gender: $("#gender").val() == "Male" ? 0 : 1,
        story: $("#story").val(),
        cid: JSON.stringify(cid)
    };
   

    closeWindow(null, true);
    showCursor(false)
    showLoading(true, "Loome uue tegelase");

    setTimeout(function(){
        sendNuiMessage(data);

        if (debug) {
            createdCharacter();
        }
    }, 200);
}

function retry(show){
    showError(null, null, null, false);
    closeWindow(null, true);

    if (show){
        fetchPlayerData();
        return;
    }

    showLoading(true, "Proovib uuesti");
    setTimeout(function(){
        fetchPlayerData();
    }, 1500);
}

function disconnect(){
    closeMenu();
    sendNuiMessage({disconnect: true});
}

function listen(){
    listenMouse();
    window.addEventListener("message", receivedNuiMessage);
    window.onkeyup = listenInput;

    /*$(".button").mouseenter(function(){
        hoverClick.pause();
        hoverClick.volume = 0.05;
        hoverClick.currentTime = 0;
        hoverClick.play();
    })*/

    $("#characterForm").submit(function(){
        newCharacterSubmit();
    })
}

function fetchPlayerData(){
    waitingEnter = false;
    waitingData = true;
    showLoading(true, "Kärbime teie andmeid");
    closeWindow("init");
    closeWindow("changelog");
    
    setTimeout(function(){
        sendNuiMessage({fetchdata: true});
        if (debug){
            receivedPlayerData({playerdata: {debug: true}});
        }
    }, 1500);
}

function fetchPlayerCharacters(){
    waitingCharData = true;

    setTimeout(function(){
        sendNuiMessage({fetchcharacters: true});

        if (debug){
            receivedCharacterData();
        }
    }, 200);
}

function validateCharacterData(data){
    showLoading(true, "Valideerime tegelase andmed");

    if (!debug && data.playercharacters["char1"]){
        for (var k in data.playercharacters){
            var char = data.playercharacters[k];

            if (!char || char == undefined || char == null || char == ""){
                showError("Error", "One of your characters returned nil. (cslot: " + k + ")<br/>Contact an administrator if this persists.", true, true);
                return;
            }

            for(var i in char){
                var entry = char[i];
                if (entry != 0 && !entry || entry == undefined || entry == null || entry === ""){
                    showError("Error", "One of your characters has invalid data. Contact an administrator if this persists.<br/> Cid: " + char.id + " Entry: " + i.toString(), true, true);
                    return;
                }
            }
        }
    }

    var chars = debug ? false : data.playercharacters;

    setTimeout(function(){
        showLoading(false);
        buildCharacterSlots(chars);
        showCharacterSelect(true);
    }, 200);
}

function receivedCharacterData(data){
    if (!waitingCharData) {return;}

    waitingCharData = false;

    showLoading(true, "Saime tegelase andmed kätte")

    setTimeout(function(){
        validateCharacterData(data);
    }, 200);
}

function validatePlayerData(data){
    showLoading(true, "Valideerime andmed");

    setTimeout(function(){
        for (var k in data.playerdata){
            if (!data.playerdata[k] && data.playerdata[k] != 0 || data.playerdata[k] === "" || data.playerdata[k] == undefined || data.playerdata[k] == null && !debug){
                showError("Error", "There was an error validating your data; Couldn't retrieve value '" + k + "'", true, true);
                showLoading(false);
                return;
            }
        }

        showLoading(true, "Kärbime teie tegelasi");

        fetchPlayerCharacters();
    }, 200);
}

function receivedPlayerData(data){
    if (!waitingData) {return;}
    
    waitingData = false;

    if (!data.playerdata){
        showError("Error", "Viga andmete kärpimisel", true, true);
        showLoading(false);
        return;
    }

    showLoading(true, "Saime andmed kätte");

    setTimeout(function(){
        validatePlayerData(data);
    }, 200)
}

function listenInput(e){
    var key = e.keyCode ? e.keyCode : e.which;

    if (key == 13 && waitingEnter){
        showCursor(false);
        fetchPlayerData();
    }

    /*if (key == 27){
        closeMenu();
    }*/
}

function listenMouse(){
    window.document.onmousemove = function(e) {
        $("#cursor").css("left", e.pageX);
        $("#cursor").css("top", e.pageY);
	}
}