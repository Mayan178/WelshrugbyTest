<cfcomponent name="session" extends="parent" hint="Model, queries and logic for session">
	<cffunction name="init" access="public" returntype="session">
		<cfset super.init()>
		
		<cfreturn this/>
	</cffunction>

	<cffunction name="create" access="public" returntype="boolean" hint="Creates a session structure and populates it">
		<cfargument name="wipe" type="boolean" required="false" default="false">
		<cfif isDefined("session")>
			<cfif NOT StructKeyExists(session, application.ApplicationName)>
				<cfset StructInsert(session, application.ApplicationName, StructNew(), true)>
			</cfif>
	
			<cfif NOT exists("started") OR arguments.wipe>
				<cfset set("sessionID", session.SessionID)>
				<cfset set("started", now())>
				<cfset set("clientIP", cgi.remote_host)>
				<cfset set("lastURL", "/")>
				<cfset set("currentURL", request.scope.get("script_name"))>

				<cfset set("SiteViewURL", request.scope.get("script_name"))>
                
				<!--- TODO: Candidate for cfthread --->
				<cflock name="applicationSessions" timeout="5" type="Exclusive" throwontimeout="false">
					<cfset application.totalSessions = application.totalSessions + 1>
					<cfset application.currentSessions = application.currentSessions + 1>
				</cflock>
			</cfif>
			<cfreturn true>
		</cfif>
		<cfreturn false>
	</cffunction>

	<cffunction name="set" access="public" returntype="any" hint="Sets a session variable">
		<cfargument name="key" type="string" required="true">
		<cfargument name="value" type="Any" required="true">
		<cfargument name="timeout" type="any" required="false" default="#CreateTimeSpan(0,24,0,0)#">

		<cfset var local = structNew()>
		<cfset local.debug = false>

		<cfset local.setting = structNew()>
		<cfset local.setting.value = arguments.value>
		<cfset local.setting.key = Trim(arguments.key)>
		<cfset local.setting.timeout = now() + arguments.timeout>

		<cfset session[application.applicationName][local.setting.key] = local.setting>
		
		<cfif local.debug>
			<cfoutput><div style="border:1px solid gray;padding:5px;margin:10px">
				 <strong>Session key</strong>: #arguments.key#<br>
				<cfdump var="#local.setting#">
			</div></cfoutput>
		</cfif>

	</cffunction>

	<cffunction name="param" access="public" returntype="any" hint="Sets a session variable if not set">
		<cfargument name="key" type="string" required="true">
		<cfargument name="value" type="Any" required="true">

		<cfif NOT exists(arguments.key)>
			<cfset set(arguments.key, arguments.value)>
		</cfif>
	</cffunction>

	<cffunction name="get" access="public" returntype="any" hint="Gets a session variable" output="false">
		<cfargument name="key" type="string" required="false" default="">

		<cfset var local = structNew()>

		<cfif create()>
	 		<cfif Len(arguments.key)>
				<cfif exists(arguments.key)>
					<cfset local.setting = session[application.applicationName][arguments.key]/>
					<cfif local.setting.timeout le now()>
						<cfset delete(arguments.key)>
						<cfset local.value = "">
					<cfelse>
						<cfset local.value = local.setting.value>
					</cfif>
				<cfelseif arguments.key eq "sessionID">
					<cfset local.value = session.sessionID>
				<cfelse>
					<cfset local.value = "">
				</cfif>
			<cfelse>
				<cfset local.value = structNew()>
				<cfloop list="#structKeyList(session[application.applicationName])#" index="local.key">
					<cfset local.value[local.key] = get(local.key)>
				</cfloop>
			</cfif>
		<cfelse>
			<cfset local.value = "">
		</cfif>
        
		<cfreturn local.value>
	</cffunction>

	<cffunction name="delete" access="public" returntype="void">
		<cfargument name="key" type="string" required="true">
	
		<cfset StructDelete(session[application.applicationName], arguments.key, false)>
	</cffunction>

	<cffunction name="exists" access="public" returntype="boolean">
		<cfargument name="key" type="string" required="true">
		<cfif StructKeyExists(session[application.applicationName], arguments.key)>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>

	<cffunction name="initialised" access="public" returntype="boolean">
		<cfif StructKeyExists(session, application.ApplicationName)>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>

	<cffunction name="clear" access="public" returntype="void">
		<cfset StructDelete(session, application.applicationName)>
		<cfset create()>
	</cffunction>

	<cffunction name="setSiteView" access="public" returntype="void">
		<cfargument name="siteView" type="string" required="true">

		<cfset set("SiteView","League")>
			<cfset set("siteTemplate",getFactory().getSetting("defaultleagueTemplate"))>
			<cfif Len(getFactory().get("login").model.getUser().user.leagueLogo)>
                <cfset set("SiteLogo",getFactory().get("login").model.getUser().user.leagueLogo)>
            <cfelse>
                <cfset set("SiteLogo",getFactory().getSetting("defaultleagueLogo"))>
            </cfif>
	</cffunction>    
</cfcomponent>