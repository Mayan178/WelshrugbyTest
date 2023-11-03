<cfcomponent name="home" extends="parent" hint="Controller for the homepage">
	
	<cffunction name="init" returntype="home" access="public">
		<cfset super.init()>
		<cfreturn this/>
	</cffunction>

	<cffunction name="default" access="public" returntype="struct" hint="Default behaviour for this component">
		<cfargument name="data" type="struct" required="false">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        
		<!--- if the user is not logged in, he/she cannot see the homepage...so redirect to login page --->
		<cfif NOT getFactory().get("login").model.isLoggedIn()>
            <cfset getFactory().get("session").model.set("returnURL", "/login")>
            
            <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
			getFactory().get("session").model.get("returnURL"),
			getFactory().get("template").view.failure(getModel().getMessage("failure","2","title"),"","50%").output,
			1
			)>
		<!--- user logged in, view the homepage --->
		<cfelse>
			<cfset local.result = homepage(data=arguments.data)>
		</cfif>
		
		<cfreturn local.result>
	</cffunction>
	
    <cffunction name="homepage" access="public" returntype="struct" hint="User defined homepage">
		<cfargument name="data" type="struct" required="false">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
		<!--- if the user is not logged in, he/she cannot see the homepage...so redirect to login page --->
		<cfif NOT getFactory().get("login").model.isLoggedIn()>
            <cfset getFactory().get("session").model.set("returnURL", "/login")>
            <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
			getFactory().get("session").model.get("returnURL"),
			getFactory().get("template").view.failure(getModel().getMessage("failure","2","title"),"","50%").output,
			1
			)>
		<!--- user logged in --->
		<cfelse>
            
			<cfset local.data = structNew()>
			<!--- get information for current logged in user --->
			<cfset local.data.user = getFactory().get("login").model.getUser()>
            <!--- get the top 10 CSR for league players --->
            <cfset local.data.top10CSR = getFactory().get("leagueplayers").model.gettop10CSR()>
            
			<cfset local.result = getView().display(method="default", data=local.data)>
			<!--- page title and breadcrumb --->
            <cfset local.result.title = "Welcome #getFactory().get("login").model.getUser().user.username#!">
			<cfset local.result.breadcrumb = variables.breadcrumb>
		</cfif>
		
		<cfreturn local.result>
	</cffunction>
    
	

</cfcomponent>
