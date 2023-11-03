<cfcomponent name="login" extends="parent" hint="View for login">
	<cffunction name="init" returntype="login" access="public">
		<cfset var local = structNew()>

		<cfset super.init()>
		<cfreturn this/>
	</cffunction>

	<cffunction name="default" access="private" returntype="struct" hint="default view for this component">
		<cfargument name="data" type="struct" required="false">
		<cfargument name="step" type="numeric" required="false" default="0">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
        #login(arguments.data,arguments.step).output#
		<cfreturn local.result>
	</cffunction>
    
	<cffunction name="login" access="private" returntype="struct" hint="Displays the login form">
		<cfargument name="data" type="struct" required="false">
		<cfargument name="step" type="numeric" required="false" default="0">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		<cfset local.result.title = "Please Log in">
		
		<cfparam name="arguments.data.username" default="">

		<cfsavecontent variable="local.result.output">
			<cfoutput>
                <form action="/login" method="POST" id="user-login" class="was-validated">
					<input type="hidden" name="step" id="step" value="#arguments.step#">
					#getFactory().get("formFactory").view.display(method="inputText", id="username", label="Username", value=arguments.data.username, required=true, loginScreen=true).output#

					#getFactory().get("formFactory").view.display(method="inputText", id="password", label="Password", value="", required=true, loginScreen=true, showRepeat=false, password=true).output#
					
                    <input type="submit" name="doLogin" id="doLogin" value="Login" class="btn btn-dark mt-2">
				</form>
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>

</cfcomponent>