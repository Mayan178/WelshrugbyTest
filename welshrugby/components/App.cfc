<cfcomponent name="App">
	<!--- Use the core component to get the application name based on the domain name --->
	<cfset this.core = createObject("component", "welshrugby.core").init()>
	<cfset this.name = this.core.get("applicationName") & Replace(cgi.SERVER_NAME, ".", "", "ALL")>

	<cfset local = structNew()>
	<cfset local.app = this.core.get()>
	<cfloop list="#StructKeyList(local.app)#" index="local.set">
		<cfset StructInsert(this, local.set, local.app[local.set], true)>
	</cfloop>

	<!--- APPLICATION --->
	<cffunction name="onApplicationStart">
		<cfset startUp()>
	</cffunction>

	<cffunction name="onApplicationEnd" output="false">
		<cfargument name="applicationScope" required="true">

		<cflog file="#this.name#" type="information" text="Application #this.name# shutdown">
	</cffunction>

	<!--- SESSION --->
	<cffunction name="onSessionStart" output="false">
		<cfset startSession()>
	</cffunction>

	<cffunction name="onSessionEnd" output="false">
		<cfargument name="sessionScope" required="true"/>
		<cfargument name="applicationScope" required="true"/>

		<cfset var local = structNew()>
		<cfset local.sessionLength = TimeFormat(Now() - sessionScope.started, "H:mm:ss")>

		<cflock name="applicationSessions" timeout="5" type="Exclusive">
			<cfset application.currentSessions = application.currentSessions - 1>
		</cflock>

		<cflog file="#this.name#" type="Information"
				text="Session #arguments.sessionScope.sessionid# ended. Length: #local.sessionLength# Active sessions: #arguments.applicationScope.sessions#">
	</cffunction>
	
	<!--- REQUEST --->
	<cffunction name="onRequestStart">
		<!--- initialise the request.scope with the URL and form variables --->
		<!---<cfset request.monitor = createObject("component", "welshrugby.model.monitor").init()>--->
		<cfif NOT StructKeyExists(request, "scope")>
			<cfset request.scope = createObject("component", "welshrugby.model.scope").init()>
		</cfif>
	<!---<cfdump var="#request.scope.get("SCRIPT_NAME")#"><cfabort>--->
		<!--- Load app on user request or application setting --->
		<cfif Len(this.core.get("reload")) OR (request.scope.exists("reload") AND request.scope.get("reload") eq "true")>
			<cfset startUp()>
		</cfif>
        <!---
		<cfif request.scope.exists("reloadComponent")>
			<!--- We've requested a component-specific reload --->
			<cfset local.config = createObject("component", "welshrugby.model.config").init()>
			<cfset getFactory().load(config=local.config, components=request.scope.get("reloadComponent"))>
			<cfoutput><p>Reloaded #request.scope.get("reloadComponent")#. This message does not appear to anyone else.</p></cfoutput>
		</cfif>
		--->
		<!---<cfif NOT application.factory.get("session").model.initialised()>--->
        <cfif (structkeyexists(application,'factory') AND NOT application.factory.get("session").model.initialised())>
			<cfset startSession()>
		<cfelseif request.scope.exists("startSession")>
			<cfoutput><p>Forced session restart</p></cfoutput>
			<cfset startSession(wipe=true)>
		</cfif>

		<!--- Print out a header message if configured --->
		<cfif Len(getHeaderMessage())>
			<cfoutput>
				<div style="border:1px solid black;width:200px;background-color:white;font-weight:bold;margin-bottom:10px;padding:6px;">#getHeaderMessage()#</div>
			</cfoutput>
		</cfif>

		<!--- uncomment this to allow site lock-out based on password --->
		<cfif getLockout()>
			<cfif NOT authorise()>
				<cfoutput><h3>Currently locked out due to maintenance</h3></cfoutput>
				<cfabort>
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="onRequestEnd">
		<cfset var local = structNew()>
		
		<cfset local.pageContent = "">
		<!--- copy the current contents of out
			(which is what cfmx will send to the browser at the end of processing) --->
		<cfset local.pageContent = getPageContext().getOut().getString()>
		<!--- now we have a copy, clear the out buffer --->
		<cfset getPageContext().getOut().clearBuffer()>
		    
		<!--- tidy up --->
		<cfset local.pageContent = reReplace(local.pageContent, chr(9), "", "all" )>
		<cfset local.pageContent = reReplace(local.pageContent, "    ","", "all" )>
		<cfset local.lastContent = "">
		<cfloop condition="local.lastContent neq local.pageContent">
			<cfset local.lastContent = local.pageContent>
			<cfset local.pageContent = reReplace(local.pagecontent, "[\r\n]+", "#chr(10)#", "ALL")>
		</cfloop>

		<!--- send our cleaned content to the browser --->
		<cfset writeOutput(Trim(local.pageContent))>
		<cfset getPageContext().getOut().flush()>

		<cfif request.scope.exists("debug")>
			<cfdump var="#request.scope.get()#" label="request.scope" expand="false">
		</cfif>

		<cfsetting enablecfoutputonly="false">
	</cffunction>

	<cffunction name="onError" output="true">
		<cfargument name="exception" type="any" default="" required=false/>
		<cfargument name="eventName" type="String" required=false/>

		<cfset var local = structNew()>
		<cfparam name="this.name" default="notset">

		<cfsavecontent variable="local.err">
			<cfoutput>
				<html>
					<head>
						<title>#application.ApplicationName# Error</title>
						<link rel="stylesheet" href="/res/css/welshrugby.css"></link>
					</head>
					<body>
						<div style="padding:10px;font-weight:bold">
							<h3>#application.ApplicationName# Website Error</h3>
							We apologise, there has been an error. Our technical team have been automatically notified. Please try again later.
						</div>
					</body>
				</html>
			</cfoutput>
		</cfsavecontent>

		<cftry>
        	<!---
			<cfset local.logFile = getFactory().getSetting("logPath") & "\errors\" & DateFormat(now(), "yyyymmdd") & "-" & TimeFormat(now(), 'HHmmss') & ".htm">
			<cffile action="write" file="#local.logFile#" output="#local.err#">
			--->
			<cfcatch type="any">
			</cfcatch>
		</cftry>

		<cfif structKeyExists(url, "debug")>
			<cfdump var="#arguments#">
		</cfif>

		<cfoutput>#local.err#</cfoutput>
		<cfabort>
	</cffunction>


	<cffunction name="authorise" access="private" hint="Mickey Mouse Lock/Unlock the system to users" returntype="boolean">
		<cfset var local =structNew()>
		
        <!---
		<cfset local.authorized = false>
		<cfloop list="#application.factory.getSetting('authorizedIPs')#" index="local.reIP">
			<cfif ReFind(local.reIP, cgi.REMOTE_HOST)>
				<cfset local.authorized = true>
				<cfbreak>
			</cfif>
		</cfloop>
		--->
        <cfset local.authorized = true>

		<cfif NOT local.authorized>
			<cflog file="#this.name#" type="information" text="Auth for #cgi.REMOTE_HOST# #cgi.LOCAL_ADDR# : Failed">
		</cfif>

		<cfreturn local.authorized>
	</cffunction>	
	
	<!--- OTHER FUNCTIONS --->
	<cffunction name="startUp" access="private">
		<cfset var local = structNew()>

		<cfset setLocale("English (UK)")>
		<cfset local.abort = false>
		
		<cfset request.scope = createObject("component", "welshrugby.model.scope").init()>
        <cfset StructInsert(application, "core", this.core, true)>
    
        <!--- extra bits --->
        <cfset local.cfg = application.core.get()>
        <cfloop list="#StructKeyList(local.cfg)#" index="local.set">
            <cfset application[local.set] = local.cfg[local.set]>
        </cfloop>

        <cftry>
            <!--- load configuration file --->
            <cfset variables.config = createObject("component", "welshrugby.model.config").init()>

            <!--- reset session counters --->
            <cfset application.totalSessions = 0>
            <cfset application.currentSessions = 0>

            <!--- create the IceFactory instance and trigger the load based on the configuration file already attached to the app --->
            <cfset application.factory = createObject("component", "welshrugby.factory").init()>
            <cfset application.factory.load(config=variables.config)>
            <cfcatch type="any">
                <cfdump var="Error starting Application in App.cfc startUp()">
                <cfdump var="#cfcatch#">
                <cfset local.abort = true>
            </cfcatch>
        </cftry>
		
		
		<cfif local.abort>
			<cfset onError()>
		</cfif>

	</cffunction>

	<cffunction name="startSession" access="private">
		<cfargument name="wipe" type="boolean" required="false" default="false">
		<cfif NOT StructKeyExists(request, "scope")>
			<cfset request.scope = createObject("component", "welshrugby.model.scope").init()>
		</cfif>
		<cfset getFactory().get("session").model.create(wipe=arguments.wipe)>
	</cffunction>
	
	<cffunction name="getFactory" access="private">
		<cfif NOT StructKeyExists(application, "factory")>
			<cfabort showerror="Factory does not exists - ISAPI rewrite probably not working">
		</cfif>
		<cfreturn application.factory>
	</cffunction>

	<cffunction name="getHeaderMessage" returntype="string" access="private">
		<cfreturn application.core.get("headerMessage")>
	</cffunction>

	<cffunction name="getLockout" returntype="string" access="private">
		<cfreturn application.core.get("lockout")>
	</cffunction>

	<cffunction name="getApplicationName" access="private">
		<cfreturn this.name>
	</cffunction>
</cfcomponent>

