<cfcomponent name="parent" hint="Global Parent">

	<cffunction name="init" returntype="parent">
		<cfset variables.metadata = StructNew()>
		<cfset variables.metadata.name = getMetaData(this).name>

		<cfset setObjectType()>
		<cfset setName()>
		<cfset setFunctions()>

		<cfreturn this>
	</cffunction>
	
	<cffunction name="getFactory" returntype="Factory" output="false">
		<cfreturn application.Factory>
	</cffunction>
	
	<cffunction name="getController" access="public" returntype="any">
		<cfset var local = structNew()>
		<cfset local.group = getFactory().get(getObjectType())>
		<cfif StructKeyExists(local.group, "controller")>
			<cfreturn local.group.controller>
		<cfelse>
			<cfreturn structNew()>
		</cfif>
	</cffunction>

	<cffunction name="getView" access="public" returntype="any">
		<cfreturn getFactory().get(getObjectType()).view>
	</cffunction>

	<cffunction name="getModel" access="public" returntype="any">
		<cfreturn getFactory().get(getObjectType()).model>
	</cffunction>

	<cffunction name="setSub" access="public" returntype="void">
		<cfargument name="name" required="true" type="string" hint="The sub-name to be used as the key inside this object">
		<cfargument name="object" required="true" type="any" hint="">
	</cffunction>

	<cffunction name="getType" access="public" returntype="string" output="false">
		<cfreturn getObjectType()>
	</cffunction>

	<cffunction name="getObjectType" access="public" returntype="string" output="false">
		<cfreturn variables.shortObjectType>
	</cffunction>

	<cffunction name="setObjectType" access="private" returntype="void" hint="ABSTRACT Sets objectType property">
		<cfset variables.objectType = variables.metadata.name>
		<cfset variables.shortObjectType = ListLast(variables.objectType, ".")>
	</cffunction>

	<cffunction name="setName" access="private" returntype="void">
		<cfset variables.name = variables.metadata.name>
	</cffunction>

	<cffunction name="getName" access="public" returntype="string" output="false">
		<cfreturn variables.name>
	</cffunction>

	<cffunction name="setFunctions" access="private" returntype="void">

		<cfset var local = structNew()>
		<cfset local.functions = "">
		<cfset local.displayMethods = "">

		<cfloop from="1" to="#arrayLen(getMetaData().functions)#" index="local.i">
			<cfset local.fnc = getMetaData().functions[local.i]>
			<cfset local.functions = listAppend(local.functions, local.fnc.name)>

			<cfif (FindNoCase(".view", getName()))
					AND	(((StructKeyExists(local.fnc, "access") AND local.fnc.access eq "public") OR NOT StructKeyExists(local.fnc, "access"))
					OR (StructKeyExists(local.fnc, "returnType") AND local.fnc.access eq "struct"))>
				<cfset local.displayMethods = listAppend(local.displayMethods, getMetaData().functions[local.i].name)>
			</cfif>
		</cfloop>
		
		<cfset variables.functions = local.functions>
		<cfset variables.displaymethods = local.displayMethods>
		
	</cffunction>

	<cffunction name="getFunctions" access="public" returntype="string">
		<cfreturn variables.functions>
	</cffunction>

	<cffunction name="getDisplayMethods" access="public" returntype="string">
		<cfreturn variables.displayMethods>
	</cffunction>

</cfcomponent>