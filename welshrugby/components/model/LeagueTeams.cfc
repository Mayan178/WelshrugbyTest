<cfcomponent name="leagueteams" extends="parent" hint="Model, queries and logic for league teams">

	<cffunction name="init" returntype="leagueteams" access="public">
		<cfset var local = structNew()>

		<cfset super.init()>
		
		<cfset local.cfcPath = getDirectoryFromPath(getCurrentTemplatePath())>
		<cffile action="read" file="#local.cfcPath#..\..\config\#application.core.get('configFolder')#\LeagueTeamMessages.xml" variable="local.rawData">
		<cfset local.xml = xmlParse(local.rawData)>
		
		<cfset variables.messages = StructNew()>
		
		<cfloop from="1" to="#ArrayLen(local.xml.leagueteammessages.message)#" index="local.m">
			<cfloop list="#StructKeyList(local.xml.leagueteammessages.message[local.m].xmlAttributes)#" index="local.key">
				<cfset local.messages = ArrayNew(1)>

				<cfloop from="1" to="#ArrayLen(local.xml.leagueteammessages.message[local.m].container)#" index="local.c">
					  <cfset local.message = structNew()>
						<cfif NOT StructKeyExists(local.message,"title")>
							<cfset StructInsert(local.message, "title",local.xml.leagueteammessages.message[local.m].container[local.c].xmlAttributes.title)>
						</cfif>
						<cfif NOT StructKeyExists(local.message,"summary")>
							<cfset StructInsert(local.message, "summary",local.xml.leagueteammessages.message[local.m].container[local.c].xmlAttributes.summary)>
						</cfif>
						
						<cfset ArrayAppend(local.messages, local.message)>
				</cfloop>
				
				<cfif NOT StructKeyExists(variables.messages,local.xml.leagueteammessages.message[local.m].xmlAttributes[local.key])>
					<cfset StructInsert(variables.messages, local.xml.leagueteammessages.message[local.m].xmlAttributes[local.key], local.messages)>
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfreturn this/>
	</cffunction>

    <cffunction name="deleteTeam" access="public" returntype="struct" hint="To delete a team's data from the db">
		<cfargument name="teamID" type="numeric" required="true">
		
        <cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        <cfset local.result.success = true>
        <cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>

        
		<cftry>
			<cfquery name="local.delete" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
				delete 
                from 	LeagueTeams
				where 	teamID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.teamID#">
                and		userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
			</cfquery>
            
            <cfquery name="local.deletefromplayers" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
				delete 
                from 	LeagueTeamPlayers
				where 	teamID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.teamID#">
			</cfquery>
            
            
            <cfquery name="local.deletefromcomments" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
				delete 
                from 	LeagueTeamComments
				where 	teamID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.teamID#">
			</cfquery>
            
			<cfcatch type="any">
                
				<cfset local.result.success = false>
                <cfset local.result.output = "Database error - please contact IT support">
			</cfcatch>
		</cftry>
        <cfreturn local.result>
	</cffunction>

    <cffunction name="getTeamDetails" access="public" returntype="query" hint="Getting a specific team's details">
		<cfargument name="teamID" type="numeric" required="true">
		
        <cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        
		<cftry>
                <cfquery name="local.result" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                    select  lt.teamTitle,
                            lt.teamID
                    from	LeagueTeams lt
                    where 	lt.teamID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.teamID#">
               </cfquery>
                
			<cfcatch type="any">
                <cfdump var="#cfcatch#">
				<cfset local.result.success = false>
                <cfset local.result.output = "Database error - please contact IT support">
			</cfcatch>
		</cftry>
        <cfreturn local.result>
	</cffunction>

    <cffunction name="createTeamFile" access="public" returntype="struct" hint="Writing a jSON file containing a specific team's details">
		<cfargument name="teamID" type="numeric" required="true">
		
        <cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		<cftry>
            <cfset local.fullTeamInfo = StructNew()>

            <!--- get general team info --->
            <cfset local.teamInfo = #getTeamDetails(arguments.teamID)#>
            <cfloop query="local.teamInfo">
                <cfset local.fullTeamInfo.TeamID = #TeamID#>
                <cfset local.fullTeamInfo.TeamTitle = #TeamTitle#>
            </cfloop>

            <!--- now get the player information for the team --->
            <cfset local.players = ArrayNew(1)>
            <cfset local.teamPlayersInfo = #getFactory().get('LeaguePlayers').model.getaspecificTeam(teamID=arguments.teamID)#>
            <cfset local.myPlayerColumns = local.teamPlayersInfo.columnList>
            
            <cfloop query="local.teamPlayersInfo">
                <cfset local.individualPlayer= StructNew()>
                <cfloop array = "#local.teamPlayersInfo.getColumnList()#" index = columnName>
                    <cfset local.individualPlayer[columnName] = #local.teamPlayersInfo[columnName][currentrow]#>
                </cfloop>
                <cfset ArrayAppend(local.players, local.individualPlayer)>
            </cfloop>

            <cfset local.fullTeamInfo.TeamPlayers = local.players>

            <cfset local.myJSON = SerializeJSON(local.fullTeamInfo)>
            <cfset local.newFileName = "Team_#local.fullTeamInfo.TeamID#_#DateFormat(Now() , "dd-mm-yy-hh-mm-ss")#.json">

            <!--- writing the file onto the server --->
            <cfoutput>
                <cffile action = "write" 
                file = "#getFactory().getSetting("jSONDataPath")#\#local.newFileName#" 
                output = "#local.myJSON#">
            </cfoutput>

            <cfset local.result.fileName = local.newFileName>
                
			<cfcatch type="any">
                <cfdump var="#cfcatch#">
				<cfset local.result.success = false>
                <cfset local.result.output = "Database error - please contact IT support">
			</cfcatch>
		</cftry>
        <cfreturn local.result>
	</cffunction>
    
    <cffunction name="updateTeam" access="public" returntype="struct" hint="To update a specific team's details">
		<cfargument name="data" type="struct" required="true">
		
        <cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        <cfset local.result.success = true>
        <cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
        
		<cftry>
                <cfquery name="local.edit" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                    update	LeagueTeams
                    set		teamTitle = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.teamTitle#">
                    where 	teamID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.teamID#">
                    and		userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
                </cfquery>
                
			<cfcatch type="any">
                <cfdump var="#cfcatch#">
				<cfset local.result.success = false>
                <cfset local.result.output = "Database error - please contact IT support">
			</cfcatch>
		</cftry>
        <cfreturn local.result>
	</cffunction>

    <cffunction name="insertTeam" access="public" returntype="struct" hint="To add a new team to the db">
        <cfargument name="data" type="struct" required="true">
		
        <cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        <cfset local.result.success = true>
        <cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
        
		<cftry>
        	<!--- first of all, make sure the name does not yet exist in db for the same user --->
            <cfquery name="local.checkTeamTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                select  lt.teamID
                from    LeagueTeams lt
                where   lt.teamTitle = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.teamTitle#">
                and     lt.userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
            </cfquery>

            <!--- only insert if not existing yet --->
            <cfif NOT local.checkTeamTitle.recordcount>
                <cfquery name="local.add" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                    insert into	LeagueTeams
                                (teamTitle,
                                userID,
                                dateAdded)
                    values		(<cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.teamTitle#">,
                                <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">,
                                #CreateODBCDateTime(now())#)
                </cfquery>
                
                <cfset local.result.id = getFactory().get("databaseUtil").util.getLastTeamID(getFactory().get("session").model.get('SiteDatabase'), "LeagueTeams")>
                
                <!--- now add positions for team --->
                <cfset local.positions = getFactory().get("leaguePlayers").model.getPositions()>
                
                <cfset local.addPlayersToTeam = getFactory().get("leaguePlayers").model.positionInsert(teamID=local.result.id,positions=local.positions)>
            <cfelse>
                <cfset local.result.success = false>
            </cfif>

			<cfcatch type="any">
				<cfset local.result.success = false>
                <cfset local.result.output = "Database error - please contact IT support">
			</cfcatch>
		</cftry>
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

    <cffunction name="checkTeamExists" access="public" returntype="boolean" hint="Checking if a specific team's title already exists in the db">
		<cfargument name="teamTitle" type="string" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

        <cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>

            <cfset local.isExisting = false>
		
			<cfquery name="local.checkExistence" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                select  lt.teamID
                from    LeagueTeams lt
                where   lt.teamTitle = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.teamTitle#">
                and     lt.userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
            </cfquery>

            <cfif local.checkExistence.recordCount>
                <cfset local.isExisting = true>
            </cfif>
		
		<cfreturn local.isExisting>
	</cffunction>
	
</cfcomponent>