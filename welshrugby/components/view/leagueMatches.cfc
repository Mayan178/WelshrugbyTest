<cfcomponent name="leaguematches" extends="parent" hint="View for under 20 s matches">
	<cffunction name="init" returntype="leaguematches" access="public">
		<cfset super.init()>
		<cfreturn this/>
	</cffunction>

	<cffunction name="default" access="private" returntype="struct" hint="default view for this component">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
        <cfset local.result.output=#myMatches(arguments.data).output#>
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="myMatches" access="private" returntype="struct" hint="Displays matches added by the current user">
		<cfargument name="data" type="struct" required="false">        
        <cfargument name="setNo" type="numeric" required="false" default="0">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
        <cfset local.setSize = 10>
        <cfset local.sets = Ceiling(arguments.data.allMatches.recordcount / local.setSize)>
                
        <cfset local.listofMatches = "">
        <cfloop query="arguments.data.allmatches">
        <cfset local.listofMatches = listappend(local.listofMatches,matchID)>
        </cfloop>

        <cfset local.showSetNo = 1>
        
        <cfset local.lastMatch = listlast(local.listofMatches)>

        <cftry>
            <cfsavecontent variable="local.result.output">
                <cfoutput>
                    <div class="container-fluid mb-4 p-3">
                        <div class="float-end"><a href="/leaguematches/addmatch" class="btn btn-dark mt-2 text-white float-end" role="button">Add a Match</a></div>                
                    </div>
                    <div class="container-fluid p-3">
                        You currently have #arguments.data.allMatches.recordcount# match<cfif #arguments.data.allMatches.recordcount# gt 1>es</cfif> on your League side
                        <br /><br />
                        <div class="container-fluid w-auto my-2">
                            <cfloop from="1" to="#local.sets#" index="local.setNo">
                                <div class="row" id="currentset-#local.setNo#" <cfif local.setNo neq 1>style="display:none"</cfif>>
                                    <div class="col">
                                        <div class="pagination" id="previous-open-set-#local.setNo - 1#" <cfif local.setNo eq 1>style="display:none"</cfif>>Previous</div>
                                    </div>
                                    <div class="col">
                                        <div id="current-#local.setNo#">Page #local.setNo# of #local.sets#</div>
                                    </div>
                                    <div class="col">
                                        <div class="pagination" id="next-open-set-#local.setNo + 1#" <cfif local.setNo eq #local.sets#>style="display:none"</cfif>>Next</div>
                                    </div>
                                </div>

                                <script>
                                    $(document).ready(function(){
                                        $("##previous-open-set-#local.setNo - 1#").click(function(){
                                            <cfloop from="1" to="#local.sets#" index="local.s">
                                                $("##currentset-#local.s#").hide(); 
                                                $("##monitor-set-#local.s#").hide(); 
                                            </cfloop>
                                            $("##currentset-#local.setNo - 1#").show(); 
                                            $("##monitor-set-#local.setNo - 1#").show(); 
                                        });
                                        $("##next-open-set-#local.setNo + 1#").click(function(){
                                            <cfloop from="1" to="#local.sets#" index="local.s">
                                                $("##currentset-#local.s#").hide(); 
                                                $("##monitor-set-#local.s#").hide(); 
                                            </cfloop>
                                            $("##currentset-#local.setNo + 1#").show(); 
                                            $("##monitor-set-#local.setNo + 1#").show(); 
                                        });
                                    });
                                </script>

                            </cfloop>

                            <div class="row my-2">
                                <div class="col">
                                    <cfloop from="1" to="#local.sets#" index="local.setNo">
                                        <div id="monitor-set-#local.setNo#" <cfif local.setNo neq local.showSetNo>style="display:none"</cfif>>
                                            
                                            <cfset local.fromRow = ((local.setNo-1) * local.setSize) + 1>
                                            <cfset local.toRow = Min(arguments.data.allMatches.recordcount, local.fromRow + local.setSize - 1)>
                                            <cfloop from="#local.fromRow#" to="#local.toRow#" index="local.r">
                                        
                                                #display(method="individualMatch",MatchID=arguments.data.allMatches.MatchID[local.r],OpponentName=arguments.data.allMatches.opponentname[local.r],MatchResultTitle=arguments.data.allMatches.MatchResultTitle[local.r],MatchTypeTitle=arguments.data.allMatches.MatchTypeTitle[local.r], isHome=arguments.data.allMatches.isHome[local.r],matchdate=arguments.data.allMatches.matchdate[local.r]).output#

                                            </cfloop>
                                        </div>
                                    </cfloop>
                                </div>
                            </div>
                        </div>
                    </div>
                </cfoutput>    
            </cfsavecontent>

            <cfcatch type="any">
                <cfdump var="#cfcatch#">
            </cfcatch>
        </cftry>

		<cfreturn local.result>
	</cffunction>

    <cffunction name="individualMatch" access="public" returntype="struct" hint="Displays individual matches details">
    	<cfargument name="MatchID" type="numeric" required="true" default="0">
        <cfargument name="OpponentName" type="string" required="true" default="">
        <cfargument name="MatchResultTitle" type="string" required="true" default="">
        <cfargument name="MatchTypeTitle" type="string" required="true" default="">
        <cfargument name="isHome" type="boolean" required="true" default="">
        <cfargument name="matchdate" type="string" required="true" default="0">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
                
		<cfsavecontent variable="local.result.output">
			<cfoutput>                
                <!--- main information for the match --->
                 <div class="row matchStats my-3">
                    <!--- Name info --->
                    <div class="col">
                        <div id="match-title-#arguments.MatchID#" title="View Details" class="matchToggle">#arguments.OpponentName#</div>
                    </div>
                    <!--- General info --->
                    <div class="col text-right">
                        <cfif arguments.MatchResultTitle eq "Won">
                            <strong>Won</strong>
                        <cfelseif arguments.MatchResultTitle eq "Lost">
                            <strong>Lost</strong>
                        <cfelseif arguments.MatchResultTitle eq "Drew">
                            <strong>Drew</strong>
                        </cfif>
                        &nbsp;&##124;
                        <strong>Comp:</strong>&nbsp;#arguments.MatchTypeTitle#
                        &nbsp;&##124;
                        <strong>Played:</strong> <cfif arguments.isHome>Home<cfelse>Away</cfif>
                        &nbsp;&##124;
                        <strong>Date:</strong> #dateformat(arguments.matchdate,"dd/mm/yy")#
                    </div>
                </div>
                <!--- end of main information for the match ---> 

            <!--- onclicking the title of the match, a div gets filled in with the relevant information --->
            <div id="match-full-info-#arguments.MatchID#" style="display:none;"></div>

            <script>
            $(document).ready(function(){
                $("##match-title-#arguments.MatchID#").click(function(){
                    $("##match-full-info-#arguments.MatchID#").load("/leagueMatches/showMatchDetails/MatchID/#arguments.MatchID#");
                    $("##match-full-info-#arguments.MatchID#").slideToggle(); 
                });
            });
            </script>

			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>   
    
    <cffunction name="addMatch" access="private" returntype="struct" hint="Displays form for adding a match">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
		<cfsavecontent variable="local.result.output">
			<cfoutput>
                <!--- paste in form --->
                <cfif StructKeyExists(arguments.data, "errors")>
                    #getFactory().get("template").view.errors(arguments.data.errors).output#
                </cfif>

               <div class ="container-fluid">
                <div class="row">                      
                    <div class="col-sm-8 col-md-6 col-lg-6 col-xl-6 mx-20">
                        <form action="/leaguematches/addmatch" method="POST" id="match-add-paste" name="matchaddpaste" class="was-validated">
                            <input type="hidden" name="step" id="step" value="#arguments.step#"/>
                            <h4>Match Details</h4>
                                
                            #getFactory().get("formFactory").view.display(method="inputDate", id="matchDate", label="Match Date", value=arguments.data.matchDate, required=true).output#

                            #getFactory().get("formFactory").view.display(method="inputText", id="opponentName", label="Opponent Name", value=arguments.data.opponentName, required=true).output#

                            #getFactory().get("formFactory").view.display(method="inputRadio", id="isHome", options="Home|1,Away|0", value=arguments.data.isHome, fieldTitle="Home or Away?", required=true).output#

                            <div id="scoringHome" <cfif NOT arguments.data.isHome>style="display:none"</cfif>>
                                #getFactory().get("formFactory").view.display(method="scoringHome", scoreHome=arguments.data.score, otherScoreHome=arguments.data.otherScore).output#
                                <!--- area to display error message if team score not a number --->
                                <div id="scoreHomeError" style="display:none;color:red;">
                                Please, enter a number for your team's score.
                                </div>
                                <!--- area to display error message if opponent score not a number --->
                                <div id="otherScoreHomeError" style="display:none;color:red;">
                                Please, enter a number for your opponent's score.
                                </div>
                            </div>
                            <div id="scoringAway" <cfif arguments.data.isHome>style="display:none"</cfif>>
                                #getFactory().get("formFactory").view.display(method="scoringAway", scoreAway=arguments.data.score, otherScoreAway=arguments.data.otherScore).output#
                                <!--- area to display error message if team score not a number --->
                                <div id="scoreAwayError" style="display:none;color:red;">
                                Please, enter a number for your team's score.
                                </div>
                                <!--- area to display error message if opponent score not a number --->
                                <div id="otherScoreAwayError" style="display:none;color:red;">
                                Please, enter a number for your opponent's score.
                                </div>
                            </div>

                            <!--- match result
                            <cfset local.matchResults = getFactory().get("user").model.getMatchResults()>
                            <cfset local.optionsmr = "">
                            <cfloop query="local.matchResults">
                                <cfset local.optionsmr = listAppend(local.optionsmr,"#matchResultTitle#|#matchResultID#")>
                            </cfloop>
                            #getFactory().get("formFactory").view.display(method="inputRadio", id="matchResult", options=local.optionsmr, value=arguments.data.matchResult, fieldTitle="Match Result", required=true).output#
                                --->

                            <!--- match type --->
                            <cfset local.mathTypes = getFactory().get("user").model.getMatchTypes()>
                            <cfset local.optionsmt = "">
                            <cfloop query="local.mathTypes">
                                <cfset local.optionsmt = listAppend(local.optionsmt,"#matchTypeTitle#|#matchTypeID#")>
                            </cfloop>
                            #getFactory().get("formFactory").view.display(method="inputRadio", id="matchType", options=local.optionsmt, value=arguments.data.matchType, fieldTitle="Type of Match", required=true).output#

                            <!--- Attendance section --->
                            <div id="attendance" <cfif NOT arguments.data.isHome>style="display:none"</cfif>>
                                <br/><br/>
                                <h4>Attendance</h4>
                                #getFactory().get("formFactory").view.display(method="MatchAttendance", AttendanceStanding=arguments.data.AttendanceStanding, AttendanceUncovered=arguments.data.AttendanceUncovered, AttendanceCovered=arguments.data.AttendanceCovered, AttendanceMembers=arguments.data.AttendanceMembers, AttendanceVIP=arguments.data.AttendanceVIP).output#
                                <!--- for any errors relating to above values not being numeric --->
                                <div id="AttendanceStandingError" style="display:none;color:red;">
                                    Please, enter a number for your Standing attendance.
                                </div>
                                <div id="AttendanceUncoveredError" style="display:none;color:red;">
                                    Please, enter a number for your Uncovered attendance.
                                </div>
                                <div id="AttendanceCoveredError" style="display:none;color:red;">
                                    Please, enter a number for your Covered attendance.
                                </div>
                                <div id="AttendanceMembersError" style="display:none;color:red;">
                                    Please, enter a number for your Members attendance.
                                </div>
                                <div id="AttendanceVIPError" style="display:none;color:red;">
                                    Please, enter a number for your VIP attendance.
                                </div>
                            </div>
                            <br/><br/>
                            <h4>Ratings</h4>
                            #getFactory().get("formFactory").view.display(method="MatchTeamRatings", data = arguments.data).output#                         

                            #getFactory().get("formFactory").view.display(method="inputTextArea", id="PlayersRatings", label="Players Ratings", value=arguments.data.PlayersRatings, required=true,help=true).output#
                            
                            #getFactory().get("formFactory").view.display(method="inputText", id="ManofTheMatch", label="Man of the Match", value=arguments.data.manOfTheMatch, required=false).output#
                        
                            <div class="row my-3">
                                <div class="col">&nbsp;</div>
                                <div class="col">
                                    <input type="submit" name="insert-paste" id="insert-paste" value="Add Match" class="btn btn-dark mt-2">
                                </div>
                            </div>
                        </form>
                   
                        <!--- end of paste in form --->
                        <script type="text/javascript">
                        $(document).ready(function () {
                            $("##isHome_Home").on("click", function () {
                                {$("##attendance").show(); }
                                {$("##scoringHome").show(); }
                                {$("##scoringAway").hide(); }
                            });
                            $("##isHome_Away").on("click", function () {
                                {$("##attendance").hide(); }
                                {$("##scoringHome").hide(); }
                                {$("##scoringAway").show(); }
                            });
                            $("##match-add-paste").submit(function(event){
                                event.preventDefault();

                                var validteamScore = true;
                                var validopponentScore= true;
                                var validAttendanceStanding = true;
                                var validAttendanceUncovered= true;
                                var validAttendanceCovered= true;
                                var validAttendanceMembers= true;
                                var validAttendanceVIP= true;

                                var scoreHomevalue = $("##scoreHome").val();
                                var otherScoreHomevalue = $("##otherScoreHome").val();
                                var scoreAwayvalue = $("##scoreAway").val();
                                var otherScoreAwayvalue = $("##otherScoreAway").val();
                                
                                var AttendanceStandingvalue = $("##AttendanceStanding").val();
                                var AttendanceUncoveredvalue = $("##AttendanceUncovered").val();
                                var AttendanceCoveredvalue = $("##AttendanceCovered").val();
                                var AttendanceMembersvalue = $("##AttendanceMembers").val();
                                var AttendanceVIPvalue = $("##AttendanceVIP").val();

                                if ($('##isHome_Home').is(':checked'))
                                {
                                    if ((scoreHomevalue.length > 0 ) && (!$.isNumeric(scoreHomevalue)))
                                    { 
                                        $("##scoreHomeError").show(); 
                                        $("##scoreHome").focus();
                                        validteamScore = false;
                                    }
                                    else 
                                    {
                                        $("##scoreHomeError").hide(); 
                                        validteamScore = true;
                                    }

                                    if ((otherScoreHomevalue.length > 0 ) && (!$.isNumeric(otherScoreHomevalue)))
                                    { 
                                        $("##otherScoreHomeError").show(); 
                                        $("##otherScoreHome").focus();
                                        validopponentScore = false;
                                    }
                                    else 
                                    {
                                        $("##otherScoreHomeError").hide(); 
                                        validopponentScore = true;
                                    }

                                    if ((AttendanceStandingvalue.length > 0 ) && (!$.isNumeric(AttendanceStandingvalue)))
                                    { 
                                        $("##AttendanceStandingError").show(); 
                                        $("##AttendanceStanding").focus();
                                        validAttendanceStanding = false;
                                    }
                                    else 
                                    {
                                        $("##AttendanceStandingError").hide(); 
                                        validAttendanceStanding = true;
                                    }

                                    if ((AttendanceUncoveredvalue.length > 0 ) && (!$.isNumeric(AttendanceUncoveredvalue)))
                                    { 
                                        $("##AttendanceUncoveredError").show(); 
                                        $("##AttendanceUncovered").focus();
                                        validAttendanceUncovered = false;
                                    }
                                    else 
                                    {
                                        $("##AttendanceUncoveredError").hide(); 
                                        validAttendanceUncovered = true;
                                    }

                                    if ((AttendanceCoveredvalue.length > 0 ) && (!$.isNumeric(AttendanceCoveredvalue)))
                                    { 
                                        $("##AttendanceCoveredError").show(); 
                                        $("##AttendanceCovered").focus();
                                        validAttendanceCovered = false;
                                    }
                                    else 
                                    {
                                        $("##AttendanceCoveredError").hide(); 
                                        validAttendanceCovered = true;
                                    }
                                    if ((AttendanceMembersvalue.length > 0 ) && (!$.isNumeric(AttendanceMembersvalue)))
                                    { 
                                        $("##AttendanceMembersError").show(); 
                                        $("##AttendanceMembers").focus();
                                        validAttendanceMembers = false;
                                    }
                                    else 
                                    {
                                        $("##AttendanceMembersError").hide(); 
                                        validAttendanceMembers = true;
                                    }
                                    if ((AttendanceVIPvalue.length > 0 ) && (!$.isNumeric(AttendanceVIPvalue)))
                                    { 
                                        $("##AttendanceVIPError").show(); 
                                        $("##AttendanceVIP").focus();
                                        validAttendanceVIP = false;
                                    }
                                    else 
                                    {
                                        $("##AttendanceVIPError").hide(); 
                                        validAttendanceVIP = true;
                                    }
                                }
                                    
                                if ($('##isHome_Away').is(':checked'))
                                {
                                    if ((scoreAwayvalue.length > 0 ) && (!$.isNumeric(scoreAwayvalue)))
                                    { 
                                        $("##scoreAwayError").show(); 
                                        $("##scoreAway").focus();
                                        validteamScore = false;
                                    }
                                    else 
                                    {
                                        $("##scoreAwayError").hide(); 
                                        validteamScore = true;
                                    }

                                        if ((otherScoreAwayvalue.length > 0 ) && (!$.isNumeric(otherScoreAwayvalue)))
                                    { 
                                        $("##otherScoreAwayError").show(); 
                                        $("##otherScoreAway").focus();
                                        validopponentScore = false;
                                    }
                                    else 
                                    {
                                        $("##otherScoreAwayError").hide(); 
                                        validopponentScore = true;
                                    }
                                }                                    
                                    if (validteamScore && validopponentScore && validAttendanceStanding && validAttendanceUncovered && validAttendanceCovered && validAttendanceMembers && validAttendanceVIP) this.submit();
                            });
                        });
                        </script>
                    </div>
                </div>
            </div>
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="showMatchDetails" access="private" returntype="struct" hint="Displays a specific match data">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        <cftry>
            <cfif arguments.data.matchDetails.HomeOrAway is "home">
                <cfset local.attendanceTotal = arguments.data.matchDetails.attendanceStanding+arguments.data.matchDetails.attendanceUncovered+arguments.data.matchDetails.attendanceCovered+arguments.data.matchDetails.attendanceMembers+arguments.data.matchDetails.attendanceVIP>
            </cfif>
            
            <cfsavecontent variable="local.result.output">
             <div class="container-fluid">
                <!--- general match information --->
                <div class="row mb-3">
                    <div class="col">
                        <table cellspacing="0" class="maininfotable">
                            <cfloop from="1" to="#arrayLen(arguments.data.MatchTeamRatingsToUse)#" index="local.i">
                            <cfoutput>
                            <tr>
                                <td class="first"><strong>#arguments.data.MatchTeamRatingsToUse[local.i].name#:</strong></td>
                                <td>
                                <cfif arguments.data.matchDetails.HomeOrAway is "home">
                                <img src="/res/img/stars/#replacenocase(arguments.data.MatchTeamRatingsToUse[local.i].value,'.','_','all')#.gif" alt="#arguments.data.MatchTeamRatingsToUse[local.i].value#">
                                <cfelse>
                                <img src="/res/img/stars/left_#replacenocase(arguments.data.MatchTeamRatingsToUse[local.i].value,'.','_','all')#.gif" alt="#arguments.data.MatchTeamRatingsToUse[local.i].value#">
                                </cfif>
                                </td>
                            </tr>
                            </cfoutput>
                            </cfloop>
                        </table>
                    </div>
                </div>
                <!--- end of general match information --->

                <!--- visual representation of the match --->
                <div class="row mb-3">
                    <div class="col">
                        <div class="table-responsive">
                            <div class ="teamVisual">
                                <cfoutput query="arguments.data.myMatch">
                                    <cfif arguments.data.myMatch.positionid lte 15>
                                        <cfif arguments.data.myMatch.stars gte 1>
                                            <cfif left(arguments.data.myMatch.stars,1) eq "0">
                                                <cfset local.playerstars = Mid(arguments.data.myMatch.stars, 2, len(arguments.data.myMatch.stars))>
                                            <cfelse>
                                                <cfset local.playerstars = arguments.data.myMatch.stars>
                                            </cfif>
                                        <cfelse>
                                            <cfset local.playerstars = arguments.data.myMatch.stars>
                                        </cfif>
                                        <div id="position#arguments.data.myMatch.positionid#">
                                            <table cellpadding="0" cellspacing="0" class="positiontable">
                                                <tr>
                                                    <td><img src="/res/img/national/#getFactory().get("session").model.get("country")#/number#arguments.data.myMatch.positionid#.gif"></td>
                                                    <td class="info">
                                                    <cfif Len(arguments.data.myMatch.firstname) AND Len(arguments.data.myMatch.lastname)>
                                                    #arguments.data.myMatch.firstname# #arguments.data.myMatch.lastname#
                                                    <cfelse>
                                                    Sold or Fired
                                                    </cfif>
                                                    <cfif arguments.data.myMatch.manofthematch>&nbsp;<img src="/res/img/icons/manofthematch.gif" id="manofthematch" alt="Man of the Match"></cfif><br/>
                                                    <cfif arguments.data.myMatch.playerExpectationTitle eq "Player performed better than expected">
                                                        <img src="/res/img/players/arrow_up.gif" alt="Player performed better than expected">
                                                    <cfelseif arguments.data.myMatch.playerExpectationTitle eq "Player performed worse than expected">
                                                        <img src="/res/img/players/arrow_down_red.gif" alt="Player performed worse than expected">
                                                    <cfelseif arguments.data.myMatch.playerExpectationTitle eq "Player performed as expected">
                                                        <img src="/res/img/players/icon_tick_grey.gif" alt="Player performed as expected">
                                                    </cfif>
                                                    <cfif arguments.data.myMatch.playerPotentialTitle eq "Player did not reach their potential in the position played">
                                                    <img src="/res/img/players/icon_cross_grey.gif" alt="Player did not reach their potential in the position played">                         	
                                                    <cfelseif arguments.data.myMatch.playerPotentialTitle eq "Player reached their potential in the position played">
                                                        <img src="/res/img/players/icon_tick_green.gif" alt="Player reached their potential in the position played">                         			
                                                    </cfif>
                                                    &nbsp;(#local.playerstars#)
                                                    </td>
                                                </tr>
                                            </table>  
                                        </div>
                                    </cfif>
                                </cfoutput>
                            </div>
                        </div>
                    </div>
                </div>
                <!--- end of visual representation of the match --->

                <!--- replacements and information --->
                <div class="row mb-3">
                    <cfif arguments.data.matchDetails.HomeOrAway is "home">
                        <div class="col">
                            <table cellspacing="0" class="smallinfotable">
                                <tr>
                                    <td colspan="2" class="first"><strong>Replacements:</strong></td>
                                </tr>
                                <cfoutput query="arguments.data.matchPlayers">
                                <tr>
                                    <td class="first">#positionID#. #playerfullname#<cfif manofthematch>&nbsp;<img src="/res/img/icons/manofthematch.gif" id="manofthematch" alt="Man of the Match"></cfif></td>
                                    <td class="right">
                                    <cfif len(DidPlayText)>
                                    #DidPlayText#
                                    <cfelse>
                                        <cfif playerExpectationTitle eq "Player performed better than expected">
                                        <img src="/res/img/players/arrow_up.gif" alt="played Player performed better than expected">
                                        <cfelseif playerExpectationTitle eq "Player performed worse than expected ">
                                            <img src="/res/img/players/arrow_down_red.gif" alt="played Player performed worse than expected ">
                                        <cfelseif playerExpectationTitle eq "Player performed as expected">
                                            <img src="/res/img/players/icon_tick_grey.gif" alt="played Player performed as expected">
                                        </cfif>
                                        
                                        <cfif playerPotentialTitle eq "Player did not reach their potential in the position played">  
                                        <img src="/res/img/players/icon_cross_grey.gif" alt="Player did not reach their potential in the position played">                         	
                                        <cfelseif playerPotentialTitle eq "Player reached their potential in the position played">  
                                            <img src="/res/img/players/icon_tick_green.gif" alt="Player reached their potential in the position played">                         			
                                        </cfif>
                                        
                                    </cfif>
                                    </td>
                                </tr>
                                </cfoutput>
                            </table>
                        </div>
                        <div class="col">                                
                            <table cellspacing="0" class="smallinfotable">
                                <tr>
                                    <td colspan="2" class="first"><strong>Attendance:</strong></td>
                                </tr>
                                <cfoutput query="arguments.data.matchDetails">
                                <tr>
                                    <td class="first"><strong>Standing:</strong></td>
                                    <td>#AttendanceStanding#</td>
                                </tr>
                                <tr>
                                    <td class="first"><strong>Uncovered:</strong></td>
                                    <td>#AttendanceUncovered#</td>
                                </tr>
                                <tr>
                                    <td class="first"><strong>Covered:</strong></td>
                                    <td>#AttendanceCovered#</td>
                                </tr>
                                <tr>
                                    <td class="first"><strong>Members:</strong></td>
                                    <td>#AttendanceMembers#</td>
                                </tr>
                                <tr>
                                    <td class="first"><strong>Corporate/VIP:</strong></td>
                                    <td>#AttendanceVIP#</td>
                                </tr>
                                </cfoutput>
                            </table>
                            <cfif StructKeyExists(arguments.data,"matchAttendance")>
                                <br/>
                                <cfchart	 
                                backgroundColor = "##ffffff"	 
                                chartHeight = "300"	 
                                chartWidth = "300"	 
                                font = "arial"	 
                                fontBold = "yes"	 
                                fontItalic = "no"	 
                                fontSize = "12"	 
                                foregroundColor = "##000000"	 
                                format = "jpg"	
                                show3D = "yes"	
                                showBorder = "no"	 
                                showMarkers = "yes"	
                                showXGridlines = "no"
                                showYGridlines = "no"
                                sortXAxis = "no" 
                                title = "Total: #local.AttendanceTotal#"
                                pieSliceStyle="sliced">
                                                                    
                                    <cfchartseries type="pie" 
                                    query="arguments.data.matchAttendance"
                                    itemcolumn="AttendanceTitle" 
                                    valuecolumn="AttendanceValue"
                                    seriescolor="##7ABDC6" 
                                    paintstyle="plain"
                                    dataLabelStyle="value">
                                    </cfchartseries>
                                                                    
                                </cfchart>
                            </cfif>
                        </div>
                    <cfelse>
                        <div class="col">
                            <table cellspacing="0" class="smallinfotable">
                                <tr>
                                    <td colspan="2" class="first"><strong>Replacements:</strong></td>
                                </tr>
                                <cfoutput query="arguments.data.matchPlayers">
                                <tr>
                                    <td class="first">#positionID#. #playerfullname#<cfif manofthematch>&nbsp;<img src="/res/img/icons/manofthematch.gif" id="manofthematch" alt="Man of the Match"></cfif></td>
                                    <td class="right">
                                    <cfif len(DidPlayText)>
                                    #DidPlayText#
                                    <cfelse>
                                        <cfif playerExpectationTitle eq "Player performed better than expected">
                                        <img src="/res/img/players/arrow_up.gif" alt="played Player performed better than expected">
                                        <cfelseif playerExpectationTitle eq "Player performed worse than expected ">
                                            <img src="/res/img/players/arrow_down_red.gif" alt="played Player performed worse than expected ">
                                        <cfelseif playerExpectationTitle eq "Player performed as expected">
                                            <img src="/res/img/players/icon_tick_grey.gif" alt="played Player performed as expected">
                                        </cfif>
                                        
                                        <cfif playerPotentialTitle eq "Player did not reach their potential in the position played">  
                                        <img src="/res/img/players/icon_cross_grey.gif" alt="Player did not reach their potential in the position played">                         	
                                        <cfelseif playerPotentialTitle eq "Player reached their potential in the position played">  
                                            <img src="/res/img/players/icon_tick_green.gif" alt="Player reached their potential in the position played">                         			
                                        </cfif>
                                    </cfif>
                                    </td>
                                </tr>
                                </cfoutput>
                            </table>
                        </div>
                    </cfif>
                </div>    
            </div>
            </cfsavecontent>

            <cfcatch type="any">
                <cfdump var="#cfcatch#">
            </cfcatch>
        </cftry>

		<cfreturn local.result>
	</cffunction>
    
</cfcomponent>
