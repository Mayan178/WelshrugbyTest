<!--- *** DON'T EXTEND *** - this gets created for EVERY request --->
<cfcomponent name="scope" output="false" hint="Maintains variables for the current scope">

	<cfset variables.scope = StructNew()>

    <cffunction name="init" access="public" returntype="scope">

		<cfset var local = structNew()>

		<cfparam name="request.scopeCall" default="0">
		<cfset request.ScopeCall++>

		<!--- loop through the args, with various possible delimiters. First half of pair is the key, second half is the value --->
		<cfset set("SCRIPT_NAME", ListGetAt(url.original, 1, "?"))>

		<!--- strangeness with double occurence of url parameter original coming through on some site set-ups --->
		<cfset set("SCRIPT_NAME", ReReplace(get("SCRIPT_NAME"), "\n", " ", "ALL"))>

		<!--- sort out spaces occuring in URLs --->
		<cfif ListLen(get("SCRIPT_NAME"), " ") gt 1>
			<cfif ListGetAt(get("SCRIPT_NAME"), 1, " ") eq ListGetAt(get("SCRIPT_NAME"), 2, " ")>
				<cfset set("SCRIPT_NAME", Replace(ListFirst(get("SCRIPT_NAME"), " "), " ", "", "ALL"))>
			</cfif>
		</cfif>

		<cfif ListLen(url.original, "?") gt 1>
			<cfset set("QUERY_STRING", ListGetAt(url.original, 2, "?"))>
		<cfelse>
			<cfset set("QUERY_STRING", "")>
		</cfif>
		<cfset set("QUERY_STRING", ReReplace(get("QUERY_STRING"), "\n", " ", "ALL"))>
		<cfset set("QUERY_STRING", ListFirst(get("QUERY_STRING"), " "))>

		<cfset set("REWRITE", cgi.SCRIPT_NAME & "?" & cgi.QUERY_STRING)>
	
		<cfset set("VIEW_METHOD", false)>
		<cfset set("ASSUMED_METHOD", false)>
        
    	<cfset set("SERVER_NAME", cgi.SERVER_NAME)>
		<cfset set("REMOTE_HOST", cgi.REMOTE_HOST)>
		<cfset set("HTTP_REFERER", cgi.HTTP_REFERER)>

		<cfif cgi.SERVER_PORT_SECURE>
			<cfset set("HTTPS", true)>
		<cfelse>
			<cfset set("HTTPS", false)>
		</cfif>

		<cfset local.startArgs = 0>
		<cfloop from="1" to="#ListLen(get('SCRIPT_NAME'),'/')#" index="local.i">
			<cfset local.item = ListGetAt(get("SCRIPT_NAME"), local.i, "/")>
			<cfif local.i eq 1>
				<cfset set("component", local.item)>
			<cfelseif local.i eq 2>
				<cftry>
					<cfif application.factory.exists(get("component")) AND FindNoCase(local.item, application.factory.get(get("component")).controller.getFunctions())>
						<cfset set("method", local.item)>
						<cfset local.startArgs = local.i+1>
					<cfelseif application.factory.exists(get("component")) AND StructKeyExists(application.factory.get(get("component")), "view")
							AND FindNoCase(local.item, application.factory.get(get("component")).view.getFunctions())>
						<cfset set("method", local.item)>
						<cfset local.startArgs = local.i+1>
						<cfset set("VIEW_METHOD", true)>
					<cfelse>
                    	<cfif local.item neq "page">
                        <!---
							<cfset request.monitor.debug("The method &quot;#local.item#&quot; is not a valid method of controller.#get('component')#. Reported from anachem.model.scope", true)>--->
                            <cfset set("method", "default")>
                            <cfset set("ASSUMED_METHOD", true)>
                            <cfset local.startArgs = local.i>
                            <!---cfset application.factory.get("icicle").controller.debug(get())--->
                        <cfelse>
                        	<cfset set("component", ListGetAt(get("SCRIPT_NAME"), 1, "/"))>
                            <cfset set("page", ListLast(get("SCRIPT_NAME"),"/"))>
                        </cfif>
					</cfif>
					<cfcatch type="any">
						<cftry>
                        <!---
							<cfset request.monitor.Alert(note="Something wrong in scope.cfc when trying to use #get('component')# - #cfcatch.message#", severity="Critical", state=get(), catch=cfcatch)>--->
							<cfcatch type="any">
								<cftry>
                                <!---
									<cfset request.monitor.Alert(note="Scope.cfc exited abnormally", severity="Critical", state=get(), catch=cfcatch)>--->
									<cfcatch type="any"><cfdump var="#cfcatch#"></cfcatch>
								</cftry>
							</cfcatch>
						</cftry>
					</cfcatch>
				</cftry>
			</cfif>
		</cfloop>
		<cfif NOT exists("component")>
			<cfset set("component", "default")>
		</cfif>
		<cfif NOT exists("method")>
			<cfset set("method", "default")>
		</cfif>
		
		<!--- now get remaining args by assuming first hit out of two is a key name, and the second is the value --->
		<cfif local.startArgs>
			<cfset local.bKey = true>		
			<cfloop from="#local.startArgs#" to="#ListLen(get('SCRIPT_NAME'),'/')#" index="local.i">
				<cfif local.bKey>
					<cfset local.key = ListGetAt(get("SCRIPT_NAME"), local.i, "/")>
					<cfset local.bKey = false>
				<cfelse>
					<cfset local.value= ListGetAt(get("SCRIPT_NAME"), local.i, "/")>
					<cfset set(local.key, local.value)>

					<cfset local.bKey = true>
				</cfif>
			</cfloop>
		</cfif>

		<cfif len(get("QUERY_STRING"))>
			<cfloop from="1" to="#ListLen(get('QUERY_STRING'),'&')#" index="local.i">
				<cfset local.pair = listGetAt(get("QUERY_STRING"),local.i, "&")>
				<cfset local.key = ListGetAt(local.pair, 1, "=")>
				<cfif ListLen(local.pair, "=") eq 1>
					<cfset local.value = "">
				<cfelse>
					<cfset local.value = listGetAt(local.pair, 2, "=")>
				</cfif>
				<cfset set(local.key, local.value)>
			</cfloop>
		</cfif>
		
		<!--- now pick up anything from the FORM, overriding anything previously stored --->
		<cfif isDefined("FORM")>
			<cfloop list="#structKeyList(form)#" index="local.key">
            	<cfset set(local.key, form[local.key])>
			</cfloop>
		</cfif>

<!--- DEBUG FOR REGEX matching - DO NOT DELETE EVEN IF YOU THINK YOU WILL NEVER USE IT!!!!

<cfset local.startlist = "/paf,/paf/,/paf/migration,/paf/migration/,/paf/migration?reload=true&wibble=1,/paf/migration/?reload=true&wibble=1,/paf/migration/postcode/sg2 7dz/country/uk">

<cfoutput>#cgi.SCRIPT_NAME#?#cgi.QUERY_STRING#<p></p></cfoutput>
<cfloop list="#local.startlist#" index="local.start">
	<cfset local.match = "^/([^/?]+)?/?([^/?]+)?/?\??(.*)?$">

	<cfset local.pattern = "\1|\2|\3|\4|\5">
	<cfset local.url = ReReplaceNoCase(local.start,local.match,local.pattern)>
	<cfoutput><p>#local.start#</p></cfoutput>
	<cfoutput><p>#local.url#</p></cfoutput>
	
	<cfset local.pattern = "/index.cfm?action=\1&method=\2&\3">
	<cfset local.url = ReReplaceNoCase(local.start,local.match,local.pattern)>
	<cfoutput><p>#local.url#</p></cfoutput>
	<cfoutput><hr></cfoutput>
</cfloop>

<cfdump var="#url#">
<cfabort>
--->
		<cfreturn this>
	</cffunction>

	<cffunction name="exists" access="public" returntype="boolean">
		<cfargument name="key" required="true" type="string">
		<cfif StructKeyExists(variables.scope, arguments.key)>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>

	<cffunction name="get" access="public" returntype="any" output="false">
		<cfargument name="key" required="false" default="" type="string">
		<cfsilent>
			<cfif Len(arguments.key) eq 0>
				<cfreturn variables.scope>
			<cfelse>
				<cfif StructKeyExists(variables.scope, arguments.key)>
					<cfreturn variables.scope[arguments.key]>
				<cfelse>
					<cfreturn "">
				</cfif>
			</cfif>
		</cfsilent>
	</cffunction>

	<cffunction name="delete" access="public" returntype="void" output="false">
		<cfargument name="key" required="false" default="" type="string">
		<cfset StructDelete(variables.scope, arguments.key)>
	</cffunction>

	<cffunction name="set" access="public" returntype="struct" output="false">
		<cfargument name="key" type="string" required="true">
		<cfargument name="value" type="any" required="true">

		<!--- might be useful 
		<cfif arguments.key eq "HTTPS">
			<cftry>
				<cfset StackTrace()>
				<cfset request.monitor.alert(note="#arguments.key# set to #arguments.value#. StackTrace attached as state", state=request.stackTraces)>
				<cfcatch type="any"><cfdump var="#cfcatch#"></cfcatch>
			</cftry>
		</cfif>
		--->

		<cfsilent>
			<cfset variables.scope[arguments.key] = arguments.value>
			<cfreturn get()>
		</cfsilent>
	</cffunction>

	<cffunction name="getURL" access="public" returntype="string">
		<cfreturn get("request")>
	</cffunction>

	<cffunction name="param" access="public" returntype="void">
		<cfargument name="key" required="true" type="string">
		<cfargument name="value" required="true" type="any">

		<cfif NOT exists(arguments.key)>
			<cfset set(arguments.key, arguments.value)>
		</cfif>
	</cffunction>

	<cffunction name="StackTrace" access="public" returntype="void" output="false">
	 
		<!--- Define local variables. --->
		<cfset var Trace = StructNew() />
		<cfparam name="request.stackTraces" default="#arrayNew(1)#">
		<cftry>
			<!--- Throw custom error. --->
			<cfthrow
				message="This is thrown to gain access to the strack trace."
				type="StackTrace"
			/>
			<!--- Catch custom error so that page doesn't crap out. --->
			<cfcatch>
				<!---
				Create the trace object. The automatically
				generated CFCATCH object (from CFTry/CFCatch)
				should now have key elements that we can get
				our hands on.
				--->
				<cfset Trace.StackTrace = CFCATCH.StackTrace />
				<cfset Trace.TagContext = CFCATCH.TagContext />
				 
				<!--- Add stack trace to request. --->
				<cfset ArrayAppend(
					REQUEST.StackTraces,
					Trace
				) />
			</cfcatch>
		</cftry>
		 
		<!--- Return out. --->
		<cfreturn />
	</cffunction>

</cfcomponent>