<cfcomponent name="leagueteams" extends="parent" hint="View for under 20 s teams">
	<cffunction name="init" returntype="leagueteams" access="public">
		<cfset var local = structNew()>

		<cfset super.init()>
		<cfreturn this/>
	</cffunction>

	<cffunction name="default" access="private" returntype="struct" hint="default view for this component">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
        <cfset local.result.output=#myteams(arguments.data).output#>
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="myteams" access="private" returntype="struct" hint="Displays all teams added by current user">
		<cfargument name="data" type="struct" required="false">        
        <cfargument name="setNo" type="numeric" required="false" default="0">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
        <cfset local.setSize = 10>
        <cfset local.sets = Ceiling(arguments.data.allTeams.recordcount / local.setSize)>
        
        <!--- if the user has been editing a team --->
        <cfset local.showSetNo = 1>
        
        <cfset local.listofTeams = "">
        <cfloop query="arguments.data.allTeams">
        <cfset local.listofTeams = listappend(local.listofTeams,teamID)>
        </cfloop>
        <cfset local.lastTeam = listlast(local.listofTeams)>
        
		<cfsavecontent variable="local.result.output">
			<cfoutput>
            <div class="container-fluid mb-5 p-3">
                <div class="float-end"><a href="/LeagueTeams/addTeam" class="btn btn-dark mt-2">Add a Team</a></div>
            </div>
            <div class="container-fluid w-auto my-2">
            	You currently have #arguments.data.allTeams.recordcount# team<cfif #arguments.data.allTeams.recordcount# gt 1>s</cfif> on your League side
                <br /><br />
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

                <div class="row">
                    <div class="col">
                
                    <cfloop from="1" to="#local.sets#" index="local.setNo">
                        <div id="monitor-set-#local.setNo#" <cfif local.setNo neq local.showSetNo>style="display:none"</cfif>>                                
                            <cfset local.fromRow = ((local.setNo-1) * local.setSize) + 1>
                            <cfset local.toRow = Min(arguments.data.allTeams.recordcount, local.fromRow + local.setSize - 1)>
                            <cfloop from="#local.fromRow#" to="#local.toRow#" index="local.r">
                                <!--- TEAM INDIVIDUAL INFO --->
                                <div class="row teamStats my-3">
                                    <div class="col">
                                        <div class="teamToggle" id="team-title-team-title-#arguments.data.allTeams.teamID[local.r]#" title="View Details">
                                        #arguments.data.allTeams.teamtitle[local.r]#
                                    </div>
                                    </div>
                                    <div class="col">
                                        Date Created: #dateformat(arguments.data.allTeams.dateadded[local.r],"dd/mm/yy")#
                                    </div>
                                    <div class="col">
                                        Date Last Updated: #dateformat(arguments.data.allTeams.datelastupdated[local.r],"dd/mm/yy")#
                                    </div>
                                    <!--- links for editing team info and deleting teams --->
                                    <div class="col">
                                        <div class="teamactions" id="team-editlink-#arguments.data.allTeams.teamID[local.r]#">Edit</div>
                                    </div>
                                    <div class="col">
                                        <div class="teamactions" id="team-deletelink-#arguments.data.allTeams.teamID[local.r]#">Delete</div>
                                    </div>
                                    <div class="col">
                                        <div class="teamactions" id="team-exportlink-#arguments.data.allTeams.teamID[local.r]#">Export Team Data</div>
                                    </div>
                                    <!--- end of links for editing team info and deleting teams --->
                                </div>

                                <div id="team-details-#arguments.data.allTeams.teamID[local.r]#" class="teamall" style="display:none;"></div>

                                <script>
                                $(document).ready(function(){
                                    $("##team-title-team-title-#arguments.data.allTeams.teamID[local.r]#").click(function(){
                                        <cfloop from="#local.fromRow#" to="#local.toRow#" index="local.ra">
                                            <cfif local.ra neq local.r>
                                            $("##team-details-#arguments.data.allTeams.teamID[local.ra]#").hide(); 
                                            </cfif>
                                        </cfloop>
                                        
                                        $("##team-details-#arguments.data.allTeams.teamID[local.r]#").load("/Leagueteams/showTeamDetails/teamID/#arguments.data.allTeams.teamID[local.r]#");
                                        $("##team-details-#arguments.data.allTeams.teamID[local.r]#").slideToggle(); 
                                    });                                        
                                    $("##team-editlink-#arguments.data.allTeams.teamID[local.r]#").click(function(){
                                        window.location.href = "/leagueTeams/editTeam/teamID/#arguments.data.allTeams.teamID[local.r]#";
                                    });
                                    $("##team-deletelink-#arguments.data.allTeams.teamID[local.r]#").click(function(){
                                        if (window.confirm('Are you sure you want to delete team #arguments.data.allTeams.teamtitle[local.r]#?'))
                                        {
                                            window.location.href = "/leagueTeams/deleteTeam/teamID/#arguments.data.allTeams.teamID[local.r]#";
                                        }
                                    });
                                    $("##team-exportlink-#arguments.data.allTeams.teamID[local.r]#").click(function(){
                                        window.location.href = "/leagueTeams/exportTeam/teamID/#arguments.data.allTeams.teamID[local.r]#";
                                    });
                                });
                            </script>

                            </cfloop>
                        </div>
                    </cfloop>
                    </div>
                </div>
            </div>
			</cfoutput>    
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="showTeamDetails" access="private" returntype="struct" hint="Displays a specific team's details">
		<cfargument name="data" type="struct" required="false">
        <cfargument name="teamID" type="numeric" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
		<cfsavecontent variable="local.result.output">
            <cfoutput>
            <div class="container-fluid" id="stadium-#arguments.teamID#">
            </cfoutput>

            <div class="table-responsive">
                <div class ="teamVisual">  
                    <cfoutput query="arguments.data.myTeam">

                    <cfset local.potentialPlayers = getFactory().get("Leagueplayers").model.getAllPotentialPlayers(teamDateCreated=#arguments.data.myTeam.dateadded#)>
                    <cfif arguments.data.myTeam.positionid lte 17>
                       <div id="position#arguments.data.myTeam.positionid#">
                       <table cellpadding="0" cellspacing="0" class="positiontable">
                            <tr>
                                <td>#arguments.data.myTeam.positionid#. #arguments.data.myTeam.positiontitle#</td>
                            </tr>
                            <tr>
                                <td>
                                    <select name="team#teamid#-position#arguments.data.myTeam.positionid#" id="team#teamid#-position#arguments.data.myTeam.positionid#">
                                    <option value="">Unassigned</option>
                                    <cfloop query="local.potentialPlayers">
                                    <option value="#playerID#" <cfif arguments.data.myTeam.playerID eq playerID>selected</cfif> style="font-weight:bold"><cfif arguments.data.myTeam.playerID eq playerID>*</cfif> #firstname# #lastname#</option>
                                    </cfloop>
                                    </select>
                                </td>
                            </tr>
                        </table>  
                        
                        <script type="text/javascript">
                            $(document).ready(function(){
                                $("##team#teamid#-position#arguments.data.myTeam.positionid#").change(function(){
									selOldPlayer = '#arguments.data.myTeam.playerID#';
									selTeamID = '#teamID#';
									selPositionID = '#positionid#';
                                    selNewPlayer = $('##team#teamid#-position#arguments.data.myTeam.positionid#').val();
									newHref = "/Leagueteams/showTeamDetails";
									if (selOldPlayer.length)
										newHref = newHref + "/oldPlayer/" + selOldPlayer;
									if (selTeamID.length)
										newHref = newHref + "/teamID/" + selTeamID;
									if (selPositionID.length)
										newHref = newHref + "/positionID/" + selPositionID;
									if (selNewPlayer.length)
										newHref = newHref + "/newPlayer/" + selNewPlayer;
                                    $("##stadium-#arguments.teamID#").load(newHref);

                                });
                            });
						</script>
                        </div>
                    </cfif>
                    </cfoutput>
                    </div>
                </div>
            </div>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>

    <cffunction name="editTeam" access="private" returntype="struct" hint="Displays form enabling user to edit a team">
		<cfargument name="teamID" type="numeric" required="true" default="0">
        <cfargument name="teamTitle" type="string" required="true" default="">
        <cfargument name="setNo" type="numeric" required="false" default="0">
        
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        
		<cfsavecontent variable="local.result.output">
			<cfoutput>
                <div class="container-fluid">
                    <form action="/Leagueteams/editTeam/teamID/#arguments.teamID#" method="POST" id="team-edit-#arguments.teamID#" class="was-validated"> 

                        #getFactory().get("formFactory").view.display(method="inputText", id="teamTitle", label="Team Title", value=arguments.teamTitle, required=true).output#
                            
                        <div class="row">
                            <div class="col">
                                <a class="btn btn-dark my-2" href="/leagueteams/myteams" role="button" id="canceledit-#arguments.teamID#">Cancel</a>
                            </div>
                            <div class="col">
                                <input type="submit" name="update" id="update" value="Update Team" class="btn btn-dark my-2">
                            </div>
                        </div>
                    </form>
                </div>
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>

    <cffunction name="addTeam" access="private" returntype="struct"> hint="Displays a form enabling user to add a team"
        <cfargument name="setNo" type="numeric" required="false" default="0">
        
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        
		<cfsavecontent variable="local.result.output">
			<cfoutput>
                <div class="container-fluid">
                    <form action="/Leagueteams/addTeam/" method="POST" id="team-add"  class="was-validated"> 
                        <div id="teamExists" style="display:none; color:red;"></div>
                        #getFactory().get("formFactory").view.display(method="inputText", id="teamTitle", label="Team Title", value="", required=true).output#
                        <div class="row float-end">
                            <div class="col">
                                <a class="btn btn-dark my-2 text-white" href="/leagueteams/myteams" role="button" id="canceledit">Cancel</a>
                            </div>
                            <div class="col">
                                <input type="submit" name="add" id="add" value="Add a Team" class="btn btn-dark my-2">
                            </div>
                        </div>
                    </form>
                </div>

                <script>
                    $(document).ready(function(){
                        $("##teamTitle").blur(function(){
                            var teamTitle = document.getElementById("teamTitle").value;
                            $("##teamExists").show(); 
                            $("##teamExists").load("/LeagueTeams/checkTeamExists/teamTitle/" + teamTitle);
                            var existingContent = document.getElementById("teamExists").innerHTML;
                        });
                        $("##team-add").submit(function(){
                            var existingContent = document.getElementById("teamExists").innerHTML;
                            if (existingContent.indexOf('already') != -1)
                            {
                                return false;
                            }
                        });
                    });
                    </script>
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="exportTeam" access="private" returntype="struct" hint="Displays a link to a generated jSON file">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

        <cftry>
            <cffile action = "read" 
            file = "#getFactory().getSetting("jSONDataPath")#\#arguments.data.filename#" 
            variable = "local.myJSON">

            <cfcatch type="any">
            <cfdump var="#local.myJSON#">
            </cfcatch>
        </cftry>
                
        <cfsavecontent variable="local.result.output">
			<cfoutput>
            	<div class="container-fluid">
                    <div class="row">
                        <div class="col">
                            Please, click on the link below to view the generated JSON file.
                        </div>
                    </div>
                    <div class="row">
                        <div class="col">
                            <div id="download" class="btn btn-dark mt-2 text-white float-right" role="button" target="_blank">View  #arguments.data.filename#</div>
                        </div>
                    </div>
                </div>

                <script>
                    $("##download").click(function(){
                    window.location.href = "/leagueTeams/download/filename/#arguments.data.filename#";
                    });
                </script>

                <br/><br/>

				#getFactory().get("template").view.defaultFooter().output#
			</cfoutput>
		</cfsavecontent>
        
		<cfreturn local.result>
	</cffunction>
   
</cfcomponent>