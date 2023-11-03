<cfcomponent name="leaguematches" extends="parent" hint="Model, queries and logic for under 20 s matches">
	<cffunction name="init" returntype="leaguematches" access="public">
		<cfset var local = structNew()>

		<cfset super.init()>
        <!--- load in any messages --->
		<cfset local.cfcPath = getDirectoryFromPath(getCurrentTemplatePath())>
		<cffile action="read" file="#local.cfcPath#..\..\config\#application.core.get('configFolder')#\Leaguematchmessages.xml" variable="local.rawData">
		<cfset local.xml = xmlParse(local.rawData)>
		
		<cfset variables.messages = StructNew()>
		
		<cfloop from="1" to="#ArrayLen(local.xml.Leaguematchmessages.message)#" index="local.m">
			<cfloop list="#StructKeyList(local.xml.Leaguematchmessages.message[local.m].xmlAttributes)#" index="local.key">
				
				<cfset local.messages = ArrayNew(1)>
				
				<cfloop from="1" to="#ArrayLen(local.xml.Leaguematchmessages.message[local.m].container)#" index="local.c">
					<cfset local.message = structNew()>
					<cfif NOT StructKeyExists(local.message,"title")>
						<cfset StructInsert(local.message, "title",local.xml.Leaguematchmessages.message[local.m].container[local.c].xmlAttributes.title)>
					</cfif>
					<cfif NOT StructKeyExists(local.message,"summary")>
						<cfset StructInsert(local.message, "summary",local.xml.Leaguematchmessages.message[local.m].container[local.c].xmlAttributes.summary)>
					</cfif>

					<cfset ArrayAppend(local.messages, local.message)>
				</cfloop>

				<cfif NOT StructKeyExists(variables.messages,local.xml.Leaguematchmessages.message[local.m].xmlAttributes[local.key])>
					<cfset StructInsert(variables.messages, local.xml.Leaguematchmessages.message[local.m].xmlAttributes[local.key], local.messages)>
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfreturn this/>
	</cffunction>    
 	
    <cffunction name="getMyMatches" returntype="query" access="public" hint="returns a list of either all the matches added by the user, or only the ones that were played at home for report purposes">
		<cfargument name="userID" type="numeric" required="false" default="#getFactory().get('login').model.getUser().user.userID#">
        <cfargument name="IsHome" type="boolean" required="false" default = "false">
        
		<cfset var local = structNew()>
		
		<cfquery name="local.result" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	m.MatchID,
            		m.MatchDate,
                    m.OpponentName,
                    m.IsHome,
                    m.DateAdded,
                    m.DateLastUpdated,
                    m.MatchResult,
                    m.Score,
                    m.matchType,
                    m.OtherScore,
                    m.AttendanceStanding,
                    m.AttendanceUncovered,
                    m.AttendanceCovered,
                    m.AttendanceMembers,
                    m.AttendanceVIP,
                    m.AttendanceTotal,
                    mt.MatchTypeTitle,
                    mr.MatchResultTitle
            from	((LeagueMatches m
            inner join MatchTypes mt
            ON		m.MatchType = mt.MatchTypeID)
            inner join MatchResults mr
            ON		m.MatchResult = mr.MatchResultID)
            <cfif arguments.userID neq 0>
            where	userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.userID#">
            </cfif>
            <cfif arguments.IsHome>
            and	m.IsHome = 1
            </cfif>
            order by MatchDate DESC
		</cfquery>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getDateFrom" returntype="string" access="public" hint="returns first date for matches">
		<cfargument name="userID" type="numeric" required="false" default="#getFactory().get('login').model.getUser().user.userID#">
        
		<cfset var local = structNew()>
		
		<cfquery name="local.result" datasource="#getFactory().get("session").model.get('SiteDatabase')#" maxrows="1">
			select	lm.MatchDate
            from	LeagueMatches lm
            where	lm.IsHome = 1
            <cfif arguments.userID neq 0>
            and		lm.userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.userID#">
            </cfif>
            
            order by lm.MatchDate ASC
		</cfquery>
        
        <cfif local.result.recordcount>
			<cfset local.datefrom = "#dateformat(local.result.MatchDate,"dd/mm/yy")#">
        <cfelse>
        	<cfset local.datefrom = "">
        </cfif>
        
		<cfreturn local.datefrom>
	</cffunction>
    
    <cffunction name="getDateTo" returntype="string" access="public" hint="returns last date for matches">
		<cfargument name="userID" type="numeric" required="false" default="#getFactory().get('login').model.getUser().user.userID#">
        
		<cfset var local = structNew()>
		
		<cfquery name="local.result" datasource="#getFactory().get("session").model.get('SiteDatabase')#" maxrows="1">
			select	lm.MatchDate
            from	LeagueMatches lm
            where	lm.IsHome = 1
            <cfif arguments.userID neq 0>
            and		lm.userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.userID#">
            </cfif>
            
            order by MatchDate DESC
		</cfquery>
        
        <cfif local.result.recordcount>
			<cfset local.dateto = "#dateformat(local.result.MatchDate,"dd/mm/yy")#">
        <cfelse>
        	<cfset local.dateto = "">
        </cfif>
        
		<cfreturn local.dateto>
	</cffunction>
    
    <cffunction name="getmatchDetails" returntype="query" access="public" hint="returns a specific match information">
		<cfargument name="userID" type="numeric" required="false" default="#getFactory().get('login').model.getUser().user.userID#">
        <cfargument name="matchID" type="numeric" required="false" default="0">
		<cfset var local = structNew()>
		
		<cfquery name="local.matchdetails" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	lm.MatchID,
            		lm.MatchDate,
                    lm.OpponentName,
                    lm.IsHome,
                    lm.DateAdded,
                    lm.DateLastUpdated,
                    lm.AttendanceStanding,
                    lm.AttendanceUncovered,
                    lm.AttendanceCovered,
                    lm.AttendanceMembers,
                    lm.AttendanceVIP,
                    lm.Score,
                    lm.OtherScore,
                    lm.matchResult,
                    lm.matchType
            from	leaguematches lm
            where	lm.MatchID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.MatchID#">
            <cfif arguments.userID neq 0>
            and		lm.userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.userID#">
            </cfif>
            
		</cfquery>
		
        <cfset local.result = QueryNew("MatchID,MatchDate,OpponentName,HomeorAway,DateAdded,DateLastUpdated,AttendanceStanding,AttendanceUncovered,AttendanceCovered,AttendanceMembers,AttendanceVIP,isHome,Score,OtherScore,matchResult,matchType,TeamRating,ForwardsRating,BacksRating,TeamRatingPotential,ForwardsRatingPotential,BacksRatingPotential","integer,varchar,varchar,varchar,varchar,varchar,integer,integer,integer,integer,integer,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar")>
        
        <cfloop query="local.matchdetails">
                             
                <cfset QueryAddRow(local.result, 1)>
                <cfset QuerySetCell(local.result, "MatchID", MatchID)>
                <cfset QuerySetCell(local.result, "MatchDate", MatchDate)>
                <cfset QuerySetCell(local.result, "OpponentName", OpponentName)>
                <cfif isHome>
                	<cfset QuerySetCell(local.result, "HomeorAway", "Home")>
                <cfelse>
                	<cfset QuerySetCell(local.result, "HomeorAway", "Away")>
                </cfif>
                <cfset QuerySetCell(local.result, "DateAdded", DateAdded)>
                <cfset QuerySetCell(local.result, "DateLastUpdated", DateLastUpdated)>
                
                <cfset QuerySetCell(local.result, "AttendanceStanding", AttendanceStanding)>
                <cfset QuerySetCell(local.result, "AttendanceUncovered", AttendanceUncovered)>
                <cfset QuerySetCell(local.result, "AttendanceCovered", AttendanceCovered)>
                <cfset QuerySetCell(local.result, "AttendanceMembers", AttendanceMembers)>
                <cfset QuerySetCell(local.result, "AttendanceVIP", AttendanceVIP)>
                <cfset QuerySetCell(local.result, "isHome", isHome)>
                <cfset QuerySetCell(local.result, "Score", Score)>
                <cfset QuerySetCell(local.result, "OtherScore", OtherScore)>
                <cfset QuerySetCell(local.result, "matchResult", matchResult)>
                <cfset QuerySetCell(local.result, "matchType", matchType)>
        </cfloop>
        
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getaspecificMatch" returntype="query" access="public" hint="returns details for a specific match">
		<cfargument name="userID" type="numeric" required="false" default="#getFactory().get('login').model.getUser().user.userID#">
        <cfargument name="matchID" type="numeric" required="false" default="0">
        
		<cfset var local = structNew()>
		
		<cfquery name="local.matchdetails" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	m.MatchID,
            		m.MatchDate,
                    m.OpponentName,
                    m.IsHome,
                    m.DateAdded,
                    m.DateLastUpdated,
            		p.PositionTitle,
                    p.PositionID,
                    pl.Firstname,
                    pl.Lastname,
                    pl.PlayerID,
                    mp.PlayerExpectationID,
                    mp.playerPotentialID,
                    mp.stars,
                    mp.ManOfTheMatch
            from	 (((leaguematches m INNER JOIN LeagueMatchPlayers mp 
            ON 		 m.MatchID = mp.MatchID)
            INNER JOIN Positions p ON mp.PositionID = p.PositionID)
            left outer join LeaguePlayers pl
            on mp.PlayerID = pl.PlayerID)
            where	m.MatchID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.MatchID#">
            <cfif arguments.userID neq 0>
            and		m.userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.userID#">
            </cfif>
            
            order by m.OpponentName,p.DisplayOrder
		</cfquery>
        
        <cfset local.result = QueryNew("MatchID,MatchDate,OpponentName,IsHome,DateAdded,DateLastUpdated,PositionTitle,PositionID,Firstname,Lastname,PlayerID,PlayerExpectationID,playerPotentialID,stars,ManofTheMatch,playerExpectationTitle,playerPotentialTitle","integer,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar")>
        
        <cfloop query="local.matchdetails">
        	
                <cfset QueryAddRow(local.result, 1)>
                <cfset QuerySetCell(local.result, "MatchID", MatchID)>
                <cfset QuerySetCell(local.result, "MatchDate", MatchDate)>
                <cfset QuerySetCell(local.result, "OpponentName", OpponentName)>
                <cfset QuerySetCell(local.result, "IsHome", IsHome)>

                <cfset QuerySetCell(local.result, "DateAdded", DateAdded)>
                <cfset QuerySetCell(local.result, "DateLastUpdated", DateLastUpdated)>
                <cfset QuerySetCell(local.result, "PositionTitle", PositionTitle)>
                <cfset QuerySetCell(local.result, "PositionID", PositionID)>
                <cfset QuerySetCell(local.result, "Firstname", Firstname)>
                <cfset QuerySetCell(local.result, "Lastname", Lastname)>  
                <cfset QuerySetCell(local.result, "PlayerID", PlayerID)>

                <cfset QuerySetCell(local.result, "PlayerExpectationID", PlayerExpectationID)>
                <cfset QuerySetCell(local.result, "playerPotentialID", playerPotentialID)>
                <cfset QuerySetCell(local.result, "stars", stars)>
                
                <cfquery name="local.getplayerExpectationTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                select 	pe.PlayerExpectationTitle
                from	PlayerExpectations pe
                where	pe.PlayerExpectationID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#PlayerExpectationID#">
                </cfquery>
                
                <cfset QuerySetCell(local.result, "PlayerExpectationTitle", local.getplayerExpectationTitle.PlayerExpectationTitle)>
                
                <cfquery name="local.getplayerPotentialTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                select 	pp.PlayerPotentialTitle
                from	PlayerPotentials pp
                where	pp.PlayerPotentialID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#playerPotentialID#">
                </cfquery>
                
                <cfset QuerySetCell(local.result, "PlayerPotentialTitle", local.getplayerPotentialTitle.PlayerPotentialTitle)>
                
                <cfif ManofTheMatch>
                	<cfset QuerySetCell(local.result, "ManofTheMatch", "Yes")>
                <cfelse>
                	<cfset QuerySetCell(local.result, "ManofTheMatch", "No")>
                </cfif>
        </cfloop>
		
		<cfreturn local.result>
	</cffunction>
        
    <cffunction name="matchInsert" access="public" returntype="struct" hint="Trying to insert a new match into the database">
		<cfargument name="data" type="struct" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

        <cfset local.data = arguments.data>
        
        <cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
              
        <cfif local.data.IsHome>
        	<cfset local.score = local.data.scoreHome>
            <cfset local.otherscore = local.data.otherScoreHome>
        <cfelse>
        	<cfset local.score = local.data.otherScoreAway>
            <cfset local.otherscore = local.data.scoreAway>
        </cfif>
        <cfif local.data.IsHome>
        <cfset local.attendanceTotal = local.data.AttendanceStanding+local.data.AttendanceUncovered+local.data.AttendanceCovered+local.data.AttendanceMembers+local.data.AttendanceVIP>
        </cfif>
            
        <cflock name="newmatch" timeout="30" type="exclusive">
            <cftransaction action="begin">
                <cftry>
                    <cfquery datasource="#getFactory().get("session").model.get('SiteDatabase')#" name="local.insert">
                        insert into leaguematches
                            (MatchDate,
                            OpponentName,
                            IsHome,
                            DateAdded,
                            DateLastUpdated,
                            AddedByUserID,
                            UserID,
                            MatchResult,
                            Score,
                            OtherScore,
                            MatchType
                            <cfif local.data.IsHome>
                            ,AttendanceStanding,
                            AttendanceUncovered,
                            AttendanceCovered,
                            AttendanceMembers,
                            AttendanceVIP,
                            AttendanceTotal
                            </cfif>
                            ) 
                values 		(
                            #CreateODBCDateTime(local.data.matchdate)#,
                            <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.OpponentName#">,
                            <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.IsHome#">,
                            #CreateODBCDateTime(now())#,
                            #CreateODBCDateTime(now())#,
                            <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">,
                            <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">,
                            <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.MatchResult#">,
                            <cfqueryparam cfsqltype="cf_sql_char" value="#local.Score#">,
                            <cfqueryparam cfsqltype="cf_sql_char" value="#local.OtherScore#">,
                            <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.MatchType#">
                            <cfif arguments.data.IsHome>
                            ,<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.AttendanceStanding#">,
                            <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.AttendanceUncovered#">,
                            <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.AttendanceCovered#">,
                            <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.AttendanceMembers#">,
                            <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.AttendanceVIP#">,
                            <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.attendanceTotal#">
                            </cfif>
                            )
                    </cfquery>
                    
                    <cfset local.result.id = getFactory().get("databaseUtil").util.getLastMatchID(getFactory().get("session").model.get('SiteDatabase'), "leaguematches")>

                    <!--- now insert the players for the match --->
                    <cfset playersInsert(data=local.data,matchID=local.result.id)>
                    
                    <!--- now insert the team ratings --->
                    <cfset teamRatingInsert(data=local.data,matchID=local.result.id)>
                    
                    <cftransaction action="commit"/>
                    <cfset local.result.output = "New match added">
                    
                    <cfcatch type="any">
                        <cftransaction action="rollback"/>
                        <cfdump var="#cfcatch#">
                        <cfset local.result.success = false>
                        <cfset local.result.output = "Database error - please contact IT support">
                    </cfcatch>
                </cftry>
            </cftransaction>
        </cflock>
		
		<cfreturn local.result>
	</cffunction>
        
    <cffunction name="playersInsert" access="public" returntype="struct" hint="Adding data for a player when a match was added">
		<cfargument name="data" type="struct" required="true">
        <cfargument name="matchID" type="numeric" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

        <cfset local.data = arguments.data>
        <cfset local.result.success = true>
		
		<cftry>	
        	            
        	<!--- first loop through the stats --->
            <cfloop from="1" to="#arrayLen(local.data.allMatchPlayers)#" index="local.p">
            	<cfset local.playerID = #local.data.allMatchPlayers[local.p].playerID#>
                <cfset local.PositionID = #local.data.allMatchPlayers[local.p].PositionID#>
                <cfset local.PlayerExpectationID = #local.data.allMatchPlayers[local.p].PlayerExpectationID#>
                <cfset local.playerPotentialID = #local.data.allMatchPlayers[local.p].playerPotentialID#>
                <cfset local.stars = #local.data.allMatchPlayers[local.p].stars#>
                
                <cfset local.DidPlay = #local.data.allMatchPlayers[local.p].DidPlay#>
                <cfset local.ManofTheMatch = #local.data.allMatchPlayers[local.p].ManofTheMatch#>
                
                 <cfquery datasource="#getFactory().get("session").model.get('SiteDatabase')#" name="local.insertplayers">
                insert into LeagueMatchPlayers
                    (MatchID,
                    PlayerID,
                    PositionID,
                    stars,
                    PlayerExpectationID,
                    playerPotentialID,
                    DidPlay,
                    ManofTheMatch
                    ) 
        values 		(
                    <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.matchID#">,
                    <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.playerID#">,
                    <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.PositionID#">,
                    <cfqueryparam cfsqltype="cf_sql_char" value="#local.stars#">,
                    <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.PlayerExpectationID#">,
                    <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.playerPotentialID#">,
                    <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.DidPlay#">,
                    <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.ManofTheMatch#">
                    )
            	</cfquery>
                
            </cfloop>
           
			<cfcatch type="any">
                <cfset local.result.success = false>
                <cfrethrow>
            </cfcatch>
		</cftry>			
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getmatchPlayers" returntype="query" access="public" hint="returns players for a specific match">
		<cfargument name="userID" type="numeric" required="false" default="#getFactory().get('login').model.getUser().user.userID#">
        <cfargument name="matchID" type="numeric" required="false" default="0">
        <cfargument name="extraPlayersOnly" type="boolean" required="false" default="false">
        
		<cfset var local = structNew()>
		
		<cfquery name="local.playerdetails" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	*
            from	LeagueMatchPlayers lmp
            where	lmp.MatchID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.MatchID#">  
            <cfif arguments.extraPlayersOnly>
            and		lmp.PositionID > <cfqueryparam cfsqltype="cf_sql_numeric" value="15">
            </cfif>         
		</cfquery>
		
        <cfset local.result = QueryNew("PlayerID,PlayerFullName,PositionID,ManofTheMatch,playerPotentialID,playerExpectationTitle,DidPlayText,PlayerPotentialTitle","integer,varchar,varchar,varchar,varchar,varchar,varchar,varchar")>
        
        <cfloop query="local.playerdetails">
                                               
                <cfquery name="local.playername" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                    select	lp.firstname,
                            lp.lastname
                    from	LeaguePlayers lp
                    where	lp.playerID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#playerID#">            
                </cfquery>
               
                <cfset QueryAddRow(local.result, 1)>
                <cfset QuerySetCell(local.result, "PlayerID", PlayerID)>
                <cfset QuerySetCell(local.result, "PlayerFullName", "#local.playername.firstname# #local.playername.lastname#")>
                <cfset QuerySetCell(local.result, "PositionID", PositionID)>

                <cfset QuerySetCell(local.result, "playerPotentialID", playerPotentialID)>
                
                <cfquery name="local.getplayerExpectationTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                    select	pe.playerExpectationTitle
                    from	playerExpectations pe
                    where	pe.playerExpectationID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#playerExpectationID#">            
                </cfquery>
                
                <cfset QuerySetCell(local.result, "playerExpectationTitle", local.getplayerExpectationTitle.playerExpectationTitle)>
                
                <cfquery name="local.getplayerPotentialTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                    select	pp.playerPotentialTitle
                    from	playerPotentials pp
                    where	pp.playerPotentialID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#playerPotentialID#">            
                </cfquery>
                
                <cfset QuerySetCell(local.result, "playerPotentialTitle", local.getplayerPotentialTitle.playerPotentialTitle)>
                
                <cfif DidPlay>
                	<cfset QuerySetCell(local.result, "DidPlayText", "")>
                <cfelse>
                	<cfset QuerySetCell(local.result, "DidPlayText", "Did Not Play")>
                </cfif>
                <cfif ManofTheMatch>
                	<cfset QuerySetCell(local.result, "ManofTheMatch", "Yes")>
                <cfelse>
                	<cfset QuerySetCell(local.result, "ManofTheMatch", "No")>
                </cfif>
        </cfloop>
        
		<cfreturn local.result>
	</cffunction>
    

    <cffunction name="getmatchAttendance" returntype="query" access="public" hint="returns a specific match">
		<cfargument name="userID" type="numeric" required="false" default="#getFactory().get('login').model.getUser().user.userID#">
        <cfargument name="matchID" type="numeric" required="false" default="0">
		<cfset var local = structNew()>
		
		<cfquery name="local.matchattendance" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	lm.AttendanceStanding,
                    lm.AttendanceUncovered,
                    lm.AttendanceCovered,
                    lm.AttendanceMembers,
                    lm.AttendanceVIP
            from	LeagueMatches lm
            where	lm.MatchID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.MatchID#">
            <cfif arguments.userID neq 0>
            and		lm.userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.userID#">
            </cfif>
            
		</cfquery>
		
        <cfset local.result = QueryNew("MatchID,AttendanceTitle,AttendanceValue","integer,varchar,integer")>
        
        <cfloop query="local.matchattendance">
            	
                <cfset QueryAddRow(local.result, 1)>
                <cfset QuerySetCell(local.result, "MatchID", MatchID)>
                <cfset QuerySetCell(local.result, "AttendanceTitle", "Standing")>
                <cfset QuerySetCell(local.result, "AttendanceValue", AttendanceStanding)>
                
                <cfset QueryAddRow(local.result, 1)>
                <cfset QuerySetCell(local.result, "MatchID", MatchID)>
                <cfset QuerySetCell(local.result, "AttendanceTitle", "Uncovered")>
                <cfset QuerySetCell(local.result, "AttendanceValue", AttendanceUncovered)>
                
                <cfset QueryAddRow(local.result, 1)>
                <cfset QuerySetCell(local.result, "MatchID", MatchID)>
                <cfset QuerySetCell(local.result, "AttendanceTitle", "Covered")>
                <cfset QuerySetCell(local.result, "AttendanceValue", AttendanceCovered)>
                
                <cfset QueryAddRow(local.result, 1)>
                <cfset QuerySetCell(local.result, "MatchID", MatchID)>
                <cfset QuerySetCell(local.result, "AttendanceTitle", "Members")>
                <cfset QuerySetCell(local.result, "AttendanceValue", AttendanceMembers)>
                
			    <cfset QueryAddRow(local.result, 1)>
                <cfset QuerySetCell(local.result, "MatchID", MatchID)>
                <cfset QuerySetCell(local.result, "AttendanceTitle", "VIP")>
                <cfset QuerySetCell(local.result, "AttendanceValue", AttendanceVIP)>
                
        </cfloop>
        
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getMessage" access="public" returntype="string" hint="Returns title for a message">
		<cfargument name="messagetype" type="string" required="true" default="warning">
		<cfargument name="key" type="numeric" required="true">
		<cfargument name="messagepart" type="string" required="true" default="title">

		<cfset var local = structNew()>
		
		<cfif StructKeyExists(variables.messages[arguments.messagetype][arguments.key], arguments.messagepart)>
			<cfreturn variables.messages[arguments.messagetype][arguments.key][arguments.messagepart]>
		<cfelse>
			<cfreturn "">
		</cfif>
	</cffunction>
    
    <cffunction name="getTeamRatingsStats" returntype="query" access="public" hint="returns the query containing all team ratings stats">
    	<cfargument name="teamID" type="numeric" required="true" default="0">
		
		<cfset var local = structNew()>
        
		<cfquery name="local.getTeamRatingsStats" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	mtrs.statID,
                    mtrs.statTitle
			from	MatchTeamRatingStats mtrs
		</cfquery>
		
		<cfreturn local.getTeamRatingsStats>
	</cffunction>
    
    <cffunction name="checkExpectationexists" returntype="numeric" access="public" hint="returns the id of a specific expectation text bit if it exists">
    	<cfargument name="ExpectationTitle" type="string" required="true" default="">
		
		<cfset var local = structNew()>
        
		<cfquery name="local.checkExpectationexists" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	pe.PlayerExpectationID
			from	PlayerExpectations pe
			where	pe.PlayerExpectationTitle = <cfqueryparam cfsqltype="cf_sql_char" value="#trim(arguments.ExpectationTitle)#">
		</cfquery>
		
        <cfif local.checkExpectationexists.recordcount>
        	<cfset local.PlayerExpectationID = local.checkExpectationexists.PlayerExpectationID>
        <cfelse>
        	<cfset local.PlayerExpectationID = 0>
        </cfif>
        
		<cfreturn local.PlayerExpectationID>
	</cffunction>
    
    <cffunction name="checkPotentialexists" returntype="numeric" access="public" hint="returns the id of a specific expectation text bit">
    	<cfargument name="potentialTitle" type="string" required="true" default="">
		
		<cfset var local = structNew()>
        
		<cfquery name="local.checking" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	p.PotentialID
			from	Potentials p
			where	p.PotentialTitle = <cfqueryparam cfsqltype="cf_sql_char" value="#trim(arguments.potentialTitle)#">
		</cfquery>

        <cfif local.checking.recordcount>
        	<cfset local.PlayerPotentialID = local.checking.PotentialID>
        <cfelse>
        	<cfset local.PlayerPotentialID = 0>
        </cfif>
        
		<cfreturn local.PlayerPotentialID>
	</cffunction>
    
     <cffunction name="getmatchTeamRatings" returntype="array" access="public" hint="returns a specific match's team ratings">
        <cfargument name="matchID" type="numeric" required="false" default="0">
		<cfset var local = structNew()>
		
		<cfquery name="local.matchTeamRatingsdetails" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	lmts.MatchTeamStatID,
            		lmts.StatID,
                    lmts.MatchID,
                    lmts.StatLevel
            from	LeagueMatchTeamStats lmts
            where	lmts.MatchID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.MatchID#">            
		</cfquery>
        
        <cfset local.result = arrayNew(1)>
        
        <cfloop query="local.matchTeamRatingsdetails">
        	
            <cfquery name="local.getStatTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                select	mtrs.StatTitle
                from	MatchTeamRatingStats mtrs
                where	mtrs.StatID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#StatID#">            
            </cfquery>
            
        	<cfset local.teamdatabit = structNew()>
        	<cfset local.teamdatabit.name = local.getStatTitle.StatTitle>
			<cfset local.teamdatabit.value = StatLevel>
            <cfset local.teamdatabit.statID = StatID>
            
            <cfset ArrayAppend(local.result,local.teamdatabit)>
        </cfloop>
        
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="teamRatingInsert" access="public" returntype="struct" hint="">
		<cfargument name="data" type="struct" required="true">
        <cfargument name="matchID" type="numeric" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

        <cfset local.data = arguments.data>
		
		<cftry>	

            <cfset local.data.availableTeamRatingsStats = getModel().getTeamRatingsStats()>
                <!--- first loop through the stats --->
                <cfloop query="local.data.availableTeamRatingsStats">
                    <cfset local.statID = #statID#>
                    <cfset local.StatLevel = #Evaluate("local.data.MatchTeamRatings_#local.statID#")#>
                
                 <cfquery datasource="#getFactory().get("session").model.get('SiteDatabase')#" name="local.insertteamRatings">
                insert into LeagueMatchTeamStats
                            (StatID,
                            MatchID,
                            StatLevel
                            ) 
                values 		(
                			<cfqueryparam cfsqltype="cf_sql_numeric" value="#local.statID#">,
                            <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.matchID#">,
                            <cfqueryparam cfsqltype="cf_sql_char" value="#local.StatLevel#">
                            )
            	</cfquery>

                </cfloop>
                
			<cfcatch type="any">
                <cfrethrow>
            </cfcatch>
		</cftry>			
		
		<cfreturn local.result>
	</cffunction>
    
</cfcomponent>