function $(id) {

return document.getElementById(id);

}

function process() {
// Check browser whether is Firefox, IE or not supported Ajax.

if ( window.XMLHttpRequest ) {
var xhr = new XMLHttpRequest();
} else if ( window.ActiveXObject ) {
var xhr = new ActiveXObject(”MSXML2.XMLHTTP”);
} else {
$(’result’).innerHTML = “Ajax not supported”;
return;
}

//Check whether the server send response successful or not.

xhr.onreadystatechange = function() {
if ( (xhr.readyState == 4) && (xhr.status == 200) ) {
response = xhr.responseText;
listOptions();
}
}

//Send request to server (process.cfm?year=????), include timestamp in order to avoid browser cache.

xhr.open(”GET”, “/players/getMyTeamPlayers/teamID” + $(’teamID’).value + “&t=” + new Date().getTime(), true);
xhr.send(null);

//Update the lstClass.

function listOptions() {
options = response.split(’|');
for ( var i = 0; i < options.length; i++ ) {
$(’class’).options[i] = new Option(options[i]);
}
}

}

//Write the appropriate result.

function show() {
$(’result’).innerHTML = “You’re studying in year ” + $(’year’).value + “, and in class ” + $(’class’).value;
}

