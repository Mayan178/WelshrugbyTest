<cfcomponent name="user" extends="parent" hint="Model, queries and logic for user">

	<cffunction name="init" returntype="user" access="public">
		<cfset var local = structNew()>

		<cfset super.init()>
		
		<cfset local.cfcPath = getDirectoryFromPath(getCurrentTemplatePath())>

		<cffile action="read" file="#local.cfcPath#..\..\config\#application.core.get('configFolder')#\UserMessages.xml" variable="local.rawData">
		<cfset local.xml = xmlParse(local.rawData)>
		
		<cfset variables.messages = StructNew()>
		
		<cfloop from="1" to="#ArrayLen(local.xml.usermessages.message)#" index="local.m">
			<cfloop list="#StructKeyList(local.xml.usermessages.message[local.m].xmlAttributes)#" index="local.key">
				<cfset local.messages = ArrayNew(1)>

				<cfloop from="1" to="#ArrayLen(local.xml.usermessages.message[local.m].container)#" index="local.c">
					  <cfset local.message = structNew()>
						<cfif NOT StructKeyExists(local.message,"title")>
							<cfset StructInsert(local.message, "title",local.xml.usermessages.message[local.m].container[local.c].xmlAttributes.title)>
						</cfif>
						<cfif NOT StructKeyExists(local.message,"summary")>
							<cfset StructInsert(local.message, "summary",local.xml.usermessages.message[local.m].container[local.c].xmlAttributes.summary)>
						</cfif>
						
						<cfset ArrayAppend(local.messages, local.message)>
				</cfloop>
				
				<cfif NOT StructKeyExists(variables.messages,local.xml.usermessages.message[local.m].xmlAttributes[local.key])>
					<cfset StructInsert(variables.messages, local.xml.usermessages.message[local.m].xmlAttributes[local.key], local.messages)>
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfreturn this/>
	</cffunction>

	<cffunction name="logout" access="public" returntype="struct" hint="Logging the user out by killing the login session variables">
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

		<cfset local.result.output = "Thank you for visiting. Hope you come back soon.">

		<!--- Clear the cache --->
		<cfset local.cachedData = getFactory().get("cacheUtil").util.delete(
				getFactory().get("session").model.get("userID")
		)>

		<!--- reset default currency to GB --->
		<cfset getFactory().get("session").model.clear()>
		
		<cfset getFactory().get("login").model.setLoginVariables(expires="NOW")>
		
		<cfreturn local.result>
	</cffunction>

	<cffunction name="userUpdate" access="public" returntype="struct" hint="updating current user's details">
		<cfargument name="data" type="struct" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
			<cflock name="user#arguments.data.userID#" timeout="30" type="exclusive">
				<cftransaction action="begin">
					<cftry>
						<cfquery datasource="#getFactory().getDatasource('adminSecurity')#" name="local.update">
							update 	Security
                            set		Userpassword = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.password#">,
                            		AccessKey = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.AccessKey#">,
                                    TeamID = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.TeamID#">,
                                    RedMaxLevel = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.RedMaxLevel#">,
                                    GreenMaxLevel = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.GreenMaxLevel#">
                                    
							where 	userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.userID#">
						</cfquery>
                        
						<cftransaction action="commit"/>
                    
                        <!--- now log the user out and back in again --->
                        <cfif arguments.data.originalPassword neq arguments.data.password>
                            <cfset getFactory().get("session").model.set("password", arguments.data.password)>
                        </cfif>
						<cfcatch type="any">
							<cftransaction action="rollback"/>
							<cfset local.result.success = false>
							<cfset local.result.output = "Database error - please contact IT support">
						</cfcatch>
					</cftry>
				</cftransaction>
			</cflock>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="otherUserUpdate" access="public" returntype="struct" hint="Updating another user's details">
		<cfargument name="data" type="struct" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

        <!--- by default, we return success is true --->
        <cfset local.result.success = true>
			
        <cfset local.countryID = getFactory().get("login").model.getUser().user.countryID>

        <cflock name="user#arguments.data.userID#" timeout="30" type="exclusive">
            <cftransaction action="begin">
                <cftry>
                    <cfquery datasource="#getFactory().getDatasource('adminSecurity')#" name="local.update">
                        update 	Security
                        set		Userpassword = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.password#">,
                                SecurityLevelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.SecurityLevelID#">,
                        <!--- manager level...country predefined --->
                        <cfif getFactory().get("login").model.getUser().user.securityLevelID eq 4>
                                CountryID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.countryID#">
                        <!--- admin level...country coming from the form --->
                        <cfelseif getFactory().get("login").model.getUser().user.securityLevelID eq 5>
                                CountryID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.countryID#">
                        </cfif>
                        where 	userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.userID#">
                    </cfquery>
                    
                    <cftransaction action="commit"/>
                
                    <cfcatch type="any">
                        <cftransaction action="rollback"/>
                        <cfset local.result.success = false>
                        <cfset local.result.output = "Database error - please contact IT support">
                    </cfcatch>
                </cftry>
            </cftransaction>
        </cflock>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="userInsert" access="public" returntype="struct" hint="Adding a user to the db">
		<cfargument name="data" type="struct" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        
        <cfset local.countryID = getFactory().get("login").model.getUser().user.countryID>
		
            <cftry>


                <cfquery datasource="#getFactory().getDatasource('adminSecurity')#" name="local.update">
                    insert into	Security
                                (Userpassword,
                                Username,
                                RedMaxLevel,
                                GreenMaxLevel,
                                SecurityLevelID,
                                countryID)
                    values		(<cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.password#">,
                                <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.username#">,
                                <cfqueryparam cfsqltype="cf_sql_numeric" value="6">,
                                <cfqueryparam cfsqltype="cf_sql_numeric" value="11">,
                                <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.SecurityLevelID#">,
                                <!--- manager level...country predefined --->
                                <cfif getFactory().get("login").model.getUser().user.securityLevelID eq 4>
                                    <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.countryID#">
                                <!--- admin level...country coming from the form --->
                                <cfelseif getFactory().get("login").model.getUser().user.securityLevelID eq 5>
                                    <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.countryID#">
                                </cfif>)
                </cfquery>
                
                <cfset local.result.id = getFactory().get("databaseUtil").util.getLastUserID(getFactory().getDatasource('adminSecurity'), "Security")>
                
                <!--- get country for new user so to get the associated db --->
                <cfquery datasource="#getFactory().getDatasource('adminSecurity')#" name="local.getCountryDb">
                    select	sc.countryDatabase
                    from	SecurityCountries sc
                    <cfif getFactory().get("login").model.getUser().user.securityLevelID eq 4>
                    where 	sc.countryID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.countryID#">
                    <!--- admin level...country coming from the form --->
                    <cfelseif getFactory().get("login").model.getUser().user.securityLevelID eq 5>
                    where 	sc.countryID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.countryID#">
                    </cfif>
                </cfquery>
                
                <cfset local.newUserDb = local.getCountryDb.countryDatabase>
                
                <!--- now make sure we insert default values for position stats --->
                <cfquery datasource="#local.newUserDb#" name="local.getdefaultpositionstats">
                    select	dps.*
                    from	DefaultPositionStats dps
                </cfquery>
                
                <cfloop query="local.getdefaultpositionstats">
                    <cfquery datasource="#local.newUserDb#" name="local.insertdefaultpositionStats">
                        insert into	LeaguePositionStats
                                    (PositionID,
                                    StatID,
                                    OrderofRelevance,
                                    UserID)
                        values		(<cfqueryparam cfsqltype="cf_sql_numeric" value="#positionID#">,
                                    <cfqueryparam cfsqltype="cf_sql_numeric" value="#StatID#">,
                                    <cfqueryparam cfsqltype="cf_sql_numeric" value="#OrderofRelevance#">,
                                    <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.result.id#">)
                    </cfquery>
                </cfloop>
                
                <cfquery datasource="#local.newUserDb#" name="local.getdefaultpositionsizes">
                    select	dps.*
                    from	DefaultPositionSizes dps
                </cfquery>
                
                <cfloop query="local.getdefaultpositionsizes">
                    <cfquery datasource="#local.newUserDb#" name="local.insertdefaultpositionStats">
                        insert into	LeaguePositionSizes
                                    (PositionID,
                                    MinWeight,
                                    MaxWeight,
                                    MinHeight,
                                    MaxHeight,
                                    UserID)
                        values		(<cfqueryparam cfsqltype="cf_sql_numeric" value="#positionID#">,
                                    <cfqueryparam cfsqltype="cf_sql_numeric" value="#MinWeight#">,
                                    <cfqueryparam cfsqltype="cf_sql_numeric" value="#MaxWeight#">,
                                    <cfqueryparam cfsqltype="cf_sql_numeric" value="#MinHeight#">,
                                    <cfqueryparam cfsqltype="cf_sql_numeric" value="#MaxHeight#">,
                                    <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.result.id#">)
                    </cfquery>
                </cfloop>
                
                <cfset local.result.output = "Added user (#arguments.data.username#)">
                
                <cfcatch type="any">
                    <cfdump var="#cfcatch#"><cfabort>
                    
                    <cfset local.result.success = false>
                    <cfset local.result.output = "Database error - please contact IT support">
                </cfcatch>


            </cftry>
            
		<cfreturn local.result>
	</cffunction>

    <cffunction name="checkUserExists" access="public" returntype="boolean" hint="checks if a specific user exists">
		<cfargument name="userName" type="string" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

            <cfset local.isExisting = false>
		
			<cfquery datasource="#getFactory().getDatasource('adminSecurity')#" name="local.checkExistence">
                select  s.userID
                from    Security s
                where 	s.userName = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.userName#">
            </cfquery>

            <cfif local.checkExistence.recordCount>
                <cfset local.isExisting = true>
            </cfif>
		
		<cfreturn local.isExisting>
	</cffunction>
    
    <cffunction name="validateUser" access="public" returntype="struct">
		<cfargument name="data" type="struct" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		<cfset local.result.errors = ArrayNew(1)>

		<cfset local.valUtil = getFactory().get("validationUtil").util>
		
        <cfif arguments.data.GreenMaxLevel lte arguments.data.RedMaxLevel>
			<cfset ArrayAppend(local.result.errors, "The value you selected for the green colour needs to be higher than the red colour")>
        </cfif>
        
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
    
    
    <cffunction name="getallUsers" returntype="query" access="public" hint="returns all the users from the database">
		
		<cfset var local = structNew()>
		
		<cfquery name="local.getUsers" datasource="#getFactory().getDatasource('adminSecurity')#">
			select	s.userID,
            		s.username,
            		s.lastloggedin,
                    s.securityLevelID,
                    sl.securityLevel,
                    sc.countryname
            from	((Security s INNER JOIN SecurityLevels sl
            ON		s.securityLevelID = sl.securityLevelID)
            INNER JOIN SecurityCountries sc 
            ON 		sc.countryID = s.countryID)
            order by s.username ASC
		</cfquery>
        
        <cfset local.result = QueryNew("username,userID,lastloggedin,playersAdded,securityLevelID,securityLevel,country","varchar,varchar,varchar,varchar,integer,varchar,varchar")>
                 
        <cfloop query="local.getUsers">
            <cfset QueryAddRow(local.result, 1)>
			<cfset QuerySetCell(local.result, "username", username)>
            <cfset QuerySetCell(local.result, "userID", userID)>
            <cfset QuerySetCell(local.result, "lastloggedin", lastloggedin)>
            <cfset QuerySetCell(local.result, "securityLevelID", securityLevelID)>
            <cfset QuerySetCell(local.result, "securityLevel", securityLevel)>
            <cfset QuerySetCell(local.result, "country", countryname)>
        
            <cfquery name="local.playersadded" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                select	lp.playerID
                from	LeaguePlayers lp
                where	lp.AddedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#userID#">
            </cfquery>
            
            <cfset QuerySetCell(local.result, "playersAdded", local.playersadded.recordcount)>
		</cfloop>
        
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getallUsers4andbelow" returntype="query" access="public" hint="returns all the users from the database that have a security level below or equal to 4">
		
		<cfset var local = structNew()>
		
        <cfset local.countryID = getFactory().get("login").model.getUser().user.countryID>
        
		<cfquery name="local.getUsers" datasource="#getFactory().getDatasource('adminSecurity')#">
			select	s.userID,
            		s.username,
            		s.lastloggedin,
                    s.securityLevelID,
                    sl.securityLevel,
                    sc.countryname
            from	((Security s INNER JOIN SecurityLevels sl
            ON		s.securityLevelID = sl.securityLevelID)
            INNER JOIN SecurityCountries sc 
            ON 		sc.countryID = s.countryID)
            where 	s.SecurityLevelID <= <cfqueryparam cfsqltype="cf_sql_numeric" value="4">
            and		s.CountryID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.countryID#">
            order by s.username ASC
		</cfquery>
        
        <cfset local.result = QueryNew("username,userID,lastloggedin,playersAdded,securityLevelID,securityLevel","varchar,varchar,varchar,varchar,integer,varchar")>
                 
        <cfloop query="local.getUsers">
            <cfset QueryAddRow(local.result, 1)>
			<cfset QuerySetCell(local.result, "username", username)>
            <cfset QuerySetCell(local.result, "userID", userID)>
            <cfset QuerySetCell(local.result, "lastloggedin", lastloggedin)>
            <cfset QuerySetCell(local.result, "securityLevelID", securityLevelID)>
            <cfset QuerySetCell(local.result, "securityLevel", securityLevel)>
        
            <cfquery name="local.playersadded" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                select	lp.playerID
                from	LeaguePlayers lp
                where	lp.AddedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#userID#">
            </cfquery>
            
            <cfset QuerySetCell(local.result, "playersAdded", local.playersadded.recordcount)>
		</cfloop>
        
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getUserDetails" access="public" returntype="query" hint="gets a specific user's details">
		<cfargument name="userID" type="numeric" required="false" default="0">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		<cfset local.result.success = false>
        
        <cftry>
            <cfquery datasource="#getFactory().getDatasource('adminSecurity')#" name="local.result">
                select 	*
                from 	Security s
                where 	s.userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.userID#">
            </cfquery>
		
            <cfcatch type="any">
                <cfset local.result.success = false>
                <cfdump var="#cfcatch#">
            </cfcatch>
        </cftry>
        
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="deleteUser" access="public" returntype="struct" hint="Deletes a specific user">
		<cfargument name="UserID" type="numeric" required="true">
		
        <cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        <cfset local.result.success = true>
        
            
		            <cftry>

                        <cfquery name="local.getdeleteduserdb" datasource="#getFactory().getDatasource('adminSecurity')#">
                            select	sc.countryDatabase 
                            from 	SecurityCountries sc
                            where 	sc.countryID = (select countryID from Security where userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.UserID#">)
                        </cfquery>
                        
                        <cfset local.countrydb = local.getdeleteduserdb.countryDatabase>
                        
                        <cfquery name="local.deleteuser" datasource="#getFactory().getDatasource('adminSecurity')#">
                            delete 
                            from 	Security
                            where 	userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.UserID#">
                        </cfquery>
                        
                        <cfquery name="local.getleagueplayers" datasource="#local.countrydb#">
                            select	lp.playerID 
                            from 	LeaguePlayers lp
                            where 	lp.addedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.UserID#">
                        </cfquery>
                        
                        <cfloop query="local.getleagueplayers">
                            <cfquery name="local.deleteleagueplayers" datasource="#local.countrydb#">
                                delete 
                                from 	LeaguePlayers
                                where 	playerID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#playerID#">
                            </cfquery>
                            
                            <cfquery name="local.deleteleagueplayerstats" datasource="#local.countrydb#">
                                delete 
                                from 	LeaguePlayerStats
                                where 	playerID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#playerID#">
                            </cfquery>
                            
                            <cfquery name="local.deleteleagueteamplayers" datasource="#local.countrydb#">
                                delete 
                                from 	LeagueTeamPlayers
                                where 	playerID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#playerID#">
                            </cfquery>
                        </cfloop>
                        
                        <cfquery name="local.deleteleagueteams" datasource="#local.countrydb#">
                            delete 
                            from 	LeagueTeams
                            where 	userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.UserID#">
                        </cfquery>
                        
                        <cfquery name="local.deleteleagueteamcomments" datasource="#local.countrydb#">
                            delete 
                            from 	LeagueTeamComments
                            where 	AddedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.UserID#">
                        </cfquery>
                        
                        <cfquery name="local.updatenationalplayers1" datasource="#local.countrydb#">
                            update	NationalPlayers
                            set		AddedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="0">
                            where 	AddedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.UserID#">
                        </cfquery>
                        
                        <cfquery name="local.updatenationalplayers2" datasource="#local.countrydb#">
                            update	NationalPlayers
                            set		LastUpdatedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="0">
                            where 	LastUpdatedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.UserID#">
                        </cfquery>
                        
                        <cfquery name="local.deletenationalteamcomments" datasource="#local.countrydb#">
                            delete 
                            from 	NationalTeamComments
                            where 	AddedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.UserID#">
                        </cfquery>
                        
                        <cfquery name="local.deletenationalteams" datasource="#local.countrydb#">
                            delete 
                            from 	NationalTeams
                            where 	UserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.UserID#">
                            and		Published = <cfqueryparam cfsqltype="cf_sql_numeric" value="0">
                        </cfquery>
                        
                        <cfquery name="local.updatenationalteams" datasource="#local.countrydb#">
                            update	NationalTeams
                            set		UserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="0">
                            where 	UserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.UserID#">
                            and		Published = <cfqueryparam cfsqltype="cf_sql_numeric" value="1">
                        </cfquery>
                        
                        
                        <cfquery name="local.deleteLeaguePositionStats" datasource="#local.countrydb#">
                            delete 
                            from 	LeaguePositionStats
                            where 	UserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.UserID#">
                        </cfquery>
                        
                        <cftransaction action="commit"/>
						<cfset local.result.output = "Deleted user (#arguments.UserID#)">
					
                        <cfcatch type="any">
                            <cfdump var="#cfcatch#"><cfabort>
                            <cftransaction action="rollback"/>
                            <cfset local.result.success = false>
                            <cfset local.result.output = "Database error - please contact IT support">
                        </cfcatch>
                        
                    </cftry>

        <cfreturn local.result>
	</cffunction>
    
    <cffunction name="getAllSecurityLevelIDs" access="public" returntype="query" hint="get a list of all security levels">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		<cfset local.result.success = false>
        
        <cftry>
            <cfquery datasource="#getFactory().getDatasource('adminSecurity')#" name="local.result">
                select 	sl.securityLevelID,
                		sl.securityLevel
                from 	SecurityLevels sl
            </cfquery>
		
            <cfcatch type="any">
                <cfset local.result.success = false>
                <cfdump var="#cfcatch#">
            </cfcatch>
        </cftry>
        
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getSecurityLevelIDs3andbelow" access="public" returntype="query" hint="get a list of all security levels equal to 3 or below">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		<cfset local.result.success = false>
        
        <cftry>
            <cfquery datasource="#getFactory().getDatasource('adminSecurity')#" name="local.result">
                select 	sl.securityLevelID,
                		sl.securityLevel
                from 	SecurityLevels sl
                where	sl.securityLevelID <= <cfqueryparam cfsqltype="cf_sql_numeric" value="3">
            </cfquery>
		
            <cfcatch type="any">
                <cfset local.result.success = false>
                <cfdump var="#cfcatch#">
            </cfcatch>
        </cftry>
        
		<cfreturn local.result>
	</cffunction>
        
    <cffunction name="getAllCountries" access="public" returntype="query" hint="get a list of all countries">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		<cfset local.result.success = false>
        
        <cftry>
            <cfquery datasource="#getFactory().getDatasource('adminSecurity')#" name="local.result">
                select 	sc.countryID,
                		sc.countryName
                from 	SecurityCountries sc
            </cfquery>
		
            <cfcatch type="any">
                <cfset local.result.success = false>
                <cfdump var="#cfcatch#">
            </cfcatch>
        </cftry>
        
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getMatchTypes" returntype="query" access="public" hint="returns all the match types">
		
		<cfset var local = structNew()>
		
		<cfquery name="local.result" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	mt.matchTypeID,
            		mt.matchTypetitle
			from	matchTypes mt
		</cfquery>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getMatchResults" returntype="query" access="public" hint="returns all the match results">
		
		<cfset var local = structNew()>
		
		<cfquery name="local.result" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	mr.matchResultID,
            		mr.matchResulttitle
			from	matchResults mr
		</cfquery>
		
		<cfreturn local.result>
	</cffunction>
    
    
    <cffunction name="getDefenseTypes" returntype="query" access="public" hint="returns all defense types">
		
		<cfset var local = structNew()>
		
		<cfquery name="local.result" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	mdf.defenseTypeID,
            		mdf.defenseTypetitle
			from	matchdefenseTypes mdf
		</cfquery>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getIntensities" returntype="query" access="public" hint="returns all intensities">
		
		<cfset var local = structNew()>
		
		<cfquery name="local.result" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	mi.IntensityID,
            		mi.Intensitytitle
			from	matchIntensity mi
		</cfquery>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getDisciplines" returntype="query" access="public" hint="returns all disciplines">
		
		<cfset var local = structNew()>
		
		<cfquery name="local.result" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	md.DisciplineID,
            		md.Disciplinetitle
			from	matchDiscipline md
		</cfquery>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getCountries" returntype="query" access="public" hint="returns all countries">
		
		<cfset var local = structNew()>
		
		<cfquery name="local.result" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	c.countryID,
            		c.countrytitle
			from	countries c
            order by c.countryTitle
		</cfquery>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="checkStatsLevels" returntype="numeric" access="public" hint="returns the id of a specific stat level title">
    	<cfargument name="levelTitle" type="string" required="true" default="">
		
		<cfset var local = structNew()>
		
		<cfquery name="local.checkStatsLevels" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	sl.levelID
			from	StatsLevels sl
			where	sl.levelTitle = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.levelTitle#">
		</cfquery>
		
        <cfif local.checkStatsLevels.recordcount>
        	<cfset local.levelID = local.checkStatsLevels.levelID>
        <cfelse>
        	<cfset local.levelID = 0>
        </cfif>
        
		<cfreturn local.levelID>
	</cffunction>
    
    <cffunction name="checkPotentialLevels" returntype="numeric" access="public" hint="returns the id of a specific potential level title">
    	<cfargument name="potentialTitle" type="string" required="true" default="">
		
		<cfset var local = structNew()>
		
		<cfquery name="local.checkPotentialLevels" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	p.potentialID
			from	Potentials p
			where	p.otentialTitle = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.potentialTitle#">
		</cfquery>
		
        <cfif local.checkPotentialLevels.recordcount>
        	<cfset local.potentialID = local.checkPotentialLevels.potentialID>
        <cfelse>
        	<cfset local.potentialID = 0>
        </cfif>
        
		<cfreturn local.potentialID>
	</cffunction>
    
    <cffunction name="getLevelandPotentialInfo" returntype="string" access="public" hint="returns level and potential information">
        <cfargument name="LevelID" type="numeric" required="false" default="0">
        <cfargument name="PotentialID" type="numeric" required="false" default="0">
            
        <cfset var local = structNew()>
        
        <cfquery name="local.getLevelTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
        select 	sl.LevelTitle
        from	StatsLevels sl
        where	sl.LevelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.LevelID#">
        </cfquery>
                        
        <cfquery name="local.getPotentialTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
        select 	p.PotentialTitle
        from	Potentials p
        where	p.PotentialID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.PotentialID#">
        </cfquery>
        
        <cfset local.result = "#local.getLevelTitle.LevelTitle# (#local.getPotentialTitle.PotentialTitle#)">
        
        <cfreturn local.result>
    </cffunction>
    
    <cffunction name="getallUsersforAPI" returntype="query" access="public" hint="returns all the users details to use with API from the database">
		
		<cfset var local = structNew()>
		
		<cfquery name="local.result" datasource="#getFactory().getDatasource('adminSecurity')#">
			select	s.UserID,
            		s.AccessKey,
            		s.TeamID,
                    sc.countryDatabase
            from 	Security s INNER JOIN SecurityCountries sc
            ON		s.CountryID = sc.CountryID
		</cfquery>
                
		<cfreturn local.result>
	</cffunction>
    
    
    <cffunction name="insertUserError" returntype="struct" access="public" hint="returns all the users details to use with API from the database">
		<cfargument name="userID" type="numeric" required="false" default="0">
        <cfargument name="userError" type="string" required="false" default="">
        <cfargument name="Type" type="string" required="false" default="">
        <cfargument name="MoreInfo" type="string" required="false" default="">
        <cfargument name="teamID" type="numeric" required="false" default="0">
        <cfargument name="playerID" type="numeric" required="false" default="0">
        
		<cfset var local = structNew()>
        <cfset local.result = getFactory().getResult()>
        		
		<cfquery name="local.insertError" datasource="#getFactory().getDatasource('adminSecurity')#">
			insert into 	userErrors
            				(
                            UserID,
                            ErrorMessage,
                            ErrorDate,
                            Type,
                            MoreInfo,
                            teamID,
                            playerID
                            )
            values			(
            				<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.userID#">,
                            <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.userError#">,
                            #CreateODBCDateTime(now())#,
                            <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.Type#">,
                            <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.MoreInfo#">,
                            <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.teamID#">,
                            <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.playerID#">
                            )
		</cfquery>
                
                
		<cfreturn local.result>
	</cffunction>
    	
</cfcomponent>