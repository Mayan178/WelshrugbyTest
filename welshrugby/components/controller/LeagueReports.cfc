<cfcomponent name="LeagueReports" extends="parent" hint="Controller for league reports">
	<cffunction name="init" returntype="LeagueReports" access="public">
		<cfset super.init()>
		<cfset variables.breadcrumb = "View All Reports|LeagueReports">
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
        <!--- user is logged in. Show available reports --->
		<cfelse>
            <cfset local.result = myReports(data=arguments.data)>
		</cfif>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="myReports" access="public" returntype="struct" hint="Displays a full list of all the reports available to the user">
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
                        
            <cfset getFactory().get("session").model.set("returnURL", "/LeagueReports")>
			<cfset local.result = getView().display(method="default")>
            <cfset local.result.title = "View All Reports">
            <cfset local.result.breadcrumb = variables.breadcrumb>
            
		</cfif>
		
		<cfreturn local.result>
	</cffunction>
    
    
   <cffunction name="positionAverage" access="public" returntype="struct" hint="Controller for creating a report on position average">
		<cfargument name="data" type="struct" required="false">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        
        <!--- user not logged in, redirect to login page --->
        <cfif NOT getFactory().get("login").model.isLoggedIn()>
            <cfset getFactory().get("session").model.set("returnURL", "/login")>
            <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
			getFactory().get("session").model.get("returnURL"),
			getFactory().get("template").view.failure(getModel().getMessage("failure","1","title"),"","50%").output,
			1
			)>
        <!--- user is logged in --->
		<cfelse>
        	<cfset local.data = arguments.data>

			<!--- initialise step control with 0 as the initial (unvalidated) state --->
            <cfif NOT StructKeyExists(local.data, "step")>
                <cfset local.step = 0>
            <cfelse>
                <cfset local.step = local.data.step>
            </cfif>
           
            <!--- Validation and step control --->
            <cfswitch expression="#local.step#">
                <!--- first time around --->
                <cfcase value="0">
                    <cfset local.data.position = "">
                    <cfset local.step++>
                </cfcase>
                
                <!--- user has submitted data --->
                <cfcase value="1">
                	<cfset local.step++>
                </cfcase>
            </cfswitch>

        	<cfswitch expression="#local.step#">
            	<!--- add player form --->
                <cfcase value="1">
                    <cfset local.result.output = getView().display(method="positionAverage", data=local.data,step=local.step).output>
                </cfcase>
                
                <!--- user has submitted data...display results --->
                <cfcase value="2">
                	<!--- do search in database for selected position --->
                    <cfset local.data.players = getModel().getPositionAverage(local.data.position)>
                    
                    <cfset local.result.output = getView().display(method="positionAverage", data=local.data,step=local.step).output>
                </cfcase>                
            </cfswitch>

            <cfset local.result.title = "Position Average Report">
            <cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "Position Average Report|positionAverage")>
            <cfset local.result.breadcrumb = variables.breadcrumb>
            
		</cfif>
        
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="players" access="public" returntype="struct" hint="Controller for creating a report on  a specific player">
		<cfargument name="data" type="struct" required="false">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
         <!--- user not logged in, redirect to login page --->
        <cfif NOT getFactory().get("login").model.isLoggedIn()>
            <cfset getFactory().get("session").model.set("returnURL", "/login")>
            <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
			getFactory().get("session").model.get("returnURL"),
			getFactory().get("template").view.failure(getModel().getMessage("failure","1","title"),"","50%").output,
			1
			)>
        <!--- user is logged in --->
		<cfelse>
        
        	<cfset local.data = arguments.data>
			<!--- initialise step control with 0 as the initial (unvalidated) state --->
            <cfif NOT StructKeyExists(local.data, "step")>
                <cfset local.step = 0>
            <cfelse>
                <cfset local.step = local.data.step>
            </cfif>
           
            <!--- Validation and step control --->
            <cfswitch expression="#local.step#">
                <!--- first time around --->
                <cfcase value="0">
                    <cfset local.data.playerID = "">
                    <cfset local.step++>
                </cfcase>
                
                <!--- user has submitted data --->
                <cfcase value="1">
                	<cfset local.step++>
                </cfcase>
            </cfswitch>
              
        	<cfswitch expression="#local.step#">
            	<!--- add player form --->
                <cfcase value="1">
                    <cfset local.result.output = getView().display(method="players", data=local.data,step=local.step).output>
                </cfcase>
                
                <!--- user has submitted data...display results --->
                <cfcase value="2"><cfdump var="#local.data.playerID#">
                	<!--- do search in database for selected player --->
                    <cfset local.data.player = getFactory().get("LeaguePlayers").model.getPlayerReport(local.data.playerID)>
                    <cfset local.data.playerName = getFactory().get("LeaguePlayers").model.getPlayerDetailsReport(local.data.playerID)>

                    <cfset local.result.output = getView().display(method="players", data=local.data,step=local.step).output>
                </cfcase>                
            </cfswitch>

            <cfset local.result.title = "Players Report">
            <cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "Players Report|players")>
            <cfset local.result.breadcrumb = variables.breadcrumb>
            
		</cfif>
        
		<cfreturn local.result>
	</cffunction>
    
    
    <cffunction name="playersaverage" access="public" returntype="struct" hint="Controller for creating a report on a specific player's average data ">
		<cfargument name="data" type="struct" required="false">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
         <!--- user not logged in, redirect to login page --->
        <cfif NOT getFactory().get("login").model.isLoggedIn()>
            <cfset getFactory().get("session").model.set("returnURL", "/login")>
            <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
			getFactory().get("session").model.get("returnURL"),
			getFactory().get("template").view.failure(getModel().getMessage("failure","1","title"),"","50%").output,
			1
			)>
        <!--- user is logged in --->
		<cfelse>
        
        	<cfset local.data = arguments.data>
			<!--- initialise step control with 0 as the initial (unvalidated) state --->
            <cfif NOT StructKeyExists(local.data, "step")>
                <cfset local.step = 0>
            <cfelse>
                <cfset local.step = local.data.step>
            </cfif>
           
            <!--- Validation and step control --->
            <cfswitch expression="#local.step#">
                <!--- first time around --->
                <cfcase value="0">
                    <cfset local.data.playerID = "">
                    <cfset local.step++>
                </cfcase>
                
                <!--- user has submitted data --->
                <cfcase value="1">
                	<cfset local.step++>
                </cfcase>
            </cfswitch>
              
        	<cfswitch expression="#local.step#">
            	<!--- add player form --->
                <cfcase value="1">
                    <cfset local.result.output = getView().display(method="playersaverage", data=local.data,step=local.step).output>
                </cfcase>
                
                <!--- user has submitted data...display results --->
                <cfcase value="2">
                	<!--- do search in database for selected player --->
                    <cfset local.data.player = getModel().getPlayerAverage(local.data.playerID)>
                    <cfset local.data.playerName = getFactory().get("LeaguePlayers").model.getPlayerDetailsReport(local.data.playerID)>

                    <cfset local.result.output = getView().display(method="playersaverage", data=local.data,step=local.step).output>
                </cfcase>                
            </cfswitch>

            <cfset local.result.title = "Players Average Report">
            <cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "Players Average Report|playersaverage")>
            <cfset local.result.breadcrumb = variables.breadcrumb>
            
		</cfif>
        
		<cfreturn local.result>
	</cffunction>

    <cffunction name="playersprogression" access="public" returntype="struct" hint="Controller for creating a report on a specific players' progression">
		<cfargument name="data" type="struct" required="false">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
         <!--- user not logged in, redirect to login page --->
        <cfif NOT getFactory().get("login").model.isLoggedIn()>
            <cfset getFactory().get("session").model.set("returnURL", "/login")>
            <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
			getFactory().get("session").model.get("returnURL"),
			getFactory().get("template").view.failure(getModel().getMessage("failure","1","title"),"","50%").output,
			1
			)>
        <!--- user is logged in --->
		<cfelse>
        
        	<cfset local.data = arguments.data>
			<!--- initialise step control with 0 as the initial (unvalidated) state --->
            <cfif NOT StructKeyExists(local.data, "step")>
                <cfset local.step = 0>
            <cfelse>
                <cfset local.step = local.data.step>
            </cfif>
           
            <!--- Validation and step control --->
            <cfswitch expression="#local.step#">
                <!--- first time around --->
                <cfcase value="0">
                    <cfset local.data.playerID = "">
                    <cfset local.data.periodCovered = "">
                    <cfset local.data.seasonFrom = "">
                    <cfset local.data.seasonTo = "">
                    <cfset local.data.roundFrom = "">
                    <cfset local.data.roundTo = "">
                    <cfset local.data.dateFrom = "">
                    <cfset local.data.dateTo = "">
                                        
                    <cfset local.data.formLevel = "true">
                    <cfset local.data.agressionLevel = "true">
                    <cfset local.data.leadershipLevel = "true">
                    <cfset local.data.energyLevel = "true">
                    <cfset local.data.disciplineLevel = "true">
                    <cfset local.data.experienceLevel = "true">
                    
                    <cfset local.data.staminaLevel = "true">
                    <cfset local.data.handlingLevel = "true">
                    <cfset local.data.attackLevel = "true">
                    <cfset local.data.defenseLevel = "true">
                    <cfset local.data.techniqueLevel = "true">
                    <cfset local.data.strengthLevel = "true">
                    <cfset local.data.jumpingLevel = "true">
                    <cfset local.data.speedLevel = "true">
                    <cfset local.data.agilityLevel = "true">
                    <cfset local.data.kickingLevel = "true">
                    
                    <cfset local.data.csr = "true">
                    
                    <cfset local.step++>
                </cfcase>
                
                <!--- user has submitted data --->
                <cfcase value="1">
                	<cfset local.step++>
                </cfcase>
            </cfswitch>
              
        	<cfswitch expression="#local.step#">
            	<!--- add player form --->
                <cfcase value="1">
                    <cfset local.result.output = getView().display(method="playersprogression", data=local.data,step=local.step).output>
                </cfcase>
                
                <!--- user has submitted data...display results --->
                <cfcase value="2">
                	<!--- do search in database for selected player --->
                    <cfset local.data.playerHistory = getFactory().get("LeaguePlayers").model.getPlayerHistoryReport(playerID=local.data.playerID,periodCovered=local.data.periodCovered,seasonFrom=local.data.seasonFrom,seasonTo=local.data.seasonTo,roundFrom=local.data.roundFrom,roundTo=local.data.roundTo,dateFrom=local.data.dateFrom,dateTo=local.data.dateTo)>

                    <cfset local.data.playerdetails = getFactory().get("LeaguePlayers").model.getplayerDetails(local.data.playerID)>
                    
                    <cfset local.result.output = getView().display(method="playersprogression", data=local.data,step=local.step).output>
                </cfcase>                
            </cfswitch>

            <cfset local.result.title = "Players Progression Report">
            <cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "Players Progression Report|playersprogression")>
            <cfset local.result.breadcrumb = variables.breadcrumb>
            
		</cfif>
        
		<cfreturn local.result>
	</cffunction>

    <cffunction name="matchcomparison" access="public" returntype="struct" hint="Controller for creating a report comparing 2 matches fixtures">
		<cfargument name="data" type="struct" required="false">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        <!--- user not logged in, redirect to login page --->
        <cfif NOT getFactory().get("login").model.isLoggedIn()>
            <cfset getFactory().get("session").model.set("returnURL", "/login")>
            <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
			getFactory().get("session").model.get("returnURL"),
			getFactory().get("template").view.failure(getModel().getMessage("failure","1","title"),"","50%").output,
			1
			)>
        <!--- user is logged in --->
		<cfelse>
        
        	<cfset local.data = arguments.data>
			<!--- initialise step control with 0 as the initial (unvalidated) state --->
            <cfif NOT StructKeyExists(local.data, "step")>
                <cfset local.step = 0>
            <cfelse>
                <cfset local.step = local.data.step>
            </cfif>
           
            <!--- Validation and step control --->
            <cfswitch expression="#local.step#">
                <!--- first time around --->
                <cfcase value="0">
                    <cfset local.data.match1 = "">
                    <cfset local.data.match2 = "">
                    <cfset local.step++>
                </cfcase>
                
                <!--- user has submitted data --->
                <cfcase value="1">
                	<!--- put through validation make sure that the same stat has not been submitted twice for the same position--->
                    <cfset local.validation = getModel().validatematchcomparison(local.data)>
                    
                    <cfif ArrayLen(local.validation.errors)>
                        <cfset local.data.errors = local.validation.errors>                        
                    <!--- validated --->
                    <cfelse>
                    	<cfset local.step++>
                	</cfif>
                	
                </cfcase>
            </cfswitch>
              
        	<cfswitch expression="#local.step#">
            	<!--- add player form --->
                <cfcase value="1">
                    <cfset local.result.output = getView().display(method="matchcomparison", data=local.data,step=local.step).output>
                </cfcase>
                
                <!--- user has submitted data...display results --->
                <cfcase value="2">
                	<!--- do search in database for match data --->
                    <cfset local.data.detailsMatch1 = getModel().getMatchPlayerDetails(local.data.match1)>
                    <cfset local.data.detailsMatch2 = getModel().getMatchPlayerDetails(local.data.match2)>
                    <cfset local.result.output = getView().display(method="matchcomparison", data=local.data,step=local.step).output>
                </cfcase>                
            </cfswitch>

            <cfset local.result.title = "Match Fixtures Comparison Report">
            <cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "Match Fixtures Comparison Report|matchcomparison")>
            <cfset local.result.breadcrumb = variables.breadcrumb>
            
		</cfif>
        
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="attendance" access="public" returntype="struct" hint="Controller for creating a report on match attendance">
		<cfargument name="data" type="struct" required="false">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        <!--- user not logged in, redirect to login page --->
        <cfif NOT getFactory().get("login").model.isLoggedIn()>
            <cfset getFactory().get("session").model.set("returnURL", "/login")>
            <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
			getFactory().get("session").model.get("returnURL"),
			getFactory().get("template").view.failure(getModel().getMessage("failure","1","title"),"","50%").output,
			1
			)>
        <!--- user is logged in --->
		<cfelse>
        
        	<cfset local.data = arguments.data>
			
        	<!--- do search in database for attendance --->
            <cfset local.data.AttendanceDateFrom = getFactory().get("LeagueMatches").model.getDateFrom()>
            <cfset local.data.AttendanceDateTo = getFactory().get("LeagueMatches").model.getDateTo()>
            
			<cfset local.data.AttendanceStanding = getModel().getAttendanceStanding()>
            <cfset local.data.AttendanceUncovered = getModel().getAttendanceUncovered()>
            <cfset local.data.AttendanceCovered = getModel().getAttendanceCovered()>
            <cfset local.data.AttendanceMembers = getModel().getAttendanceMembers()>
            <cfset local.data.AttendanceVIP = getModel().getAttendanceVIP()>
            
            <cfset local.data.PotentialAttendances = getModel().getPotentialAttendances()>
            
            <cfset local.result.title = "Attendance Report">
            <cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "Attendance Report|attendance")>
            <cfset local.result.breadcrumb = variables.breadcrumb>

            <cfset local.result.output = getView().display(method="attendance", data=local.data).output>
            
		</cfif>
        
		<cfreturn local.result>
	</cffunction>
    
</cfcomponent>