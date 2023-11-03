<cfcomponent name="Core">
	<cffunction name="init" access="public" returntype="Core">
		<cfset var local = structNew()>
		<cfset variables.config = structNew()>

		<!--- Get the real, actual BOX name --->
		<cfset set("computerName", CreateObject("java", "java.lang.System").getEnv("COMPUTERNAME"))>
		<cfset set("domainName", cgi.SERVER_NAME)>

		<!--- load file-based xml into this CFC--->
		<cfset local.cfcPath = getDirectoryFromPath(getCurrentTemplatePath())>
		<cffile action="read" file="#local.cfcPath#..\config\core.xml" variable="local.rawData">
		<cfset local.xml = xmlParse(local.rawData)>
		
		<!--- load into config and get the current site --->
		<cfloop from="1" to="#ArrayLen(local.xml.sites.site)#" index="local.i">
			<cfset local.useThis = false>
			<cfloop list="#local.xml.sites.site[local.i].xmlAttributes.domains#" index="local.dom">
				<!--- see if the list of domains contains the current server name --->
				<cfif local.dom eq cgi.SERVER_NAME>
					<cfset local.useThis = true>
					<cfbreak>
				</cfif>
			</cfloop>
            
			<cfif local.useThis>
				<!--- load the site attributes --->
				<cfloop list="#StructKeyList(local.xml.sites.site[local.i].xmlAttributes)#" index="local.a">
					<cfset set(local.a, local.xml.sites.site[local.i].xmlAttributes[local.a])>
				</cfloop>

				<!--- set the application.this scope settings --->
				<cfloop from="1" to="#ArrayLen(local.xml.sites.site[local.i].setting)#" index="local.s">
					<cfset local.settingName = local.xml.sites.site[local.i].setting[local.s].xmlAttributes.name>
					<cfset local.settingValue = local.xml.sites.site[local.i].setting[local.s].xmlAttributes.value>
					<cfif StructKeyExists(local.xml.sites.site[local.i].setting[local.s].xmlAttributes, "eval")
							AND local.xml.sites.site[local.i].setting[local.s].xmlAttributes.eval
					>
						<cfset set(local.settingName, Evaluate(local.settingValue))>
					<cfelse>
						<cfset set(local.settingName, local.settingValue)>
					</cfif>
				</cfloop>

				<!--- and now, work out the dynamic settings --->
				<cfif StructKeyExists(local.xml.sites.site[local.i], "settings")>
					<cfloop from="1" to="#ArrayLen(local.xml.sites.site[local.i].settings.dependant)#" index="local.d">
						<!---cfdump var="#local.xml.sites.site[local.i].settings.dependant[local.d]#" expand="false"--->
						<cftry>
							<cfset local.evaluateExpression = local.xml.sites.site[local.i].settings.dependant[local.d].xmlAttributes["evaluate"]>
							<cfset local.evaluatedValue = Evaluate(local.evaluateExpression)>
							<cfset local.settingCompareTo = local.xml.sites.site[local.i].settings.dependant[local.d].xmlAttributes["compareTo"]>
	
							<cfif local.evaluatedValue eq local.settingCompareTo>
								<cfset local.settingName = local.xml.sites.site[local.i].settings.dependant[local.d].xmlAttributes["name"]>
								<cfset local.settingValue = local.xml.sites.site[local.i].settings.dependant[local.d].xmlAttributes["value"]>
								
								<cfset set(local.settingName, local.settingValue)>
							</cfif>
	
							<cfcatch type="any">
								<cfdump var="#cfcatch#" expand="false" label="cfcatch">
							</cfcatch>
						</cftry>
					</cfloop>
				</cfif>

				<cfbreak>
			</cfif>
		</cfloop>

		<cfif NOT local.useThis>
			<cfabort showerror="Unable to find a configuration in core.xml for #cgi.SERVER_NAME#">
		</cfif>

		<cfreturn this/>
	</cffunction>

	<cffunction name="get" returntype="any" access="public" output="false">
		<cfargument name="key" type="string" required="false" default="">

		<cfif Len(arguments.key) eq 0>
			<cfreturn variables.application>
		<cfelseif exists(arguments.key)>
			<cfreturn variables.application[arguments.key]>
		<cfelse>
			<cfreturn "">
		</cfif>
	</cffunction>

	<cffunction name="set" returntype="any" access="private">
		<cfargument name="key" type="string" required="true">
		<cfargument name="value" type="any" required="true">
		
		<cfset variables.application[arguments.key] = arguments.value>
	</cffunction>

	<cffunction name="exists" returntype="boolean" access="private">
		<cfargument name="key" type="string" required="true">
		
		<cfreturn StructKeyExists(variables.application, arguments.key)>
	</cffunction>

</cfcomponent>