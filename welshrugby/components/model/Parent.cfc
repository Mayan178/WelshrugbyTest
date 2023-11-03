<cfcomponent name="parent" hint="Parent for Models" extends="welshrugby.parent">

	<cffunction name="init" returntype="parent" access="public">
		<cfset super.init()>
		<cfreturn this/>
	</cffunction>

</cfcomponent>