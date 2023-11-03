<cfcomponent name="parent" hint="Parent for Controllers" extends="welshrugby.parent">
	<cffunction name="init" returntype="parent" access="public">
		<cfset super.init()>
		<cfset variables.breadcrumb = "">
		<cfreturn this/>
	</cffunction>

</cfcomponent>