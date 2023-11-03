<cfcomponent name="Factory" extends="parent" hint="Factory/Manager">

	<cffunction name="init" returntype="Factory" access="public">
		<cfset variables.components = structNew()>
		<cfset variables.settings = structNew()>

		<cfset super.init()>
		<cfreturn this>
	</cffunction>

	<cffunction name="load" returntype="void" access="public">
		<cfargument name="config" type="welshrugby.model.config" required="false" hint="Configuration file from config.xml">
		<cfargument name="components" type="string" required="false" default="" hint="List of component(s)">

		<cfset var local = structNew()>

		<cfset local.config = arguments.config.getConfig()>
		<cfset variables.config = local.config>

		<cftry>
			<cfif Len(arguments.components)>
				<!--- reload specified components - can only do after the initial load --->
				<cfloop list="#arguments.components#" index="local.com">
					<cfloop list="#structKeyList(local.config.components[local.com])#" index="local.sub">
						<cftry>
							<cfset set(local.com, local.sub,
									createObject("component", local.config.components[local.com][local.sub].path).init())>
							<cfcatch type="any">
								<cfdump var="#cfcatch#" expand="false">
							</cfcatch>
						</cftry>
					</cfloop>
				</cfloop>
			<cfelse>
				<cflock name="#application.ApplicationName#_components" type="exclusive" timeout="60">
					<!--- use the config file passed in and create variables.components keys (structures) for each configured
						object group and then create the instances --->
					<cfloop list="#StructKeyList(local.config.settings)#" index="local.key">
						<cfset setSetting(local.key, local.config.settings[local.key])>
					</cfloop>
					<cfloop list="#local.config.componentLoadOrder#" index="local.com">
						<cfset create(local.com)>
						<cfloop list="#structKeyList(local.config.components[local.com])#" index="local.sub">
							<cftry>
								<cfset set(local.com, local.sub,
										createObject("component", local.config.components[local.com][local.sub].path).init())>
								<cfcatch type="any">
									<cfdump var="#cfcatch#" expand="false">
								</cfcatch>
							</cftry>
						</cfloop>
					</cfloop>
				</cflock>
			</cfif>

			<cfcatch type="any">
				<cfdump var="#cfcatch#" expand="false">
			</cfcatch>
		</cftry>

		<cfif Len(arguments.components)>
			<cfloop list="#arguments.components#" index="local.com">
				<cfloop list="#StructKeyList(local.config.components[local.com])#" index="local.sub">
					<cfset local.family = get(local.com)>
					<cfset local.component = local.family[local.sub]>
					<cfloop list="#local.config.components[local.com][local.sub].postExecute#" index="local.fnc">
						<cfinvoke component="#local.component#" method="#local.fnc#"></cfinvoke>
					</cfloop>
				</cfloop>
			</cfloop>
		<cfelse>
			<cfloop list="#local.config.componentLoadOrder#" index="local.com">
				<cfloop list="#StructKeyList(local.config.components[local.com])#" index="local.sub">
					<cftry>
						<cfset local.family = get(local.com)>
						<cfset local.component = local.family[local.sub]>
						<cfloop list="#local.config.components[local.com][local.sub].postExecute#" index="local.fnc">
							<cfinvoke component="#local.component#" method="#local.fnc#"></cfinvoke>
						</cfloop>
						<cfcatch type="any">
							<cfdump var="#cfcatch#" expand="false">
						</cfcatch>
					</cftry>
				</cfloop>
			</cfloop>
		</cfif>
			
	</cffunction>

	<cffunction name="getResult" returntype="struct" hint="Generic function used to create a structure used as a standard way of storing results returned from a function">
		<cfset var local = structNew()>
		<cfset local = structNew()>
		<cfset local.success = true>
		<cfset local.output = "">
		<cfset local.restrictOutput = false>
		<cfset local.breadcrumb = "">
		<cfset local.title = "">
		<cfset local.indent = true>
		<cfset local.error = "">
		<cfreturn local>
	</cffunction>

	<cffunction name="create" access="public" returntype="void" hint="Creates key-level struct to hold components">
		<cfargument name="name" type="string" required="true">
		
		<cfset StructInsert(variables.components, arguments.name, structNew())>
	</cffunction>

	<cffunction name="set" access="public" returntype="void" roles="" output="no" hint="Sets a component in the IceFactory">
		<cfargument name="parent" type="string" required="true" hint="The key in variables.components">
		<cfargument name="name" required="yes" type="string" hint="The sub-name in variables.components[arguments.parent] under which to store the CFC" />
		<cfargument name="component" type="any" required="yes" hint="A CFC instance used by the application" />

		<cfset StructInsert(variables.components[arguments.parent], arguments.name, arguments.component, true)>
	</cffunction>

	<cffunction name="get" access="public" returntype="any" output="false" hint="Returns the specified component.">
		<cfargument name="name" required="yes" type="string" />

		<cfset var local = structNew()>

		<cfsilent>
			<cflock name="#application.ApplicationName#_components" type="readonly" timeout="7">
				<cfif exists(trim(arguments.name))>
					<cfset local.retrieved = variables.components[trim(arguments.name)]>
				<cfelse>
                    <cfdump var="No such component '#arguments.name#' in Factory. Components that exist: #ListSort(getComponentList(),'textnocase','asc')#" expand="false">
					<cfset local.retrieved = StructNew()>
				</cfif>
			</cflock>
		</cfsilent>
		
		<cfreturn local.retrieved>
	</cffunction>

	<cffunction name="exists" access="public" returntype="boolean">
		<cfargument name="component" type="string" required="true">

		<cfreturn structKeyExists(variables.components, arguments.component)>
	</cffunction>

	<cffunction name="getDatasource" access="public" returntype="string">
		<cfargument name="alias" type="string" required="true">
		
		<cfreturn variables.config.datasources[arguments.alias]>
	</cffunction>

	<cffunction name="getComponentList" returntype="string" access="public">
		<cfreturn StructKeyList(variables.components)>
	</cffunction>

	<cffunction name="setSetting" returntype="void" access="private">
		<cfargument name="key" type="string" required="true">
		<cfargument name="value" type="any" required="true">
		
		<cfset variables.settings[arguments.key] = arguments.value>
	</cffunction>

	<cffunction name="getSetting" returntype="any" access="public" output="false">
		<cfargument name="key" type="string" required="false" default="">
		
		<cfif Len(arguments.key)>
			<cftry>
				<cfreturn trim(variables.settings[arguments.key])>
				<cfcatch type="any">
					<cfreturn "">
				</cfcatch>
			</cftry>
		<cfelse>
			<cfreturn variables.settings>
		</cfif>
	</cffunction>

</cfcomponent>
