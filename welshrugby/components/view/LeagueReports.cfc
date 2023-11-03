<cfcomponent name="LeagueReports" extends="parent" hint="View for league reports">
	<cffunction name="init" returntype="LeagueReports" access="public">
		<cfset super.init()>
		<cfreturn this/>
	</cffunction>

	<cffunction name="default" access="private" returntype="struct" hint="default view for this component">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
        <cfset local.result.output=#myReports().output#>
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="myReports" access="private" returntype="struct" hint="displaying list of available reports">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		                
		<cfsavecontent variable="local.result.output">
			<cfoutput>

            <div class="container-fluid p-3">
                <div class="table-responsive">
                    <table class="table  table-striped table-bordered">
                        <thead class="thead-dark">
                            <tr>
                                <th>Type of Report to Run</th>
                                <th>&nbsp;</th>
                            </tr>
                        </thead>
                        <tbody>
                            
                            <tr>
                                <td>Position Average</td>
                                <td>
                                <a href="/Leaguereports/positionAverage/" id="run-positionAverage">Select</a>
                                </td>                           
                            </tr>
                            <tr>
                                <td>Players</td>
                                <td>
                                <a href="/Leaguereports/players/" id="run-players">Select</a>
                                </td>                           
                            </tr>
                            <tr>
                                <td>Players Average</td>
                                <td>
                                <a href="/Leaguereports/playersaverage/" id="run-playersaverage">Select</a>
                                </td>                           
                            </tr>
                            <tr>
                                <td>Players Progression</td>
                                <td>
                                <a href="/Leaguereports/playersprogression/" id="run-playersprogression">Select</a>
                                </td>                           
                            </tr>
                            <tr>
                                <td>Match Fixtures Comparison</td>
                                <td>
                                <a href="/Leaguereports/matchcomparison/" id="run-matchcomparison">Select</a>
                                </td>                           
                            </tr>
                            <tr>
                                <td>Attendance</td>
                                <td>
                                <a href="/Leaguereports/attendance/" id="run-attendance">Select</a>
                                </td>                           
                            </tr>
                            
                        </tbody>
                    </table>
                </div>
            </div>                
			</cfoutput>    
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="positionAverage" access="private" returntype="struct" hint="Form enabling user to search for a position's average data">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
		<cfsavecontent variable="local.result.output">
			<cfoutput>
            <div class="container-fluid w-auto my-2">
                <div class="row">                      
                    <div class="col-sm-8 col-md-6 col-lg-6 col-xl-6 mx-20">
                        <form action="/Leaguereports/positionAverage" method="POST" class="was-validated" id="r-positionaverage">
                            <input type="hidden" name="step" id="step" value="#arguments.step#"/>
                            
                            <!--- first time around --->
                            <cfif arguments.step eq 1>
                                #getFactory().get("formFactory").view.display(method="position", value=arguments.data.position,required=true).output#
                                <div class="row">
                                    <div class="col">
                                        <a class="btn btn-dark my-2" href="/leagueReports" role="button">Cancel</a>
                                    </div>
                                    <div class="col"><input type="submit" name="search" id="search" value="Search" class="btn btn-dark my-2"></div>
                                </div>
                            <!--- search made. Display result and allow to search again --->
                            <cfelseif arguments.step eq 2>
                                    <div class="row">
                                    <div class="col">#getFactory().get("formFactory").view.display(method="position", value=arguments.data.position,required=true).output#</div>
                                    <div class="col"><input type="submit" name="search" id="search" value="Search again" class="btn btn-dark my-4"></div>
                                </div>
                            </cfif>
                        </form>
                    </div>
                </div>

                <!--- result of any search --->
                <cfif arguments.step eq 2>
                    <div class="row"> 
                        <div class="col mx-20">
                            <br/><br/>
                            Results for position #arguments.data.position#
                            <br/><br/>
                            <div class="table-responsive">
                                <table class="table  table-striped table-bordered">
                                    <thead class="thead-dark">
                                        <tr>
                                            <th>Name</th>
                                            <th>Times in Position</th>
                                            <th>Times Played</th>
                                            <th>Average Stat in Position</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <cfloop query="arguments.data.players">
                                        <tr>
                                            <td>#FirstName# #LastName#</td>
                                            <td>#NoTimesInPosition#</td>
                                            <td>#NoTimesPlayed#</td>
                                            <td>
                                            <cfif AverageStarsInPosition neq "00">
                                                <cfif AverageStarsInPosition lt 1>
                                                    <cfset local.AverageStarsInPosition = numberFormat(AverageStarsInPosition,"_._")>
                                                <cfelse>
                                                    <cfset local.AverageStarsInPosition = AverageStarsInPosition>
                                                </cfif>
                                                <img src="/res/img/stars/#replacenocase(local.AverageStarsInPosition,'.','_','all')#.gif" alt="#local.AverageStarsInPosition#">
                                            <cfelse>
                                            N/A
                                            </cfif>
                                            </td>
                                        </tr>
                                        </cfloop>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </cfif>
            </div>
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>
    
    
    <cffunction name="players" access="private" returntype="struct" hint="Form enabling user to search for a specific player's data">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

		
		<cfsavecontent variable="local.result.output">
			<cfoutput>
            	<div class="container-fluid w-auto my-2">
                    <div class="row">                      
                        <div class="col-sm-8 col-md-6 col-lg-6 col-xl-6 mx-20">
                            <form action="/Leaguereports/players" method="POST" class="was-validated" id="r-players">
                                <input type="hidden" name="step" id="step" value="#arguments.step#"/>
                                
                                <!--- first time around --->
                                <cfif arguments.step eq 1>
                                    #getFactory().get("formFactory").view.display(method="playerReport", value=arguments.data.playerID,required=true).output#
                                    <div class="row">
                                        <div class="col">
                                            <a class="btn btn-dark my-2" href="/leagueReports" role="button">Cancel</a>
                                        </div>
                                        <div class="col"><input type="submit" name="search" id="search" value="Search" class="btn btn-dark my-2"></div>
                                    </div>
                                <!--- search made. Display result and allow to search again --->
                                <cfelseif arguments.step eq 2>
                                        <div class="row">
                                        <div class="col">#getFactory().get("formFactory").view.display(method="playerReport", value=arguments.data.playerID,required=true).output#</div>
                                        <div class="col"><input type="submit" name="search" id="search" value="Search again" class="btn btn-dark my-4"></div>
                                    </div>
                                </cfif>
                            </form>
                        </div>
                    </div>

                    <!--- result of any search --->
                    <cfif arguments.step eq 2>
                        <div class="row"> 
                            <div class="col mx-20">
                                <br/><br/>
                                <cfif arguments.data.player.recordcount>
                                    Results for player #arguments.data.playerName.firstname# #arguments.data.playerName.lastname#
                                        <br/><br/>
                                        <div class="table-responsive">
                                            <table class="table  table-striped table-bordered">
                                                <thead class="thead-dark">
                                                    <tr>
                                                        <th>Match</th>
                                                        <th>Position</th>
                                                        <th>Man of the Match</th>
                                                        <th>Expectations</th>
                                                        <th>Potential</th>
                                                        <th>&nbsp;</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <cfloop query="arguments.data.player">
                                                    <tr>
                                                        <td>#OpponentName# on #dateformat(MatchDate,"dd/mm/yyyy")#</td>
                                                        <td>#PositionTitle#</td>
                                                        <td><cfif manofTheMatch>Yes<cfelse>No</cfif></td>
                                                        <td>
                                                        <cfif expectationTitle eq "Player performed better than expected">
                                                            <img src="/res/img/players/arrow_up.gif" alt="played better than expected">
                                                        <cfelseif expectationTitle eq "Player performed worse than expected">
                                                            <img src="/res/img/players/arrow_down_red.gif" alt="played worse than expected">
                                                        <cfelseif expectationTitle eq "Player performed as expected">
                                                            <img src="/res/img/players/icon_tick_grey.gif" alt="played as well as expected">
                                                        </cfif>
                                                        </td>
                                                        <td>
                                                        <cfif PlayerPotentialID eq "2">  
                                                        <img src="/res/img/players/icon_cross_grey.gif" alt="#PlayerPotentialTitle#">                         	
                                                        <cfelseif PlayerPotentialID eq "3">  
                                                            <img src="/res/img/players/icon_tick_green.gif" alt="#PlayerPotentialTitle#">      
                                                        <cfelse>
                                                        &nbsp;                   			
                                                        </cfif>
                                                        </td>
                                                        <td>
                                                        <cfif stars neq 0>
                                                        <img src="/res/img/stars/#replacenocase(stars,'.','_','all')#.gif" alt="#stars#">
                                                        <cfelse>
                                                        N/A
                                                        </cfif>
                                                        </td>
                                                    </tr>
                                                    </cfloop>
                                                </tbody>
                                            </table>
                                        </div>
                                    <cfelse>
                                        There were no results for player #arguments.data.playerName.firstname# #arguments.data.playerName.lastname#
                                    </cfif>

                            </div>
                        </div>
                    </cfif>
                </div>
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>
    
    
    <cffunction name="playersaverage" access="private" returntype="struct" hint="Form enabling user to search for a specific player's average data">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
		<cfsavecontent variable="local.result.output">
			<cfoutput>
            	<div class="container-fluid w-auto my-2">
                    <div class="row">                      
                        <div class="col-sm-8 col-md-6 col-lg-6 col-xl-6 mx-20">
                            <form action="/Leaguereports/playersaverage" method="POST" class="was-validated" id="r-playersaverage">
                                <input type="hidden" name="step" id="step" value="#arguments.step#"/>
                                
                                <!--- first time around --->
                                <cfif arguments.step eq 1>
                                    #getFactory().get("formFactory").view.display(method="playerReport", value=arguments.data.playerID,required=true).output#
                                    <div class="row">
                                        <div class="col">
                                            <a class="btn btn-dark my-2" href="/leagueReports" role="button">Cancel</a>
                                        </div>
                                        <div class="col"><input type="submit" name="search" id="search" value="Search" class="btn btn-dark my-2"></div>
                                    </div>
                                <!--- search made. Display result and allow to search again --->
                                <cfelseif arguments.step eq 2>
                                        <div class="row">
                                        <div class="col">#getFactory().get("formFactory").view.display(method="playerReport", value=arguments.data.playerID,required=true).output#</div>
                                        <div class="col"><input type="submit" name="search" id="search" value="Search again" class="btn btn-dark my-4"></div>
                                    </div>
                                </cfif>
                            </form>
                        </div>
                    </div>

                    <!--- result of any search --->
                    <cfif arguments.step eq 2>                            
                        <div class="row"> 
                            <div class="col mx-20">
                                <br/><br/>
                                <cfif arguments.data.player.recordcount>
                                    Results for player #arguments.data.playerName.firstname# #arguments.data.playerName.lastname#
                                    <br/><br/>
                                    <div class="table-responsive">
                                        <table class="table  table-striped table-bordered">
                                            <thead class="thead-dark">
                                                <tr>
                                                    <th>Position</th>
                                                    <th>Times in Position</th>
                                                    <th>Times Man of the Match</th>
                                                    <th>&nbsp;</th>
                                                    <th>Average Stat in Position</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <cfloop query="arguments.data.player">
                                                <tr>
                                                    <td>#PositionTitle#</td>
                                                    <td>#NoTimesPosition#</td>
                                                    <td>#NomanofTheMatch#</td>
                                                    <td>
                                                    <cfloop from="1" to="#NoTimesPotentialReachedInPosition#" index="local.i">
                                                        <img src="/res/img/players/icon_tick_green.gif" alt="Reached Potential" title="Reached Potential">  
                                                    </cfloop> 
                                                    <cfloop from="1" to="#NoTimesPotentialNotReachedInPosition#"  index="local.i">
                                                        <img src="/res/img/players/icon_cross_grey.gif" alt="Did not reach Potential" title="Did not reach Potential">
                                                    </cfloop>  
                                                    <cfif NoTimesPotentialReachedInPosition eq 0 AND NoTimesPotentialNotReachedInPosition eq 0>
                                                    &nbsp;
                                                    </cfif>
                                                    </td>
                                                    <td>
                                                    <cfif AverageStarsInPosition neq 0>
                                                    <img src="/res/img/stars/#replacenocase(AverageStarsInPosition,'.','_','all')#.gif" alt="#AverageStarsInPosition#">
                                                    <cfelse>
                                                    N/A
                                                    </cfif>
                                                    </td>
                                                </tr>
                                                </cfloop>
                                            </tbody>
                                        </table>
                                    </div>
                                <cfelse>
                                    There were no results for player #arguments.data.playerName.firstname# #arguments.data.playerName.lastname#
                                </cfif>
                            </div>
                        </div>
                        
                    </cfif>
                </div>
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="playersprogression" access="private" returntype="struct" hint="Form enabling user to search for a specific player's progression">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        <cfset local.data = arguments.data>
		
        <cftry>
		<cfsavecontent variable="local.result.output">
			<cfoutput>
                <div class="container-fluid w-auto my-2">
                <div class="row">                      
                    <div class="col-sm-8 col-md-6 col-lg-6 col-xl-6 mx-20">
                        
                        <!--- first time around --->
                        <cfif arguments.step eq 1>
                            <form action="/Leaguereports/playersprogression" method="POST" class="was-validated" id="r-progression">
                            <input type="hidden" name="step" id="step" value="#arguments.step#"/>

                            #getFactory().get("formFactory").view.display(method="playerReport", value=local.data.playerID,required=true).output#
                            
                            #getFactory().get("formFactory").view.display(method="periodCoveredReportBlock", periodCovered=local.data.periodCovered,seasonFrom=local.data.seasonFrom,seasonTo=local.data.seasonTo,roundFrom=local.data.roundFrom,roundTo=local.data.roundTo,dateFrom=local.data.dateFrom,dateTo=local.data.dateTo).output#

                        
                            #getFactory().get("formFactory").view.display(method="inputRadio",id="formLevel", options="Yes|1,No|0",
                            value=local.data.formLevel,fieldTitle="Include Form Level?").output#

                            #getFactory().get("formFactory").view.display(method="inputRadio",id="agressionLevel", options="Yes|1,No|0",
                            value=local.data.agressionLevel,fieldTitle="Include Agression Level?").output#

                            #getFactory().get("formFactory").view.display(method="inputRadio",id="leadershipLevel", options="Yes|1,No|0",
                            value=local.data.leadershipLevel,fieldTitle="Include Leadership Level?").output#

                            #getFactory().get("formFactory").view.display(method="inputRadio",id="energyLevel", options="Yes|1,No|0",
                            value=local.data.energyLevel,fieldTitle="Include Energy Level?").output#
                        
                            #getFactory().get("formFactory").view.display(method="inputRadio",id="disciplineLevel", options="Yes|1,No|0",
                            value=local.data.disciplineLevel,fieldTitle="Include Discipline Level?").output#

                            #getFactory().get("formFactory").view.display(method="inputRadio",id="experienceLevel", options="Yes|1,No|0",
                            value=local.data.experienceLevel,fieldTitle="Include Experience Level?").output#
                            
                            <br/>
                            #getFactory().get("formFactory").view.display(method="inputRadio",id="staminaLevel", options="Yes|1,No|0",
                            value=local.data.staminaLevel,fieldTitle="Include Stamina Level?").output#

                            #getFactory().get("formFactory").view.display(method="inputRadio",id="handlingLevel", options="Yes|1,No|0",
                            value=local.data.handlingLevel,fieldTitle="Include Handling Level?").output#

                            #getFactory().get("formFactory").view.display(method="inputRadio",id="attackLevel", options="Yes|1,No|0",
                            value=local.data.attackLevel,fieldTitle="Include Attack Level?").output#

                            #getFactory().get("formFactory").view.display(method="inputRadio",id="defenseLevel", options="Yes|1,No|0",
                            value=local.data.defenseLevel,fieldTitle="Include Defense Level?").output#

                            #getFactory().get("formFactory").view.display(method="inputRadio",id="techniqueLevel", options="Yes|1,No|0",
                            value=local.data.techniqueLevel,fieldTitle="Include Technique Level?").output#

                            #getFactory().get("formFactory").view.display(method="inputRadio",id="strengthLevel", options="Yes|1,No|0",
                            value=local.data.strengthLevel,fieldTitle="Include Strength Level?").output#
                            
                            #getFactory().get("formFactory").view.display(method="inputRadio",id="jumpingLevel", options="Yes|1,No|0",
                            value=local.data.jumpingLevel,fieldTitle="Include Jumping Level?").output#
                            
                            #getFactory().get("formFactory").view.display(method="inputRadio",id="speedLevel", options="Yes|1,No|0",
                            value=local.data.speedLevel,fieldTitle="Include Speed Level?").output#
                            
                            #getFactory().get("formFactory").view.display(method="inputRadio",id="agilityLevel", options="Yes|1,No|0",
                            value=local.data.agilityLevel,fieldTitle="Include Agility Level?").output#
                            
                            #getFactory().get("formFactory").view.display(method="inputRadio",id="kickingLevel", options="Yes|1,No|0",
                            value=local.data.kickingLevel,fieldTitle="Include Kicking Level?").output#

                            <br/>

                            #getFactory().get("formFactory").view.display(method="inputRadio",id="csr", options="Yes|1,No|0",
                            value=local.data.csr,fieldTitle="Include CSR?").output#

                            <div class="row">
                                <div class="col">
                                    <a class="btn btn-dark my-2" href="/leagueReports" role="button">Cancel</a>
                                </div>
                                <div class="col"><input type="submit" name="search" id="search" value="Search" class="btn btn-dark my-2"></div>
                            </div>
                        </form>

                        <script>
                        $(document).ready(function(){
                            $("##r-progression").submit(function(){
                                var periodCoveredvalue = $("##periodCovered").val();
                                var dateToValue = $("##dateTo").val();
                                var dateFromValue = $("##dateFrom").val();
                                var roundFromValue = $("##roundFrom").val();
                                var roundToValue = $("##roundTo").val();

                                if (periodCoveredvalue == "Set of Rounds")
                                {
                                    if (roundFromValue >= roundToValue)
                                    {
                                        $("##roundFromInvalid").show(); 
                                        $("##roundFromInvalid").text("The first round must be before the second round");
                                        $("##roundFrom").focus();
                                        return false;
                                    }
                                    else
                                    {
                                        $("##roundFromInvalid").hide();
                                    }
                                } 

                                if (periodCoveredvalue == "Set of Dates")
                                {
                                    if (new Date($("##dateFrom").val()) == "Invalid Date") 
                                    {
                                       $("##dateFromInvalid").show(); 
                                       $("##dateFromInvalid").text("You must select a valid Date");
                                       $("##dateFrom").focus();
                                       return false;
                                    } 
                                    else
                                    {
                                        $("##dateFromInvalid").hide();
                                    }
                                    if (new Date($("##dateTo").val()) == "Invalid Date") 
                                    {
                                        $("##dateToInvalid").show(); 
                                        $("##dateToInvalid").text("You must select a valid Date");
                                        $("##dateTo").focus();
                                        return false;
                                    }
                                    else
                                    {
                                        $("##dateToInvalid").hide(); 
                                    }
                                    if (Date.parse(dateToValue) <= Date.parse(dateFromValue)) 
                                    {
                                        $("##dateToInvalid").show(); 
                                        $("##dateToInvalid").text("This date must be after the first one");
                                        $("##dateTo").focus();
                                        return false;
                                    }
                                    else
                                    {
                                        $("##dateToInvalid").hide(); 
                                    }
                                }
                            });
                        });
                        </script>


                        <!--- search made. Display result and allow to search again --->
                        <cfelseif arguments.step eq 2>
                                <div class="row">
                                <div class="col">
                                    <a class="btn btn-dark my-2" href="/LeagueReports/playersprogression" role="button">Search Again</a>
                                </div>
                            </div>

                            
                        </cfif>
                        
                    </div>
                </div>

                <!--- result of any search --->
                <cfif arguments.step eq 2>
                    
                        
                        <div class="row"> 
                            <div class="col mx-20">
                                <br/><br/>
                                <cfif local.data.periodCovered eq "">
                                    <cfset local.periodInfo = " so far">
                                <cfelseif local.data.periodCovered eq "Current Season">
                                    <cfset local.periodInfo = " for the current season">
                                <cfelseif local.data.periodCovered eq "Set of Seasons">
                                    <cfset local.periodInfo = " for season #local.data.seasonFrom# to #local.data.seasonTo#">
                                <cfelseif local.data.periodCovered eq "Set of Rounds">
                                    <cfset local.periodInfo = " for round #local.data.roundFrom# to #local.data.roundTo# of the current season">
                                <cfelseif local.data.periodCovered eq "Set of Dates">
                                    <cfset local.periodInfo = " between #dateformat(local.data.dateFrom,'dd/mm/yy')# and #dateformat(local.data.dateTo,'dd/mm/yy')#">
                                </cfif>
                                    
                                <cfset local.csrchartTitle = "CSR Data for #arguments.data.playerdetails.firstname# #arguments.data.playerdetails.lastname#" & local.periodInfo>
                                
                                <cfset local.mainchartTitle = "General Data for #arguments.data.playerdetails.firstname# #arguments.data.playerdetails.lastname#" & local.periodInfo>

                                <br/><br/>
                                <cfif arguments.data.csr>
                                <div class="table-responsive">
                                    <cfchart	 
                                        backgroundColor = "##ffffff"	 
                                        chartHeight = "400"	 
                                        chartWidth = "600"	 
                                        font = "arial"	 
                                        fontBold = "yes"	 
                                        fontItalic = "no"	 
                                        fontSize = "12"	 
                                        foregroundColor = "##000000"	 
                                        format = "jpg"	
                                        show3D = "no"	
                                        showBorder = "no"	 
                                        showMarkers = "yes"	
                                        markerSize = "3"
                                        showXGridlines = "no"
                                        showYGridlines = "yes"
                                        sortXAxis = "yes" 
                                        title = "#local.csrchartTitle#"
                                        xaxistitle="Dates"
                                        yaxistitle="Values"
                                        seriesPlacement="default"
                                        showLegend="yes"
                                        labelformat="number">
                                        
                                            <cfchartseries type="line" 
                                                query="arguments.data.playerHistory"
                                                itemcolumn="PlayerDate" 
                                                valuecolumn="CSR"
                                                seriescolor="##4966A6" 
                                                paintstyle="light" 
                                                serieslabel="CSR">
                                            </cfchartseries>
                                        
                                    </cfchart>
                                    </div>
                                </cfif>  
                                
                                <div class="table-responsive">
                                <cfchart	 
                                    backgroundColor = "##ffffff"	 
                                    chartHeight = "400"	 
                                    chartWidth = "600"	 
                                    font = "arial"	 
                                    fontBold = "yes"	 
                                    fontItalic = "no"	 
                                    fontSize = "12"	 
                                    foregroundColor = "##000000"	 
                                    format = "jpg"	
                                    show3D = "no"	
                                    showBorder = "no"	 
                                    showMarkers = "yes"	
                                    markerSize = "3"
                                    showXGridlines = "no"
                                    showYGridlines = "yes"
                                    sortXAxis = "yes" 
                                    title = "#local.mainchartTitle#"
                                    xaxistitle="Dates"
                                    yaxistitle="Values"
                                    seriesPlacement="default"
                                    showLegend="yes"
                                    labelformat="number">
                                    <cfif arguments.data.formLevel>              
                                        <cfchartseries type="line" 
                                            query="arguments.data.playerHistory"
                                            itemcolumn="PlayerDate" 
                                            valuecolumn="formLevel"
                                            seriescolor="##A6496A" 
                                            paintstyle="light"
                                            serieslabel="Form">
                                        </cfchartseries>
                                    </cfif>    
                                    <cfif arguments.data.agressionLevel>
                                        <cfchartseries type="line" 
                                            query="arguments.data.playerHistory"
                                            itemcolumn="PlayerDate" 
                                            valuecolumn="agressionLevel"
                                            seriescolor="##49A64D" 
                                            paintstyle="light"
                                            serieslabel="Agression">
                                        </cfchartseries>
                                    </cfif>    
                                    <cfif arguments.data.leadershipLevel>
                                        <cfchartseries type="line" 
                                            query="arguments.data.playerHistory"
                                            itemcolumn="PlayerDate" 
                                            valuecolumn="leadershipLevel"
                                            seriescolor="##A69649" 
                                            paintstyle="light"
                                            serieslabel="Leadership">
                                        </cfchartseries>
                                    </cfif>  
                                    <cfif arguments.data.energyLevel>   
                                        <cfchartseries type="line" 
                                            query="arguments.data.playerHistory"
                                            itemcolumn="PlayerDate" 
                                            valuecolumn="energyLevel"
                                            seriescolor="##6849A6" 
                                            paintstyle="light"
                                            serieslabel="Energy">
                                        </cfchartseries>
                                    </cfif>   
                                    <cfif arguments.data.disciplineLevel>   
                                        <cfchartseries type="line" 
                                            query="arguments.data.playerHistory"
                                            itemcolumn="PlayerDate" 
                                            valuecolumn="disciplineLevel"
                                            seriescolor="##FA0841" 
                                            paintstyle="light" 
                                            serieslabel="Discipline">
                                        </cfchartseries>
                                    </cfif>    
                                    <cfif arguments.data.experienceLevel>  
                                        <cfchartseries type="line" 
                                            query="arguments.data.playerHistory"
                                            itemcolumn="PlayerDate" 
                                            valuecolumn="experienceLevel"
                                            seriescolor="##08FA41" 
                                            paintstyle="light" 
                                            serieslabel="Experience">
                                        </cfchartseries>
                                    </cfif>   
                                    <cfif arguments.data.staminaLevel>  
                                        <cfchartseries type="line" 
                                            query="arguments.data.playerHistory"
                                            itemcolumn="PlayerDate" 
                                            valuecolumn="staminaLevel"
                                            seriescolor="##FAF108" 
                                            paintstyle="light" 
                                            serieslabel="Stamina">
                                        </cfchartseries>
                                    </cfif>    
                                    <cfif arguments.data.handlingLevel>
                                        <cfchartseries type="line" 
                                            query="arguments.data.playerHistory"
                                            itemcolumn="PlayerDate" 
                                            valuecolumn="handlingLevel"
                                            seriescolor="##08FAD5" 
                                            paintstyle="light" 
                                            serieslabel="Handling">
                                        </cfchartseries>
                                    </cfif>     
                                    <cfif arguments.data.attackLevel>
                                        <cfchartseries type="line" 
                                            query="arguments.data.playerHistory"
                                            itemcolumn="PlayerDate" 
                                            valuecolumn="attackLevel"
                                            seriescolor="##FAA708" 
                                            paintstyle="light" 
                                            serieslabel="Attack">
                                        </cfchartseries>
                                    </cfif>     
                                    <cfif arguments.data.defenseLevel>
                                        <cfchartseries type="line" 
                                            query="arguments.data.playerHistory"
                                            itemcolumn="PlayerDate" 
                                            valuecolumn="defenseLevel"
                                            seriescolor="##08A2FA" 
                                            paintstyle="light" 
                                            serieslabel="Defense">
                                        </cfchartseries>
                                    </cfif>    
                                    <cfif arguments.data.techniqueLevel>
                                        <cfchartseries type="line" 
                                            query="arguments.data.playerHistory"
                                            itemcolumn="PlayerDate" 
                                            valuecolumn="techniqueLevel"
                                            seriescolor="##AE9085" 
                                            paintstyle="light" 
                                            serieslabel="Technique">
                                        </cfchartseries>
                                    </cfif>     
                                    <cfif arguments.data.strengthLevel>
                                        <cfchartseries type="line" 
                                            query="arguments.data.playerHistory"
                                            itemcolumn="PlayerDate" 
                                            valuecolumn="strengthLevel"
                                            seriescolor="##9140CA" 
                                            paintstyle="light" 
                                            serieslabel="Strength">
                                        </cfchartseries>
                                    </cfif>     
                                    <cfif arguments.data.jumpingLevel>
                                        <cfchartseries type="line" 
                                            query="arguments.data.playerHistory"
                                            itemcolumn="PlayerDate" 
                                            valuecolumn="jumpingLevel"
                                            seriescolor="##8CF2B0" 
                                            paintstyle="light" 
                                            serieslabel="Jumping">
                                        </cfchartseries>
                                    </cfif>    
                                    <cfif arguments.data.speedLevel>
                                        <cfchartseries type="line" 
                                            query="arguments.data.playerHistory"
                                            itemcolumn="PlayerDate" 
                                            valuecolumn="speedLevel"
                                            seriescolor="##107E36" 
                                            paintstyle="light" 
                                            serieslabel="Speed">
                                        </cfchartseries>
                                    </cfif>    
                                    <cfif arguments.data.agilityLevel>
                                        <cfchartseries type="line" 
                                            query="arguments.data.playerHistory"
                                            itemcolumn="PlayerDate" 
                                            valuecolumn="agilityLevel"
                                            seriescolor="##1834DB" 
                                            paintstyle="light" 
                                            serieslabel="Agility">
                                        </cfchartseries>
                                    </cfif>    
                                    <cfif arguments.data.kickingLevel>
                                        <cfchartseries type="line" 
                                            query="arguments.data.playerHistory"
                                            itemcolumn="PlayerDate" 
                                            valuecolumn="kickingLevel"
                                            seriescolor="##FBE099" 
                                            paintstyle="light" 
                                            serieslabel="Kicking">
                                        </cfchartseries>
                                    </cfif>    
                                    </cfchart>
                                    </div>
                            </div>
                        </div>
                    
                </cfif>
            </div>
			</cfoutput>
		</cfsavecontent>

            <cfcatch type="any">
                <cfdump var="#cfcatch#">
            </cfcatch>
        </cftry>

		<cfreturn local.result>
	</cffunction>

    <cffunction name="matchcomparison" access="private" returntype="struct" hint="Form enabling user to compare match data">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
		<cfsavecontent variable="local.result.output">
			<cfoutput>
					<div class="container-fluid w-auto my-2">
                    <div class="row">                      
                        <div class="col-sm-8 col-md-6 col-lg-6 col-xl-6 mx-20">
                            <cfif StructKeyExists(arguments.data, "errors")>
                                #getFactory().get("template").view.errors(arguments.data.errors).output#
                            </cfif>
                            <form action="/Leaguereports/matchcomparison" method="POST" class="was-validated" id="r-matchcomparison">
                                <input type="hidden" name="step" id="step" value="#arguments.step#"/>
                                
                                <cfset local.matches = getFactory().get("leaguematches").model.getMyMatches()>

                                <!--- first time around --->
                                <cfif arguments.step eq 1>
                                    #getFactory().get("formFactory").view.display(method="matchReport", value=arguments.data.match1,label="Match 1",selectid="match1").output#
                                    
                                    #getFactory().get("formFactory").view.display(method="matchReport", value=arguments.data.match2,label="Match 2",selectid="match2").output#
                                    <div class="row">
                                        <div class="col">
                                            <a class="btn btn-dark my-2" href="/leagueReports" role="button">Cancel</a>
                                        </div>
                                        <div class="col"><input type="submit" name="search" id="search" value="Search" class="btn btn-dark my-2"></div>
                                    </div>
                                <!--- search made. Display result and allow to search again --->
                                <cfelseif arguments.step eq 2>
                                        <div class="row">
                                        #getFactory().get("formFactory").view.display(method="matchReport", value=arguments.data.match1,label="Match 1",selectid="match1").output#
                                    
                                        #getFactory().get("formFactory").view.display(method="matchReport", value=arguments.data.match2,label="Match 2",selectid="match2").output#
                                        
                                        <div class="col"><input type="submit" name="search" id="search" value="Search again" class="btn btn-dark my-4"></div>
                                    </div>
                                </cfif>
                            </form>
                        </div>
                    </div>

                    <!--- result of any search --->
                    <cfif arguments.step eq 2>
                        <div class="row"> 
                            <div class="col mx-20">
                                <div class="table-responsive">
                                    <table class="table  table-striped table-bordered">
                                        <thead class="thead-dark">
                                            <tr>
                                                <th colspan="2">Match vs #arguments.data.detailsMatch1.opponentName# on #dateformat(arguments.data.detailsMatch1.matchdate,"dd/mm/yy")#:</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <cfloop query="arguments.data.detailsMatch1">
                                                <tr>
                                                    <td class="firstmatch"><strong>#positionID#.</strong></td>
                                                    <td class="lastmatch">
                                                        #firstname# #lastname#
                                                        <br/>
                                                        <cfif manofthematch><img src="/res/img/icons/manofthematch.gif" id="manofthematch" alt="Man of the Match"></cfif>
                                                        <cfif playerExpectationTitle eq "Player performed better than expected">
                                                            <img src="/res/img/players/arrow_up.gif" alt="Player performed better than expected">
                                                        <cfelseif playerExpectationTitle eq "Player performed worse than expected">
                                                            <img src="/res/img/players/arrow_down_red.gif" alt="Player performed worse than expected">
                                                        <cfelseif playerExpectationTitle eq "Player performed as expected">
                                                            <img src="/res/img/players/icon_tick_grey.gif" alt="Player performed as expected">
                                                        </cfif>
                                                        <cfif playerPotentialTitle eq "Player did not reach their potential in the position played">  
                                                        <img src="/res/img/players/icon_cross_grey.gif" alt="Player did not reach their potential in the position played">                         	
                                                        <cfelseif playerPotentialTitle eq "Player reached their potential in the position played">  
                                                            <img src="/res/img/players/icon_tick_green.gif" alt="Player reached their potential in the position played">                         			
                                                        </cfif>
                                                        &nbsp;<img src="/res/img/stars/#replacenocase(stars,'.','_','all')#.gif" alt="#stars#"><br>
                                                    </td>
                                                </tr>
                                                </cfloop>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                            <div class="col mx-20">        
                                <div class="table-responsive">
                                    <table class="table  table-striped table-bordered">
                                        <thead class="thead-dark">
                                            <tr>
                                                <th colspan="2">Match vs #arguments.data.detailsMatch2.opponentName# on #dateformat(arguments.data.detailsMatch2.matchdate,"dd/mm/yy")#:</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <cfloop query="arguments.data.detailsMatch2">
                                                <tr>
                                                    <td class="firstmatch"><strong>#positionID#.</strong></td>
                                                    <td class="lastmatch">
                                                        #firstname# #lastname#
                                                        <br/>
                                                        <cfif manofthematch><img src="/res/img/icons/manofthematch.gif" id="manofthematch" alt="Man of the Match"></cfif>
                                                        <cfif playerExpectationTitle eq "Player performed better than expected">
                                                            <img src="/res/img/players/arrow_up.gif" alt="Player performed better than expected">
                                                        <cfelseif playerExpectationTitle eq "Player performed worse than expected">
                                                            <img src="/res/img/players/arrow_down_red.gif" alt="Player performed worse than expected">
                                                        <cfelseif playerExpectationTitle eq "Player performed as expected">
                                                            <img src="/res/img/players/icon_tick_grey.gif" alt="Player performed as expected">
                                                        </cfif>
                                                        <cfif playerPotentialTitle eq "Player did not reach their potential in the position played">  
                                                        <img src="/res/img/players/icon_cross_grey.gif" alt="Player did not reach their potential in the position played">                         	
                                                        <cfelseif playerPotentialTitle eq "Player reached their potential in the position played">  
                                                            <img src="/res/img/players/icon_tick_green.gif" alt="Player reached their potential in the position played">                         			
                                                        </cfif>
                                                        &nbsp;<img src="/res/img/stars/#replacenocase(stars,'.','_','all')#.gif" alt="#stars#"><br>
                                                    </td>
                                                </tr>
                                                </cfloop>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                               
                        </div>
                    </cfif>
                </div>
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>
    
   
    <cffunction name="attendance" access="private" returntype="struct" hint="Form enabling user to search for attendance to matches">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		<cfsavecontent variable="local.result.output">
			<cfoutput>
                <br/><br/>
                <div class="table-responsive">
                   <cfchart	 
                    backgroundColor = "##ffffff"	 
                    chartHeight = "400"	 
                    chartWidth = "600"	 
                    font = "arial"	 
                    fontBold = "yes"	 
                    fontItalic = "no"	 
                    fontSize = "12"	 
                    foregroundColor = "##000000"	 
                    format = "jpg"	
                    show3D = "no"	
                    showBorder = "no"	 
                    showMarkers = "yes"	
                    markerSize = "3"
                    showXGridlines = "no"
                    showYGridlines = "yes"
                    sortXAxis = "yes" 
                    title = "Attendance between #arguments.data.AttendanceDateFrom# and #arguments.data.AttendanceDateTo#"
                    xaxistitle="Dates"
                    yaxistitle="Number"
                    seriesPlacement="default"
                    showLegend="yes"
                    labelformat="number">
                        <cfchartseries type="line" 
                            query="arguments.data.AttendanceStanding"
                            itemcolumn="MatchDate" 
                            valuecolumn="AttendanceStanding"
                            seriescolor="##4966A6" 
                            paintstyle="light" 
                            serieslabel="Standing">
                        </cfchartseries>
                        
                        <cfchartseries type="line" 
                            query="arguments.data.PotentialAttendances"
                            itemcolumn="DateAdded" 
                            valuecolumn="StadiumStanding"
                            seriescolor="##6891EC" 
                            paintstyle="shade" 
                            serieslabel="Standing Potential">
                        </cfchartseries>
                                            
                        <cfchartseries type="line" 
                            query="arguments.data.AttendanceUncovered"
                            itemcolumn="MatchDate" 
                            valuecolumn="AttendanceUncovered"
                            seriescolor="##A6496A" 
                            paintstyle="light"
                            serieslabel="Uncovered">
                        </cfchartseries>
                        
                        <cfchartseries type="line" 
                            query="arguments.data.PotentialAttendances"
                            itemcolumn="DateAdded" 
                            valuecolumn="StadiumUncovered"
                            seriescolor="##E46592" 
                            paintstyle="shade" 
                            serieslabel="Uncovered Potential">
                        </cfchartseries>
                        
                        <cfchartseries type="line" 
                            query="arguments.data.AttendanceCovered"
                            itemcolumn="MatchDate" 
                            valuecolumn="AttendanceCovered"
                            seriescolor="##49A64D" 
                            paintstyle="light"
                            serieslabel="Covered">
                        </cfchartseries>
                        
                        <cfchartseries type="line" 
                            query="arguments.data.PotentialAttendances"
                            itemcolumn="DateAdded" 
                            valuecolumn="StadiumCovered"
                            seriescolor="##63E568" 
                            paintstyle="shade" 
                            serieslabel="Covered Potential">
                        </cfchartseries>
                        
                        <cfchartseries type="line" 
                            query="arguments.data.AttendanceMembers"
                            itemcolumn="MatchDate" 
                            valuecolumn="AttendanceMembers"
                            seriescolor="##A69649" 
                            paintstyle="light"
                            serieslabel="Members">
                        </cfchartseries>
                        
                        <cfchartseries type="line" 
                            query="arguments.data.PotentialAttendances"
                            itemcolumn="DateAdded" 
                            valuecolumn="StadiumMembers"
                            seriescolor="##E3CD62" 
                            paintstyle="shade" 
                            serieslabel="Members Potential">
                        </cfchartseries>
                        
                        <cfchartseries type="line" 
                            query="arguments.data.AttendanceVIP"
                            itemcolumn="MatchDate" 
                            valuecolumn="AttendanceVIP"
                            seriescolor="##6849A6" 
                            paintstyle="light"
                            serieslabel="Corporate">
                        </cfchartseries>
                        
                        <cfchartseries type="line" 
                            query="arguments.data.PotentialAttendances"
                            itemcolumn="DateAdded" 
                            valuecolumn="StadiumCorporate"
                            seriescolor="##9367EC" 
                            paintstyle="shade" 
                            serieslabel="Corporate Potential">
                        </cfchartseries>
                	</cfchart>
                    </div>
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>
    
</cfcomponent>
