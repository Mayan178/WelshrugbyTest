<cfcomponent name="leagueteams" extends="parent" hint="Controller for league teams">
	
	<cffunction name="init" returntype="leagueteams" access="public">
		<cfset super.init()>
		<cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "League Teams|leagueteams")>
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
			getFactory().get("template").view.failure(getModel().getMessage("failure","1","title"),"","50%").output,
			1
			)>
        <!--- user is logged in. Show teams created by the user --->
		<cfelse>
			<cfset local.result = myteams(data=arguments.data)>
		</cfif>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="myteams" access="public" returntype="struct" hint="Controller for viewing my teams">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		<!--- if the user is not logged in, he/she cannot see the homepage...so redirect to login page --->
		<cfif NOT getFactory().get("login").model.isLoggedIn()>
            <cfset getFactory().get("session").model.set("returnURL", "/login")>
            <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
			getFactory().get("session").model.get("returnURL"),
			getFactory().get("template").view.failure(getModel().getMessage("failure","1","title"),"","50%").output,
			1
			)>
        <!--- user is logged in --->
		<cfelse>
            
        	<!--- get the list of all of the user's teams --->
            <cfset local.data.allTeams = getFactory().get("leagueplayers").model.getallMyTeams()>
            
            <cfset getFactory().get("session").model.set("returnURL", "/leagueteams")>
			<cfset local.result = getView().display(method="myteams", data=local.data)>
            
            <cfset local.result.title = "Your Teams">
			<cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "Your Teams|myteams")>
			
            <cfset local.result.breadcrumb = variables.breadcrumb>
            
		</cfif>
		
		<cfreturn local.result>
	</cffunction>
	
	<cffunction name="deleteTeam" access="public" returntype="struct" hint="Controller for deleting a team">
		<cfargument name="data" type="struct" required="false">
        
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
			
		<cfset local.data = arguments.data>        
            	
		<cfset local.result.deleteTeam = getModel().deleteTeam(local.data.teamID)>

        <cfif local.result.deleteTeam.success>
            <cfset getFactory().get("session").model.set("returnURL", "/leagueTeams/myTeams")>
            
            <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
                getFactory().get("session").model.get("returnURL"),
                getFactory().get("template").view.success(getModel().getMessage("success","1","title"), local.result.output,"50%").output, 1
            )>
           
        <cfelse>
           
            <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
                getFactory().get("session").model.get("returnURL"),
                getFactory().get("template").view.failure(getModel().getMessage("failure","2","title"), local.result.output,"50%").output, 1
            )>
        </cfif>
         	
		<cfreturn local.result>
	</cffunction>

    <cffunction name="addTeam" access="public" returntype="struct" hint="Controller for adding a team">
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
            <!--- the user has processed the form and is adding a team --->
            <cfif StructKeyExists(arguments.data, "add")>
                <!--- insert into the db --->
                <cfset local.result.insert = getModel().insertTeam(
                        data=arguments.data
                )>

                <cfif local.result.insert.success>
                    
                    <cfset getFactory().get("session").model.set("returnURL", "/leagueTeams/myTeams")>
                    <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
                        getFactory().get("session").model.get("returnURL"),
                        getFactory().get("template").view.success(getModel().getMessage("success","6","title"), local.result.output,"50%").output, 1
                    )>
                <cfelse>
                    <cfset getFactory().get("session").model.set("returnURL", "/leagueTeams/myTeams")>
                    <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
                        getFactory().get("session").model.get("returnURL"),
                        getFactory().get("template").view.failure(getModel().getMessage("failure","7","title"), local.result.output,"50%").output, 1
                    )>
                </cfif>
            <!--- first time around. The user is viewing the form enabling them to add a team --->
            <cfelse>
                
                <cfset local.data.teamTitle = "">
                
                <cfset local.result.output = getView().display(method="addTeam", data=local.data).output>
                <cfset local.result.title = "Add a Team">
                <cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "Add a Team|addTeam")>
                <cfset local.result.breadcrumb = variables.breadcrumb>
            </cfif>
		</cfif>
        
		<cfreturn local.result>
	</cffunction>

    <cffunction name="editTeam" access="public" returntype="struct" hint="Controller for editing a team">
		<cfargument name="data" type="struct" required="false">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        <!--- user is not logged in. Redirect to login page --->
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
            <!--- the user has processed the form and is updating their team's name --->
            <cfif StructKeyExists(arguments.data, "update")>
                <!--- update the db --->
                <cfset local.result.update = getModel().updateTeam(
                        data=arguments.data
                )>

                <cfif local.result.update.success>
                    
                    <cfset getFactory().get("session").model.set("returnURL", "/leagueTeams/myTeams")>
                    <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
                        getFactory().get("session").model.get("returnURL"),
                        getFactory().get("template").view.success(getModel().getMessage("success","2","title"), local.result.output,"50%").output, 1
                    )>
                <cfelse>
                    <cfset getFactory().get("session").model.set("returnURL", "/leagueTeams/myTeams")>
                    <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
                        getFactory().get("session").model.get("returnURL"),
                        getFactory().get("template").view.failure(getModel().getMessage("failure","3","title"), local.result.output,"50%").output, 1
                    )>
                </cfif>
            <!--- viewing the form enabling the user to update their team's name --->
            <cfelse>
                <cfset local.data = getModel().getTeamDetails(teamID=arguments.data.teamID)>

                <cfset local.result.output = getView().display(method="editTeam", teamID=local.data.teamID, teamTitle=local.data.teamTitle).output>
                <cfset local.result.title = "Edit a Team">
                <cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "Edit a Team|editTeam")>
                <cfset local.result.breadcrumb = variables.breadcrumb>
            </cfif>
		</cfif>
        
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="showTeamDetails" access="public" returntype="struct" hint="Controller for showing a team's details">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        <cfset local.result.restrictOutput = true>
        
        <!--- if moving players around --->
        <cfif StructKeyExists(arguments.data,"newPlayer") AND StructKeyExists(arguments.data,"oldPlayer")>
        	<!--- call the function to update 2 players' positions --->
            <cfif arguments.data.positionID neq 16 AND arguments.data.positionID neq 17>
            	<cfset local.updatePlayerPosition = getFactory().get("leagueplayers").model.updatePlayerPosition(teamID=arguments.data.teamID,positionID=arguments.data.positionID,oldPlayer=arguments.data.oldPlayer,newPlayer=arguments.data.newPlayer)>
            <cfelse>
            	<cfset local.updatePlayerPosition = getFactory().get("leagueplayers").model.updatePlayerPosition(teamID=arguments.data.teamID,positionID=arguments.data.positionID,oldPlayer=arguments.data.oldPlayer,newPlayer=arguments.data.newPlayer,canduplicate=true)>
            </cfif>
            
        <!--- if changing from unassigned to a player --->
        <cfelseif StructKeyExists(arguments.data,"newPlayer") AND NOT StructKeyExists(arguments.data,"oldPlayer")>
        	<cfset arguments.data.oldPlayer = 0>
        	<cfif arguments.data.positionID neq 16 AND arguments.data.positionID neq 17>
                <!--- call the function to update 2 players' positions --->
                <cfset local.updatePlayerPosition = getFactory().get("leagueplayers").model.updatePlayerPosition(teamID=arguments.data.teamID,positionID=arguments.data.positionID,oldPlayer=arguments.data.oldPlayer,newPlayer=arguments.data.newPlayer)>
            <cfelse>
            	<cfset local.updatePlayerPosition = getFactory().get("leagueplayers").model.updatePlayerPosition(teamID=arguments.data.teamID,positionID=arguments.data.positionID,oldPlayer=arguments.data.oldPlayer,newPlayer=arguments.data.newPlayer,canduplicate=true)>
            </cfif>
        <!--- if changing a player to unassigned --->
        <cfelseif NOT StructKeyExists(arguments.data,"newPlayer") AND StructKeyExists(arguments.data,"oldPlayer")>
        	<cfif arguments.data.positionID neq 16 AND arguments.data.positionID neq 17>
				<!--- call the function to move the initial player into the pool --->
                <cfset local.unassignPlayerPosition = getFactory().get("leagueplayers").model.unassignPlayerPosition(teamID=arguments.data.teamID,positionID=arguments.data.positionID,oldPlayer=arguments.data.oldPlayer)>
            <cfelse>
				<!--- call the function to move the initial player into the pool --->
                <cfset local.unassignPlayerPosition = getFactory().get("leagueplayers").model.unassignPlayerPosition(teamID=arguments.data.teamID,positionID=arguments.data.positionID,oldPlayer=arguments.data.oldPlayer,canduplicate=true)>
            </cfif>
        </cfif>
        
		<!--- get the list of all of the user's teams --->
        <cfset local.data.myTeam = getFactory().get("leagueplayers").model.getaspecificTeam(teamID=arguments.data.teamID)>

        <cfset getFactory().get("session").model.set("returnURL", "/leagueteams/showTeamDetails")>
        <cfset local.result.output = getView().display(method="showTeamDetails", data=local.data, teamID=arguments.data.teamID).output>
        
		<cfreturn local.result>
	</cffunction>

    <cffunction name="exportTeam" access="public" returntype="struct" hint="Controller for exporting a team's details into a json file">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        <!--- user is not logged in. Redirect to the login page --->
        <cfif NOT getFactory().get("login").model.isLoggedIn()>
        	<!---
			<cfset local.result = getFactory().get("login").controller.login(data=arguments.data)>
			--->
            <cfset getFactory().get("session").model.set("returnURL", "/login")>
            <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
			getFactory().get("session").model.get("returnURL"),
			getFactory().get("template").view.failure(getModel().getMessage("failure","2","title"),"","50%").output,
			1
			)>
        <!--- user is logged in --->
		<cfelse>

            <cfset local.data = getModel().createTeamFile(teamID=arguments.data.teamID)>
            <cfset getFactory().get("session").model.set("returnURL", "/leagueteams/showTeamDetails")>
            <cfset local.result.output = getView().display(method="exportTeam", data=local.data).output>      
            <cfset local.result.title = "Export a Team as a JSON file">
            <cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "Export a Team as a JSON file|exportTeam")>
            <cfset local.result.breadcrumb = variables.breadcrumb>

        </cfif>
                
		<cfreturn local.result>
	</cffunction>

    <cffunction name="download" access="public" returntype="struct" hint="Controller for downloading a json file">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        <!--- user is not logged in. Redirect to the login page --->
        <cfif NOT getFactory().get("login").model.isLoggedIn()>
            <cfset getFactory().get("session").model.set("returnURL", "/login")>
            <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
			getFactory().get("session").model.get("returnURL"),
			getFactory().get("template").view.failure(getModel().getMessage("failure","2","title"),"","50%").output,
			1
			)>
        <!--- view the jSON file --->
		<cfelse>
            <cfheader name="content-disposition" value="attachment;filename=#arguments.data.filename#">
            <cfcontent type="text/plain" file="#getFactory().getSetting("jSONDataPath")#\#arguments.data.filename#">

        </cfif>
                
		<cfreturn local.result>
	</cffunction>

    <cffunction name="checkTeamExists" access="public" returntype="struct" hint="checking if a specific team title exists already">
		<cfargument name="data" type="struct" required="false">
        
		<cfset var local = structNew()>
        <cfset local.result = getFactory().getResult()>
        <cfset local.result.restrictOutput = true>
		
        <cftry>
            <cfparam name="arguments.data.teamTitle" default="">
            <cfset local.isExisting = getModel().checkTeamExists(arguments.data.teamTitle)>

            <cfif local.isExisting>
                <cfset local.result.output = "This team already exists. Please, enter a different team title.">
            <cfelse>
                <cfset local.result.output = "">
            </cfif>

            <cfcatch type="any">
                <cfdump var="#cfcatch#">
            </cfcatch>
        </cftry>
		<cfreturn local.result>
	</cffunction>
    
</cfcomponent>
