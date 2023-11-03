<cfcomponent name="Config">
	<cffunction name="init" access="public" returntype="config">
		<cfset var local = structNew()>

		<!--- load into config --->
		<cfset variables.config = structNew()>
		<cfset variables.config.componentLoadOrder = "">
		<cfset variables.config.components = structNew()>
		<cfset variables.config.settings = structNew()>
		<cfset variables.config.datasources = structNew()>
        
        <cfset local.debug = false>

		<!--- set the server name with Java magic --->
		<cfset local.system = CreateObject("java", "java.lang.System")>
		<cfset set("settings", "serverName", local.system.getEnv().computerName)>
		<cfset set("settings", "domainName", cgi.SERVER_NAME)>

		<!--- load file-based xml into this CFC--->
		<cfset local.cfcPath = getDirectoryFromPath(getCurrentTemplatePath())>
		<cffile action="read" file="#local.cfcPath#..\..\config\#application.core.get('configFolder')#\config.xml" variable="local.rawData">
		<cfset local.xml = xmlParse(local.rawData)>

		<!--- Determine site --->
		<cfset local.site = "">
		<cfloop from="1" to="#ArrayLen(local.xml.factory.site)#" index="local.i">
			<cfif local.xml.factory.site[local.i].xmlAttributes.name eq application.core.get("applicationName")>
				<cfset local.site = local.xml.factory.site[local.i]>
				<cfbreak>
			</cfif>
		</cfloop>

		<!--- error trap for site --->
		<cfif NOT isXML(local.site)>
        	<cfif local.debug>
            	<cfdump var="No site configured for #application.core.get("applicationName")#">
            </cfif>
			<cfthrow type="application" message="Unable to start-up" detail="#local.site#">
		</cfif>

		<!--- get environment section ...that bit was commented out --->
		<cfset local.environment = "">
		<cfloop from="1" to="#ArrayLen(local.site.environment)#" index="local.i">
			<cfif local.site.environment[local.i].xmlAttributes.domainName eq get("domainName")>
				<cfset local.environment = local.site.environment[local.i]>
				<!---cfset set("settings", "environment", local.environment.xmlAttributes.name)--->
				<cfbreak>
			</cfif>
		</cfloop>
		
		<!--- error trap for environment
		<cfif NOT isXML(local.site)>
        	<cfif local.debug>
            	<cfdump var="No environment configured for #application.core.get("applicationName")# using server name #get("serverName")#">
            </cfif>
			<cfthrow type="application" message="Unable to start-up" detail="#local.site#">
		</cfif> --->

		<!--- load components --->
		<cfloop from="1" to="#ArrayLen(local.site.component)#" index="local.i">
			<cfset local.comName = local.site.component[local.i].xmlAttributes.name>
			<cfset variables.config.componentLoadOrder = ListAppend(variables.config.componentLoadOrder, local.comName)>

			<cfset set("components", local.comName, structNew())>
			<cfloop from="1" to="#ArrayLen(local.site.component[local.i].xmlChildren)#" index="local.j">
				<cftry>
					<cfset local.tmpConfig = StructNew()>
					<cfset local.tmpConfig.name = local.site.component[local.i].xmlChildren[local.j].xmlName>
					<cfset local.tmpConfig.path = local.site.component[local.i].xmlChildren[local.j].xmlAttributes.path>
					<cfif StructKeyExists(local.site.component[local.i].xmlChildren[local.j].xmlAttributes, "postExecute")>
						<cfset local.tmpConfig.postExecute = local.site.component[local.i].xmlChildren[local.j].xmlAttributes.postExecute>
					<cfelse>
						<cfset local.tmpConfig.postExecute = "">
					</cfif>
					<cfset variables.config.components[local.comName][local.tmpConfig.name] = local.tmpConfig>

					<cfcatch type="any">
						<cfdump var="#local.site.component[local.i].xmlChildren[local.j]#">
						<cfabort showerror="Could not insert #local.site.component[local.i].xmlChildren[local.j].xmlName#/#local.site.component[local.i].xmlChildren[local.j].xmlAttributes.path# into the object factory in config.cfc">
                        <cfif local.debug>
                        	<cfdump var="Could not insert #local.site.component[local.i].xmlChildren[local.j].xmlName#/#local.site.component[local.i].xmlChildren[local.j].xmlAttributes.path# into the object factory in config.cfc">
                        </cfif>
					</cfcatch>
				</cftry>
			</cfloop>
		</cfloop>

		<cfif StructKeyExists(local.site, "setting")>
			<cfloop from="1" to="#ArrayLen(local.site.setting)#" index="local.i">
				<cfset local.name = local.site.setting[local.i].xmlAttributes.name>
				<cfset set("settings", local.name, local.site.setting[local.i].xmlAttributes.value)>
			</cfloop>
		</cfif>
        <!--- that next bit was commented out--->
		<cfif StructKeyExists(local.environment, "setting")>
			<cfloop from="1" to="#ArrayLen(local.environment.setting)#" index="local.i">
				<cfset local.name = local.environment.setting[local.i].xmlAttributes.name>
				<cfset set("settings", local.name, local.environment.setting[local.i].xmlAttributes.value)>
			</cfloop>
		</cfif>
		
		<cfif StructKeyExists(local.site, "datasource")>
			<cfloop from="1" to="#ArrayLen(local.site.datasource)#" index="local.i">
				<cfset local.name = local.site.datasource[local.i].xmlAttributes.name>
				<cfset set("datasources", local.name, local.site.datasource[local.i].xmlAttributes.value)>
			</cfloop>
		</cfif>
        <!---
		<cfif StructKeyExists(local.environment, "datasource")>
			<cfloop from="1" to="#ArrayLen(local.environment.datasource)#" index="local.i">
				<cfset local.name = local.environment.datasource[local.i].xmlAttributes.name>
				<cfset set("datasources", local.name, local.environment.datasource[local.i].xmlAttributes.value)>
			</cfloop>
		</cfif>--->

		<cfreturn this/>
	</cffunction>

	<cffunction name="getConfig" returntype="struct" access="public">
		<cfreturn variables.config>
	</cffunction>

	<cffunction name="get" returntype="any" access="public">
		<cfargument name="key" type="string" required="true">
		
		<cfset var local = structNew()>
		<cfif StructKeyExists(variables.config.settings, arguments.key)>
			<cfreturn variables.config.settings[arguments.key]>
		<cfelse>
			<cfreturn "">
		</cfif>

	</cffunction>

	<cffunction name="set" returntype="void" access="private">
		<cfargument name="type" type="string" required="true">
		<cfargument name="key" type="string" required="true">
		<cfargument name="value" type="any" required="true">

		<cfset variables.config[arguments.type][arguments.key] = arguments.value>
	</cffunction>
</cfcomponent>