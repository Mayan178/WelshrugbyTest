<cfcomponent name="LeagueReports" extends="parent" hint="Model, queries and logic for league reports">
	<cffunction name="init" returntype="LeagueReports" access="public">
		<cfset var local = structNew()>

		<cfset super.init()>
        <!--- load in any messages --->
		<cfset local.cfcPath = getDirectoryFromPath(getCurrentTemplatePath())>
		<cffile action="read" file="#local.cfcPath#..\..\config\#application.core.get('configFolder')#\Leaguereportmessages.xml" variable="local.rawData">
		<cfset local.xml = xmlParse(local.rawData)>
		
		<cfset variables.messages = StructNew()>
		
		<cfloop from="1" to="#ArrayLen(local.xml.Leaguereportmessages.message)#" index="local.m">
			<cfloop list="#StructKeyList(local.xml.Leaguereportmessages.message[local.m].xmlAttributes)#" index="local.key">
				
				<cfset local.messages = ArrayNew(1)>
				
				<cfloop from="1" to="#ArrayLen(local.xml.Leaguereportmessages.message[local.m].container)#" index="local.c">
					<cfset local.message = structNew()>
					<cfif NOT StructKeyExists(local.message,"title")>
						<cfset StructInsert(local.message, "title",local.xml.Leaguereportmessages.message[local.m].container[local.c].xmlAttributes.title)>
					</cfif>
					<cfif NOT StructKeyExists(local.message,"summary")>
						<cfset StructInsert(local.message, "summary",local.xml.Leaguereportmessages.message[local.m].container[local.c].xmlAttributes.summary)>
					</cfif>

					<cfset ArrayAppend(local.messages, local.message)>
				</cfloop>

				<cfif NOT StructKeyExists(variables.messages,local.xml.Leaguereportmessages.message[local.m].xmlAttributes[local.key])>
					<cfset StructInsert(variables.messages, local.xml.Leaguereportmessages.message[local.m].xmlAttributes[local.key], local.messages)>
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfreturn this/>
	</cffunction>    
 	
	<cffunction name="getPositionAverage" returntype="query" access="public" hint="Returning list of players in a specific position, as well as their average stats for that position">
		<cfargument name="positionID" type="numeric" required="false" default="0">
        
		<cfset var local = structNew()>
		
        <cfset local.mymatches = getFactory().get("LeagueMatches").model.getMyMatches()>
        
		<cfquery name="local.players" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	distinct p.firstname,
            		p.lastname,
                    p.playerID
            from	LeagueMatchPlayers mp
            INNER JOIN	LeaguePlayers p
            ON		mp.playerID = p.playerID
            where	mp.positionID = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.positionID#">
            and		mp.didplay = <cfqueryparam cfsqltype="CF_SQL_BIT" value="1">
            and		mp.matchID IN (<cfqueryparam cfsqltype="cf_sql_char" value="#valuelist(local.mymatches.matchID)#" list="true">)
		</cfquery>
        
        <cfset local.result = QueryNew("PlayerID,FirstName,LastName,NoTimesInPosition,NoTimesPlayed,AverageStarsInPosition","integer,varchar,varchar,integer,integer,varchar")>
        
        <cfloop query="local.players">
        	<cfset QueryAddRow(local.result, 1)>
			<cfset QuerySetCell(local.result, "PlayerID", PlayerID)>
            <cfset QuerySetCell(local.result, "FirstName", FirstName)>
            <cfset QuerySetCell(local.result, "LastName", LastName)>
            
            <cfquery name="local.notimes" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                select	count(*) AS NoOfTimes
                from	LeagueMatchPlayers lmp
                where	lmp.playerID = <cfqueryparam cfsqltype="cf_sql_char" value="#PlayerID#">
                and		lmp.positionID = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.positionID#">
                and 	lmp.didplay = <cfqueryparam cfsqltype="CF_SQL_BIT" value="1">
                and		lmp.matchID IN (<cfqueryparam cfsqltype="cf_sql_char" value="#valuelist(local.mymatches.matchID)#" list="true">)
            </cfquery>
                        
            <cfquery name="local.notimestotal" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                select	count(*) AS NoOfTimesTotal
                from	LeagueMatchPlayers lmp
                where	lmp.playerID = <cfqueryparam cfsqltype="cf_sql_char" value="#PlayerID#">
                and 	lmp.didplay = <cfqueryparam cfsqltype="CF_SQL_BIT" value="1">
                and		lmp.matchID IN (<cfqueryparam cfsqltype="cf_sql_char" value="#valuelist(local.mymatches.matchID)#" list="true">)
            </cfquery>
                                    
            <cfset QuerySetCell(local.result, "NoTimesInPosition", local.notimes.NoOfTimes)>
			<cfset QuerySetCell(local.result, "NoTimesPlayed", local.notimestotal.NoOfTimesTotal)>
            
            <cfquery name="local.getAverageStarsInPosition" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                select	lmp.stars,
                		lmp.statLevelID
                from	LeagueMatchPlayers lmp
                where	lmp.playerID = <cfqueryparam cfsqltype="cf_sql_char" value="#PlayerID#">
                and		lmp.positionID = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.positionID#">
                and 	lmp.didplay = <cfqueryparam cfsqltype="CF_SQL_BIT" value="1">
                and		lmp.matchID IN (<cfqueryparam cfsqltype="cf_sql_char" value="#valuelist(local.mymatches.matchID)#" list="true">)
            </cfquery>
                
			<cfset local.AverageStarsdb = 0>
            <cfloop query="local.getAverageStarsInPosition">
            	<!--- new way --->
                <cfif stars neq 0>
					<cfset local.AverageStarsdb = local.AverageStarsdb+stars>
                <!--- old way --->
                <cfelse>
                	<cfset local.stars = (statLevelID-1)/2>
                	<cfset local.AverageStarsdb = local.AverageStarsdb+local.stars>
                </cfif>
            </cfloop>
            <cfset local.AverageStarsdb = local.AverageStarsdb/local.getAverageStarsInPosition.recordcount>
            
			<cfset local.averageStars = int(local.AverageStarsdb)>
            <cfset local.averageStarsremains = local.AverageStarsdb-local.averageStars>
            
            <cfif local.averageStarsremains lte "0.25">
                <cfset local.averageStarsFinal = local.averageStars>
            <cfelseif local.averageStarsremains gt "0.25" and local.averageStarsremains lte "0.75">
                <cfset local.averageStarsFinal = local.averageStars+0.5>
            <cfelseif local.averageStarsremains gt "0.75">
                <cfset local.averageStarsFinal = local.averageStars+1>
            </cfif>
            
            <cfif local.averageStarsFinal lt 10>
                <cfset local.averageStarsFinal = "0#local.averageStarsFinal#">
            </cfif>
            

            <cfset QuerySetCell(local.result, "AverageStarsInPosition", local.averageStarsFinal)>
            <!---<cfset QuerySetCell(local.result, "AverageStatInPositionTitle", local.getStatTitle.LevelTitle)>--->
        </cfloop>
        
        <cfquery dbtype="query" name="local.resultinOrder">
            select	*	  
            from	[local].result
            order by AverageStarsInPosition DESC
        </cfquery>
                
		<cfreturn local.resultinOrder>
	</cffunction>
        
    <cffunction name="getPlayerAverage" returntype="query" access="public" hint="returns information about a specific player and their positions with stats">
		<cfargument name="playerID" type="numeric" required="false" default="0">
        
		<cfset var local = structNew()>
		
        <cfset local.mymatches = getFactory().get("LeagueMatches").model.getMyMatches()>
		<cfquery name="local.player" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	lp.playerID,
            		lp.firstname,
            		lp.lastname
            from	LeaguePlayers lp
            where	lp.playerID = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.playerID#">
		</cfquery>
		
        <cfset local.result = QueryNew("PlayerID,FirstName,LastName,PositionID,PositionTitle,NoTimesPosition,NomanofTheMatch,NoTimesPotentialReachedInPosition,NoTimesPotentialNotReachedInPosition,AverageStarsInPosition","integer,varchar,varchar,integer,varchar,integer,integer,varchar,varchar,varchar")>
        
        <cfloop query="local.player">
            
            <cfset local.PlayerID = PlayerID>
            <cfset local.FirstName = FirstName>
            <cfset local.LastName = LastName>
            
            <cfquery name="local.positionsForPlayer" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                select	distinct lmp.positionID
                from	LeagueMatchPlayers lmp
                where	lmp.playerID = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.PlayerID#">
                and		lmp.didPlay = <cfqueryparam cfsqltype="CF_SQL_BIT" value="1">
                and		lmp.matchID IN (<cfqueryparam cfsqltype="cf_sql_char" value="#valuelist(local.mymatches.matchID)#" list="true">)
            </cfquery>
            
            <cfloop query="local.positionsForPlayer">
				<cfset QueryAddRow(local.result, 1)>
                <cfset QuerySetCell(local.result, "PlayerID", local.PlayerID)>
                <cfset QuerySetCell(local.result, "FirstName", local.FirstName)>
                <cfset QuerySetCell(local.result, "LastName", local.LastName)>
                
                <cfquery name="local.getPositionTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                    select	p.PositionTitle
                    from	Positions p
                    where	p.PositionID = <cfqueryparam cfsqltype="cf_sql_char" value="#PositionID#">
                </cfquery>
                
                <cfset QuerySetCell(local.result, "PositionID", PositionID)>
                <cfset QuerySetCell(local.result, "PositionTitle", local.getPositionTitle.PositionTitle)>    
                
                <cfquery name="local.NoTimesPosition" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                    select	count(*) AS NoTimesPosition
                    from	LeagueMatchPlayers lmp
                    where	lmp.playerID = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.PlayerID#">
                    and		lmp.didPlay = <cfqueryparam cfsqltype="CF_SQL_BIT" value="1">
                    and		lmp.matchID IN (<cfqueryparam cfsqltype="cf_sql_char" value="#valuelist(local.mymatches.matchID)#" list="true">)
                    and		lmp.positionID = <cfqueryparam cfsqltype="cf_sql_char" value="#positionID#">
                </cfquery>
                
                <cfset QuerySetCell(local.result, "NoTimesPosition", local.NoTimesPosition.NoTimesPosition)>   
                
                <cfquery name="local.manOfMatchInPosition" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                    select	count(*) AS NoManOfMatchInPosition
                    from	LeagueMatchPlayers lmp
                    where	lmp.playerID = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.PlayerID#">
                    and		lmp.didPlay = <cfqueryparam cfsqltype="CF_SQL_BIT" value="1">
                    and		lmp.matchID IN (<cfqueryparam cfsqltype="cf_sql_char" value="#valuelist(local.mymatches.matchID)#" list="true">)
                    and		lmp.positionID = <cfqueryparam cfsqltype="cf_sql_char" value="#positionID#">
                    and		lmp.manofTheMatch = <cfqueryparam cfsqltype="cf_sql_char" value="1">
                </cfquery>
                
                <cfset QuerySetCell(local.result, "NomanofTheMatch", local.manOfMatchInPosition.NoManOfMatchInPosition)>
                
                <cfquery name="local.playerpotentialReached" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                    select	count(*) AS NoTimesPotentialReachedInPosition
                    from	LeagueMatchPlayers lmp
                    where	lmp.playerID = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.PlayerID#">
                    and		lmp.didPlay = <cfqueryparam cfsqltype="CF_SQL_BIT" value="1">
                    and		lmp.matchID IN (<cfqueryparam cfsqltype="cf_sql_char" value="#valuelist(local.mymatches.matchID)#" list="true">)
                    and		lmp.positionID = <cfqueryparam cfsqltype="cf_sql_char" value="#positionID#">
                    and		lmp.playerPotentialID = <cfqueryparam cfsqltype="cf_sql_char" value="3">
                </cfquery>
                
                <cfset QuerySetCell(local.result, "NoTimesPotentialReachedInPosition", local.playerpotentialReached.NoTimesPotentialReachedInPosition)>
                
                <cfquery name="local.playerpotentialNotReached" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                    select	count(*) AS NoTimesPotentialNotReachedInPosition
                    from	LeagueMatchPlayers lmp
                    where	lmp.playerID = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.PlayerID#">
                    and		lmp.didPlay = <cfqueryparam cfsqltype="CF_SQL_BIT" value="1">
                    and		lmp.matchID IN (<cfqueryparam cfsqltype="cf_sql_char" value="#valuelist(local.mymatches.matchID)#" list="true">)
                    and		lmp.positionID = <cfqueryparam cfsqltype="cf_sql_char" value="#positionID#">
                    and		lmp.playerPotentialID = <cfqueryparam cfsqltype="cf_sql_char" value="2">
                </cfquery>
                
                <cfset QuerySetCell(local.result, "NoTimesPotentialNotReachedInPosition", local.playerpotentialNotReached.NoTimesPotentialNotReachedInPosition)>
                
                
                <cfquery name="local.getstars" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                    select	stars,statLevelID
                    from	LeagueMatchPlayers lmp
                    where	lmp.playerID = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.PlayerID#">
                    and		lmp.didPlay = <cfqueryparam cfsqltype="CF_SQL_BIT" value="1">
                    and		lmp.matchID IN (<cfqueryparam cfsqltype="cf_sql_char" value="#valuelist(local.mymatches.matchID)#" list="true">)
                    and		lmp.positionID = <cfqueryparam cfsqltype="cf_sql_char" value="#positionID#">
                </cfquery>
                
                <cfset local.averageStarsdb = 0>
                <cfloop query="local.getstars">
                	<!--- new way --->
					<cfif stars neq 0>
                        <cfset local.averageStarsdb = local.averageStarsdb+stars>
					<!--- old way --->
                    <cfelse>
                        <cfset local.stars = (statLevelID-1)/2>
                        <cfset local.averageStarsdb = local.averageStarsdb+local.stars>
                    </cfif>
                </cfloop>
                
                <cfset local.averageStars = int(local.averageStarsdb/local.getstars.recordcount)>
                <cfset local.averageStarsremains = (local.averageStarsdb/local.getstars.recordcount)-local.averageStars>
                
                <cfif local.averageStarsremains lte "0.25">
					<cfset local.averageStarsFinal = local.averageStars>
                <cfelseif local.averageStarsremains gt "0.25" and local.averageStarsremains lte "0.75">
                    <cfset local.averageStarsFinal = local.averageStars+0.5>
                <cfelseif local.averageStarsremains gt "0.75">
                    <cfset local.averageStarsFinal = local.averageStars+1>
                </cfif>
                
                <cfif local.averageStarsFinal lt 10>
					<cfset local.averageStarsFinal = "0#local.averageStarsFinal#">
                </cfif>
                
                <cfset QuerySetCell(local.result, "AverageStarsInPosition", local.averageStarsFinal)>
        	</cfloop>        
        </cfloop>

        <cfquery dbtype="query" name="local.resultinOrder">
            select	*	  
            from	[local].result
            order by PositionID ASC
        </cfquery>
        
		<cfreturn local.resultinOrder>
	</cffunction>
        
    <cffunction name="getAttendanceStanding" returntype="query" access="public" hint="returns information about match standing attendance">
		<cfargument name="playerID" type="numeric" required="false" default="0">
        
		<cfset var local = structNew()>
		
        <cfset local.mymatches = getFactory().get("LeagueMatches").model.getMyMatches(IsHome = true)>
		
        <cfset local.result = QueryNew("MatchDate,AttendanceStanding","date,integer")>
        
        <cfloop query="local.mymatches">
            <cfset QueryAddRow(local.result, 1)>
			<cfset QuerySetCell(local.result, "MatchDate", "#MatchDate#")>
            <cfset QuerySetCell(local.result, "AttendanceStanding", AttendanceStanding)>
        </cfloop>

        <cfreturn local.result>
	</cffunction>
    
    <cffunction name="getAttendanceUncovered" returntype="query" access="public" hint="returns information about match uncovered attendance">
		<cfargument name="playerID" type="numeric" required="false" default="0">
        
		<cfset var local = structNew()>
		
        <cfset local.mymatches = getFactory().get("LeagueMatches").model.getMyMatches(IsHome = true)>
		
        <cfset local.result = QueryNew("MatchDate,AttendanceUncovered","date,integer")>
        
        <cfloop query="local.mymatches">
            <cfset QueryAddRow(local.result, 1)>
			<cfset QuerySetCell(local.result, "MatchDate", "#MatchDate#")>
            <cfset QuerySetCell(local.result, "AttendanceUncovered", AttendanceUncovered)>
        </cfloop>
        
        <cfreturn local.result>
	</cffunction>
    
    <cffunction name="getAttendanceCovered" returntype="query" access="public" hint="returns information about match covered attendance">
		<cfargument name="playerID" type="numeric" required="false" default="0">
        
		<cfset var local = structNew()>
		
        <cfset local.mymatches = getFactory().get("LeagueMatches").model.getMyMatches(IsHome = true)>
		
        <cfset local.result = QueryNew("MatchDate,AttendanceCovered","date,integer")>
        
        <cfloop query="local.mymatches">
            <cfset QueryAddRow(local.result, 1)>
			<cfset QuerySetCell(local.result, "MatchDate", "#MatchDate#")>
            <cfset QuerySetCell(local.result, "AttendanceCovered", AttendanceCovered)>
        </cfloop>
        
        <cfreturn local.result>
	</cffunction>
    
    <cffunction name="getAttendanceMembers" returntype="query" access="public" hint="returns information about match members attendance">
		<cfargument name="playerID" type="numeric" required="false" default="0">
        
		<cfset var local = structNew()>
		
        <cfset local.mymatches = getFactory().get("LeagueMatches").model.getMyMatches(IsHome = true)>
		
        <cfset local.result = QueryNew("MatchDate,AttendanceMembers","date,integer")>
        
        <cfloop query="local.mymatches">
            <cfset QueryAddRow(local.result, 1)>
			<cfset QuerySetCell(local.result, "MatchDate", "#MatchDate#")>
            <cfset QuerySetCell(local.result, "AttendanceMembers", AttendanceMembers)>
        </cfloop>
        
        <cfreturn local.result>
	</cffunction>
    
    <cffunction name="getAttendanceVIP" returntype="query" access="public" hint="returns information about match VIP attendance">
		<cfargument name="playerID" type="numeric" required="false" default="0">
        
		<cfset var local = structNew()>
		
        <cfset local.mymatches = getFactory().get("LeagueMatches").model.getMyMatches(IsHome = true)>
		
        <cfset local.result = QueryNew("MatchDate,AttendanceVIP","date,integer")>
        
        <cfloop query="local.mymatches">
            <cfset QueryAddRow(local.result, 1)>
			<cfset QuerySetCell(local.result, "MatchDate", "#MatchDate#")>
            <cfset QuerySetCell(local.result, "AttendanceVIP", AttendanceVIP)>
        </cfloop>
        
        <cfreturn local.result>
	</cffunction>
    
    <cffunction name="getPotentialAttendances" returntype="query" access="public" hint="returns information about match potential attendance">
        <cfargument name="userDatabase" type="string" required="false" default="#getFactory().get("session").model.get('SiteDatabase')#">
        <cfargument name="userID" type="string" required="false" default="#getFactory().get('login').model.getUser().user.UserID#">
        <cfargument name="BRTeamID" type="string" required="false" default="#getFactory().get("session").model.get('TeamID')#">
        
		<cfset var local = structNew()>
		
        <cfquery name="local.clubhistory" datasource="#arguments.userDatabase#">
			select	*
			from	BRTeamsHistory bth
			where	bth.AddedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.userID#">
            and		bth.BRTeamID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.BRTeamID#">
		</cfquery>
		
        <cfset local.result = QueryNew("DateAdded,StadiumCorporate,StadiumCovered,StadiumMembers,StadiumStanding,StadiumUncovered","date,integer,integer,integer,integer,integer")>
        
        <cfloop query="local.clubhistory">
            <cfset QueryAddRow(local.result, 1)>
			<cfset QuerySetCell(local.result, "DateAdded", "#DateAdded#")>
            <cfset QuerySetCell(local.result, "StadiumCorporate", StadiumCorporate)>
            <cfset QuerySetCell(local.result, "StadiumCovered", StadiumCovered)>
            <cfset QuerySetCell(local.result, "StadiumMembers", StadiumMembers)>
            <cfset QuerySetCell(local.result, "StadiumStanding", StadiumStanding)>
            <cfset QuerySetCell(local.result, "StadiumUncovered", StadiumUncovered)>
        </cfloop>
        <cfreturn local.result>
	</cffunction>
        
    
    
    <cffunction name="getFirstSeason" returntype="numeric" access="public" hint="returns the first season">
        
		<cfset var local = structNew()>
		<cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
        
		<cfquery name="local.getthefirstseason" datasource="#getFactory().get("session").model.get('SiteDatabase')#" maxrows="1">
			select	lph.brt_season
            from	LeaguePlayersHistory lph
            where	lph.AddedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
            order by lph.brt_season ASC
		</cfquery>
        
        <cfif local.getthefirstseason.recordcount>
        	<cfset local.firstseason = local.getthefirstseason.brt_season>
        <cfelse>
        	<cfset local.firstseason = "0">
        </cfif>
		<cfreturn local.firstseason>
	</cffunction>
    
    <cffunction name="getLastSeason" returntype="numeric" access="public" hint="returns the last season">
        
		<cfset var local = structNew()>
		<cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
        
		<cfquery name="local.gettheLastSeason" datasource="#getFactory().get("session").model.get('SiteDatabase')#" maxrows="1">
			select	lph.brt_season
            from	LeaguePlayersHistory lph
            where	lph.AddedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
            order by lph.brt_season DESC
		</cfquery>
        
        <cfif local.gettheLastSeason.recordcount>
        	<cfset local.lastseason = local.gettheLastSeason.brt_season>
        <cfelse>
        	<cfset local.lastseason = "0">
        </cfif>
		<cfreturn local.lastseason>
	</cffunction>
    
    <cffunction name="getcurrentSeason" returntype="string" access="public" hint="returns the current season">
        
		<cfset var local = structNew()>
		<cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
        
		<cfquery name="local.getcurrentseason" datasource="#getFactory().get("session").model.get('SiteDatabase')#" maxrows="1">
			select	lph.brt_season
            from	LeaguePlayersHistory lph
            where	lph.AddedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
            order by lph.brt_season DESC
		</cfquery>
        
        <cfif local.getcurrentseason.recordcount>
        	<cfset local.currentseason = local.getcurrentseason.brt_season>
        <cfelse>
        	<cfset local.currentseason = "0">
        </cfif>
		<cfreturn local.currentseason>
	</cffunction>
    
    <cffunction name="getFirstRound" returntype="string" access="public" hint="returns the first round of the current season">
        
		<cfset var local = structNew()>
		<cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
        
        <cfset local.currentSeason = getcurrentSeason()>
        
		<cfquery name="local.getthefirstround" datasource="#getFactory().get("session").model.get('SiteDatabase')#" maxrows="1">
			select	lph.brt_round
            from	LeaguePlayersHistory lph
            where	lph.AddedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
            and		lph.brt_season = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.currentseason#">
            order by lph.brt_round ASC
		</cfquery>
        
        <cfif local.getthefirstround.recordcount>
        	<cfset local.firstround = local.getthefirstround.brt_round>
        <cfelse>
        	<cfset local.firstround = "0">
        </cfif>
        
		<cfreturn local.firstround>
	</cffunction>
    
    <cffunction name="getLastRound" returntype="string" access="public" hint="returns the last round of the current season">
        
		<cfset var local = structNew()>
		<cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
        
        <cfset local.currentSeason = getcurrentSeason()>
        
		<cfquery name="local.getthelastround" datasource="#getFactory().get("session").model.get('SiteDatabase')#" maxrows="1">
			select	lph.brt_round
            from	LeaguePlayersHistory lph
            where	lph.AddedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
            and		lph.brt_season = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.currentseason#">
            order by lph.brt_round DESC
		</cfquery>
        
        <cfif local.getthelastround.recordcount>
        	<cfset local.lastround = local.getthelastround.brt_round>
        <cfelse>
        	<cfset local.lastround = "0">
        </cfif>
        
		<cfreturn local.lastround>
	</cffunction>
    
    <cffunction name="getMatchPlayerDetails" returntype="query" access="public" hint="returns a list of all the matches added by the user">
    	<cfargument name="matchID" type="numeric" required="false" default="0">
		<cfargument name="userID" type="numeric" required="false" default="#getFactory().get('login').model.getUser().user.userID#">
        
		<cfset var local = structNew()>
		
		<cfquery name="local.result" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	m.MatchID,
            		m.matchDate,
                    m.opponentName,
            		mp.*,
                    p.firstname,
                    p.lastname,
                    pp.PlayerPotentialTitle,
                    pe.PlayerExpectationTitle
            from	((((LeagueMatchPlayers mp
            inner join LeagueMatches m
            ON		mp.MatchID = m.MatchID)
            inner join LeaguePlayers p
            ON		mp.playerID = p.playerID)
            inner join PlayerPotentials pp
            ON		mp.PlayerPotentialID = pp.PlayerPotentialID)
            inner join PlayerExpectations pe
            ON		mp.PlayerExpectationID = pe.PlayerExpectationID)
            where	m.MatchID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.matchID#">
            <cfif arguments.userID neq 0>
            and		m.userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.userID#">
            </cfif>   
            order by positionID         
		</cfquery>
		
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
    
    <cffunction name="validatematchcomparison" access="public" returntype="struct">
		<cfargument name="data" type="struct" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		<cfset local.result.errors = ArrayNew(1)>

		<cfset local.valUtil = getFactory().get("validationUtil").util>
		
		<cfif arguments.data.match1 eq arguments.data.match2>
            <cfset ArrayAppend(local.result.errors, "You selected the same match")>
        </cfif>
       
		<cfreturn local.result>
	</cffunction>
    
</cfcomponent>