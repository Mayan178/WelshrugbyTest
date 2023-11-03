<cfcomponent name="application" extends="parent" hint="Model, queries and logic for application">
	<cffunction name="init" access="public" returntype="application">
		<cfset super.init()>
		<cfreturn this/>
	</cffunction>

	<cffunction name="create" access="public" returntype="boolean" hint="Creates a session structure and populates it">
		<cfif NOT StructKeyExists(application, application.ApplicationName)>
			<cfset application[application.applicationName] = StructNew()>
			
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>

	<cffunction name="set" access="public" returntype="any" hint="Sets a application variable">
		<cfargument name="key" type="string" required="true">
		<cfargument name="value" type="Any" required="true">
		<cfset application[application.applicationName][trim(arguments.key)] = arguments.value>
	</cffunction>

	<cffunction name="param" access="public" returntype="any" hint="Sets a application variable if not set">
		<cfargument name="key" type="string" required="true">
		<cfargument name="value" type="Any" required="true">

		<cfif NOT StructKeyExists(application[application.applicationName], arguments.key)>
			<cfset application[application.applicationName][arguments.key] = arguments.value>
		</cfif>
	</cffunction>

	<cffunction name="get" access="public" returntype="any" hint="Gets a application variable">
		<cfargument name="key" type="string" required="false" default="">

		<cfif create()>
	 		<cfif Len(arguments.key)>
				<cfif StructKeyExists(application[application.applicationName], arguments.key)>
					<cfreturn application[application.applicationName][arguments.key]>
				<cfelse>
					<cfreturn ""/>
				</cfif>
			<cfelse>
				<cfreturn application[application.applicationName]>
			</cfif>
		<cfelse>
			<cfreturn "">
		</cfif>
	</cffunction>

	<cffunction name="delete" access="public" returntype="void">
		<cfargument name="key" type="string" required="true">
	
		<cfset StructDelete(application[application.applicationName], arguments.key, false)>
	</cffunction>

	<cffunction name="exists" access="public" returntype="boolean">
		<cfargument name="key" type="string" required="true">
		<cfif StructKeyExists(application[application.applicationName], arguments.key)>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>

</cfcomponent>