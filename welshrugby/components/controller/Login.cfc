<cfcomponent name="login" extends="parent" hint="Controller for login">
	
	<cffunction name="init" returntype="login" access="public">
		<cfset super.init()>
		<cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "Login|login")>
		<cfreturn this/>
	</cffunction>

	<cffunction name="default" access="public" returntype="struct" hint="Default behaviour for this component">
		<cfargument name="data" type="struct" required="false">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        <!--- user is not logged in. Show the login page  --->	
		<cfif NOT getModel().isLoggedIn()>
			<cfset local.result = login(data=arguments.data)>
		<!--- user is logged in. Show the homepage --->
		<cfelse>
			<cfset local.result = getFactory().get("home").controller.default(data=arguments.data)>
		</cfif>
		
		<cfreturn local.result>
	</cffunction>
	
	<cffunction name="login" access="public" returntype="struct">
		<cfargument name="data" type="struct" required="false">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		<cfset local.data = arguments.data>
		
		<!--- initialise step control with 0 as the initial (unvalidated) state --->
		<cfif NOT StructKeyExists(local.data, "step")>
			<cfset local.step = 0>
		<cfelse>
			<cfset local.step = local.data.step>
		</cfif>
		
		<!--- Validation and step control --->
		<cfswitch expression="#local.step#">
			<cfcase value="0">
				<!--- step into the first screen --->
				<cfset local.step++>
			</cfcase>

			<cfcase value="1">
				<cfset local.step++>
			</cfcase>
		</cfswitch>

		<cfswitch expression="#local.step#">
			<cfcase value="1">
				<cfset local.result = getView().display(method="login", data=local.data, step=local.step)>
			</cfcase>
			<cfcase value="2">
            	<!--- try to login the user --->
				<cfset local.login = getModel().login(
						username=arguments.data.username,
						password=arguments.data.password
				)>
                
                <!--- the user is successfull, take to homepage --->
				<cfif local.login.success>
                	<cfset getFactory().get("session").model.set("returnURL", "/home")>
					<!--- if successfull send the user to their homepage --->
					<cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
							getFactory().get("session").model.get("returnURL"),
							getFactory().get("template").view.success(getModel().getMessage("success","1","title"),getModel().getMessage("success","1","summary"),"50%").output,
							1
					)>
                <!--- the user fails to login, take back to login page --->
				<cfelse>
                	<cfset getFactory().get("session").model.set("returnURL", "/login")>
                    <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
							getFactory().get("session").model.get("returnURL"),
							getFactory().get("template").view.failure(getModel().getMessage("failure","1","title"), local.login.output).output,
							1
					)>
				</cfif>
			</cfcase>
		</cfswitch>

		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="logout" access="public" returntype="struct" hint="Controller triggering the user to be logged out">
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

		<cfset local.logout = getFactory().get("user").model.logout()>
		
        <cfset getFactory().get("session").model.set("returnURL", "/")>
            <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
                getFactory().get("session").model.get("returnURL"),
                getFactory().get("template").view.success(getModel().getMessage("success","2","title"), local.result.output,"50%").output, 1
            )>

		<cfreturn local.result>
	</cffunction>	
	
</cfcomponent>
