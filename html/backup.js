function buildCharacterSlots(characters){
    if(debug) {return;}

    $("#characters").html("");
    var slot = 0;
    for (var k in characters){
        slot++;
        var charsV2 = characters[k];
        var chardata = charsV2.charinfo
        var names = chardata.chardata
        var money = charsV2.money
        var citizenid = charsV2.citizenid
        var birth = chardata.birthdate
        citizenids = citizenid
        //var char = characters;
        console.log(JSON.stringify(charsV2))
        var date = new Date(birth);
        date = (date.getMonth() + 1) + "-" + (date.getDate() + 1) + "-" + date.getFullYear();
        curLuaTime = parseInt(curLuaTime);
        selectId = charsV2.citizenid
        

        var numSlot = "<div id='" + slot + "' class='slot'>";
        var title = "<div class='title'>" + names.firstname + "</div><br><br>";
        var name = "<div class='name'><span class='entry'>Name:</span><br> " + names.firstname + " " + names.lastname + "</div><br><br>";
        var dob = "<div class='dob'><span class='entry'>DOB:</span><br> " + date + "</div><br><br>";
        var gender = "<div class='gender'><span class='entry'>Gender:</span><br> " + (chardata.gender == 0 ? "Male" : "Female") + "</div><br><br>";
        var phone = "<div class='phone'><span class='entry'>Phone #:</span><br> " + chardata.chardata.phone + "</div><br><br>";
        var cid = "<div class='cid'><span class='entry'>ID #:</span><br> " + charsV2.cid + "</div><br><br>";
        var citizen = "<div class='citizen'><span class='entry'>CitizenID #:</span><br> " + charsV2.citizenid + "</div><br><br>";
        var cash = "<div class='cash'><span class='entry'><br />Cash:</span><br> $" + money.cash + "</div><br><br>";
        var bank = "<div class='bank'><span class='entry'>Bank:</span><br> $" + money.bank + "</div><br><br>";
        var story = "<div class='story' style='word-wrap: break-word;'><span class='entry'><br/>Story: </span><br /> " + chardata.backstory + "</div>";
        var buttons = "<div class='buttons'><div class='button' onclick='selectCharacter(" + selectId + ");'><div class='verticalAlign'>Select Character</div></div><div class='button del' onclick='showDeleteCharacter(" + selectId + ");'><div class='verticalAlign'>Delete Character</div></div></div>";

        $("#characters").append(numSlot + title + "<div id='cdata' class='scroll'>" + name + dob + gender + phone + cid + citizen + cash + bank + story + "</div>" + buttons + "</div>");
    }
    var emptySlots = 4 - slot;
    var count = emptySlots;
    if (emptySlots > 0){
        for (i = emptySlots; i > 0; i--){
            var numSlot = "<div id='slot" + count + "' class='slot'>";
            var title = "<div class='title'>Empty Slot</div>";
            var cdata = "<div id='cdata' class='scroll'> </div>";
            var buttons = "<div class='buttons'><div class='button' onclick='showCreateCharacter();'><div class='verticalAlign'>New Character</div></div></div>"
            $("#characters").append(numSlot + title + cdata + buttons + "</div>")
            count--;
        }
    }
}