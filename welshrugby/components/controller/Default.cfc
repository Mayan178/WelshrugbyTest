s<cfcomponent name="default" extends="parent" hint="Controller for Default behaviour">
	<cffunction name="init" returntype="default" access="public">
		<cfset super.init()>
		<cfreturn this/>
	</cffunction>

	<cffunction name="default" access="public" returntype="struct" hint="Default behaviour for this component">
		<cfargument name="data" type="struct" required="false">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		<!--- if the user is not logged in, he/she cannot see the homepage...so take to login page --->
		<cfif NOT getFactory().get("login").model.isLoggedIn()>
        	<cfset local.result = getFactory().get("login").controller.default(arguments.data)>
		<!--- user logged in, take to the Home Controller component --->
		<cfelse>
			<cfset local.result = getFactory().get("home").controller.default(arguments.data)>
		</cfif>
		
		<cfreturn local.result>
	</cffunction>

</cfcomponent>