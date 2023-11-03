<cfapplication applicationtimeout="#createTimeSpan(1,0,0,0)#" clientmanagement="false"
				clientstorage="registry" loginstorage="session" sessionmanagement="true" sessiontimeout="#createTimeSpan(0,2,0,0)#"
				setclientcookies="true" setdomaincookies="false" scriptprotect="false" name="fckeditor">

<cfhttp url="http://admin.anachem.co.uk/cms/getFCKuploadLocations" result="fckLocs" timeout="60"/>
<cfset config = XMLParse(fckLocs.fileContent)>

<cfset application.userFilesPath = config.fck.userFilesPath.xmlText>
<cfset application.userFilesURLPath = config.fck.userFilesURLPath.xmlText>
