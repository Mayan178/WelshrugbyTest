<cfcomponent name="leagueplayers" extends="parent" hint="View for league players">
	<cffunction name="init" returntype="leagueplayers" access="public">
		<cfset super.init()>
		<cfreturn this/>
	</cffunction>

	<cffunction name="default" access="private" returntype="struct" hint="default view for this component">
		<cfargument name="data" type="struct" required="false">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
        <cfset local.result.output=#allPlayers(arguments.data).output#>
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="allPlayers" access="private" returntype="struct" hint="Displays all players added by the current user">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
        <cfset local.setSize = 10>
		<cfset local.sets = Ceiling(arguments.data.allPlayers.recordcount / local.setSize)> 
        
        <cfset local.showSetNo = 1>
       
        <cfset local.listofPlayers = "">
        <cfloop query="arguments.data.allPlayers">
        <cfset local.listofPlayers = listappend(local.listofPlayers,playerid)>
        </cfloop>
        
        <cfset local.lastPlayer = listlast(local.listofPlayers)>
        
		<cfsavecontent variable="local.result.output">
			<cfoutput>
                <div class="container-fluid mb-5 p-3">
            	    <div class="float-end"><a href="/leagueplayers/search" class="btn btn-dark mt-2">Search for Players</a></div>                
                </div>
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

                    <div class="row">
                        <div class="col">
                        <cfloop from="1" to="#local.sets#" index="local.setNo">
                            <div id="monitor-set-#local.setNo#" <cfif local.setNo neq local.showSetNo>style="display:none"</cfif>>

                                <cfset local.fromRow = ((local.setNo-1) * local.setSize) + 1>
                                <cfset local.toRow = Min(arguments.data.allPlayers.recordcount, local.fromRow + local.setSize - 1)>

                                <cfloop from="#local.fromRow#" to="#local.toRow#" index="local.r">
                                #display(method="individualPlayer",BRplayerID=arguments.data.allPlayers.BRplayerID[local.r],playerID=arguments.data.allPlayers.playerID[local.r],firstName=arguments.data.allPlayers.firstName[local.r],nickName=arguments.data.allPlayers.nickName[local.r],lastname=arguments.data.allPlayers.lastname[local.r],CSR=arguments.data.allPlayers.CSR[local.r],weight=arguments.data.allPlayers.weight[local.r],height=arguments.data.allPlayers.height[local.r],age=arguments.data.allPlayers.age[local.r],top1=arguments.data.allPlayers.top1[local.r],top2=arguments.data.allPlayers.top2[local.r],top3=arguments.data.allPlayers.top3[local.r],top4=arguments.data.allPlayers.top4[local.r],best1=arguments.data.allPlayers.best1[local.r],best2=arguments.data.allPlayers.best2[local.r],best3=arguments.data.allPlayers.best3[local.r],best4=arguments.data.allPlayers.best4[local.r],best5=arguments.data.allPlayers.best5[local.r],setNo=local.setNo,country=arguments.data.allPlayers.country[local.r],injured=arguments.data.allPlayers.injured[local.r]).output#
                                <!--- END OF PLAYER INDIVIDUAL INFO --->
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
        
    <cffunction name="searchResults" access="private" returntype="struct" hint="Displays players matching the search criteria">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
        <cfset local.setSize = 10>
		<cfset local.sets = Ceiling(arguments.data.searchResults.recordcount / local.setSize)>
        
        <cfset local.listofPlayers = "">
        <cfloop query="arguments.data.searchResults">
        <cfset local.listofPlayers = listappend(local.listofPlayers,playerid)>
        </cfloop>
        
        <cfset local.lastPlayer = listlast(local.listofPlayers)>
        
		<cfsavecontent variable="local.result.output">
			<cfoutput>
                <div class="container-fluid">
                    <div class="row">
                        <div class="col">
                            <!--- if no criteria selected --->
                            <cfif NOT Len(arguments.data.position) AND NOT Len(arguments.data.firstname) AND NOT Len(arguments.data.lastname) AND NOT Len(arguments.data.nickname) AND (arguments.data.age EQ 0) AND (arguments.data.csr EQ 10000) AND (arguments.data.height EQ 170) AND (arguments.data.weight EQ 80) AND NOT Len(arguments.data.handed) AND NOT Len(arguments.data.footed) AND NOT Len(arguments.data.formlevel) AND NOT Len(arguments.data.energylevel) AND NOT Len(arguments.data.agressionlevel) AND NOT Len(arguments.data.disciplinelevel) AND NOT Len(arguments.data.leadershiplevel) AND NOT Len(arguments.data.experiencelevel) AND NOT Len(arguments.data.team) AND (NOT Len(arguments.data.BRPlayerID) OR (arguments.data.BRPlayerID EQ 0)) AND NOT Len(arguments.data.staminalevel) AND NOT Len(arguments.data.Attacklevel) AND NOT Len(arguments.data.Techniquelevel) AND NOT Len(arguments.data.Jumpinglevel) AND NOT Len(arguments.data.Agilitylevel) AND NOT Len(arguments.data.Handlinglevel) AND NOT Len(arguments.data.Defenselevel) AND NOT Len(arguments.data.Strengthlevel) AND NOT Len(arguments.data.Speedlevel) AND NOT Len(arguments.data.Kickinglevel) AND (arguments.data.country eq "Wales")>
                                All Players
                            <!--- search criteria selected by the user --->
                            <cfelse>
                                <cfif Len(arguments.data.position)>Position: #arguments.data.position#<br /></cfif>
                                <cfif Len(arguments.data.firstname)>Firstname: #arguments.data.firstname#<br /></cfif>
                                <cfif Len(arguments.data.lastname)>Lastname: #arguments.data.lastname#<br /></cfif>
                                <cfif Len(arguments.data.nickname)>Nickname: #arguments.data.nickname#<br /></cfif>
                                <cfif Len(arguments.data.age) AND arguments.data.age neq 0><cfif arguments.data.agetype eq "minimum">Minimum<cfelse>Maximum</cfif> Age: #arguments.data.age#<br /></cfif>
                                <cfif Len(arguments.data.csr) AND arguments.data.csr neq 10000>Minimum CSR: #arguments.data.csr#<br /></cfif>
                                <cfif Len(arguments.data.height) AND arguments.data.height neq 170>Minimum Height: #arguments.data.height#<br /></cfif>
                                <cfif Len(arguments.data.weight)  AND arguments.data.weight neq 80>Minimum Weight: #arguments.data.weight#<br /></cfif>
                                <cfif Len(arguments.data.handed)>Handed: #arguments.data.handed#<br /></cfif>
                                <cfif Len(arguments.data.footed)>Footed: #arguments.data.footed#<br /></cfif>
                                <cfif Len(arguments.data.formlevel)>Minimum Form: #arguments.data.formlevel#<br /></cfif>
                                <cfif Len(arguments.data.energylevel)>Minimum Energy: #arguments.data.energylevel#<br /></cfif>
                                <cfif Len(arguments.data.agressionlevel)>Minimum Agression: #arguments.data.agressionlevel#<br /></cfif>
                                <cfif Len(arguments.data.disciplinelevel)>Minimum Discipline: #arguments.data.disciplinelevel#<br /></cfif>
                                <cfif Len(arguments.data.leadershiplevel)>Minimum Leadership: #arguments.data.leadershiplevel#<br /></cfif>
                                <cfif Len(arguments.data.experiencelevel)>Minimum Experience: #arguments.data.experiencelevel#<br /></cfif>
                                <cfif Len(arguments.data.team)>Team: #arguments.data.team#<br /></cfif>
                                <cfif Len(arguments.data.BRPlayerID) AND arguments.data.BRPlayerID neq 0>Player ID: #arguments.data.BRPlayerID#<br /></cfif>
                                <cfif Len(arguments.data.staminalevel)>Minimum Stamina: #arguments.data.staminalevel#<br /></cfif>
                                <cfif Len(arguments.data.Attacklevel)>Minimum Attack: #arguments.data.Attacklevel#<br /></cfif>
                                <cfif Len(arguments.data.Techniquelevel)>Minimum Technique: #arguments.data.Techniquelevel#<br /></cfif>
                                <cfif Len(arguments.data.Jumpinglevel)>Minimum Jumping: #arguments.data.Jumpinglevel#<br /></cfif>
                                <cfif Len(arguments.data.Agilitylevel)>Minimum Agility: #arguments.data.Agilitylevel#<br /></cfif>
                                <cfif Len(arguments.data.Handlinglevel)>Minimum Handling: #arguments.data.Handlinglevel#<br /></cfif>
                                <cfif Len(arguments.data.Defenselevel)>Minimum Defense: #arguments.data.Defenselevel#<br /></cfif>
                                <cfif Len(arguments.data.Strengthlevel)>Minimum Strength: #arguments.data.Strengthlevel#<br /></cfif>
                                <cfif Len(arguments.data.Speedlevel)>Minimum Speed: #arguments.data.Speedlevel#<br /></cfif>
                                <cfif Len(arguments.data.Kickinglevel)>Minimum Kicking: #arguments.data.Kickinglevel#<br /></cfif>
                                <cfif Len(arguments.data.country) AND arguments.data.country neq "Wales">Country: #arguments.data.country#<br /></cfif>
                            </cfif>
                            <br /><br />
                            <strong>Your search returned #arguments.data.searchResults.recordcount# result<cfif arguments.data.searchResults.recordcount gt 1>s</cfif>.</strong>
                            <br /><br />
                        </div>
                    </div>
                
                    <!--- reordering form --->
                    <cfif arguments.data.searchResults.recordcount>
                        <form action="/leagueplayers/searchresults" method="POST" id="search-form">
                            <div class="row">
                                <div class="col-sm-3">
                                    <!--- order by field select --->
                                    <cfset local.orderingOptions = getFactory().get("leagueplayers").model.getOrderingOptions()>

                                    <!--- build array of structs dataset to use in inputSelect --->
                                    <cfset local.dataob = ArrayNew(1)>
                                    <cfloop list="#local.orderingOptions#" index="local.o">
                                        <cfset local.fvalue = local.o>
                                        <cfif local.fvalue neq "CSR">
                                            <cfset local.fvalue = Ucase(Left(local.fvalue,1)) & Lcase(Right(local.fvalue,Len(local.fvalue)-1))>
                                            <cfif Right(local.fvalue,5) eq "level">
                                                <cfset local.fvalue = Left(local.fvalue,Len(local.fvalue)-5)>
                                            </cfif>
                                            <cfif local.fvalue eq "BRplayerID">
                                                <cfset local.fvalue = "Player ID">
                                            </cfif>
                                            <cfif local.fvalue eq "datelastupdated">
                                                <cfset local.fvalue = "Date Last Updated">
                                            </cfif>
                                            <cfif local.fvalue eq "dateadded">
                                                <cfset local.fvalue = "Date Added">
                                            </cfif>
                                        </cfif>
                                        
                                        <cfset local.str = {label=local.fvalue, value=local.o}>
                                        <cfset ArrayAppend(local.dataob, local.str)>
                                    </cfloop>
                                    #getFactory().get("formFactory").view.display(method="inputSelect", selectid="orderBy", label="Order By", data=local.dataob, value="#arguments.data.orderBy#").output#
                                </div>
                                <div class="col-sm-3">
                                    <!--- order by ascending/descending --->
                                    <!--- build array of structs dataset to use in inputSelect --->
                                    <cfset local.dataot = ArrayNew(1)>
                                    
                                    <cfset local.str = {label="Ascending", value="Asc"}>
                                    <cfset ArrayAppend(local.dataot, local.str)>
                                    
                                    <cfset local.str = {label="Descending", value="Desc"}>
                                    <cfset ArrayAppend(local.dataot, local.str)>
                                    
                                    #getFactory().get("formFactory").view.display(method="inputSelect", selectid="orderType", label="", data=local.dataot, value="#arguments.data.orderType#").output#
                                </div>
                                <div class="col-auto">
                                    <div class="float-end">
                                        <input type="submit" name="doreorderSearch" id="doreorderSearch" value="Re-order Search" class="btn btn-dark my-2 mt-4">
                                    </div>
                                </div>
                            </div>
                        </form>
                    </cfif>
                    <!--- end of reordering form --->
                    <br /><br />
                    <!--- pagination --->
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
                    <!--- end of pagination --->
                    <div class="row">
                        <div class="col">
                            <cfloop from="1" to="#local.sets#" index="local.setNo">
                                <div id="monitor-set-#local.setNo#">
                                    <cfset local.fromRow = ((local.setNo-1) * local.setSize) + 1>
                                    <cfset local.toRow = Min(arguments.data.searchResults.recordcount, local.fromRow + local.setSize - 1)>
                                    <cfloop from="#local.fromRow#" to="#local.toRow#" index="local.r">
                                    #display(method="individualPlayer",BRplayerID=arguments.data.searchResults.BRplayerID[local.r],playerID=arguments.data.searchResults.playerID[local.r],firstName=arguments.data.searchResults.firstName[local.r],nickName=arguments.data.searchResults.nickName[local.r],lastname=arguments.data.searchResults.lastname[local.r],CSR=arguments.data.searchResults.CSR[local.r],weight=arguments.data.searchResults.weight[local.r],height=arguments.data.searchResults.height[local.r],age=arguments.data.searchResults.age[local.r],top1=arguments.data.searchResults.top1[local.r],top2=arguments.data.searchResults.top2[local.r],top3=arguments.data.searchResults.top3[local.r],top4=arguments.data.searchResults.top4[local.r],best1=arguments.data.searchResults.best1[local.r],best2=arguments.data.searchResults.best2[local.r],best3=arguments.data.searchResults.best3[local.r],best4=arguments.data.searchResults.best4[local.r],best5=arguments.data.searchResults.best5[local.r],setNo=local.setNo,country=arguments.data.searchResults.country[local.r],injured=arguments.data.searchResults.injured[local.r]).output#
                                    <!--- END OF PLAYER INDIVIDUAL INFO --->
                                    </cfloop>
                                </div>
                            </cfloop>
                        </div>
                    </div>	
                </div>
            </div>	
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>
    
 	<cffunction name="individualPlayer" access="public" returntype="struct" hint="Displays an individual player's details">
    	<cfargument name="BRplayerID" type="numeric" required="true" default="0">
    	<cfargument name="playerID" type="numeric" required="true" default="0">
        <cfargument name="firstName" type="string" required="true" default="">
        <cfargument name="nickName" type="string" required="true" default="">
        <cfargument name="lastname" type="string" required="true" default="">
        <cfargument name="CSR" type="numeric" required="true" default="0">
        <cfargument name="weight" type="numeric" required="true" default="0">
        <cfargument name="height" type="numeric" required="true" default="0">
        <cfargument name="age" type="numeric" required="true" default="0">
        <cfargument name="top1" type="string" required="true" default="">
        <cfargument name="top2" type="string" required="true" default="">
        <cfargument name="top3" type="string" required="true" default="">
        <cfargument name="top4" type="string" required="true" default="">
        
        <cfargument name="best1" type="string" required="true" default="">
        <cfargument name="best2" type="string" required="true" default="">
        <cfargument name="best3" type="string" required="true" default="">
       
        <cfargument name="preview" type="boolean" required="false" default="false">   
        
        <cfargument name="caneditDelete" type="boolean" required="false" default="true"> 
        
        <cfargument name="setNo" type="numeric" required="false" default="0">
        
        <cfargument name="handed" type="string" required="false" default="">
        <cfargument name="footed" type="string" required="false" default="">
        <cfargument name="FormLevelTitle" type="string" required="false" default="">
        <cfargument name="EnergyLevelTitle" type="string" required="false" default="">
        <cfargument name="AgressionLevelTitle" type="string" required="false" default="">
        <cfargument name="DisciplineLevelTitle" type="string" required="false" default="">
        <cfargument name="LeadershipLevelTitle" type="string" required="false" default="">
        <cfargument name="ExperienceLevelTitle" type="string" required="false" default="">
        <cfargument name="country" type="string" required="false" default="">
        
        <cfargument name="team" type="string" required="false" default="">
        <cfargument name="staminaLevel" type="string" required="false" default="">
        <cfargument name="staminaLeveltitle" type="string" required="false" default="">
        <cfargument name="attackLevel" type="string" required="false" default="">
        <cfargument name="attackLeveltitle" type="string" required="false" default="">
        <cfargument name="techniqueLevel" type="string" required="false" default="">
        <cfargument name="techniqueLeveltitle" type="string" required="false" default="">
        <cfargument name="jumpingLevel" type="string" required="false" default="">
        <cfargument name="jumpingLeveltitle" type="string" required="false" default="">
      	<cfargument name="agilityLevel" type="string" required="false" default="">
        <cfargument name="agilityLeveltitle" type="string" required="false" default="">
        <cfargument name="handlingLevel" type="string" required="false" default="">
        <cfargument name="handlingLeveltitle" type="string" required="false" default="">
        <cfargument name="defenseLevel" type="string" required="false" default="">
        <cfargument name="defenseLeveltitle" type="string" required="false" default="">
        <cfargument name="strengthLevel" type="string" required="false" default="">
        <cfargument name="strengthLeveltitle" type="string" required="false" default="">
        <cfargument name="speedLevel" type="string" required="false" default="">
        <cfargument name="speedLeveltitle" type="string" required="false" default="">
        <cfargument name="kickingLevel" type="string" required="false" default="">
        <cfargument name="kickingLeveltitle" type="string" required="false" default="">
        
        <cfargument name="injured" type="boolean" required="false" default="false"> 
        
        <cfargument name="dopadding" type="boolean" required="false" default="false"> 
        
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
                
		<cfsavecontent variable="local.result.output">
			<cfoutput>
            <div class="container-fluid w-auto">
                <cfif arguments.injured>
                    <cfset local.classextra = "injured">
                <cfelse>
                    <cfset local.classextra = "">
                </cfif>

                <!--- main information for the player --->
                <div class="row playerStats">
                    <!--- Name info --->
                    <div class="col #local.classextra#">
                        <div id="player-title-#arguments.playerID#" title="View Details" class="playerToggle">#arguments.firstName# <cfif Len(arguments.nickName)>&ldquo;#arguments.nickName#&rdquo; </cfif>#arguments.lastname#</div>
                    </div>
                    <!--- General info --->
                    <div class="col text-right #local.classextra#">
                        #arguments.age# years old 
                        &nbsp;&##124;
                        #arguments.height# cm
                        &nbsp;&##124;
                        #arguments.weight# kg
                        &nbsp;&##124;
                        CSR: #arguments.CSR#
                        &nbsp;&##124;
                        #arguments.country#
                    </div>
                </div>
                <!--- end of main information for the player ---> 

                <!--- top 4 stats --->
                <cfif NOT arguments.preview>
                    <div class="row">
                        <div class="col w-auto">
                            Top 4 Stats:
                            &nbsp;#arguments.top1#
                            &nbsp;&##124;&nbsp;#arguments.top2#
                            &nbsp;&##124;&nbsp;#arguments.top3#
                            &nbsp;&##124;&nbsp;#arguments.top4#
                        </div>
                    </div>
                    <div class="row">
                        <div class="col w-auto topPositions">
                            Best Positions:
                            <cfif Len(arguments.best1)>
                                &nbsp;#arguments.best1#
                            </cfif>

                            <cfif Len(arguments.best2)>
                                &nbsp;&##124;&nbsp;#arguments.best2#
                            </cfif>
                            
                            <cfif Len(arguments.best3)>
                                &nbsp;&##124;&nbsp;#arguments.best3#
                            </cfif>
                            
                            <cfif Len(arguments.best4)>
                                &nbsp;&##124;&nbsp;#arguments.best4#
                            </cfif>
                        </div>
                    </div>
                    <br/>
                    <br/>
                </cfif>
                <!--- end of top 4 stats --->
                
            </div>

                <!--- onclicking the name of the player, a div gets filled in with the relevant information --->
                <div id="player-full-info-#arguments.playerID#" style="display:none;"></div>

                <script>
                $(document).ready(function(){
                    $("##player-title-#arguments.playerID#").click(function(){
                        $("##player-full-info-#arguments.playerID#").load("/leagueplayers/showplayerdetails/playerid/#arguments.playerid#");
                        $("##player-full-info-#arguments.playerID#").slideToggle(); 
                    });
                });
                </script>

			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>   
    
    <cffunction name="search" access="public" returntype="struct" hint="Displays the form searching for players">
		<cfargument name="data" type="struct" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        
		<cfsavecontent variable="local.result.output">
			<cfoutput>
            <div class="container-fluid">
                <div class="row">  
                    <div class="col-sm-8 col-md-6 col-lg-6 col-xl-6 mx-20">
                        <cfif StructKeyExists(arguments.data, "errors")>
                            #getFactory().get("template").view.errors(arguments.data.errors).output#
                        </cfif>
                        
                        <form action="/leagueplayers/searchresults" method="POST" id="search-form">
                            <h4>Best Position</h4>
                            #getFactory().get("formFactory").view.display(method="position", value=arguments.data.position,required=false).output#
                            <br/><br/>
                            <h4>Basic Details</h4>

                            #getFactory().get("formFactory").view.display(method="inputText", id="firstName", label="Firstname", value=arguments.data.firstName, required=false).output#
                            #getFactory().get("formFactory").view.display(method="inputText", id="nickName", label="Nickname", value=arguments.data.nickName, required=false).output#
                            #getFactory().get("formFactory").view.display(method="inputText", id="lastName", label="Lastname", value=arguments.data.lastName, required=false).output#
                            #getFactory().get("formFactory").view.display(method="inputText", id="BRplayerID", label="Player ID", value=arguments.data.BRPlayerID, required=false).output#
                            <!--- area to display error message if playerID not a number --->
                            <div id="BRplayerIDError" style="display:none;color:red;">
                            Please, enter a number for the player ID.
                            </div>

                            #getFactory().get("formFactory").view.display(method="inputText", id="team", label="Team", value=arguments.data.team, required=false).output#
                            <!--- area to display error message if team not a number --->
                            <div id="teamError" style="display:none;color:red;">
                            Please, enter a number for the team.
                            </div>
                        
                            #getFactory().get("formFactory").view.display(method="ageSearch", value=arguments.data.age,required=false,valueradio=arguments.data.ageType, label="Age").output#
                            
                            #getFactory().get("formFactory").view.display(method="inputRange", id="CSR", label="Minimum CSR", value=arguments.data.CSR, required=false, minimum = 10000, maximum = 80000, stepping = 10000, showrange = true).output#

                            #getFactory().get("formFactory").view.display(method="inputRange", id="height", label="Minimum Height", value=arguments.data.height, required=false, minimum = 170, maximum = 210, stepping = 5, showrange = true).output#

                            #getFactory().get("formFactory").view.display(method="inputRange", id="weight", label="Minimum Weight", value=arguments.data.weight, required=false, minimum = 80, maximum = 120, stepping = 5, showrange = true).output#

                            <!--- Handed --->
                            <cfset local.handeddata = ArrayNew(1)>
                            <cfloop list="Left,Right" index="local.h">
                                <cfset local.str = {label=local.h, value=local.h}>
                                <cfset ArrayAppend(local.handeddata, local.str)>
                            </cfloop>
                            #getFactory().get("formFactory").view.display(method="inputSelect",selectid="handed", label="Handed",required=false, data=local.handeddata, value=arguments.data.handed, novalue="Handed").output#

                            <!--- Footed --->
                            <cfset local.footeddata = ArrayNew(1)>
                            <cfloop list="Left,Right" index="local.f">
                                <cfset local.str = {label=local.f, value=local.f}>
                                <cfset ArrayAppend(local.footeddata, local.str)>
                            </cfloop>
                            #getFactory().get("formFactory").view.display(method="inputSelect",selectid="footed", label="Footed",required=false, data=local.footeddata, value=arguments.data.footed, novalue="Footed").output#

                            <!--- form level --->
                            <cfset local.FLELevels = getFactory().get("leagueplayers").model.getFLELevels()>
                            <!--- build array of structs dataset to use in inputSelect --->
                            <cfset local.dataform = ArrayNew(1)>
                            <cfloop query="local.FLELevels">
                                <cfset local.str = {label="#local.FLELevels.levelID# - #local.FLELevels.levelTitle#", value=local.FLELevels.levelID}>
                                <cfset ArrayAppend(local.dataform, local.str)>
                            </cfloop>
                            #getFactory().get("formFactory").view.display(method="inputSelect",selectid="formlevel", label="Form",required=false, data=local.dataform, value=arguments.data.formlevel, novalue="Min. Form").output#

                            <!--- energy level --->
                            <cfset local.EnergyLevels = getFactory().get("leagueplayers").model.getEnergyLevels()>
                            <cfset local.dataenergy = ArrayNew(1)>
                            <cfloop query="local.EnergyLevels">
                                <cfset local.str = {label="#local.EnergyLevels.levelID# - #local.EnergyLevels.levelTitle#", value=local.EnergyLevels.levelID}>
                                <cfset ArrayAppend(local.dataenergy, local.str)>
                            </cfloop>
                            #getFactory().get("formFactory").view.display(method="inputSelect",selectid="energylevel", label="Energy",required=false, data=local.dataenergy, value=arguments.data.energylevel, novalue="Min. Energy").output#

                            <!--- agression level --->
                            <cfset local.AgressionLevels = getFactory().get("leagueplayers").model.getAgressionLevels()>
                            <!--- build array of structs dataset to use in inputSelect --->
                            <cfset local.dataagression = ArrayNew(1)>
                            <cfloop query="local.AgressionLevels">
                                <cfset local.str = {label="#local.AgressionLevels.levelID# - #local.AgressionLevels.levelTitle#", value=local.AgressionLevels.levelID}>
                                <cfset ArrayAppend(local.dataagression, local.str)>
                            </cfloop>
                            #getFactory().get("formFactory").view.display(method="inputSelect",selectid="agressionlevel", label="Agression",required=false, data=local.dataagression, value=arguments.data.agressionlevel, novalue="Min. Agression").output#

                            <!--- discipline --->
                            <cfset local.DisciplineLevels = getFactory().get("leagueplayers").model.getDisciplineLevels()>
                            <!--- build array of structs dataset to use in inputSelect --->
                            <cfset local.datadiscipline = ArrayNew(1)>
                            <cfloop query="local.DisciplineLevels">
                                <cfset local.str = {label="#local.DisciplineLevels.levelID# - #local.DisciplineLevels.levelTitle#", value=local.DisciplineLevels.levelID}>
                                <cfset ArrayAppend(local.datadiscipline, local.str)>
                            </cfloop>
                            #getFactory().get("formFactory").view.display(method="inputSelect",selectid="disciplinelevel", label="Discipline",required=false, data=local.datadiscipline, value=arguments.data.disciplinelevel, novalue="Min. Discipline").output#

                            <!--- leadership --->
                            <cfset local.FLELevels = getFactory().get("leagueplayers").model.getFLELevels()>
                            <!--- build array of structs dataset to use in inputSelect --->
                            <cfset local.dataleadership = ArrayNew(1)>
                            <cfloop query="local.FLELevels">
                                <cfset local.str = {label="#local.FLELevels.levelID# - #local.FLELevels.levelTitle#", value=local.FLELevels.levelID}>
                                <cfset ArrayAppend(local.dataleadership, local.str)>
                            </cfloop>
                            #getFactory().get("formFactory").view.display(method="inputSelect",selectid="leadershiplevel", label="Leadership",required=false, data=local.dataleadership, value=arguments.data.leadershiplevel, novalue="Min. Leadership").output#

                            <!--- experience --->
                            <cfset local.ExperienceLevels = getFactory().get("leagueplayers").model.getFLELevels()>
                            <!--- build array of structs dataset to use in inputSelect --->
                            <cfset local.dataexperience = ArrayNew(1)>
                            <cfloop query="local.ExperienceLevels">
                                <cfset local.str = {label="#local.ExperienceLevels.levelID# - #local.ExperienceLevels.levelTitle#", value=local.ExperienceLevels.levelID}>
                                <cfset ArrayAppend(local.dataexperience, local.str)>
                            </cfloop>
                            #getFactory().get("formFactory").view.display(method="inputSelect",selectid="experiencelevel", label="Experience",required=false, data=local.dataexperience, value=arguments.data.experiencelevel, novalue="Min. Experience").output#
                        
                            <!--- now display all stats --->
                            <br/><br/>
                            <h4>Statistics</h4>
                            <cfset local.StatsLevels = getFactory().get("leagueplayers").model.getStatsLevels()>
                            <!--- build array of structs dataset to use in inputSelect --->
                            <cfset local.dataAllStats = ArrayNew(1)>
                            <cfloop query="local.StatsLevels">
                                <cfset local.str = {label="#local.StatsLevels.levelID# - #local.StatsLevels.levelTitle#", value=local.StatsLevels.levelID}>
                                <cfset ArrayAppend(local.dataAllStats, local.str)>
                            </cfloop>

                            <!--- stamina level --->
                            #getFactory().get("formFactory").view.display(method="inputSelect",selectid="staminalevel", label="Stamina",required=false, data=local.dataAllStats, value=arguments.data.Staminalevel, novalue="Min. Stamina").output#

                            <!--- handling --->
                            #getFactory().get("formFactory").view.display(method="inputSelect",selectid="handlinglevel", label="Handling",required=false, data=local.dataAllStats, value=arguments.data.Handlinglevel, novalue="Min. Handling").output#

                            <!--- attack --->
                            #getFactory().get("formFactory").view.display(method="inputSelect",selectid="attacklevel", label="Attack",required=false, data=local.dataAllStats, value=arguments.data.Attacklevel, novalue="Min. Attack").output#
                            
                            <!--- defense --->
                            #getFactory().get("formFactory").view.display(method="inputSelect",selectid="defenselevel", label="Defense",required=false, data=local.dataAllStats, value=arguments.data.Defenselevel, novalue="Min. Defense").output#
                            <!--- technique --->
                            #getFactory().get("formFactory").view.display(method="inputSelect",selectid="techniquelevel", label="Technique",required=false, data=local.dataAllStats, value=arguments.data.Techniquelevel, novalue="Min. Technique").output#
                            <!--- strength --->
                            #getFactory().get("formFactory").view.display(method="inputSelect",selectid="strengthlevel", label="Strength",required=false, data=local.dataAllStats, value=arguments.data.Strengthlevel, novalue="Min. Strength").output#

                            <!--- jumping --->
                            #getFactory().get("formFactory").view.display(method="inputSelect",selectid="jumpinglevel", label="Jumping",required=false, data=local.dataAllStats, value=arguments.data.Jumpinglevel, novalue="Min. Jumping").output#
                            <!--- speed --->
                            #getFactory().get("formFactory").view.display(method="inputSelect",selectid="speedlevel", label="Speed",required=false, data=local.dataAllStats, value=arguments.data.Speedlevel, novalue="Min. Speed").output#
                            <!--- agility --->
                            #getFactory().get("formFactory").view.display(method="inputSelect",selectid="agilitylevel", label="Agility",required=false, data=local.dataAllStats, value=arguments.data.Agilitylevel, novalue="Min. Agility").output#
                            <!--- kicking --->
                            #getFactory().get("formFactory").view.display(method="inputSelect",selectid="kickinglevel", label="Kicking",required=false, data=local.dataAllStats, value=arguments.data.Kickinglevel, novalue="Min. Kicking").output#

                            <input type="hidden" name="country" value="Wales">
                            <br/><br/>
                            <!--- order by field select --->
                            <cfset local.orderingOptions = getFactory().get("leagueplayers").model.getOrderingOptions()>

                            <!--- build array of structs dataset to use in inputSelect --->
                            <cfset local.dataob = ArrayNew(1)>
                            <cfloop list="#local.orderingOptions#" index="local.o">
                                <cfset local.fvalue = local.o>
                                <cfif local.fvalue neq "CSR">
                                    <cfset local.fvalue = Ucase(Left(local.fvalue,1)) & Lcase(Right(local.fvalue,Len(local.fvalue)-1))>
                                    <cfif Right(local.fvalue,5) eq "level">
                                        <cfset local.fvalue = Left(local.fvalue,Len(local.fvalue)-5)>
                                    </cfif>
                                    <cfif local.fvalue eq "BRplayerID">
                                        <cfset local.fvalue = "Player ID">
                                    </cfif>
                                    <cfif local.fvalue eq "datelastupdated">
                                        <cfset local.fvalue = "Date Last Updated">
                                    </cfif>
                                    <cfif local.fvalue eq "dateadded">
                                        <cfset local.fvalue = "Date Added">
                                    </cfif>
                                </cfif>
                                
                                <cfset local.str = {label=local.fvalue, value=local.o}>
                                <cfset ArrayAppend(local.dataob, local.str)>
                            </cfloop>
                            #getFactory().get("formFactory").view.display(method="inputSelect", selectid="orderBy", label="Order By", data=local.dataob, value="#arguments.data.orderBy#").output#

                            <!--- order by ascending/descending --->
                            <!--- build array of structs dataset to use in inputSelect --->
                            <cfset local.dataot = ArrayNew(1)>
                            
                            <cfset local.str = {label="Ascending", value="Asc"}>
                            <cfset ArrayAppend(local.dataot, local.str)>
                            
                            <cfset local.str = {label="Descending", value="Desc"}>
                            <cfset ArrayAppend(local.dataot, local.str)>
                            
                            #getFactory().get("formFactory").view.display(method="inputSelect", selectid="orderType", label="In Order", data=local.dataot, value="#arguments.data.orderType#").output#

                            <div class="row float-end">
                                <div class="col">
                                    <input type="button" class="btn btn-dark my-2"  value="Reset" id="resetSearch">
                                </div>
                                <div class="col"><input type="submit" name="doSearch" id="doSearch" value="Search" class="btn btn-dark my-2"></div>
                            </div>

                            <input type="hidden" name="processSearch" value="true">

                            <!--- Validating any team of player ID input by the user, as these values need to be numeric --->
                            <script>
                                $(document).ready(function(){
                                    $("##search-form").submit(function(event){
                                        event.preventDefault();

                                        var validBRplayerID = true;
                                        var validteam = true;
                                        var BRplayerIDvalue = $("##BRplayerID").val();
                                        var teamvalue = $("##team").val();
                                        if ((BRplayerIDvalue.length > 0 ) && (!$.isNumeric(BRplayerIDvalue)))
                                        { 
                                            $("##BRplayerIDError").show(); 
                                            $("##BRplayerID").focus();
                                            validBRplayerID = false;
                                        }
                                        else 
                                        {
                                            $("##BRplayerIDError").hide(); 
                                            validBRplayerID = true;
                                        }
                                        if ((teamvalue.length > 0 ) && (!$.isNumeric(teamvalue)))
                                        { 
                                            $("##teamError").show();
                                            $("##team").focus();
                                            validteam = false;
                                        }
                                        else 
                                        {
                                            $("##teamError").hide(); 
                                            validteam = true;
                                        }                                            
                                        if (validBRplayerID && validteam) this.submit();
                                    });

                                    $("##resetSearch").click(function(){
                                        $("##position").val("");
                                        $("##firstName").val("");
                                        $("##nickName").val("");
                                        $("##lastName").val("");

                                        $("##BRplayerID").val("0");
                                        $("##team").val("");

                                        $("##ageType_Min").attr("checked", true);
                                        $("##ageType_Max").attr("checked", false);

                                        $("##age").val("0");
                                        $("##CSR").val("10000");
                                        $("##height").val("170");
                                        $("##weight").val("80");
                                        $("##handed").val("");
                                        $("##footed").val("");

                                        $("##formlevel").val("");
                                        $("##energylevel").val("");
                                        $("##agressionlevel").val("");
                                        $("##disciplinelevel").val("");
                                        $("##leadershiplevel").val("");
                                        $("##experiencelevel").val("");

                                        $("##staminalevel").val("");
                                        $("##handlinglevel").val("");
                                        $("##attacklevel").val("");
                                        $("##defenselevel").val("");
                                        $("##techniquelevel").val("");
                                        $("##strengthlevel").val("");
                                        $("##jumpinglevel").val("");
                                        $("##speedlevel").val("");
                                        $("##agilitylevel").val("");
                                        $("##kickinglevel").val("");

                                        $("##orderBy").val("");
                                        $("##orderType").val("");
                                    });
                                });
                            </script>
                        </form>
                    </div>
                </div>
            </div>
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>    

    <cffunction name="showPlayerDetails" access="private" returntype="struct" hint="Displays player specific data">
		<cfargument name="data" type="struct" required="false">
        
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>		

		<cfsavecontent variable="local.result.output">
            <cftry>
            	<cfset local.nrows = ceiling(arguments.data.stats.recordcount/2)>
				<cfset local.begin = 1>
                <cfset local.end = 5>
                
            <!--- show any teams the player is part of --->
                <cfif arguments.data.myPlayerExistingTeams.recordcount>
                    <cfoutput query="arguments.data.myPlayerExistingTeams">
                        <div class="row my-1">
                            <div class="col">Member of the <strong>#teamTitle#</strong> Team in position <strong>#positionID# (#positionTitle#)</strong></div>
                        </div>
                    </cfoutput>
                </cfif>

            	<cfoutput query="arguments.data.myPlayer">
                <!--- full div --->
                <div id="fulldisplay-#playerID#">
                    <!--- section showing add to team links but only if other teams available --->
                    <cfif ListLen(arguments.data.potentialTeams)>
                        <div class="row mb-4" id="updating-links-#playerID#">
                            <div class="col w-auto addtoteam" id="player-addToTeamlink-#playerID#">
                                <form action="/LeaguePlayers/addMyPlayerToTeam" method="POST" id="addtoteam-form">
                                    <input type="hidden" name="playerID" value="#playerID#">
                                    <input type="submit" name="add-button" id="" value="Add to Your Team" class="btn btn-dark mt-2 text-white buttonAction">
                                </form>
                            </div>
                            <br/><br/>
                        </div>
                    </cfif>
                    <cfif injured>
                        <cfset local.classextra = "injured">
                    <cfelse>
                        <cfset local.classextra = "">
                    </cfif>
                    <div class="container-fluid w-auto #local.classextra#" id="playerallinfo#playerID#">
                        <div class="row">
                            <div class="col">
                                <strong>PlayerID:</strong> #BRPlayerID#
                            </div>
                            <div class="col">
                                &nbsp
                            </div>
                        </div>
                        <div class="row">
                            <div class="col">
                                <strong>Handed:</strong> #Handed#
                            </div>
                            <div class="col">
                                <strong>Footed:</strong> #Footed#
                            </div>
                        </div>
                        <div class="row">
                            <div class="col">
                                <strong>Form:</strong> #FormLevelTitle#
                            </div>
                            <div class="col">
                                <strong>Energy:</strong> #EnergyLevelTitle#
                            </div>
                        </div>
                        <div class="row">
                            <div class="col">
                                <strong>Agression:</strong> #AgressionLevelTitle#
                            </div>
                            <div class="col">
                                <strong>Discipline:</strong> #DisciplineLevelTitle#
                            </div>
                        </div>
                        <div class="row">
                            <div class="col">
                                <strong>Leadership:</strong> #LeadershipLevelTitle#
                            </div>
                            <div class="col">
                                <strong>Experience:</strong> #ExperienceLevelTitle#
                            </div>
                        </div>
                        <br/><br/>
                        <div class="row #local.classextra#">
                            <div class="col">
                                <table>
                                    <!--- get user defined colors --->
                                    <cfset local.redMaxLevel=getFactory().get("login").model.getUser().user.redMaxLevel>
                                    <cfset local.greenMaxLevel=getFactory().get("login").model.getUser().user.greenMaxLevel>
                                
                                    <cfloop query="arguments.data.stats" startrow="#local.begin#" endrow="#local.end#">
                                    <tr>
                                        <td>#stattitle#</td>
                                        <td>
                                            <cfif arguments.data.myPlayer.injured>
                                                <font color="##CC0000">#Evaluate("arguments.data.myPlayer.#stattitle#leveltitle")#</font>
                                            <cfelse>
                                                <cfif #Evaluate("arguments.data.myPlayer.#stattitle#level")# lte local.redMaxLevel>
                                                <font color="##E71D1B">#Evaluate("arguments.data.myPlayer.#stattitle#leveltitle")#</font>
                                                <cfelseif #Evaluate("arguments.data.myPlayer.#stattitle#level")# gt local.redMaxLevel AND #Evaluate("arguments.data.myPlayer.#stattitle#level")# lte local.greenMaxLevel>
                                                <font color="##12BA6C">#Evaluate("arguments.data.myPlayer.#stattitle#leveltitle")#</font>
                                                <cfelse>
                                                <font color="##787878">#Evaluate("arguments.data.myPlayer.#stattitle#leveltitle")#</font>
                                                </cfif>
                                            </cfif>
                                        </td>
                                        <td class="statsbar">
                                            <cfif FileExists("#getFactory().getSetting('imageFolder')#\levels\level#Evaluate("arguments.data.myPlayer.#stattitle#level")#.gif")>
                                            <img src="/res/img/levels/level#Evaluate("arguments.data.myPlayer.#stattitle#level")#.gif" />
                                            <cfelse>&nbsp;
                                            </cfif>
                                        </td>
                                    </tr>
                                    </cfloop>
                                    <cfset local.begin = local.begin+5>
                                    <cfset local.end = local.end+5>
                                </table>
                            </div>
                            <div class="col">
                                <table>
                                    <cfloop query="arguments.data.stats" startrow="#local.begin#" endrow="#local.end#">
                                    <tr>
                                        <td>#stattitle#&nbsp;&nbsp;</td>
                                        <td>
                                            <cfif arguments.data.myPlayer.injured>
                                                <font color="##CC0000">#Evaluate("arguments.data.myPlayer.#stattitle#leveltitle")#</font>
                                            <cfelse>
                                                <cfif #Evaluate("arguments.data.myPlayer.#stattitle#level")# lte local.redMaxLevel>
                                                <font color="##E71D1B">#Evaluate("arguments.data.myPlayer.#stattitle#leveltitle")#</font>
                                                <cfelseif #Evaluate("arguments.data.myPlayer.#stattitle#level")# gt local.redMaxLevel AND #Evaluate("arguments.data.myPlayer.#stattitle#level")# lte local.greenMaxLevel>
                                                <font color="##12BA6C">#Evaluate("arguments.data.myPlayer.#stattitle#leveltitle")#</font>
                                                <cfelse>
                                                <font color="##787878">#Evaluate("arguments.data.myPlayer.#stattitle#leveltitle")#</font>
                                                </cfif>
                                            </cfif>
                                        </td>
                                        <td class="statsbar">
                                            <cfif FileExists("#getFactory().getSetting('imageFolder')#\levels\level#Evaluate("arguments.data.myPlayer.#stattitle#level")#.gif")>
                                            <img src="/res/img/levels/level#Evaluate("arguments.data.myPlayer.#stattitle#level")#.gif" />
                                            <cfelse>&nbsp;
                                            </cfif>
                                        </td>
                                    </tr>
                                    </cfloop>
                                </table>
                            </div>
                    </div>
                    <div class="row updated-data">
                        <div class="col">
                            <br />
                            Date added: #dateformat(dateadded,"dd/mm/yy")# by #AddedByUser#
                            <br />
                            <cfif Len(Trim(LastUpdatedByUser))>
                            Date last updated: #dateformat(datelastupdated,"dd/mm/yy")# by #LastUpdatedByUser#
                            </cfif>
                            <br /><br />
                        </div>
                    </div>
                </div>
				</cfoutput>

                    <cfcatch type="any">
                        <cfdump var="#cfcatch#">
                    </cfcatch>
                </cftry>
              <cfoutput>
            	#getFactory().get("template").view.defaultFooter().output#
            </cfoutput>  
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>

    <cffunction name="addMyPlayerToTeam" access="private" returntype="struct" hint="Displays a form enabling the user to add a specific player to an existing team">
		<cfargument name="data" type="struct" required="false" >
        <cfargument name="playerID" type="numeric" required="true" default="0">
        
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        
        <cfset local.data = arguments.data>

		<cfsavecontent variable="local.result.output">

            <cfset local.data.potentialTeamsdata = ArrayNew(1)>
            <cfoutput query="local.data.getTeamsAndPositions" group="teamID">
                <cfset local.str = {label=teamTitle, value=teamID}>
                <cfset ArrayAppend(local.data.potentialTeamsdata, local.str)>
            </cfoutput>

            <cfoutput>
            <div class ="container-fluid" id="teams-#arguments.playerID#">
                    
                    <div class="row">
                        <div class="col-sm-3">
                        <form id="positionstats-form"  class="was-validated">
                            #getFactory().get("formFactory").view.display(method="inputSelect",selectid="teamID", label="teamTitle",required=true, data=local.data.potentialTeamsdata, value="teamID", novalue="Select a Team").output#
                        </form>
                        </div>
                    </div>
                    <div class="col-sm-3" id="positionPotential" style="display:none;"></div>
            </div>
            
            <script>
                $(document).ready(function() {
                    $("##teamID").on("change", function(){ 
                        var selTeamID = $(this).val();
                        newHref = "/leagueplayers/getMatchingPositions/playerID/#arguments.playerID#/teamID/" + selTeamID;
                        $("##positionPotential").show();
                        $("##positionPotential").load(newHref);
                    });
                });
            </script>

            </cfoutput>
                
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>

    <cffunction name="getMatchingPositions" access="private" returntype="struct" hint="Displays list of positions available for the selected team, when adding a player to a team">
		<cfargument name="data" type="struct" required="false" >
        
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        
        <cfset local.data = arguments.data>

		<cfsavecontent variable="local.result.output">

            <cfset local.data.potentialpositionsdata = ArrayNew(1)>
            <cfloop query="local.data.getAvailablePositions">
                <cfset local.str = {label="#positionID# - #positionTitle#", value=positionID}>
                <cfset ArrayAppend(local.data.potentialpositionsdata, local.str)>
            </cfloop>
            
            <cfoutput>
                <form action="/leagueplayers/addToTeam" method="POST" id="addToTeamexisting#local.data.playerID#" name="addToTeamexisting#local.data.playerID#" class="was-validated">
                    <input type="hidden" name="playerID" value="#local.data.playerID#">
                    <input type="hidden" name="teamID" value="#local.data.teamID#">
                    <div class="row">
                        #getFactory().get("formFactory").view.display(method="inputSelect",selectid="positionID", label="positionTitle",required=true, data=local.data.potentialpositionsdata, value="positionID", novalue="Select a Position").output#
                    </div>
                    
                    <div class="row my-3">
                        <div class="col">
                            <a href="/LeaguePlayers" class="btn btn-dark mt-2 text-white buttonAction">Cancel</a>
                        </div>
                        <div class="col">
                            <input type="submit" name="addToTeamexisting-#local.data.playerID#" id="addToTeamexisting-#local.data.playerID#" value="Add to Team" class="btn btn-dark mt-2">
                        </div>
                    </div>
                </form>

            </cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="positionStats" access="public" returntype="struct" hint="view for changing league players position stats">
		<cfargument name="data" type="struct" required="true">
		
		<cfset var local = structNew()>

		<cfset local.result = getFactory().getResult()>
        
		<cfsavecontent variable="local.result.output">
			<cfoutput>
                <div class ="container-fluid">
                    <cfif StructKeyExists(arguments.data, "errors")>
                        #getFactory().get("template").view.errors(arguments.data.errors).output#
                    </cfif>
                    <div class="row">                      
                        <div class="col-sm-8 col-md-6 col-lg-6 col-xl-6 mx-20">
                            <form action="/leagueplayers/positionStats" method="POST" id="positionstats-form"  class="was-validated">
                                <!--- getting a list of all possible stats for display in selects --->
                                <cfset local.stats = getFactory().get("leaguePlayers").model.getAllStatsNames()>
                                <!--- build array of structs dataset to use in inputSelect --->
                                <cfset local.datast = ArrayNew(1)>
                                <cfloop query="local.stats">
                                    <cfset local.str = {label="#local.stats.StatTitle#", value=local.stats.StatID}>
                                    <cfset ArrayAppend(local.datast, local.str)>
                                </cfloop>

                                <!--- build array of structs dataset to use in inputSelect for minimum weight --->
                                <cfset local.datamw = ArrayNew(1)>
                                <cfloop from="80" to="150" index="local.i">
                                    <cfset local.str = {label="#local.i# Kg", value=local.i}>
                                    <cfset ArrayAppend(local.datamw, local.str)>
                                </cfloop>

                                <!--- build array of structs dataset to use in inputSelect for maximum height --->
                                <cfset local.datamh = ArrayNew(1)>
                                <cfloop from="160" to="250" index="local.i">
                                    <cfset local.str = {label="#local.i# cm", value=local.i}>
                                    <cfset ArrayAppend(local.datamh, local.str)>
                                </cfloop>

                                <cfloop query="arguments.data.allpositions">
                                    <h4>#positionID# - #positionTitle#</h4>

                                    <cfif structkeyexists(arguments.data, "stat_#positionID#_1")>
                                        <cfset local.valuestat_1 = #evaluate('arguments.data.stat_#positionID#_1')#>
                                    <cfelse>
                                        <cfset local.valuestat_1 = 0>
                                    </cfif>

                                    <cfif structkeyexists(arguments.data, "stat_#positionID#_2")>
                                        <cfset local.valuestat_2 = #evaluate('arguments.data.stat_#positionID#_2')#>
                                    <cfelse>
                                        <cfset local.valuestat_2 = 0>
                                    </cfif>

                                    <cfif structkeyexists(arguments.data, "stat_#positionID#_3")>
                                        <cfset local.valuestat_3 = #evaluate('arguments.data.stat_#positionID#_3')#>
                                    <cfelse>
                                        <cfset local.valuestat_3 = 0>
                                    </cfif>

                                    <cfif structkeyexists(arguments.data, "stat_#positionID#_4")>
                                        <cfset local.valuestat_4 = #evaluate('arguments.data.stat_#positionID#_4')#>
                                    <cfelse>
                                        <cfset local.valuestat_4 = 0>
                                    </cfif>

                                    <cfif structkeyexists(arguments.data, "stat_#positionID#_5")>
                                        <cfset local.valuestat_5 = #evaluate('arguments.data.stat_#positionID#_5')#>
                                    <cfelse>
                                        <cfset local.valuestat_5 = 0>
                                    </cfif>

                                    <cfif structkeyexists(arguments.data, "stat_#positionID#_6")>
                                        <cfset local.valuestat_6 = #evaluate('arguments.data.stat_#positionID#_6')#>
                                    <cfelse>
                                        <cfset local.valuestat_6 = 0>
                                    </cfif>

                                    <div class="from-group row">
                                        <div class="col">
                                            #getFactory().get("formFactory").view.display(method="inputSelect", value="#local.valuestat_1#",required=false,selectid="stat_#positionID#_1", label="Please Select",data=local.datast).output#
                                        </div>
                                        <div class="col">
                                            #getFactory().get("formFactory").view.display(method="inputSelect", value="#local.valuestat_2#",required=false,selectid="stat_#positionID#_2", label="Please Select",data=local.datast).output#
                                        </div>
                                    </div>
                                    <div class="from-group row">
                                        <div class="col">
                                            #getFactory().get("formFactory").view.display(method="inputSelect", value="#local.valuestat_3#",required=false,selectid="stat_#positionID#_3", label="Please Select",data=local.datast).output#
                                        </div>
                                        <div class="col">
                                            #getFactory().get("formFactory").view.display(method="inputSelect", value="#local.valuestat_4#",required=false,selectid="stat_#positionID#_4", label="Please Select",data=local.datast).output#
                                        </div>
                                    </div>

                                    <cfif positionID eq 1 OR positionID eq 2 OR positionID eq 3>
                                        <div class="from-group row">
                                            <div class="col">
                                                #getFactory().get("formFactory").view.display(method="inputSelect", value="#evaluate('arguments.data.minWeight_#positionID#')#",required=false,selectid="minWeight_#positionID#",label="Minimum Weight",data=local.datamw).output#
                                            </div>
                                            <div class="col">
                                                #getFactory().get("formFactory").view.display(method="inputSelect", value="#evaluate('arguments.data.maxHeight_#positionID#')#",required=false,selectid="maxHeight_#positionID#",data=local.datamh,label="Maximum Height").output#
                                            </div>
                                        </div>
                                    <cfelseif positionID eq 4 OR positionID eq 5>
                                        <div class="from-group row">
                                            <div class="col">
                                                #getFactory().get("formFactory").view.display(method="inputSelect", value="#evaluate('arguments.data.minHeight_#positionID#')#",required=false,selectid="minHeight_#positionID#",data=local.datamh,label="Minimum Height").output#
                                            </div>
                                            <div class="col">&nbsp;</div>
                                        </div>
                                    </cfif>
                                </cfloop>

                                <div class="row">
                                    <div class="col">&nbsp;</div>
                                    <div class="col"><input type="submit" name="doSubmit" id="doSubmit" value="Submit" class="btn btn-dark my-2"></div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="updatechanges" access="private" returntype="struct" hint="Displaying changes that occured during the last scheduled update">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
		<cfsavecontent variable="local.result.output">
			<cfoutput>
                <div class="container-fluid p-3">
                    <br />
                    <br />
                    These changes occurred on the last update (#dateformat(arguments.data.lastUpdateDate,"dd/mm/yy")#)<br /><br />
                    <cfloop from="1" to="#arrayLen(arguments.data.players)#" index="local.p">
                        #display(method="individualPlayerUpdateState", data=arguments.data.players[local.p]).output#
                    </cfloop>
                </div>
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="individualPlayerUpdateState" access="public" returntype="struct" hint="displays details for updated data">
    	<cfargument name="data" type="struct" required="true">
      
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        
		<cfsavecontent variable="local.result.output">
			<cfoutput>
                <div class="container-fluid w-100">
                    <div class="row playerStats">
                        <div class="col">
                        #arguments.data.fullname#
                        </div>
                    </div>
                    <div class="row">
                        <div class="col">
                            <cfif structKeyExists(arguments.data.changes,"standard")>
                                <cfloop from="1" to="#arrayLen(arguments.data.changes.standard)#" index="local.change">
                                #arguments.data.changes.standard[local.change]#<br/>
                                </cfloop>
                            </cfif>
                            <cfif structKeyExists(arguments.data.changes,"positive")>
                                <cfloop from="1" to="#arrayLen(arguments.data.changes.positive)#" index="local.change">
                                <div class="positive">#arguments.data.changes.positive[local.change]#<br/></div>
                                </cfloop>
                            </cfif>
                            <cfif structKeyExists(arguments.data.changes,"negative")>
                                <cfloop from="1" to="#arrayLen(arguments.data.changes.negative)#" index="local.change">
                            <div class="negative">#arguments.data.changes.negative[local.change]#<br/></div>
                                </cfloop>
                            </cfif>
                        </div>
                    </div>
                </div>
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>  
</cfcomponent>
