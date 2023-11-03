<cfcomponent name="leaguematches" extends="parent" hint="Controller for league matches">
	<cffunction name="init" returntype="leaguematches" access="public">
		<cfset super.init()>
		<cfset variables.breadcrumb = "View All Matches|leaguematches">
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
			getFactory().get("template").view.failure(getModel().getMessage("failure","3","title"),"","50%").output,
			1
			)>
        <!--- user logged in, show their matches --->
		<cfelse>
            <cfset local.result = myMatches(data=arguments.data)>
		</cfif>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="myMatches" access="public" returntype="struct" hint="Displays a full list of all the matches">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		<!--- if the user is not logged in, he/she cannot see the homepage...so redirect to login page --->
		<cfif NOT getFactory().get("login").model.isLoggedIn()>
        	<cfset getFactory().get("session").model.set("returnURL", "/login")>
            <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
			getFactory().get("session").model.get("returnURL"),
			getFactory().get("template").view.failure(getModel().getMessage("failure","3","title"),"","50%").output,
			1
			)>
		<cfelse>
            
        	<!--- get the list of all matches --->
            <cfset local.data.allMatches = getModel().getMyMatches()>
            <!--- set return URL, title, breadcrumb and return content for the page from the Leaguematches View component --->
            <cfset getFactory().get("session").model.set("returnURL", "/leaguematches")>
			<cfset local.result = getView().display(method="default", data=local.data)>
            <cfset local.result.title = "View All Matches">
            <cfset local.result.breadcrumb = variables.breadcrumb>
            
		</cfif>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="addMatch" access="public" returntype="struct" hint="Controller for adding a match">
		<cfargument name="data" type="struct" required="false">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        <!--- user not logged in, redirect to login page --->
        <cfif NOT getFactory().get("login").model.isLoggedIn()>
            <cfset getFactory().get("session").model.set("returnURL", "/login")>
            <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
			getFactory().get("session").model.get("returnURL"),
			getFactory().get("template").view.failure(getModel().getMessage("failure","3","title"),"","50%").output,
			1
			)>
        <!--- user logged in --->
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
                    <!--- set default values for form inputs --->
                    <cfset local.data.matchDate = "">
                    <cfset local.data.OpponentName = "">
                    <cfset local.data.isHome = "1">
                    
                    <!--- get match team ratings details --->
                    <cfset local.data.availableTeamRatingsStats = getModel().getTeamRatingsStats()>
                    <cfloop query="local.data.availableTeamRatingsStats">
                        <cfset local.data.MatchTeamRatings_[#statID#] = 0>
                    </cfloop>

                    <cfset local.data.PlayersRatings = "">
                    <cfset local.data.ManofTheMatch = "">
                    <cfset local.data.Score = "0">
                    <cfset local.data.OtherScore = "0">
                    <cfset local.data.MatchType = "1">
                    
                    <cfset local.data.AttendanceStanding = "0">
                    <cfset local.data.AttendanceUncovered = "0">
                    <cfset local.data.AttendanceCovered = "0">
                    <cfset local.data.AttendanceMembers = "0">
                    <cfset local.data.AttendanceVIP = "0">
                                        
                    <cfset local.step++>
                </cfcase>
                
                <!--- user has submitted data --->
                <cfcase value="1">                    
                    <!--- work out the result --->
                    <!--- if played at home --->
                    <cfif local.data.isHome>
                        <!--- won --->
                        <cfif local.data.scoreHome gt local.data.otherScoreHome>
                            <cfset local.data.MatchResult = 3>
                        <!--- drew --->
                        <cfelseif local.data.scoreHome eq local.data.otherScoreHome>
                            <cfset local.data.MatchResult = 2>
                        <!--- lost --->
                        <cfelse>
                            <cfset local.data.MatchResult = 1>
                        </cfif>
                    <!--- played away --->
                    <cfelse>
                        <!--- won --->
                        <cfif local.data.scoreAway gt local.data.otherScoreAway>
                            <cfset local.data.MatchResult = 3>
                        <!--- drew --->
                        <cfelseif local.data.scoreAway eq local.data.otherScoreAway>
                            <cfset local.data.MatchResult = 2>
                        <!--- lost --->
                        <cfelse>
                            <cfset local.data.MatchResult = 1>
                        </cfif>
                    </cfif>
                    
                    <cfset local.result.errors = ArrayNew(1)>
                                            
                    <cfset local.data2 = StructNew()>
                    <cfset local.data2.PlayersRatings = "">
                    
                    <cfset local.pCount = 1>
                    <!--- look at match team ratings here and update --->
                    <cfset local.data2.PlayersRatings = HTMLEditFormat(local.data.PlayersRatings)>
                    <cfset local.data2.PlayersRatings = replaceNoCase(local.data2.PlayersRatings,"&lt;br /&gt;","/","ALL")>

                    <cfset local.data.allMatchPlayers = ArrayNew(1)>

                    <!--- loop through and define each player's info  --->
                    <cfloop list="#local.data2.PlayersRatings#" index="local.p">
                        <cfif Len(Trim(local.p))>
                            <cfset local.player = StructNew()>
                            <cfset local.player.positionID = local.pCount>

                            <cfset local.playerfullname = ListFirst(local.p, "/")>
                            
                            <!--- remove the number from the name --->
                            <cfif arguments.data.isHome eq 1>
                                <cfset local.playerfullname = replaceNoCase(local.playerfullname,"#local.pCount#.","","ALL")>
                            <cfelse>
                                <cfset local.playerfullname = replaceNoCase(local.playerfullname,".#local.pCount#","","ALL")>
                            </cfif>

                            <cfset local.player.firstname = Trim(listGetAt(local.playerfullname,1,"#Chr(32)#"))>
                            <cfset local.player.lastname = Trim(listGetAt(local.playerfullname,2,"#Chr(32)#"))>

                            <cfif Len(local.data.manofthematch) AND trim(local.data.manofthematch) eq "#local.playerfullname#">
                                <cfset local.player.manofthematch = 1>
                            <cfelse>
                                <cfset local.player.manofthematch = 0>
                            </cfif>

                            <cfset local.checkifPlayerExistsall = getFactory().get("LeaguePlayers").model.checkifPlayerExistsall(local.player.firstname,local.player.lastname)>

                            <!--- if the player exists, then get the id --->
                            <cfif local.checkifPlayerExistsall neq 0>
                                <cfset local.player.playerID = local.checkifPlayerExistsall>
                            <!--- the player does not exist...set a playerID of 0  --->
                            <cfelse>
                                <cfset local.player.playerID = 0>
                            </cfif>

                            <cfset local.player.stars = "">

                            <cfset local.playerInfo = LCase(ListLast(local.p, "/"))>

                            <!--- find out if player played --->
                            <cfif findNoCase("did not play", local.playerInfo)>
                                <cfset local.player.didplay = "0">
                                <cfset local.player.playerExpectationTitle = "Unknown">
                                <cfset local.player.playerExpectationID = "0">
                                <cfset local.player.playerPotentialID = 0>
                            <cfelse>
                                <cfset local.player.didplay = "1">
                                <cfset local.player.playerExpectationTitle = ListFirst(local.playerInfo, " ")>
                                 <!--- now get the id for the playerexpectationtitle --->
                                <cfset local.checkExpectationexists = getModel().checkExpectationexists(local.player.playerExpectationTitle)>
                                <cfif local.checkExpectationexists neq 0>
                                    <cfset local.player.playerExpectationID = local.checkExpectationexists>
                                <cfelse>
                                    <cfset local.player.playerExpectationID = 0>
                                </cfif>

                                <!--- find position of brackets --->
                                <cfset local.findopening = findNoCase("#chr(40)#",local.playerInfo)>
                                <cfset local.findclosing = findNoCase("#chr(41)#",local.playerInfo)>
                                
                                <cfset local.player.playerPotentialTitle = Mid(local.playerInfo, local.findopening+1, local.findclosing-local.findopening-1)>
                                
                                <!--- check the id for the potential --->
                                <cfset local.checkPotentialexists = getModel().checkPotentialexists(local.player.playerPotentialTitle)>

                                 <cfif local.checkPotentialexists neq 0>
                                    <cfset local.player.playerPotentialID = local.checkPotentialexists>
                                <cfelse>
                                    <cfset local.player.playerPotentialID = 0>
                                </cfif>

                            </cfif>
                            <cfset local.pCount = local.pCount+1>
                            <cftry>
                            <cfset ArrayAppend(local.data.allMatchPlayers, local.player)>

                                <cfcatch type="any">
                                    <cfdump var="#cfcatch#">
                                </cfcatch>
                            </cftry>
                                
                        </cfif>
                    </cfloop>
                    
                    <!--- dealing with attendance --->
                    <cfif arguments.data.isHome eq 1>
                        <cfif NOT Len(local.data.AttendanceStanding) OR NOT IsNumeric(local.data.AttendanceStanding)>
                            <cfset ArrayAppend(local.result.errors, "There was a problem with the Standing attendance. This needs to be a numeric value.")>
                        </cfif>
                        <cfif NOT Len(local.data.AttendanceUncovered) OR NOT IsNumeric(local.data.AttendanceUncovered)>
                            <cfset ArrayAppend(local.result.errors, "There was a problem with the Uncovered attendance. This needs to be a numeric value.")>
                        </cfif>
                        <cfif NOT Len(local.data.AttendanceCovered) OR NOT IsNumeric(local.data.AttendanceCovered)>
                            <cfset ArrayAppend(local.result.errors, "There was a problem with the Covered attendance. This needs to be a numeric value.")>
                        </cfif>
                        <cfif NOT Len(local.data.AttendanceMembers) OR NOT IsNumeric(local.data.AttendanceMembers)>
                            <cfset ArrayAppend(local.result.errors, "There was a problem with the Members attendance. This needs to be a numeric value.")>
                        </cfif>
                        <cfif NOT Len(local.data.AttendanceVIP) OR NOT IsNumeric(local.data.AttendanceVIP)>
                            <cfset ArrayAppend(local.result.errors, "There was a problem with the Corporate/VIP attendance. This needs to be a numeric value.")>
                        </cfif>
                    </cfif>
                           
                    <cfset local.step++>
                        
                </cfcase>                
            </cfswitch>
       
        	<cfswitch expression="#local.step#">
            	<!--- add match form --->
                <cfcase value="1">
                    <cfset local.result.output = getView().display(method="addMatch", data=local.data,step=local.step).output>
                    <cfset local.result.title = "Add a Match">
                    <cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "Add a Match|addMatch")>
                    <cfset local.result.breadcrumb = variables.breadcrumb>
                </cfcase>
                
                <!--- user entered details for a match and submitted the form --->
                <cfcase value="2">
                    <cfset local.insert = getModel().matchInsert(data=local.data)>
                    <!--- match successfully added to the db --->
                    <cfif local.insert.success>
                        <!--- clear session --->
                        <cfif StructKeyExists(session.welshrugby,"myNewMatch")>
                            <cfset getFactory().get("session").model.delete("myNewMatch")>
                        </cfif>
                        
                        <cfset getFactory().get("session").model.set("returnURL", "/")>
                        <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
                            "/leaguematches",
                            getFactory().get("template").view.success(getModel().getMessage("success","6","title"), local.result.output,"50%").output, 0
                        )>
                    <!--- problem with adding the new match to the db --->
                    <cfelse>
                        <cfset getFactory().get("session").model.set("returnURL", "/")>
                        <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
                            "/leaguematches",
                            getFactory().get("template").view.failure(getModel().getMessage("failure","7","title"), local.result.output,"50%").output, 0
                        )>
                    </cfif>
                </cfcase>
            </cfswitch>
		</cfif>
        
		<cfreturn local.result>
	</cffunction>    
	
    <cffunction name="showMatchDetails" access="public" returntype="struct" hint="Controller for showing a match's details">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        <cfset local.result.restrictOutput = true>
        
		<!--- get the list of all of the user's matches --->
        <cfset local.data.myMatch = getModel().getaspecificMatch(matchID=arguments.data.matchID)>
		<cfset local.data.matchDetails = getModel().getmatchDetails(matchID=arguments.data.matchID)>
        <cfset local.data.matchPlayers = getModel().getmatchPlayers(matchID=arguments.data.matchID,extraPlayersOnly=true)>
		<cfset local.data.matchAttendance = getModel().getmatchAttendance(matchID=arguments.data.matchID)>
        <cfset local.data.MatchTeamRatingsToUse = getModel().getmatchTeamRatings(matchID=arguments.data.matchID)>


        <cfset getFactory().get("session").model.set("returnURL", "/leaguematches/showMatchDetails")>
        <cfset local.result.output = getView().display(method="showMatchDetails", data=local.data).output>
        
		<cfreturn local.result>
	</cffunction>
    
</cfcomponent>