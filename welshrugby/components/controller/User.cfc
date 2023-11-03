<cfcomponent name="user" extends="parent" hint="Controller for user">
	
	<cffunction name="init" returntype="user" access="public">
		<cfset super.init()>
		<cfreturn this/>
	</cffunction>

	<cffunction name="default" access="public" returntype="struct" hint="Default behaviour for this component">
		<cfargument name="data" type="struct" required="false">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
		<!--- if user not logged in, redirect to login page --->
		<cfif NOT getFactory().get("login").model.isLoggedIn()>
            <cfset getFactory().get("session").model.set("returnURL", "/login")>
            <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
			getFactory().get("session").model.get("returnURL"),
			getFactory().get("template").view.failure(getModel().getMessage("failure","2","title"),"","50%").output,
			1
			)>
        <!--- user is logged in. By default, show them their profile --->
		<cfelse>
			<cfset local.result = profile(data=arguments.data)>
		</cfif>
		
		<cfreturn local.result>
	</cffunction>
	
	<cffunction name="profile" access="public" returntype="struct" hint="Controller for changing a user's details">
		<cfargument name="data" type="struct" required="false">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        
        <!--- if user not logged in, redirect to login page --->
		<cfif NOT getFactory().get("login").model.isLoggedIn()>
            <cfset getFactory().get("session").model.set("returnURL", "/login")>
            <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
			getFactory().get("session").model.get("returnURL"),
			getFactory().get("template").view.failure(getModel().getMessage("failure","2","title"),"","50%").output,
			1
			)>
        <!--- user is logged in --->
		<cfelse>
        	<cfset local.data = arguments.data>
            <!--- user is trying to update their personal profile --->
            <cfif StructKeyExists(arguments.data, "update")>
                
                <!--- put through validation --->
                <cfset local.validation = getModel().validateUser(local.data)>
                <!--- there has been an error. No change in step --->
                
                <cfif ArrayLen(local.validation.errors)>
                    <cfset local.data.errors = local.validation.errors>
                    <cfset local.data.user.userpassword = arguments.data.password>
                    <cfset local.data.user.accessKey = arguments.data.accessKey>
                    <cfset local.data.user.teamID = arguments.data.teamID>
                    
                    <cfset local.data.user.RedMaxLevel = arguments.data.RedMaxLevel>
                    <cfset local.data.user.GreenMaxLevel = arguments.data.GreenMaxLevel>
                    <cfset local.data.user.username = arguments.data.username>
                    
                    <cfset local.result.output = getView().display(method="default", data=local.data).output>
                    <cfset local.result.title = "Your Details">
                    <cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "Your Details|profile")>
                    <cfset local.result.breadcrumb = variables.breadcrumb>
                    
                <!--- validated --->
                <cfelse>
                    <cfset local.data.UserID = getFactory().get("login").model.getUser().user.userID>
                    <cfset local.result.update = getModel().userUpdate(
                            data=local.data
                    )>
                    
                    <cfif local.result.update.success>
                        <cfset getFactory().get("session").model.set("returnURL", "/user/showUsers")>
                        <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
                            getFactory().get("session").model.get("returnURL"),
                            getFactory().get("template").view.success(getModel().getMessage("success","2","title"), local.result.output,"50%").output, 1
                        )>
                    <cfelse>
                        <cfset getFactory().get("session").model.set("returnURL", "/user/showUsers")>
                        <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
                            getFactory().get("session").model.get("returnURL"),
                            getFactory().get("template").view.failure(getModel().getMessage("failure","1","title"), local.result.output,"50%").output, 1
                        )>
                    </cfif>
                </cfif>
            <!--- user is only viewing the form that will enable them to update their profile --->
            <cfelse>
                
                <cfset local.data = getFactory().get("login").model.getUser().user>

                <cfset local.result.output = getView().display(method="default", data=local.data).output>
                <cfset local.result.title = "Your Details">

                <cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "View Users|user/showUsers")>
                <cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "Your Details|profile")>
                <cfset local.result.breadcrumb = variables.breadcrumb>
            </cfif>
		</cfif>
        
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="showUsers" access="public" returntype="struct" hint="Controller for viewing users details">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

		<!--- if user not logged in, redirect to login page --->
		<cfif NOT getFactory().get("login").model.isLoggedIn()>
        	
            <cfset getFactory().get("session").model.set("returnURL", "/login")>
            <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
			getFactory().get("session").model.get("returnURL"),
			getFactory().get("template").view.failure(getModel().getMessage("failure","3","title"),"","50%").output,
			1
			)>
        <!--- user is logged in --->
		<cfelse>
            
        	<!--- get all users from db --->
            <cfif getFactory().get("login").model.getUser().user.securityLevelID eq 5>
            	<cfset local.data.allusers = getModel().getallUsers()>
            <cfelseif getFactory().get("login").model.getUser().user.securityLevelID eq 4>
            	<cfset local.data.allusers = getModel().getallUsers4andbelow()>
            </cfif>
            
            <cfset getFactory().get("session").model.set("returnURL", "/user/showUsers")>
			<cfset local.result = getView().display(method="showUsers", data=local.data)>
            <cfset local.result.title = "View Users">
			<cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "View Users|showUsers")>
            <cfset local.result.breadcrumb = variables.breadcrumb>
            
		</cfif>
            
		<cfreturn local.result>
	</cffunction>
        
    <cffunction name="deleteUser" access="public" returntype="struct" hint="Controller for deleting a user">
		<cfargument name="data" type="struct" required="false">
        
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

        <!--- if user not logged in, redirect to login page --->
		<cfif NOT getFactory().get("login").model.isLoggedIn()>
        	
            <cfset getFactory().get("session").model.set("returnURL", "/login")>
            <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
			getFactory().get("session").model.get("returnURL"),
			getFactory().get("template").view.failure(getModel().getMessage("failure","3","title"),"","50%").output,
			1
			)>
        <!--- user is logged in --->
		<cfelse>
			
            <cfset local.data = arguments.data>
            <!--- deleting the user from the database --->
            <cfset local.result.deleteUser = getModel().deleteUser(arguments.data.userID)>

            <cfif local.result.deleteUser.success>
                <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
                    getFactory().get("session").model.get("returnURL"),
                    getFactory().get("template").view.success(getModel().getMessage("success","8","title"), local.result.output,"50%").output, 1
                )>
            
            <cfelse>
            
                <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
                    getFactory().get("session").model.get("returnURL"),
                    getFactory().get("template").view.failure(getModel().getMessage("failure","8","title"), local.result.output,"50%").output, 1
                )>
            </cfif>

        </cfif>
         	
		<cfreturn local.result>
	</cffunction>

    <cffunction name="checkUserExists" access="public" returntype="struct" hint="checking if a specific username exists">
		<cfargument name="data" type="struct" required="false">
        
		<cfset var local = structNew()>
        <cfset local.result = getFactory().getResult()>
        <cfset local.result.restrictOutput = true>
		
        <cftry>
            <cfparam name="arguments.data.userName" default="">
            <cfset local.isExisting = getModel().checkUserExists(arguments.data.userName)>

            <cfif local.isExisting>
                <cfset local.result.output = "This username already exists. Please, select a different one.">
            <cfelse>
                <cfset local.result.output = "">
            </cfif>

            <cfcatch type="any">
                <cfdump var="#cfcatch#">
            </cfcatch>
        </cftry>
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="editUser" access="public" returntype="struct" hint="Controller for updating a user">
		<cfargument name="data" type="struct" required="false">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
        <!--- if user not logged in, redirect to login page --->
		<cfif NOT getFactory().get("login").model.isLoggedIn()>
            <cfset getFactory().get("session").model.set("returnURL", "/login")>
            <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
			getFactory().get("session").model.get("returnURL"),
			getFactory().get("template").view.failure(getModel().getMessage("failure","2","title"),"","50%").output,
			1
			)>
        <!--- user logged in --->
		<cfelse>
            <!--- user is updating another user's details --->
            <cfif StructKeyExists(arguments.data, "update")>
                    
                <cfset local.result.update = getModel().otherUserUpdate(
                        data=arguments.data
                )>
                
                <cfif local.result.update.success>
                    
                    <cfset getFactory().get("session").model.set("returnURL", "/user/showUsers")>
                    <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
                        getFactory().get("session").model.get("returnURL"),
                        getFactory().get("template").view.success(getModel().getMessage("success","9","title"), local.result.output,"50%").output, 1
                    )>
                <cfelse>
                    <cfset getFactory().get("session").model.set("returnURL", "/user/showUsers")>
                    <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
                        getFactory().get("session").model.get("returnURL"),
                        getFactory().get("template").view.failure(getModel().getMessage("failure","9","title"), local.result.output,"50%").output, 1
                    )>
                </cfif>
            <!--- user is viewing the form that will enable them to update another user's details --->
            <cfelse>
                	
                <cfset local.data = getModel().getUserDetails(arguments.data.userID)>
                
                <cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "View Users|user/showUsers")>
                <cfset local.result.breadcrumb = variables.breadcrumb>
                <cfset local.result.output = getView().display(method="editUser", data=local.data).output>
                <cfset local.result.title = "Edit a User">
                <cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "Edit a User|editUser")>
                <cfset local.result.breadcrumb = variables.breadcrumb>
            </cfif>
		</cfif>
        
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="addUser" access="public" returntype="struct" hint="Controller for adding a user">
		<cfargument name="data" type="struct" required="false">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

        <!--- if user not logged in, redirect to login page --->
		<cfif NOT getFactory().get("login").model.isLoggedIn()>

            <cfset getFactory().get("session").model.set("returnURL", "/login")>
            <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
			getFactory().get("session").model.get("returnURL"),
			getFactory().get("template").view.failure(getModel().getMessage("failure","2","title"),"","50%").output,
			1
			)>
        <!--- user is logged in --->
		<cfelse>
        	<cfset local.data = arguments.data>
            <!--- user has processed the form and is adding a user --->
            <cfif StructKeyExists(arguments.data, "add")>
                    
                <cfset local.result.insert = getModel().userInsert(
                        data=arguments.data
                )>

                <cfif local.result.insert.success>
                    
                    <cfset getFactory().get("session").model.set("returnURL", "/user/showUsers")>
                    <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
                        getFactory().get("session").model.get("returnURL"),
                        getFactory().get("template").view.success(getModel().getMessage("success","10","title"), local.result.output,"50%").output, 1
                    )>
                <cfelse>
                    <cfset getFactory().get("session").model.set("returnURL", "/user/showUsers")>
                    <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
                        getFactory().get("session").model.get("returnURL"),
                        getFactory().get("template").view.failure(getModel().getMessage("failure","10","title"), local.result.output,"50%").output, 1
                    )>
                </cfif>
            <!--- first time around. The user is viewing a form enabling them to add a new user --->
            <cfelse>
                
                <cfset local.data.username = "">
                <cfset local.data.password = "">
                
                <cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "View Users|user/showUsers")>
                <cfset local.result.breadcrumb = variables.breadcrumb>
                <cfset local.result.output = getView().display(method="addUser", data=local.data).output>
                <cfset local.result.title = "Add a User">
                <cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "Add a User|addUser")>
                <cfset local.result.breadcrumb = variables.breadcrumb>
            </cfif>
		</cfif>
        
		<cfreturn local.result>
	</cffunction>
    
</cfcomponent>
