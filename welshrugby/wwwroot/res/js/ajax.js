/*--------------------------------------------------------------------------

Ajax JavaScript Framework
(c) 2006 Kris Brixon <kris.brixon@gmail.com>

Ajax Documentation

This script is used simplify the process to handle xmlHttpRequest calls.

===============================================

Using the $() Function
** Function from: http://www.dustindiaz.com/top-ten-javascript
** Description from: http://www.sergiopereira.com/articles/prototype.js.html

The $() function is a handy shortcut to the all-too-frequent 
document.getElementById() function of the DOM. Like the DOM function, 
this one returns the element that has the id passed as an argument.

Unlike the DOM function, though, this one goes further. You can pass 
more than one id and $() will return an Array object with all the 
requested elements.

Another nice thing about this function is that you can pass either the 
id string or the element object itself, which makes this function very 
useful when creating other functions that can also take either form of 
argument.

===============================================

Using the ajax() Function

The ajax function is used to wrap the xmlHttpRequest object and provide 
some help to implement asyncrous calls to the server.

There are three parts to the ajax() interface.

1. Input (url, method, postBody)
2. Return Handling (fillDiv, onSucess, onFailure)
3. Processing Notification (showBusy, busyDiv)


INPUT
-----------------------------

url: 
   Required
   String
   The web address to process. This must be an address on the same domain.

method: 
   Optional (Default: "post")
   String
   Use "post" to send forms and prevent IE from caching. 
   Use "get" to let IE cache the request.

postBody:
   Optional (Default: "y=y")
   String
   Form variables formatted in key=value&key=value.


RETURN HANDLING
-----------------------------

fillDiv:
   Optional
   String
   If you want all the results on the request to be inserted into a Div 
   then just supply the Div ID and the div contents will be replaced with 
   the results from the request.

onSucess:
   Optional
   Function Name (no quotes)
   If you want to process the results yourself then send in the function 
   name that you want to process the results and it will be called when 
   the results come back.

onFailure:
   Optional
   Function Name (no quotes)
   If you want to handle non 200 status codes from results then send in 
   the function name and when the request comes back with a non sucessful 
   status code it will be called.


PROCESSING NOTIFICATION
-----------------------------

showBusy:
   Optional
   Boolean
   If you want to use the default loading indicator then set the boolean 
   to true and it will show a loading notice like gmail.

busyDiv:
   Optional
   String
   If you want to use a custom loading indicator then setup a hidden div 
   and send in the Div ID and the fuction will process showing and hiding 
   the Div.    

-------------------------------------------------------------------------*/

var iBusy = 0;
document.write("<div id='ajaxBusy' style='display:none; border:3px solid #000099; position:absolute; top:0; right:0; background-color:#0000FF; color:#FFFFFF; padding:6px; font-weight:bold;'>&nbsp;&nbsp;&nbsp;Loading . . .&nbsp;&nbsp;&nbsp;</div>");

function ajax(parameters) {
	var myObj = eval(parameters);
	
	if(!myObj.url) 
		alert('Missing URL');
	
	if(!myObj.method) 
		myObj.method="post";
	
	if(!myObj.postBody) 
		myObj.postBody="y=y";

	if(!myObj.fillDiv) 
		myObj.fillDiv="";

	if(!myObj.onSucess) 
		myObj.onSucess=defaultSucess;
	
	if(!myObj.onFailure) 
		myObj.onFailure=defaultFailure;

	if(!myObj.showBusy) 
		myObj.showBusy=false;

	if(!myObj.busyDiv) 
		myObj.busyDiv="";

	var req = createRequest();
	req.onreadystatechange = function() {returnFunction(req,parameters)};

	if(myObj.method == "get") {
		req.open("GET", myObj.url, true);
		req.send(null);
		} 
	else {
		req.open("POST", myObj.url, true);
		req.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
		req.setRequestHeader('Referer', window.document.location); 
		req.send(myObj.postBody);
		}

	if(myObj.busyDiv != "") {
		$(myObj.busyDiv).style.display = 'block';
		}

	if (myObj.showBusy == true) {
		iBusy++;
		$('ajaxBusy').style.display = 'block';
		}

	}

function returnFunction(req,parameters) {
	var myObj = eval(parameters);
	
	if (req.readyState == 4) {
		
		if(myObj.busyDiv != "") {
			$(myObj.busyDiv).style.display = 'none';
			}

		if (myObj.showBusy == true) {
			iBusy--;
			if(iBusy < 1) {
				$('ajaxBusy').style.display = 'none';
				}
			}
		
		if (req.status == 200) {
			
			if(myObj.fillDiv != "") {
				$(myObj.fillDiv).innerHTML = req.responseText;
				} 
			else {
				myObj.onSucess(req);
				}
			}

		else {
			myObj.onFailure(req);
			}
		} 
	} 

function defaultSucess(req) {
	// Empty. There are times you don't want to notify the user of completion.
	}

function defaultFailure(req) {
	// Empty. There are times you don't want to notify the user of completion.
	}

function createRequest() {
	var request = null;
	try {request = new XMLHttpRequest();} 
	catch (trymicrosoft) {
		try {request = new ActiveXObject("Msxml2.XMLHTTP");} 
		catch (othermicrosoft) {
			try {request = new ActiveXObject("Microsoft.XMLHTTP");} 
			catch (failed) {request = null;}
			}
		}
	if (request == null) {alert("Error creating request object!");}
	else {return request;}
	}

function $() {
	var elements = new Array();
	for (var i = 0; i < arguments.length; i++) {
		var element = arguments[i];
		if (typeof element == 'string')
			element = document.getElementById(element);
		if (arguments.length == 1)
			return element;
		elements.push(element);
	}
	return elements;
}