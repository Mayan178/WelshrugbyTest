<cfcomponent name="leagueplayers" extends="parent" hint="Model, queries and logic for league players">
	<cffunction name="init" returntype="leagueplayers" access="public">
		<cfset var local = structNew()>

		<cfset super.init()>
        <!--- load in any messages --->
		<cfset local.cfcPath = getDirectoryFromPath(getCurrentTemplatePath())>
		<cffile action="read" file="#local.cfcPath#..\..\config\#application.core.get('configFolder')#\Leagueplayermessages.xml" variable="local.rawData">
		<cfset local.xml = xmlParse(local.rawData)>
		
		<cfset variables.messages = StructNew()>
		
		<cfloop from="1" to="#ArrayLen(local.xml.leagueplayermessages.message)#" index="local.m">
			<cfloop list="#StructKeyList(local.xml.leagueplayermessages.message[local.m].xmlAttributes)#" index="local.key">
				
				<cfset local.messages = ArrayNew(1)>
				
				<cfloop from="1" to="#ArrayLen(local.xml.leagueplayermessages.message[local.m].container)#" index="local.c">
					<cfset local.message = structNew()>
					<cfif NOT StructKeyExists(local.message,"title")>
						<cfset StructInsert(local.message, "title",local.xml.leagueplayermessages.message[local.m].container[local.c].xmlAttributes.title)>
					</cfif>
					<cfif NOT StructKeyExists(local.message,"summary")>
						<cfset StructInsert(local.message, "summary",local.xml.leagueplayermessages.message[local.m].container[local.c].xmlAttributes.summary)>
					</cfif>

					<cfset ArrayAppend(local.messages, local.message)>
				</cfloop>

				<cfif NOT StructKeyExists(variables.messages,local.xml.leagueplayermessages.message[local.m].xmlAttributes[local.key])>
					<cfset StructInsert(variables.messages, local.xml.leagueplayermessages.message[local.m].xmlAttributes[local.key], local.messages)>
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfreturn this/>
	</cffunction>
    
    <cffunction name="gettop10CSR" returntype="query" access="public" hint="returns the top 10 CSR players added by the user">
		<cfargument name="data" type="struct" required="false">
        <cfargument name="UserDatabase" type="string" required="false" default="#getFactory().get("session").model.get('SiteDatabase')#">
        
		<cfset var local = structNew()>
        
        <cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
        
            <cftry>
                <cfquery name="local.gettop10CSR" datasource="#arguments.UserDatabase#" maxrows="10">
                    select	p.BRPlayerID,
                    		p.PlayerID,
                            p.Firstname,
                            p.Nickname,
                            p.Lastname,
                            p.Age,
                            p.Height,
                            p.Weight,
                            p.CSR,
                            p.injured,
                            p.staminaLevel,
                            p.AttackLevel,
                            p.TechniqueLevel,
                            p.JumpingLevel,
                            p.AgilityLevel,
                            p.HandlingLevel,
                            p.Defenselevel,
                            p.StrengthLevel,
                            p.SpeedLevel,
                            p.KickingLevel,
                            c.countryTitle AS country,
                            c.countryID
                    from	LeaguePlayers p
                    INNER JOIN Countries c
                    ON		p.countryID = c.countryID
                    where 	p.AddedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
                    and		p.SoldorFired = <cfqueryparam cfsqltype="cf_sql_numeric" value="0">
                    order by p.CSR Desc
                </cfquery>
                
                <cfset local.result = QueryNew("BRPlayerID,PlayerID,FirstName,LastName,NickName,Age,CSR,Height,Weight,Top1,Top2,Top3,Top4,Best1,Best2,Best3,Best4,Best5,country,injured","integer,integer,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar")>
                 
                <cfloop query="local.gettop10CSR">
                    <cfset local.playerID = PlayerID>
                    
                        <cfset QueryAddRow(local.result, 1)>
                        <cfset QuerySetCell(local.result, "BRPlayerID", BRPlayerID)>
                        <cfset QuerySetCell(local.result, "PlayerID", PlayerID)>
                        <cfset QuerySetCell(local.result, "FirstName", FirstName)>
                        <cfset QuerySetCell(local.result, "LastName", LastName)>
                        <cfset QuerySetCell(local.result, "NickName", NickName)>
                        <cfset QuerySetCell(local.result, "Age", Age)>
                        <cfset QuerySetCell(local.result, "CSR", CSR)>
                        <cfset QuerySetCell(local.result, "Height", Height)>
                        <cfset QuerySetCell(local.result, "Weight", Weight)>                        
                        <cfset QuerySetCell(local.result, "country", country)>
                        <cfset QuerySetCell(local.result, "injured", injured)>
                        
                        <cfset local.staminaLevel = staminaLevel>
						<cfset local.staminaLevelTitle = getStatLevelTitle(local.staminaLevel,arguments.UserDatabase)>
                        
                        <cfset local.AttackLevel = AttackLevel>
                        <cfset local.AttackLevelTitle = getStatLevelTitle(local.AttackLevel,arguments.UserDatabase)>
                    
                        <cfset local.TechniqueLevel = TechniqueLevel>
                        <cfset local.TechniqueLevelTitle = getStatLevelTitle(local.TechniqueLevel,arguments.UserDatabase)>            
                    
                        <cfset local.JumpingLevel = JumpingLevel>
                        <cfset local.JumpingLevelTitle = getStatLevelTitle(local.JumpingLevel,arguments.UserDatabase)>     
                        
                        <cfset local.AgilityLevel = AgilityLevel>
                        <cfset local.AgilityLevelTitle = getStatLevelTitle(local.AgilityLevel,arguments.UserDatabase)>     
                        
                        <cfset local.HandlingLevel = HandlingLevel>
                        <cfset local.HandlingLevelTitle = getStatLevelTitle(local.HandlingLevel,arguments.UserDatabase)>   
        
                        <cfset local.Defenselevel = Defenselevel>
                        <cfset local.DefenselevelTitle = getStatLevelTitle(local.Defenselevel,arguments.UserDatabase)>   
                        
                        <cfset local.StrengthLevel = StrengthLevel>
                        <cfset local.StrengthLevelTitle = getStatLevelTitle(local.StrengthLevel,arguments.UserDatabase)>  
                        
                        <cfset local.SpeedLevel = SpeedLevel>
                        <cfset local.SpeedLevelTitle = getStatLevelTitle(local.SpeedLevel,arguments.UserDatabase)>  
                        
                        <cfset local.KickingLevel = KickingLevel>
                        <cfset local.KickingLevelTitle = getStatLevelTitle(local.KickingLevel,arguments.UserDatabase)>   

						<!--- now get top 6 stats --->
                        <cfset local.listofStatsValuestoCheck = "">
                        <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#staminaLevel#")>
                        <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#AttackLevel#")>
                        <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#TechniqueLevel#")>
                        <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#JumpingLevel#")>
                        <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#AgilityLevel#")>
                        <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#HandlingLevel#")>
                        <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#Defenselevel#")>   
                        <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#StrengthLevel#")>
                        <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#SpeedLevel#")>
                        <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#KickingLevel#")>             
                        <cfset local.listofStatsValuestoCheck = listsort(local.listofStatsValuestoCheck,"numeric","DESC")>
                        
                        <cfset local.finalListofStatstoLookAt = "">
                        <!--- now loop through top 6 values --->
                        <cfloop from="1" to="6" index="local.stvalue">
                            <cfset local.valuetoCheck = listgetat(local.listofStatsValuestoCheck,local.stvalue)>
                            <cfif staminaLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#staminaLevel#-Stamina-#local.StaminaLevelTitle#")>
                                <cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#staminaLevel#-Stamina-#local.StaminaLevelTitle#")>
                            </cfif>
                            <cfif AttackLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#AttackLevel#-Attack-#local.AttackLevelTitle#")>
                                <cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#AttackLevel#-Attack-#local.AttackLevelTitle#")>
                            </cfif>
                            <cfif TechniqueLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#TechniqueLevel#-Technique-#local.TechniqueLevelTitle#")>
                                <cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#TechniqueLevel#-Technique-#local.TechniqueLevelTitle#")>
                            </cfif>
                            <cfif JumpingLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#JumpingLevel#-Jumping-#local.JumpingLevelTitle#")>
                                <cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#JumpingLevel#-Jumping-#local.JumpingLevelTitle#")>
                            </cfif>
                            <cfif AgilityLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#AgilityLevel#-Agility-#local.AgilityLevelTitle#")>
                                <cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#AgilityLevel#-Agility-#local.AgilityLevelTitle#")>
                            </cfif>
                            <cfif HandlingLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#HandlingLevel#-Handling-#local.HandlingLevelTitle#")>
                                <cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#HandlingLevel#-Handling-#local.HandlingLevelTitle#")>
                            </cfif>
                            <cfif Defenselevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#Defenselevel#-Defense-#local.DefenseLevelTitle#")>
                                <cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#Defenselevel#-Defense-#local.DefenseLevelTitle#")>
                            </cfif>
                            <cfif StrengthLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#StrengthLevel#-Strength-#local.StrengthLevelTitle#")>
                                <cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#StrengthLevel#-Strength-#local.StrengthLevelTitle#")>
                            </cfif>
                            <cfif SpeedLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#SpeedLevel#-Speed-#local.SpeedLevelTitle#")>
                                <cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#SpeedLevel#-Speed-#local.SpeedLevelTitle#")>
                            </cfif>
                            <cfif KickingLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#KickingLevel#-Kicking-#local.KickingLevelTitle#")>
                                <cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#KickingLevel#-Kicking-#local.KickingLevelTitle#")>   
                            </cfif>
                        </cfloop>
                        
                            <cfset local.r = 1>
                            <cfset local.potentialPositions = "">
                                                    
                            <cfloop list="#local.finalListofStatstoLookAt#" index="local.st">
                                
                                <cfif local.r lte 4>
                                    <!--- getting top 4 stats for display --->
                                    <cfquery name="local.getAbbreviation" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                                        select	s.StatAbbr
                                        from	Stats s
                                        where	s.StatTitle = <cfqueryparam cfsqltype="cf_sql_char" value="#listgetat(local.st,'2','-')#">
                                    </cfquery>
                                    
                                    <cfset QuerySetCell(local.result, "Top#local.r#", "#local.getAbbreviation.StatAbbr#: #listgetat(local.st,'3','-')#")>
                                    <cfset local.r = local.r + 1>
                                </cfif>
                                
                                <cfquery name="local.getStatID" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                                    select	s.StatID
                                    from	Stats s
                                    where	s.StatTitle = <cfqueryparam cfsqltype="cf_sql_char" value="#listgetat(local.st,'2','-')#">
                                </cfquery>
                                
                                <cfquery name="local.checkposition" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                                    select	lps.PositionID
                                    from	LeaguePositionStats lps
                                    where	lps.StatID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.getStatID.StatID#">
                                    and		lps.userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
                                </cfquery>
                                
                                <cfif local.checkposition.recordcount>
                                    <cfset local.potentialPositions = listAppend(local.potentialPositions,valuelist(local.checkposition.PositionID))>
                                </cfif>                                
                                
                            </cfloop>
                            
                            <cfset local.superFinalPositionsList = "">
                            <!--- loop through all positions --->
                            <cfloop from="1" to="15" index="local.i">
                                <!--- if the position is found in the list 4 times, then we have a winner! :) --->
                                <cfif ListValueCountNoCase(local.potentialPositions, local.i) eq 4>
                                    <cfset local.superFinalPositionsList = listAppend(local.superFinalPositionsList,local.i)>
                                </cfif>
                            </cfloop>
                            
                            <cfset local.cntpos = 0>
                            <cfloop list="#local.superFinalPositionsList#" index="local.postoshow">
                                <cfif local.cntpos lte 4>
                                    <cfquery name="local.getpositionTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                                        select 	p.positionTitle
                                        from	Positions p
                                        where 	p.positionID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.postoshow#">
                                    </cfquery>
                                    
                                    <cfif local.postoshow eq 1 AND Weight gte getPositionPlayerMinWeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=1) AND Height lte getPositionPlayerMaxHeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=1)>
                                        <cfset local.cntpos = local.cntpos+1>
                                        <cfset QuerySetCell(local.result, "Best#local.cntpos#", local.getpositionTitle.positionTitle)>
                                    </cfif>
                                    <cfif local.postoshow eq 2 AND Weight gte getPositionPlayerMinWeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=2) AND Height lte getPositionPlayerMaxHeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=2)>
                                        <cfset local.cntpos = local.cntpos+1>
                                        <cfset QuerySetCell(local.result, "Best#local.cntpos#", local.getpositionTitle.positionTitle)>
                                    </cfif>
                                    <cfif local.postoshow eq 3 AND Weight gte getPositionPlayerMinWeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=3) AND Height lte getPositionPlayerMaxHeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=3)>
                                        <cfset local.cntpos = local.cntpos+1>
                                        <cfset QuerySetCell(local.result, "Best#local.cntpos#", local.getpositionTitle.positionTitle)>
                                    </cfif>
                                    <cfif local.postoshow eq 4 AND Height gte getPositionPlayerMinHeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=4)>
                                        <cfset local.cntpos = local.cntpos+1>
                                        <cfset QuerySetCell(local.result, "Best#local.cntpos#", local.getpositionTitle.positionTitle)>
                                    </cfif>
                                    <cfif local.postoshow eq 5 AND Height gte getPositionPlayerMinHeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=5)>
                                        <cfset local.cntpos = local.cntpos+1>
                                        <cfset QuerySetCell(local.result, "Best#local.cntpos#", local.getpositionTitle.positionTitle)>
                                    </cfif>
                                    <cfif local.postoshow neq 1 AND local.postoshow neq 2 AND local.postoshow neq 3 AND local.postoshow neq 4 AND local.postoshow neq 5>
                                        <cfset local.cntpos = local.cntpos+1>
                                        <cfset QuerySetCell(local.result, "Best#local.cntpos#", local.getpositionTitle.positionTitle)>
                                    </cfif>
                                </cfif>
                            </cfloop>
                            
                            <cfif local.cntpos lt 5>
                                <cfset local.remaining = 5-#local.cntpos#>
                                <cfset local.start = #local.cntpos#+1>
                                <cfset local.end = #local.cntpos#+#local.remaining#>
                                
                                <cfloop from="#local.start#" to="#local.end#" index="local.posremaining">
                                    <cfset QuerySetCell(local.result, "Best#local.posremaining#", "")>
                                </cfloop>
                            </cfif>
                       
                </cfloop>
                
                <cfcatch type="any">
                    <cfset local.result.success = false>
                    <cfset local.result.output = "Database error - please contact IT support">
                    <cfdump var="#cfcatch#">
                </cfcatch>
                
            </cftry>
        	        
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getlast10Added" returntype="query" access="public" hint="returns a list of the last 10 players added since the user last logged in">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>

        <cfset local.lastLoggedIn = #getFactory().get('session').model.get('lastloggedin')#>
        <cfset local.lastLoggedIn = #createDatetime(year(local.lastLoggedIn),month(local.lastLoggedIn),day(local.lastLoggedIn),hour(local.lastLoggedIn),minute(local.lastLoggedIn),second(local.lastLoggedIn))#>
        
        <cfset local.todayLoggedIn = #getFactory().get("login").model.getUser().user.LastLoggedIn#>
        <cfset local.todayLoggedIn = #createDatetime(year(local.todayLoggedIn),month(local.todayLoggedIn),day(local.todayLoggedIn),hour(local.todayLoggedIn),minute(local.todayLoggedIn),second(local.todayLoggedIn))#>
       
        <cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
        
		<cfquery name="local.result" datasource="#getFactory().get("session").model.get('SiteDatabase')#" maxrows="10">
			select	p.FirstName,
            		p.Lastname,
                    p.NickName,
                    p.DateAdded,
                    p.PlayerID,
                    p.CSR,
                    p.Age,
                    p.injured,
                    c.CountryTitle AS country
			from	LeaguePlayers p
            INNER JOIN Countries c
            ON		p.CountryID = c.countryID
			where	p.DateAdded > #local.lastLoggedIn#
            and		p.DateAdded < #local.todayLoggedIn#
            and 	p.AddedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
            and		p.SoldorFired = <cfqueryparam cfsqltype="cf_sql_numeric" value="0">
            order by p.DateAdded DESC
		</cfquery>
		
		<cfreturn local.result>
	</cffunction>


   
    <cffunction name="getsearchResults" returntype="query" access="public" hint="returns a list of League players, matching search criteria">
		<cfargument name="data" type="struct" required="false">
        <cfargument name="UserDatabase" type="string" required="false" default="#getFactory().get("session").model.get('SiteDatabase')#">
		
		<cfset var local = structNew()>
		
        <cftry>
        <cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
        
		<cfquery name="local.getPlayers" datasource="#arguments.UserDatabase#">
			select	p.*,
            		c.countryTitle AS country
			from	LeaguePlayers p
            INNER JOIN Countries c
            ON		p.countryID = c.countryID
            where	1=1
            and 	p.AddedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
            <cfif Len(Trim(arguments.data.Firstname))>
            and		p.Firstname = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.Firstname#">
            </cfif>
            <cfif Len(Trim(arguments.data.LastName))>
            and		p.LastName = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.LastName#">
            </cfif>
            <cfif Len(Trim(arguments.data.nickName))>
            and		p.Nickname = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.nickName#">
            </cfif>
            <cfif arguments.data.Age neq 0 and arguments.data.ageType eq "minimum">
            and		p.Age >= <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.Age#">
            </cfif>
            <cfif arguments.data.Age neq 0 and arguments.data.ageType eq "maximum">
            and		p.Age <= <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.Age#">
            </cfif>
            <cfif Len(Trim(arguments.data.CSR))>
            and		p.CSR >= <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.CSR#">
            </cfif>
            <cfif Len(Trim(arguments.data.Height))>
            and		p.Height >= <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.Height#">
			</cfif>
            <cfif Len(Trim(arguments.data.Weight))>
            and		p.Weight >= <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.Weight#">
            </cfif>
            <cfif Len(Trim(arguments.data.Handed))>
            and		p.Handed = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.Handed#">
            </cfif>
            <cfif Len(Trim(arguments.data.Footed))>
            and		p.Footed = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.Footed#">
            </cfif>
            <cfif Len(Trim(arguments.data.FormLevel))>
            and		p.FormLevel >= <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.FormLevel#">
            </cfif>
            <cfif Len(Trim(arguments.data.EnergyLevel))>
            and		p.EnergyLevel>= <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.EnergyLevel#">
            </cfif>
            <cfif Len(Trim(arguments.data.AgressionLevel))>
            and		p.AgressionLevel>= <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.AgressionLevel#">
            </cfif>
            <cfif Len(Trim(arguments.data.DisciplineLevel))>
            and		p.DisciplineLevel>= <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.DisciplineLevel#">
            </cfif>
            <cfif Len(Trim(arguments.data.LeadershipLevel))>
            and		p.LeadershipLevel>= <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.LeadershipLevel#">
            </cfif>
            <cfif Len(Trim(arguments.data.ExperienceLevel))>
            and		p.ExperienceLevel>= <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.ExperienceLevel#">
            </cfif>
            <cfif Len(Trim(arguments.data.Team))>
            and		p.Team = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.Team#">
            </cfif>
            <cfif Len(Trim(arguments.data.BRPlayerID)) AND arguments.data.BRPlayerID neq 0>
            and		p.BRPlayerID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.BRPlayerID#">
            </cfif>
            
            <cfif Len(Trim(arguments.data.agilityLevel))>
            and		p.agilityLevel>= <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.agilityLevel#">
            </cfif>
            <cfif Len(Trim(arguments.data.attackLevel))>
            and		p.attackLevel>= <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.attackLevel#">
            </cfif>
            <cfif Len(Trim(arguments.data.defenseLevel))>
            and		p.defenseLevel>= <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.defenseLevel#">
            </cfif>
            <cfif Len(Trim(arguments.data.handlingLevel))>
            and		p.handlingLevel>= <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.handlingLevel#">
            </cfif>
            <cfif Len(Trim(arguments.data.jumpingLevel))>
            and		p.jumpingLevel>= <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.jumpingLevel#">
            </cfif>
            <cfif Len(Trim(arguments.data.kickingLevel))>
            and		p.kickingLevel>= <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.kickingLevel#">
            </cfif>
            <cfif Len(Trim(arguments.data.speedLevel))>
            and		p.speedLevel>= <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.speedLevel#">
            </cfif>
            <cfif Len(Trim(arguments.data.staminaLevel))>
            and		p.staminaLevel>= <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.staminaLevel#">
            </cfif>
            <cfif Len(Trim(arguments.data.strengthLevel))>
            and		p.strengthLevel>= <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.strengthLevel#">
            </cfif>
            <cfif Len(Trim(arguments.data.techniqueLevel))>
            and		p.techniqueLevel>= <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.techniqueLevel#">
            </cfif>
            
            <cfif Len(arguments.data.position) AND arguments.data.position lt 4>
            	<cfif arguments.data.position eq 1>
            	and		p.Weight >= <cfqueryparam cfsqltype="cf_sql_numeric" value="#getPositionPlayerMinWeight(UserDatabase=arguments.UserDatabase,positionID=1)#">
                <cfelseif arguments.data.position eq 2>
            	and		p.Weight >= <cfqueryparam cfsqltype="cf_sql_numeric" value="#getPositionPlayerMinWeight(UserDatabase=arguments.UserDatabase,positionID=2)#">
                <cfelseif arguments.data.position eq 3>
            	and		p.Weight >= <cfqueryparam cfsqltype="cf_sql_numeric" value="#getPositionPlayerMinWeight(UserDatabase=arguments.UserDatabase,positionID=3)#">
                </cfif>
            </cfif>
            <cfif Len(arguments.data.position) AND arguments.data.position lt 6>
            	<cfif arguments.data.position eq 1>
                and		p.Height <= <cfqueryparam cfsqltype="cf_sql_numeric" value="#getPositionPlayerMaxHeight(UserDatabase=arguments.UserDatabase,positionID=1)#">
                <cfelseif arguments.data.position eq 2>
                and		p.Height <= <cfqueryparam cfsqltype="cf_sql_numeric" value="#getPositionPlayerMaxHeight(UserDatabase=arguments.UserDatabase,positionID=2)#">
                <cfelseif arguments.data.position eq 3>
                and		p.Height <= <cfqueryparam cfsqltype="cf_sql_numeric" value="#getPositionPlayerMaxHeight(UserDatabase=arguments.UserDatabase,positionID=3)#">
                <cfelseif arguments.data.position eq 4>
                and		p.Height >= <cfqueryparam cfsqltype="cf_sql_numeric" value="#getPositionPlayerMinHeight(UserDatabase=arguments.UserDatabase,positionID=4)#">
                <cfelseif arguments.data.position eq 5>
                and		p.Height >= <cfqueryparam cfsqltype="cf_sql_numeric" value="#getPositionPlayerMinHeight(UserDatabase=arguments.UserDatabase,positionID=5)#">
                </cfif>
            </cfif>
            <cfif Len(Trim(arguments.data.country))>
            and		c.countryTitle = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.data.country#">
            </cfif>
            and		p.SoldorFired = <cfqueryparam cfsqltype="cf_sql_numeric" value="0">
           order by p.CSR Desc
		</cfquery>
        
        <cfset local.result = QueryNew("PlayerID,FirstName,LastName,NickName,Age,CSR,Height,Weight,Top1,Top2,Top3,Top4,Best1,Best2,Best3,Best4,Best5,Best1Value,Best2Value,Best3Value,Best4Value,Best5Value,Team,Handed,Footed,FormLevel,EnergyLevel,AgressionLevel,DisciplineLevel,LeadershipLevel,ExperienceLevel,BRPlayerID,DateAdded,DateLastUpdated,StaminaLevel,AttackLevel,TechniqueLevel,JumpingLevel,AgilityLevel,HandlingLevel,Defenselevel,StrengthLevel,SpeedLevel,KickingLevel,country,injured","integer,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,integer,integer,integer,integer,integer,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,integer,date,date,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,varchar,varchar")>
        
        <cfif local.getPlayers.recordcount>  
            <cfloop query="local.getPlayers">
                <cfset local.playerID = PlayerID>
                <cfset local.include = true>
                                    
                    <cfquery name="local.getCountry" datasource="#arguments.UserDatabase#" maxrows="1">
                    select 	c.CountryTitle
                    from	Countries c
                    where	c.CountryID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#CountryID#">
                    </cfquery>
                    
                    <cfset local.country = local.getCountry.CountryTitle>
                    
                <cfif local.include>
                
                    <cfset QueryAddRow(local.result, 1)>
					<cfset QuerySetCell(local.result, "PlayerID", PlayerID)>
                    <cfset QuerySetCell(local.result, "FirstName", FirstName)>
                    <cfset QuerySetCell(local.result, "LastName", LastName)>
                    <cfset QuerySetCell(local.result, "NickName", NickName)>
                    <cfset QuerySetCell(local.result, "Age", Age)>
                    <cfset QuerySetCell(local.result, "CSR", CSR)>
                    <cfset QuerySetCell(local.result, "Height", Height)>
                    <cfset QuerySetCell(local.result, "Weight", Weight)>
                    <cfset QuerySetCell(local.result, "Team", Team)>
                    <cfset QuerySetCell(local.result, "Handed", Handed)>
                    <cfset QuerySetCell(local.result, "Footed", Footed)>
                    <cfset QuerySetCell(local.result, "FormLevel", FormLevel)>
                    <cfset QuerySetCell(local.result, "EnergyLevel", EnergyLevel)>
                    <cfset QuerySetCell(local.result, "AgressionLevel", AgressionLevel)>
                    <cfset QuerySetCell(local.result, "DisciplineLevel", DisciplineLevel)>
                    <cfset QuerySetCell(local.result, "LeadershipLevel", LeadershipLevel)>
                    <cfset QuerySetCell(local.result, "ExperienceLevel", ExperienceLevel)>
                    <cfset QuerySetCell(local.result, "BRPlayerID", BRPlayerID)>
                    <cfset QuerySetCell(local.result, "DateAdded", DateAdded)>
                    <cfset QuerySetCell(local.result, "DateLastUpdated", DateLastUpdated)>
                    <cfset QuerySetCell(local.result, "country", local.country)>
                    
                    <cfset QuerySetCell(local.result, "StaminaLevel", StaminaLevel)>
                    <cfset QuerySetCell(local.result, "AttackLevel",  AttackLevel)>
                    <cfset QuerySetCell(local.result, "TechniqueLevel",  TechniqueLevel)>
                    <cfset QuerySetCell(local.result, "JumpingLevel",  JumpingLevel)>
                    <cfset QuerySetCell(local.result, "AgilityLevel",  AgilityLevel)>
                    <cfset QuerySetCell(local.result, "HandlingLevel",  HandlingLevel)>
                    <cfset QuerySetCell(local.result, "Defenselevel",  Defenselevel)>
                    <cfset QuerySetCell(local.result, "StrengthLevel",  StrengthLevel)>
                    <cfset QuerySetCell(local.result, "SpeedLevel",  SpeedLevel)>
                    <cfset QuerySetCell(local.result, "KickingLevel",  KickingLevel)>
                    
                    <cfset QuerySetCell(local.result, "injured", injured)>
                    
                    <cfset local.staminaLevelTitle = getStatLevelTitle(staminaLevel,arguments.UserDatabase)>
					<cfset local.AttackLevelTitle = getStatLevelTitle(AttackLevel,arguments.UserDatabase)>
                    <cfset local.TechniqueLevelTitle = getStatLevelTitle(TechniqueLevel,arguments.UserDatabase)>            
                    <cfset local.JumpingLevelTitle = getStatLevelTitle(JumpingLevel,arguments.UserDatabase)>     
                    <cfset local.AgilityLevelTitle = getStatLevelTitle(AgilityLevel,arguments.UserDatabase)>     
                    <cfset local.HandlingLevelTitle = getStatLevelTitle(HandlingLevel,arguments.UserDatabase)>   
                    <cfset local.DefenselevelTitle = getStatLevelTitle(Defenselevel,arguments.UserDatabase)>   
                    <cfset local.StrengthLevelTitle = getStatLevelTitle(StrengthLevel,arguments.UserDatabase)>  
                    <cfset local.SpeedLevelTitle = getStatLevelTitle(SpeedLevel,arguments.UserDatabase)>  
                    <cfset local.KickingLevelTitle = getStatLevelTitle(KickingLevel,arguments.UserDatabase)>   
                    
                    <!--- now get top 6 stats --->
                    <cfset local.listofStatsValuestoCheck = "">
					<cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#staminaLevel#")>
                    <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#AttackLevel#")>
                    <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#TechniqueLevel#")>
                    <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#JumpingLevel#")>
                    <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#AgilityLevel#")>
                    <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#HandlingLevel#")>
                    <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#Defenselevel#")>   
                    <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#StrengthLevel#")>
                    <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#SpeedLevel#")>
                    <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#KickingLevel#")>             
                    <cfset local.listofStatsValuestoCheck = listsort(local.listofStatsValuestoCheck,"numeric","DESC")>
                    
                    <cfset local.finalListofStatstoLookAt = "">
                    <!--- now loop through top 6 values --->
                    <cfloop from="1" to="6" index="local.stvalue">
                    	<cfset local.valuetoCheck = listgetat(local.listofStatsValuestoCheck,local.stvalue)>
                        <cfif staminaLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#staminaLevel#-Stamina-#local.StaminaLevelTitle#")>
                        	<cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#staminaLevel#-Stamina-#local.StaminaLevelTitle#")>
                        </cfif>
                        <cfif AttackLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#AttackLevel#-Attack-#local.AttackLevelTitle#")>
                        	<cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#AttackLevel#-Attack-#local.AttackLevelTitle#")>
                        </cfif>
                        <cfif TechniqueLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#TechniqueLevel#-Technique-#local.TechniqueLevelTitle#")>
                        	<cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#TechniqueLevel#-Technique-#local.TechniqueLevelTitle#")>
                        </cfif>
                        <cfif JumpingLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#JumpingLevel#-Jumping-#local.JumpingLevelTitle#")>
                        	<cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#JumpingLevel#-Jumping-#local.JumpingLevelTitle#")>
                        </cfif>
                        <cfif AgilityLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#AgilityLevel#-Agility-#local.AgilityLevelTitle#")>
                        	<cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#AgilityLevel#-Agility-#local.AgilityLevelTitle#")>
                        </cfif>
                        <cfif HandlingLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#HandlingLevel#-Handling-#local.HandlingLevelTitle#")>
                        	<cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#HandlingLevel#-Handling-#local.HandlingLevelTitle#")>
                        </cfif>
                        <cfif Defenselevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#Defenselevel#-Defense-#local.DefenseLevelTitle#")>
                        	<cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#Defenselevel#-Defense-#local.DefenseLevelTitle#")>
                        </cfif>
                        <cfif StrengthLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#StrengthLevel#-Strength-#local.StrengthLevelTitle#")>
                        	<cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#StrengthLevel#-Strength-#local.StrengthLevelTitle#")>
                        </cfif>
                        <cfif SpeedLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#SpeedLevel#-Speed-#local.SpeedLevelTitle#")>
                        	<cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#SpeedLevel#-Speed-#local.SpeedLevelTitle#")>
                        </cfif>
                        <cfif KickingLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#KickingLevel#-Kicking-#local.KickingLevelTitle#")>
                        	<cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#KickingLevel#-Kicking-#local.KickingLevelTitle#")>   
                        </cfif>
                    </cfloop>
					
                        <cfset local.r = 1>
                        <cfset local.potentialPositions = "">
                                                
                        <cfloop list="#local.finalListofStatstoLookAt#" index="local.st">
                            
                            <cfif local.r lte 4>
                                <!--- getting top 4 stats for display --->
                                <cfquery name="local.getAbbreviation" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                                    select	s.StatAbbr
                                    from	Stats s
                                    where	s.StatTitle = <cfqueryparam cfsqltype="cf_sql_char" value="#listgetat(local.st,'2','-')#">
                                </cfquery>
                                
                                <cfset QuerySetCell(local.result, "Top#local.r#", "#local.getAbbreviation.StatAbbr#: #listgetat(local.st,'3','-')#")>
                                <cfset local.r = local.r + 1>                                
                            </cfif>
                            
                            <cfquery name="local.getStatID" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                                select	s.StatID
                                from	Stats s
                                where	s.StatTitle = <cfqueryparam cfsqltype="cf_sql_char" value="#listgetat(local.st,'2','-')#">
                            </cfquery>

                            
                            <cfquery name="local.checkposition" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                                select	lps.PositionID
                                from	LeaguePositionStats lps
                                where	lps.StatID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.getStatID.StatID#">
                                and		lps.userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
                            </cfquery>

                            <cfif local.checkposition.recordcount>
                                <cfset local.potentialPositions = listAppend(local.potentialPositions,valuelist(local.checkposition.PositionID))>
                            </cfif>                                
                            
                        </cfloop>
                        
                        <cfset local.superFinalPositionsList = "">
                        <!--- loop through all positions --->
						<cfloop from="1" to="15" index="local.i">
                        	<!--- if the position is found in the list 4 times, then we have a winner! :) --->
                            <cfif ListValueCountNoCase(local.potentialPositions, local.i) eq 4>
                                <cfset local.superFinalPositionsList = listAppend(local.superFinalPositionsList,local.i)>
                            </cfif>
                        </cfloop>
                       	
                        <cfset local.cntpos = 0>
                        <cfloop list="#local.superFinalPositionsList#" index="local.postoshow">
                        	<cfif local.cntpos lte 4>
                                <cfquery name="local.getpositionTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                                    select 	p.positionTitle
                                    from	Positions p
                                    where 	p.positionID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.postoshow#">
                                </cfquery>
                                
                                <cfif local.postoshow eq 1 AND Weight gte getPositionPlayerMinWeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=1) AND Height lte getPositionPlayerMaxHeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=1)>
                                    <cfset local.cntpos = local.cntpos+1>
                                    <cfset QuerySetCell(local.result, "Best#local.cntpos#", local.getpositionTitle.positionTitle)>
                                    <cfset QuerySetCell(local.result, "Best#local.cntpos#Value", local.postoshow)>
                                </cfif>
                                <cfif local.postoshow eq 2 AND Weight gte getPositionPlayerMinWeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=2) AND Height lte getPositionPlayerMaxHeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=2)>
                                    <cfset local.cntpos = local.cntpos+1>
                                    <cfset QuerySetCell(local.result, "Best#local.cntpos#", local.getpositionTitle.positionTitle)>
                                    <cfset QuerySetCell(local.result, "Best#local.cntpos#Value", local.postoshow)>
                                </cfif>
                                <cfif local.postoshow eq 3 AND Weight gte getPositionPlayerMinWeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=3) AND Height lte getPositionPlayerMaxHeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=3)>
                                    <cfset local.cntpos = local.cntpos+1>
                                    <cfset QuerySetCell(local.result, "Best#local.cntpos#", local.getpositionTitle.positionTitle)>
                                    <cfset QuerySetCell(local.result, "Best#local.cntpos#Value", local.postoshow)>
                                </cfif>
                                <cfif local.postoshow eq 4 AND Height gte getPositionPlayerMinHeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=4)>
                                    <cfset local.cntpos = local.cntpos+1>
                                    <cfset QuerySetCell(local.result, "Best#local.cntpos#", local.getpositionTitle.positionTitle)>
                                    <cfset QuerySetCell(local.result, "Best#local.cntpos#Value", local.postoshow)>
                                </cfif>
                                <cfif local.postoshow eq 5 AND Height gte getPositionPlayerMinHeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=5)>
                                    <cfset local.cntpos = local.cntpos+1>
                                    <cfset QuerySetCell(local.result, "Best#local.cntpos#", local.getpositionTitle.positionTitle)>
                                    <cfset QuerySetCell(local.result, "Best#local.cntpos#Value", local.postoshow)>
                                </cfif>
                                <cfif local.postoshow neq 1 AND local.postoshow neq 2 AND local.postoshow neq 3 AND local.postoshow neq 4 AND local.postoshow neq 5>
                                    <cfset local.cntpos = local.cntpos+1>
                                    <cfset QuerySetCell(local.result, "Best#local.cntpos#", local.getpositionTitle.positionTitle)>
                                    <cfset QuerySetCell(local.result, "Best#local.cntpos#Value", local.postoshow)>
                                </cfif>
                        	</cfif>
                        </cfloop>
                        
                        <cfif local.cntpos lt 5>
							<cfset local.remaining = 5-#local.cntpos#>
                            <cfset local.start = #local.cntpos#+1>
                            <cfset local.end = #local.cntpos#+#local.remaining#>
                            
                            <cfloop from="#local.start#" to="#local.end#" index="local.posremaining">
                                <cfset QuerySetCell(local.result, "Best#local.posremaining#", "")>
                                <cfset QuerySetCell(local.result, "Best#local.posremaining#Value", "0")>
                            </cfloop>
                   		</cfif>
                                        
                    <!--- now re-order query returns --->
                    <cfquery dbtype="query" name="local.resultinOrder">
                        select	*	  
                        from	[local].result
                        <cfif Len(arguments.data.position)>
                        where	(Best1Value = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.position#"> OR Best2Value = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.position#"> OR Best3Value = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.position#"> OR Best4Value = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.position#"> OR Best5Value = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.position#">)
                        </cfif>
                        <cfif Len(arguments.data.orderBy)>
                            <cfif Len(arguments.data.orderType)>
                            order by #arguments.data.orderBy# #arguments.data.orderType#
                            <cfelse>
                            order by #arguments.data.orderBy# DESC
                            </cfif>
                        <cfelse>
                        order by CSR DESC
                        </cfif>
                    </cfquery>
                                    
                <cfelse>
                	 <!--- now re-order query returns --->
                    <cfquery dbtype="query" name="local.resultinOrder">
                        select	*	  
                        from	[local].result
                        <cfif Len(arguments.data.position)>
                        where	(Best1Value = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.position#"> OR Best2Value = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.position#"> OR Best3Value = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.position#"> OR Best4Value = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.position#"> OR Best5Value = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.position#">)
                        </cfif>
                        <cfif Len(arguments.data.orderBy)>
                            <cfif Len(arguments.data.orderType)>
                            order by #arguments.data.orderBy# #arguments.data.orderType#
                            <cfelse>
                            order by #arguments.data.orderBy# DESC
                            </cfif>
                        <cfelse>
                        order by CSR DESC
                        </cfif>
                    </cfquery>
                </cfif>
                
            </cfloop>
        <cfelse>
        	<!--- now re-order query returns --->
            <cfquery dbtype="query" name="local.resultinOrder">
                select	*	  
                from	[local].result
                <cfif Len(arguments.data.position)>
                        where	(Best1Value = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.position#"> OR Best2Value = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.position#"> OR Best3Value = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.position#"> OR Best4Value = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.position#"> OR Best5Value = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.data.position#">)
                        </cfif>
                <cfif Len(arguments.data.orderBy)>
                    <cfif Len(arguments.data.orderType)>
                    order by #arguments.data.orderBy# #arguments.data.orderType#
                    <cfelse>
                    order by #arguments.data.orderBy# DESC
                    </cfif>
                <cfelse>
                order by CSR DESC
                </cfif>
            </cfquery>
        </cfif>
			
            <cfcatch type="any">
            	<cfdump var="#cfcatch#">
            </cfcatch>
            
        </cftry>
        
		<cfreturn local.resultinOrder>
	</cffunction>

	<cffunction name="getAllPlayers" returntype="query" access="public" hint="returns a list of all players added by the user from the database">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		
        <cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
        	<cftry>
                <cfquery name="local.getPlayers" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                    select	p.PlayerID,
                    		p.BRPlayerID,
                            p.Firstname,
                            p.Lastname,
                            p.Nickname,
                            p.Age,
                            p.Height,
                            p.Weight,
                            p.CSR,
                            p.handed,
                            p.footed,
                            p.FormLevel,
                            p.EnergyLevel,
                            p.AgressionLevel,
                            p.DisciplineLevel,
                            p.LeadershipLevel,
                            p.ExperienceLevel,
                            p.team,
                            p.injured,
                            p.staminaLevel,
                            p.AttackLevel,
                            p.TechniqueLevel,
                            p.JumpingLevel,
                            p.AgilityLevel,
                            p.HandlingLevel,
                            p.Defenselevel,
                            p.StrengthLevel,
                            p.SpeedLevel,
                            p.KickingLevel,
                            p.brt_timestamp,
                            p.salary,
                            c.CountryTitle AS country
                    from	LeaguePlayers p
                    INNER JOIN Countries c
                    ON		p.CountryID = c.countryID
                    where 	p.AddedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
                    and		p.SoldorFired = <cfqueryparam cfsqltype="cf_sql_numeric" value="0">
                    order by p.Lastname ASC
                </cfquery>
                
                <cfset local.result = QueryNew("BRPlayerID,PlayerID,FirstName,LastName,NickName,Age,CSR,Height,Weight,Top1,Top2,Top3,Top4,Best1,Best2,Best3,Best4,Best5,country,handed,footed,FormLevel,EnergyLevel,AgressionLevel,DisciplineLevel,LeadershipLevel,ExperienceLevel,staminalevel,handlinglevel,attacklevel,defenselevel,techniquelevel,strengthlevel,jumpinglevel,speedlevel,agilitylevel,kickinglevel,FormLevelTitle,EnergyLevelTitle,AgressionLevelTitle,DisciplineLevelTitle,LeadershipLevelTitle,ExperienceLevelTitle,staminalevelTitle,handlinglevelTitle,attacklevelTitle,defenselevelTitle,techniquelevelTitle,strengthlevelTitle,jumpinglevelTitle,speedlevelTitle,agilitylevelTitle,kickinglevelTitle,team,injured,brt_timestamp,salary","integer,integer,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,integer")>
                                                                 
                <cfloop query="local.getPlayers">
                    <cfset local.playerID = PlayerID>
                    
					<cfset QueryAddRow(local.result, 1)>
                    <cfset QuerySetCell(local.result, "BRPlayerID", BRPlayerID)>
                    <cfset QuerySetCell(local.result, "PlayerID", PlayerID)>
                    <cfset QuerySetCell(local.result, "FirstName", FirstName)>
                    <cfset QuerySetCell(local.result, "LastName", LastName)>
                    <cfset QuerySetCell(local.result, "NickName", NickName)>
                    <cfset QuerySetCell(local.result, "Age", Age)>
                    <cfset QuerySetCell(local.result, "CSR", CSR)>
                    <cfset QuerySetCell(local.result, "Height", Height)>
                    <cfset QuerySetCell(local.result, "Weight", Weight)>
                    <cfset QuerySetCell(local.result, "country", country)>
                    <cfset QuerySetCell(local.result, "handed", handed)>
                    <cfset QuerySetCell(local.result, "footed", footed)>
                    <cfset QuerySetCell(local.result, "team", team)>
                    
                    <cfset QuerySetCell(local.result, "FormLevel", FormLevel)>
                    <cfset QuerySetCell(local.result, "EnergyLevel", EnergyLevel)>
                    <cfset QuerySetCell(local.result, "AgressionLevel", AgressionLevel)>
                    <cfset QuerySetCell(local.result, "DisciplineLevel", DisciplineLevel)>
                    <cfset QuerySetCell(local.result, "LeadershipLevel", LeadershipLevel)>
                    <cfset QuerySetCell(local.result, "ExperienceLevel", ExperienceLevel)>
                    
                    <cfset QuerySetCell(local.result, "injured", injured)>
                    <cfset QuerySetCell(local.result, "brt_timestamp", brt_timestamp)>
                    <cfset QuerySetCell(local.result, "salary", salary)>
                    
                    <cfquery name="local.getFormLevelTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#" maxrows="1">
                    select 	fl.LevelTitle
                    from	FLELevels fl
                    where	fl.LevelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#FormLevel#">
                    </cfquery>
                    
                    <cfset local.FormLevelTitle = local.getFormLevelTitle.LevelTitle>
                    <cfset QuerySetCell(local.result, "FormLevelTitle", local.FormLevelTitle)>

                    
                    
                    <cfquery name="local.getEnergyLevelTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#" maxrows="1">
                    select 	el.LevelTitle
                    from	EnergyLevels el
                    where	el.LevelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#EnergyLevel#">
                    </cfquery>
                    
                    <cfset local.EnergyLevelTitle = local.getEnergyLevelTitle.LevelTitle>
                    <cfset QuerySetCell(local.result, "EnergyLevelTitle", local.EnergyLevelTitle)>
                    
                    <cfquery name="local.getAgressionLevelTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#" maxrows="1">
                    select 	al.LevelTitle
                    from	AgressionLevels al
                    where	al.LevelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#AgressionLevel#">
                    </cfquery>
                    
                    <cfset local.AgressionLevelTitle = local.getAgressionLevelTitle.LevelTitle>
                    <cfset QuerySetCell(local.result, "AgressionLevelTitle", local.AgressionLevelTitle)>
                    
                    <cfquery name="local.getDisciplineLevelTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#" maxrows="1">
                    select 	dl.LevelTitle
                    from	DisciplineLevels dl
                    where	dl.LevelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#DisciplineLevel#">
                    </cfquery>
                    
                    <cfset local.DisciplineLevelTitle = local.getDisciplineLevelTitle.LevelTitle>
                    <cfset QuerySetCell(local.result, "DisciplineLevelTitle", local.DisciplineLevelTitle)>
                    
                    <cfquery name="local.getLeadershipLevelTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#" maxrows="1">
                    select 	fl.LevelTitle
                    from	FLELevels fl
                    where	fl.LevelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#LeadershipLevel#">
                    </cfquery>
                    
                    <cfset local.LeadershipLevelTitle = local.getLeadershipLevelTitle.LevelTitle>
                    <cfset QuerySetCell(local.result, "LeadershipLevelTitle", local.LeadershipLevelTitle)>
                    
                    <cfquery name="local.getExperienceLevelTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#" maxrows="1">
                    select 	fl.LevelTitle
                    from	FLELevels fl
                    where	fl.LevelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#ExperienceLevel#">
                    </cfquery>
                    
                    <cfset local.ExperienceLevelTitle = local.getExperienceLevelTitle.LevelTitle>
                    <cfset QuerySetCell(local.result, "ExperienceLevelTitle", local.ExperienceLevelTitle)>
                    
                    <cfset local.staminaLevel = staminaLevel>
					<cfset local.staminaLevelTitle = getStatLevelTitle(local.staminaLevel,getFactory().get("session").model.get('SiteDatabase'))>
                    <cfset QuerySetCell(local.result, "staminaLevel", local.staminaLevel)>
                    
                    <cfset local.AttackLevel = AttackLevel>
                    <cfset local.AttackLevelTitle = getStatLevelTitle(local.AttackLevel,getFactory().get("session").model.get('SiteDatabase'))>
                    <cfset QuerySetCell(local.result, "AttackLevel", local.AttackLevel)>
                
                    <cfset local.TechniqueLevel = TechniqueLevel>
                    <cfset local.TechniqueLevelTitle = getStatLevelTitle(local.TechniqueLevel,getFactory().get("session").model.get('SiteDatabase'))>       
                    <cfset QuerySetCell(local.result, "TechniqueLevel", local.TechniqueLevel)>     
                
                    <cfset local.JumpingLevel = JumpingLevel>
                    <cfset local.JumpingLevelTitle = getStatLevelTitle(local.JumpingLevel,getFactory().get("session").model.get('SiteDatabase'))>     
                    <cfset QuerySetCell(local.result, "JumpingLevel", local.JumpingLevel)> 
                    
                    <cfset local.AgilityLevel = AgilityLevel>
                    <cfset local.AgilityLevelTitle = getStatLevelTitle(local.AgilityLevel,getFactory().get("session").model.get('SiteDatabase'))>     
                    <cfset QuerySetCell(local.result, "AgilityLevel", local.AgilityLevel)> 
                    
                    <cfset local.HandlingLevel = HandlingLevel>
                    <cfset local.HandlingLevelTitle = getStatLevelTitle(local.HandlingLevel,getFactory().get("session").model.get('SiteDatabase'))>   
                    <cfset QuerySetCell(local.result, "HandlingLevel", local.HandlingLevel)> 
    
                    <cfset local.Defenselevel = Defenselevel>
                    <cfset local.DefenselevelTitle = getStatLevelTitle(local.Defenselevel,getFactory().get("session").model.get('SiteDatabase'))>   
                    <cfset QuerySetCell(local.result, "Defenselevel", local.Defenselevel)> 
                    
                    <cfset local.StrengthLevel = StrengthLevel>
                    <cfset local.StrengthLevelTitle = getStatLevelTitle(local.StrengthLevel,getFactory().get("session").model.get('SiteDatabase'))>  
                    <cfset QuerySetCell(local.result, "StrengthLevel", local.StrengthLevel)>
                    
                    <cfset local.SpeedLevel = SpeedLevel>
                    <cfset local.SpeedLevelTitle = getStatLevelTitle(local.SpeedLevel,getFactory().get("session").model.get('SiteDatabase'))>  
                    <cfset QuerySetCell(local.result, "SpeedLevel", local.SpeedLevel)>
                    
                    <cfset local.KickingLevel = KickingLevel>
                    <cfset local.KickingLevelTitle = getStatLevelTitle(local.KickingLevel,getFactory().get("session").model.get('SiteDatabase'))> 
                    <cfset QuerySetCell(local.result, "KickingLevel", local.KickingLevel)>

					<!--- now get top 6 stats --->
                    <cfset local.listofStatsValuestoCheck = "">
					<cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#staminaLevel#")>
                    <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#AttackLevel#")>
                    <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#TechniqueLevel#")>
                    <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#JumpingLevel#")>
                    <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#AgilityLevel#")>
                    <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#HandlingLevel#")>
                    <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#Defenselevel#")>   
                    <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#StrengthLevel#")>
                    <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#SpeedLevel#")>
                    <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#KickingLevel#")>             
                    <cfset local.listofStatsValuestoCheck = listsort(local.listofStatsValuestoCheck,"numeric","DESC")>
                    
                    <cfset local.finalListofStatstoLookAt = "">
                    <!--- now loop through top 6 values --->
                    <cfloop from="1" to="6" index="local.stvalue">
                    	<cfset local.valuetoCheck = listgetat(local.listofStatsValuestoCheck,local.stvalue)>
                        <cfif staminaLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#staminaLevel#-Stamina-#local.StaminaLevelTitle#")>
                        	<cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#staminaLevel#-Stamina-#local.StaminaLevelTitle#")>
                        </cfif>
                        <cfif AttackLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#AttackLevel#-Attack-#local.AttackLevelTitle#")>
                        	<cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#AttackLevel#-Attack-#local.AttackLevelTitle#")>
                        </cfif>
                        <cfif TechniqueLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#TechniqueLevel#-Technique-#local.TechniqueLevelTitle#")>
                        	<cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#TechniqueLevel#-Technique-#local.TechniqueLevelTitle#")>
                        </cfif>
                        <cfif JumpingLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#JumpingLevel#-Jumping-#local.JumpingLevelTitle#")>
                        	<cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#JumpingLevel#-Jumping-#local.JumpingLevelTitle#")>
                        </cfif>
                        <cfif AgilityLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#AgilityLevel#-Agility-#local.AgilityLevelTitle#")>
                        	<cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#AgilityLevel#-Agility-#local.AgilityLevelTitle#")>
                        </cfif>
                        <cfif HandlingLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#HandlingLevel#-Handling-#local.HandlingLevelTitle#")>
                        	<cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#HandlingLevel#-Handling-#local.HandlingLevelTitle#")>
                        </cfif>
                        <cfif Defenselevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#Defenselevel#-Defense-#local.DefenseLevelTitle#")>
                        	<cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#Defenselevel#-Defense-#local.DefenseLevelTitle#")>
                        </cfif>
                        <cfif StrengthLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#StrengthLevel#-Strength-#local.StrengthLevelTitle#")>
                        	<cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#StrengthLevel#-Strength-#local.StrengthLevelTitle#")>
                        </cfif>
                        <cfif SpeedLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#SpeedLevel#-Speed-#local.SpeedLevelTitle#")>
                        	<cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#SpeedLevel#-Speed-#local.SpeedLevelTitle#")>
                        </cfif>
                        <cfif KickingLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#KickingLevel#-Kicking-#local.KickingLevelTitle#")>
                        	<cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#KickingLevel#-Kicking-#local.KickingLevelTitle#")>   
                        </cfif>
                    </cfloop>
					
                        <cfset local.r = 1>
                        <cfset local.potentialPositions = "">
                                                
                        <cfloop list="#local.finalListofStatstoLookAt#" index="local.st">
                            
                            <cfif local.r lte 4>
                                <!--- getting top 4 stats for display --->
                                <cfquery name="local.getAbbreviation" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                                    select	s.StatAbbr
                                    from	Stats s
                                    where	s.StatTitle = <cfqueryparam cfsqltype="cf_sql_char" value="#listgetat(local.st,'2','-')#">
                                </cfquery>
                                
                                <cfset QuerySetCell(local.result, "Top#local.r#", "#local.getAbbreviation.StatAbbr#: #listgetat(local.st,'3','-')#")>
                                <cfset local.r = local.r + 1>
                            </cfif>
                            
                            <cfquery name="local.getStatID" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                                select	s.StatID
                                from	Stats s
                                where	s.StatTitle = <cfqueryparam cfsqltype="cf_sql_char" value="#listgetat(local.st,'2','-')#">
                            </cfquery>
                            
                            <cfquery name="local.checkposition" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                                select	lps.PositionID
                                from	LeaguePositionStats lps
                                where	lps.StatID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.getStatID.StatID#">
                                and		lps.userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
                            </cfquery>
                            
                            <cfif local.checkposition.recordcount>
                                <cfset local.potentialPositions = listAppend(local.potentialPositions,valuelist(local.checkposition.PositionID))>
                            </cfif>                                
                            
                        </cfloop>
                        
                        <cfset local.superFinalPositionsList = "">
                        <!--- loop through all positions --->
						<cfloop from="1" to="15" index="local.i">
                        	<!--- if the position is found in the list 4 times, then we have a winner! :) --->
                            <cfif ListValueCountNoCase(local.potentialPositions, local.i) eq 4>
                                <cfset local.superFinalPositionsList = listAppend(local.superFinalPositionsList,local.i)>
                            </cfif>
                        </cfloop>
                       	
                        <cfset local.cntpos = 0>
                        <cfloop list="#local.superFinalPositionsList#" index="local.postoshow">
                        	<cfif local.cntpos lte 4>
                                <cfquery name="local.getpositionTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                                    select 	p.positionTitle
                                    from	Positions p
                                    where 	p.positionID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.postoshow#">
                                </cfquery>
                                
                                <cfif local.postoshow eq 1 AND Weight gte getPositionPlayerMinWeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=1) AND Height lte getPositionPlayerMaxHeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=1)>
                                    <cfset local.cntpos = local.cntpos+1>
                                    <cfset QuerySetCell(local.result, "Best#local.cntpos#", local.getpositionTitle.positionTitle)>
                                </cfif>
                                <cfif local.postoshow eq 2 AND Weight gte getPositionPlayerMinWeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=2) AND Height lte getPositionPlayerMaxHeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=2)>
                                    <cfset local.cntpos = local.cntpos+1>
                                    <cfset QuerySetCell(local.result, "Best#local.cntpos#", local.getpositionTitle.positionTitle)>
                                </cfif>
                                <cfif local.postoshow eq 3 AND Weight gte getPositionPlayerMinWeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=3) AND Height lte getPositionPlayerMaxHeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=3)>
                                    <cfset local.cntpos = local.cntpos+1>
                                    <cfset QuerySetCell(local.result, "Best#local.cntpos#", local.getpositionTitle.positionTitle)>
                                </cfif>
                                <cfif local.postoshow eq 4 AND Height gte getPositionPlayerMinHeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=4)>
                                    <cfset local.cntpos = local.cntpos+1>
                                    <cfset QuerySetCell(local.result, "Best#local.cntpos#", local.getpositionTitle.positionTitle)>
                                </cfif>
                                <cfif local.postoshow eq 5 AND Height gte getPositionPlayerMinHeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=5)>
                                    <cfset local.cntpos = local.cntpos+1>
                                    <cfset QuerySetCell(local.result, "Best#local.cntpos#", local.getpositionTitle.positionTitle)>
                                </cfif>
                                <cfif local.postoshow neq 1 AND local.postoshow neq 2 AND local.postoshow neq 3 AND local.postoshow neq 4 AND local.postoshow neq 5>
                                    <cfset local.cntpos = local.cntpos+1>
                                    <cfset QuerySetCell(local.result, "Best#local.cntpos#", local.getpositionTitle.positionTitle)>
                                </cfif>
                        	</cfif>
                        </cfloop>
                        
                        <cfif local.cntpos lt 5>
							<cfset local.remaining = 5-#local.cntpos#>
                            <cfset local.start = #local.cntpos#+1>
                            <cfset local.end = #local.cntpos#+#local.remaining#>
                            
                            <cfloop from="#local.start#" to="#local.end#" index="local.posremaining">
                                <cfset QuerySetCell(local.result, "Best#local.posremaining#", "")>
                            </cfloop>
                   		</cfif>
                        
                        
                </cfloop>
                
                <cfcatch type="any">
                    <cfset local.result.success = false>
                    <cfset local.result.output = "Database error - please contact IT support">
                    <cfdump var="#cfcatch#">
                </cfcatch>
            </cftry>
				
		<cfreturn local.result>
	</cffunction>

    <cffunction name="getReportPlayers" returntype="query" access="public" hint="returns a list of all players from the database">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		
        <cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
        	<cftry>
                <cfquery name="local.result" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                    select	p.PlayerID,
                            p.Firstname,
                            p.Lastname,
                            p.Nickname,
                            p.Age,
                            p.Height,
                            p.Weight,
                            p.CSR,
                            p.injured,
                            c.CountryTitle AS country
                    from	LeaguePlayers p
                    INNER JOIN Countries c
                    ON		p.countryID = c.countryID
                    where 	p.AddedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
                    and		p.SoldorFired = <cfqueryparam cfsqltype="cf_sql_numeric" value="0">
                    order by p.firstname ASC, p.lastname ASC
                </cfquery>
                                
                <cfcatch type="any">
                    <cfset local.result.success = false>
                    <cfset local.result.output = "Database error - please contact IT support">
                    <cfdump var="#cfcatch#">
                </cfcatch>
            </cftry>
				
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getplayerDetails" returntype="query" access="public" hint="returns details for a specific player">
    	<cfargument name="playerID" type="numeric" required="true" default="0">
        <cfargument name="UserDatabase" type="string" required="true" default="#getFactory().get("session").model.get('SiteDatabase')#">
        <cfargument name="userID" type="numeric" required="true" default="#getFactory().get('login').model.getUser().user.UserID#">
		
		<cfset var local = structNew()>
        
		<cftry>
		<cfquery name="local.getplayerDetails" datasource="#arguments.UserDatabase#">
			select	*
			from	LeaguePlayers lp
			where	lp.playerID = #arguments.playerID#
            and 	lp.AddedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.userID#">
		</cfquery>
        	<cfcatch type="any">
            	<cfdump var="#cfcatch#">
                <cfdump var="#arguments.playerID#">
            </cfcatch>
		</cftry>
        <cfset local.result = QueryNew("PlayerID,FirstName,LastName,NickName,Age,CSR,Height,Weight,Handed,Footed,FormLevel,EnergyLevel,AgressionLevel,DisciplineLevel,LeadershipLevel,ExperienceLevel,Team,BRPlayerID,DateAdded,DateLastUpdated,StaminaLevel,AttackLevel,TechniqueLevel,JumpingLevel,AgilityLevel,HandlingLevel,Defenselevel,StrengthLevel,SpeedLevel,KickingLevel,Top1,Top2,Top3,Top4,best1,best2,best3,best4,best5,StaminaLevelTitle,AttackLevelTitle,TechniqueLevelTitle,JumpingLevelTitle,AgilityLevelTitle,HandlingLevelTitle,DefenselevelTitle,StrengthLevelTitle,SpeedLevelTitle,KickingLevelTitle,FormLevelTitle,EnergyLevelTitle,AgressionLevelTitle,DisciplineLevelTitle,LeadershipLevelTitle,ExperienceLevelTitle,Country,CountryID,injured","integer,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,integer,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,integer,varchar")>
         
        <cfloop query="local.getplayerDetails">
            <cfset local.playerID = PlayerID>
            
            <!--- now get stats --->
				<cfset local.staminaLevel = staminaLevel>
                <cfset local.staminaLevelTitle = getStatLevelTitle(local.staminaLevel,arguments.UserDatabase)>
                
                <cfset local.AttackLevel = AttackLevel>
				<cfset local.AttackLevelTitle = getStatLevelTitle(local.AttackLevel,arguments.UserDatabase)>
            
            	<cfset local.TechniqueLevel = TechniqueLevel>
				<cfset local.TechniqueLevelTitle = getStatLevelTitle(local.TechniqueLevel,arguments.UserDatabase)>            
            
				<cfset local.JumpingLevel = JumpingLevel>
				<cfset local.JumpingLevelTitle = getStatLevelTitle(local.JumpingLevel,arguments.UserDatabase)>     
                
                <cfset local.AgilityLevel = AgilityLevel>
				<cfset local.AgilityLevelTitle = getStatLevelTitle(local.AgilityLevel,arguments.UserDatabase)>     
                
            	<cfset local.HandlingLevel = HandlingLevel>
				<cfset local.HandlingLevelTitle = getStatLevelTitle(local.HandlingLevel,arguments.UserDatabase)>   

                <cfset local.Defenselevel = Defenselevel>
				<cfset local.DefenselevelTitle = getStatLevelTitle(local.Defenselevel,arguments.UserDatabase)>   
                
                <cfset local.StrengthLevel = StrengthLevel>
				<cfset local.StrengthLevelTitle = getStatLevelTitle(local.StrengthLevel,arguments.UserDatabase)>  
                
                <cfset local.SpeedLevel = SpeedLevel>
				<cfset local.SpeedLevelTitle = getStatLevelTitle(local.SpeedLevel,arguments.UserDatabase)>  
                
                <cfset local.KickingLevel = KickingLevel>
				<cfset local.KickingLevelTitle = getStatLevelTitle(local.KickingLevel,arguments.UserDatabase)>             	
                
                <cfquery name="local.getFormLevelTitle" datasource="#arguments.UserDatabase#" maxrows="1">
                select 	fl.LevelTitle
                from	FLELevels fl
                where	fl.LevelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#FormLevel#">
                </cfquery>
                
                <cfset local.FormLevelTitle = local.getFormLevelTitle.LevelTitle>
                
                <cfquery name="local.getEnergyLevelTitle" datasource="#arguments.UserDatabase#" maxrows="1">
                select 	el.LevelTitle
                from	EnergyLevels el
                where	el.LevelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#EnergyLevel#">
                </cfquery>
                
                <cfset local.EnergyLevelTitle = local.getEnergyLevelTitle.LevelTitle>
                
                <cfquery name="local.getAgressionLevelTitle" datasource="#arguments.UserDatabase#" maxrows="1">
                select 	al.LevelTitle
                from	AgressionLevels al
                where	al.LevelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#AgressionLevel#">
                </cfquery>
                
                <cfset local.AgressionLevelTitle = local.getAgressionLevelTitle.LevelTitle>
                
                <cfquery name="local.getDisciplineLevelTitle" datasource="#arguments.UserDatabase#" maxrows="1">
                select 	dl.LevelTitle
                from	DisciplineLevels dl
                where	dl.LevelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#DisciplineLevel#">
                </cfquery>
                
                <cfset local.DisciplineLevelTitle = local.getDisciplineLevelTitle.LevelTitle>
                
                <cfquery name="local.getLeadershipLevelTitle" datasource="#arguments.UserDatabase#" maxrows="1">
                select 	fl.LevelTitle
                from	FLELevels fl
                where	fl.LevelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#LeadershipLevel#">
                </cfquery>
                
                <cfset local.LeadershipLevelTitle = local.getLeadershipLevelTitle.LevelTitle>
                
                <cfquery name="local.getExperienceLevelTitle" datasource="#arguments.UserDatabase#" maxrows="1">
                select 	fl.LevelTitle
                from	FLELevels fl
                where	fl.LevelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#ExperienceLevel#">
                </cfquery>
                
                <cfset local.ExperienceLevelTitle = local.getExperienceLevelTitle.LevelTitle>
                
                <cfquery name="local.getCountry" datasource="#arguments.UserDatabase#" maxrows="1">
                select 	c.CountryTitle
                from	Countries c
                where	c.CountryID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#CountryID#">
                </cfquery>
                
                <cfset local.country = local.getCountry.CountryTitle>
            
				<cfset QueryAddRow(local.result, 1)>
                <cfset QuerySetCell(local.result, "PlayerID", PlayerID)>
                <cfset QuerySetCell(local.result, "FirstName", FirstName)>
                <cfset QuerySetCell(local.result, "LastName", LastName)>
                <cfset QuerySetCell(local.result, "NickName", NickName)>
                <cfset QuerySetCell(local.result, "Age", Age)>
                <cfset QuerySetCell(local.result, "CSR", CSR)>
                <cfset QuerySetCell(local.result, "Height", Height)>
                <cfset QuerySetCell(local.result, "Weight", Weight)>
                <cfset QuerySetCell(local.result, "Handed", Handed)>
                <cfset QuerySetCell(local.result, "Footed", Footed)>
                <cfset QuerySetCell(local.result, "FormLevel", FormLevel)>
                <cfset QuerySetCell(local.result, "EnergyLevel", EnergyLevel)>
                <cfset QuerySetCell(local.result, "AgressionLevel", AgressionLevel)>
                <cfset QuerySetCell(local.result, "DisciplineLevel", DisciplineLevel)>
                <cfset QuerySetCell(local.result, "LeadershipLevel", LeadershipLevel)>
                <cfset QuerySetCell(local.result, "ExperienceLevel", ExperienceLevel)>
                <cfset QuerySetCell(local.result, "Team", Team)>
                <cfset QuerySetCell(local.result, "BRPlayerID", BRPlayerID)>
                <cfset QuerySetCell(local.result, "DateAdded", DateAdded)>
                <cfset QuerySetCell(local.result, "DateLastUpdated", DateLastUpdated)>
                <cfset QuerySetCell(local.result, "StaminaLevel", local.StaminaLevel)>
                <cfset QuerySetCell(local.result, "AttackLevel",  local.AttackLevel)>
                <cfset QuerySetCell(local.result, "TechniqueLevel",  local.TechniqueLevel)>
                <cfset QuerySetCell(local.result, "JumpingLevel",  local.JumpingLevel)>
                <cfset QuerySetCell(local.result, "AgilityLevel",  local.AgilityLevel)>
                <cfset QuerySetCell(local.result, "HandlingLevel",  local.HandlingLevel)>
                <cfset QuerySetCell(local.result, "Defenselevel",  local.Defenselevel)>
                <cfset QuerySetCell(local.result, "StrengthLevel",  local.StrengthLevel)>
                <cfset QuerySetCell(local.result, "SpeedLevel",  local.SpeedLevel)>
                <cfset QuerySetCell(local.result, "KickingLevel",  local.KickingLevel)>
                
                <cfset QuerySetCell(local.result, "StaminaLevelTitle", local.StaminaLevelTitle)>
                <cfset QuerySetCell(local.result, "AttackLevelTitle",  local.AttackLevelTitle)>
                <cfset QuerySetCell(local.result, "TechniqueLevelTitle",  local.TechniqueLevelTitle)>
                <cfset QuerySetCell(local.result, "JumpingLevelTitle",  local.JumpingLevelTitle)>
                <cfset QuerySetCell(local.result, "AgilityLevelTitle",  local.AgilityLevelTitle)>
                <cfset QuerySetCell(local.result, "HandlingLevelTitle",  local.HandlingLevelTitle)>
                <cfset QuerySetCell(local.result, "DefenselevelTitle",  local.DefenselevelTitle)>
                <cfset QuerySetCell(local.result, "StrengthLevelTitle",  local.StrengthLevelTitle)>
                <cfset QuerySetCell(local.result, "SpeedLevelTitle",  local.SpeedLevelTitle)>
                <cfset QuerySetCell(local.result, "KickingLevelTitle",  local.KickingLevelTitle)>
                
                <cfset QuerySetCell(local.result, "FormLevelTitle", local.FormLevelTitle)>
                <cfset QuerySetCell(local.result, "EnergyLevelTitle", local.EnergyLevelTitle)>
                <cfset QuerySetCell(local.result, "AgressionLevelTitle", local.AgressionLevelTitle)>
                <cfset QuerySetCell(local.result, "DisciplineLevelTitle", local.DisciplineLevelTitle)>
                <cfset QuerySetCell(local.result, "LeadershipLevelTitle", local.LeadershipLevelTitle)>
                <cfset QuerySetCell(local.result, "ExperienceLevelTitle", local.ExperienceLevelTitle)>
                <cfset QuerySetCell(local.result, "country", local.country)>
                <cfset QuerySetCell(local.result, "countryID", countryID)>
                <cfset QuerySetCell(local.result, "injured", injured)>
                
                <!--- now get top 6 stats --->
				<cfset local.listofStatsValuestoCheck = "">
                <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#staminaLevel#")>
                <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#AttackLevel#")>
                <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#TechniqueLevel#")>
                <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#JumpingLevel#")>
                <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#AgilityLevel#")>
                <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#HandlingLevel#")>
                <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#Defenselevel#")>   
                <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#StrengthLevel#")>
                <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#SpeedLevel#")>
                <cfset local.listofStatsValuestoCheck = listappend(local.listofStatsValuestoCheck,"#KickingLevel#")>             
                <cfset local.listofStatsValuestoCheck = listsort(local.listofStatsValuestoCheck,"numeric","DESC")>
                
                <cfset local.finalListofStatstoLookAt = "">
                <!--- now loop through top 6 values --->
                <cfloop from="1" to="6" index="local.stvalue">
                    <cfset local.valuetoCheck = listgetat(local.listofStatsValuestoCheck,local.stvalue)>
                    <cfif staminaLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#staminaLevel#-Stamina-#local.StaminaLevelTitle#")>
                        <cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#staminaLevel#-Stamina-#local.StaminaLevelTitle#")>
                    </cfif>
                    <cfif AttackLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#AttackLevel#-Attack-#local.AttackLevelTitle#")>
                        <cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#AttackLevel#-Attack-#local.AttackLevelTitle#")>
                    </cfif>
                    <cfif TechniqueLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#TechniqueLevel#-Technique-#local.TechniqueLevelTitle#")>
                        <cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#TechniqueLevel#-Technique-#local.TechniqueLevelTitle#")>
                    </cfif>
                    <cfif JumpingLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#JumpingLevel#-Jumping-#local.JumpingLevelTitle#")>
                        <cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#JumpingLevel#-Jumping-#local.JumpingLevelTitle#")>
                    </cfif>
                    <cfif AgilityLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#AgilityLevel#-Agility-#local.AgilityLevelTitle#")>
                        <cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#AgilityLevel#-Agility-#local.AgilityLevelTitle#")>
                    </cfif>
                    <cfif HandlingLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#HandlingLevel#-Handling-#local.HandlingLevelTitle#")>
                        <cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#HandlingLevel#-Handling-#local.HandlingLevelTitle#")>
                    </cfif>
                    <cfif Defenselevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#Defenselevel#-Defense-#local.DefenseLevelTitle#")>
                        <cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#Defenselevel#-Defense-#local.DefenseLevelTitle#")>
                    </cfif>
                    <cfif StrengthLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#StrengthLevel#-Strength-#local.StrengthLevelTitle#")>
                        <cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#StrengthLevel#-Strength-#local.StrengthLevelTitle#")>
                    </cfif>
                    <cfif SpeedLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#SpeedLevel#-Speed-#local.SpeedLevelTitle#")>
                        <cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#SpeedLevel#-Speed-#local.SpeedLevelTitle#")>
                    </cfif>
                    <cfif KickingLevel eq local.valuetoCheck AND NOT listfindNoCase(local.finalListofStatstoLookAt,"#KickingLevel#-Kicking-#local.KickingLevelTitle#")>
                        <cfset local.finalListofStatstoLookAt = listappend(local.finalListofStatstoLookAt,"#KickingLevel#-Kicking-#local.KickingLevelTitle#")>   
                    </cfif>
                </cfloop>
                
                    <cfset local.r = 1>
                    <cfset local.potentialPositions = "">
                                            
                    <cfloop list="#local.finalListofStatstoLookAt#" index="local.st">
                        
                        <cfif local.r lte 4>
                            <!--- getting top 4 stats for display --->
                            <cfquery name="local.getAbbreviation" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                                select	s.StatAbbr
                                from	Stats s
                                where	s.StatTitle = <cfqueryparam cfsqltype="cf_sql_char" value="#listgetat(local.st,'2','-')#">
                            </cfquery>
                            
                            <cfset QuerySetCell(local.result, "Top#local.r#", "#local.getAbbreviation.StatAbbr#: #listgetat(local.st,'3','-')#")>
                            <cfset local.r = local.r + 1>
                        </cfif>
                        
                        <cfquery name="local.getStatID" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                            select	s.StatID
                            from	Stats s
                            where	s.StatTitle = <cfqueryparam cfsqltype="cf_sql_char" value="#listgetat(local.st,'2','-')#">
                        </cfquery>
                        
                        <cfquery name="local.checkposition" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                            select	lps.PositionID
                            from	LeaguePositionStats lps
                            where	lps.StatID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.getStatID.StatID#">
                            and		lps.userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.userID#">
                        </cfquery>
                        
                        <cfif local.checkposition.recordcount>
                            <cfset local.potentialPositions = listAppend(local.potentialPositions,valuelist(local.checkposition.PositionID))>
                        </cfif>                                
                        
                    </cfloop>
                    
                    <cfset local.superFinalPositionsList = "">
                    <!--- loop through all positions --->
                    <cfloop from="1" to="15" index="local.i">
                        <!--- if the position is found in the list 4 times, then we have a winner! :) --->
                        <cfif ListValueCountNoCase(local.potentialPositions, local.i) eq 4>
                            <cfset local.superFinalPositionsList = listAppend(local.superFinalPositionsList,local.i)>
                        </cfif>
                    </cfloop>
                    
                    <cfset local.cntpos = 0>
                    <cfloop list="#local.superFinalPositionsList#" index="local.postoshow">
                        <cfif local.cntpos lte 4>
                            <cfquery name="local.getpositionTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                                select 	p.positionTitle
                                from	Positions p
                                where 	p.positionID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.postoshow#">
                            </cfquery>
                            
                            <cfif local.postoshow eq 1 AND Weight gte getPositionPlayerMinWeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=1) AND Height lte getPositionPlayerMaxHeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=1)>
                                <cfset local.cntpos = local.cntpos+1>
                                <cfset QuerySetCell(local.result, "Best#local.cntpos#", local.getpositionTitle.positionTitle)>
                            </cfif>
                            <cfif local.postoshow eq 2 AND Weight gte getPositionPlayerMinWeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=2) AND Height lte getPositionPlayerMaxHeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=2)>
                                <cfset local.cntpos = local.cntpos+1>
                                <cfset QuerySetCell(local.result, "Best#local.cntpos#", local.getpositionTitle.positionTitle)>
                            </cfif>
                            <cfif local.postoshow eq 3 AND Weight gte getPositionPlayerMinWeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=3) AND Height lte getPositionPlayerMaxHeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=3)>
                                <cfset local.cntpos = local.cntpos+1>
                                <cfset QuerySetCell(local.result, "Best#local.cntpos#", local.getpositionTitle.positionTitle)>
                            </cfif>
                            <cfif local.postoshow eq 4 AND Height gte getPositionPlayerMinHeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=4)>
                                <cfset local.cntpos = local.cntpos+1>
                                <cfset QuerySetCell(local.result, "Best#local.cntpos#", local.getpositionTitle.positionTitle)>
                            </cfif>
                            <cfif local.postoshow eq 5 AND Height gte getPositionPlayerMinHeight(UserDatabase=getFactory().get("session").model.get('SiteDatabase'),positionID=5)>
                                <cfset local.cntpos = local.cntpos+1>
                                <cfset QuerySetCell(local.result, "Best#local.cntpos#", local.getpositionTitle.positionTitle)>
                            </cfif>
                            <cfif local.postoshow neq 1 AND local.postoshow neq 2 AND local.postoshow neq 3 AND local.postoshow neq 4 AND local.postoshow neq 5>
                                <cfset local.cntpos = local.cntpos+1>
                                <cfset QuerySetCell(local.result, "Best#local.cntpos#", local.getpositionTitle.positionTitle)>
                            </cfif>
                        </cfif>
                    </cfloop>
                    
                    <cfif local.cntpos lt 5>
                        <cfset local.remaining = 5-#local.cntpos#>
                        <cfset local.start = #local.cntpos#+1>
                        <cfset local.end = #local.cntpos#+#local.remaining#>
                        
                        <cfloop from="#local.start#" to="#local.end#" index="local.posremaining">
                            <cfset QuerySetCell(local.result, "Best#local.posremaining#", "")>
                        </cfloop>
                    </cfif>
        </cfloop>
        
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getAges" returntype="query" access="public" hint="returns a list of all different player ages found in the database">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		<cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
        
		<cfquery name="local.result" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	distinct lp.age
			from	LeaguePlayers lp
            where 	lp.AddedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
            and		lp.SoldorFired = <cfqueryparam cfsqltype="cf_sql_numeric" value="0">
			order by age ASC
		</cfquery>
		
		<cfreturn local.result>
	</cffunction>

    <cffunction name="getaspecificPlayerTeams" returntype="query" access="public" hint="returns teams a specific player is part of">
		<cfargument name="playerID" type="numeric" required="false" default="0">
        
		<cfset var local = structNew()>
		<cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
        <cftry>
                
            <cfquery name="local.result" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                select	ltp.TeamID,
                        lt.TeamTitle,
                        p.positionID,
                        p.positionTitle
                from    LeagueTeamPlayers ltp   
                INNER JOIN LeagueTeams lt
                ON      ltp.TeamID = lt.TeamID  
                INNER JOIN Positions p ON ltp.PositionID = p.PositionID
                where   ltp.PlayerID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.playerID#">
                AND     lt.userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
            </cfquery>
            
            <cfcatch type="any">
                <cfset local.result.success = false>
                <cfset local.result.output = "Database error - please contact IT support">
            </cfcatch>
		</cftry>
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getMyTeams" returntype="query" access="public" hint="returns a list of all the teams added by the user that do not contain the specific player">
		<cfargument name="userID" type="numeric" required="false" default="#getFactory().get('login').model.getUser().user.userID#">
        <cfargument name="playerID" type="numeric" required="false" default="0">
		
		<cfset var local = structNew()>
		
        <!--- first get any teams where the player has been added --->
        <cfquery name="local.teamslinked" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
        	select	ltp.teamID
            from	LeagueTeamPlayers ltp
            where	ltp.playerID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.playerID#">
		</cfquery>
        
		<cfquery name="local.result" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	lt.TeamID,
            		lt.TeamTitle
			from	LeagueTeams lt
            <cfif arguments.userID neq 0>
            where	lt.userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.userID#">
            </cfif>
            <!--- and if the list of teams the user is part of is not empty --->
			<cfif ListLen(ValueList(local.teamslinked.teamID))>
            and		lt.TeamID NOT IN (#ValueList(local.teamslinked.teamID)#)
            </cfif>
			order by lt.TeamTitle
		</cfquery>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getallMyTeams" returntype="query" access="public" hint="returns a list of all the teams added by the user">
		<cfargument name="userID" type="numeric" required="false" default="#getFactory().get('login').model.getUser().user.userID#">
        
		<cfset var local = structNew()>
		
		<cfquery name="local.result" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	lt.TeamTitle,
            		lt.TeamID,
                    lt.DateAdded,
                    lt.DateLastUpdated,
                    lt.Published,
                    lt.DatePublished
            from	LeagueTeams lt
            <cfif arguments.userID neq 0>
            where	lt.userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.userID#">
            </cfif>
            
            order by DateAdded DESC
		</cfquery>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getaspecificTeam" returntype="query" access="public" hint="returns details for a specific team">
		<cfargument name="userID" type="numeric" required="false" default="#getFactory().get('login').model.getUser().user.userID#">
        <cfargument name="teamID" type="numeric" required="false" default="0">
        
		<cfset var local = structNew()>
		
		<cfquery name="local.result" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	t.TeamTitle,
            		t.TeamID,
                    t.DateAdded,
                    t.DateLastUpdated,
            		p.PositionTitle,
                    p.PositionID,
                    pl.Firstname,
                    pl.Lastname,
                    pl.Nickname,
                    pl.PlayerID,
                    pl.injured
            from	 (((LeagueTeams t INNER JOIN LeagueTeamPlayers tp 
            ON 		 t.TeamID = tp.TeamID)
            INNER JOIN Positions p ON tp.PositionID = p.PositionID)
            left outer join LeaguePlayers pl
            on tp.PlayerID = pl.PlayerID)
            where	t.TeamID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.teamID#">
            <cfif arguments.userID neq 0>
            and		((t.userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.userID#"> and t.published=0) OR (t.published=1))
            </cfif>
            
            order by t.TeamTitle,p.DisplayOrder
		</cfquery>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getaspecificPlayer" returntype="query" access="public" hint="returns details for a specific player">
		<cfargument name="playerID" type="numeric" required="false" default="0">
        
		<cfset var local = structNew()>
		<cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
        <cftry>
                
            <cfquery name="local.getplayerDetails" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                select	p.PlayerID,
                		p.BRPlayerID,
                        p.BRTeamID,
                		p.Firstname,
                        p.Nickname,
                        p.Lastname,
                        p.CSR,
                        p.Age,
                        p.Salary,
                        p.Weight,
                        p.Height,
                		p.FormLevel,
                        p.EnergyLevel,
                        p.AgressionLevel,
                        p.DisciplineLevel,
                        p.LeadershipLevel,
                        p.ExperienceLevel,
                        p.InjuredDate,
                        p.injured,
                        p.ContractDate,
                        p.contract,
                        p.Jersey,
                        p.Handed,
                        p.Footed,
                        p.nationality,
                        p.countryID,
                        p.youthID,
                        p.JoinedDate,
                        p.Team,
                        p.DateAdded,
                        p.DateLastUpdated,
                        p.SoldOrFired,
                        p.DateSoldOrFired,
                        p.AddedByUserID,
                        p.LastUpdatedByUserID,
                        p.agilityLevel,
                        p.attackLevel,
                        p.defenseLevel,
                        p.handlingLevel,
                        p.jumpingLevel,
                        p.kickingLevel,
                        p.speedLevel,
                        p.staminaLevel,
                        p.strengthLevel,
                        p.techniqueLevel,
                        c.countryTitle AS country
                from	LeaguePlayers p 
                INNER JOIN Countries c
                ON		p.CountryID = c.countryID
                where	p.PlayerID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.playerID#">
                and 	p.AddedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
            </cfquery>
            
             <!--- if results found --->
             <cfif local.getplayerDetails.recordCount>
                    
                     <cfset local.result = QueryNew("PlayerID,Firstname,Nickname,Lastname,CSR,Age,Weight,Height,Handed,Footed,FormLevel,EnergyLevel,AgressionLevel,DisciplineLevel,LeadershipLevel,ExperienceLevel,Team,DateAdded,DateLastUpdated,StaminaLevel,AttackLevel,TechniqueLevel,JumpingLevel,AgilityLevel,HandlingLevel,Defenselevel,StrengthLevel,SpeedLevel,KickingLevel,Top1,Top2,Top3,Top4,StaminaLevelTitle,AttackLevelTitle,TechniqueLevelTitle,JumpingLevelTitle,AgilityLevelTitle,HandlingLevelTitle,DefenselevelTitle,StrengthLevelTitle,SpeedLevelTitle,KickingLevelTitle,FormLevelTitle,EnergyLevelTitle,AgressionLevelTitle,DisciplineLevelTitle,LeadershipLevelTitle,ExperienceLevelTitle,AddedByUser,LastUpdatedByUser,country,countryID,injured,BRPlayerID","integer,varchar,varchar,varchar,integer,integer,integer,integer,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,integer,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,integer,varchar,varchar")>
                    <!--- now get stats --->
                        
                        <cfset local.staminaLevel = local.getplayerDetails.staminaLevel>
						<cfset local.staminaLevelTitle = getStatLevelTitle(local.staminaLevel,getFactory().get("session").model.get('SiteDatabase'))>
                        
                        <cfset local.AttackLevel = local.getplayerDetails.AttackLevel>
                        <cfset local.AttackLevelTitle = getStatLevelTitle(local.AttackLevel,getFactory().get("session").model.get('SiteDatabase'))>
                    
                        <cfset local.TechniqueLevel = local.getplayerDetails.TechniqueLevel>
                        <cfset local.TechniqueLevelTitle = getStatLevelTitle(local.TechniqueLevel,getFactory().get("session").model.get('SiteDatabase'))>            
                    
                        <cfset local.JumpingLevel = local.getplayerDetails.JumpingLevel>
                        <cfset local.JumpingLevelTitle = getStatLevelTitle(local.JumpingLevel,getFactory().get("session").model.get('SiteDatabase'))>     
                        
                        <cfset local.AgilityLevel = local.getplayerDetails.AgilityLevel>
                        <cfset local.AgilityLevelTitle = getStatLevelTitle(local.AgilityLevel,getFactory().get("session").model.get('SiteDatabase'))>     
                        
                        <cfset local.HandlingLevel = local.getplayerDetails.HandlingLevel>
                        <cfset local.HandlingLevelTitle = getStatLevelTitle(local.HandlingLevel,getFactory().get("session").model.get('SiteDatabase'))>   
        
                        <cfset local.Defenselevel = local.getplayerDetails.Defenselevel>
                        <cfset local.DefenselevelTitle = getStatLevelTitle(local.Defenselevel,getFactory().get("session").model.get('SiteDatabase'))>   
                        
                        <cfset local.StrengthLevel = local.getplayerDetails.StrengthLevel>
                        <cfset local.StrengthLevelTitle = getStatLevelTitle(local.StrengthLevel,getFactory().get("session").model.get('SiteDatabase'))>  
                        
                        <cfset local.SpeedLevel = local.getplayerDetails.SpeedLevel>
                        <cfset local.SpeedLevelTitle = getStatLevelTitle(local.SpeedLevel,getFactory().get("session").model.get('SiteDatabase'))>  
                        
                        <cfset local.KickingLevel = local.getplayerDetails.KickingLevel>
                        <cfset local.KickingLevelTitle = getStatLevelTitle(local.KickingLevel,getFactory().get("session").model.get('SiteDatabase'))> 
                        
                        
                        <cfquery name="local.getFormLevelTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#" maxrows="1">
                        select 	fl.LevelTitle
                        from	FLELevels fl
                        where	fl.LevelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.getplayerDetails.FormLevel#">
                        </cfquery>
                        
                        <cfset local.FormLevelTitle = local.getFormLevelTitle.LevelTitle>
                        
                        <cfquery name="local.getEnergyLevelTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#" maxrows="1">
                        select 	el.LevelTitle
                        from	EnergyLevels el
                        where	el.LevelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.getplayerDetails.EnergyLevel#">
                        </cfquery>
                        
                        <cfset local.EnergyLevelTitle = local.getEnergyLevelTitle.LevelTitle>
                        
                        <cfquery name="local.getAgressionLevelTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#" maxrows="1">
                        select 	al.LevelTitle
                        from	AgressionLevels al
                        where	al.LevelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.getplayerDetails.AgressionLevel#">
                        </cfquery>
                        
                        <cfset local.AgressionLevelTitle = local.getAgressionLevelTitle.LevelTitle>
                        
                        <cfquery name="local.getDisciplineLevelTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#" maxrows="1">
                        select 	dl.LevelTitle
                        from	DisciplineLevels dl
                        where	dl.LevelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.getplayerDetails.DisciplineLevel#">
                        </cfquery>
                        
                        <cfset local.DisciplineLevelTitle = local.getDisciplineLevelTitle.LevelTitle>
                        
                        <cfquery name="local.getLeadershipLevelTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#" maxrows="1">
                        select 	fl.LevelTitle
                        from	FLELevels fl
                        where	fl.LevelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.getplayerDetails.LeadershipLevel#">
                        </cfquery>
                        
                        <cfset local.LeadershipLevelTitle = local.getLeadershipLevelTitle.LevelTitle>
                        
                        <cfquery name="local.getExperienceLevelTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#" maxrows="1">
                        select 	fl.LevelTitle
                        from	FLELevels fl
                        where	fl.LevelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.getplayerDetails.ExperienceLevel#">
                        </cfquery>
                        
                        <cfset local.ExperienceLevelTitle = local.getExperienceLevelTitle.LevelTitle>
                    	
                        
                        <cfquery name="local.AddedByUser" datasource="#getFactory().getDatasource('adminSecurity')#">
                        select 	s.Username
                        from	Security s
                        where	s.UserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.getplayerDetails.AddedByUserID#">
                        </cfquery>
                        
                        <cfset local.AddedByUser = local.AddedByUser.Username>
                        
                        <cfif Len(local.getplayerDetails.LastUpdatedByUserID) AND IsNumeric(local.getplayerDetails.LastUpdatedByUserID)>
                            <cfquery name="local.LastUpdatedByUser" datasource="#getFactory().getDatasource('adminSecurity')#">
                            select 	s.Username
                            from	Security s
                            where	s.UserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.getplayerDetails.LastUpdatedByUserID#">
                            </cfquery>
                            
                            <cfset local.LastUpdatedByUser = local.LastUpdatedByUser.Username>
                        <cfelse>
                        	<cfset local.LastUpdatedByUser = "">
                        </cfif>
                        
                        
                        <cfset local.Country = local.getplayerDetails.country>
                        
						<cfset QueryAddRow(local.result, 1)>
                        <cfset QuerySetCell(local.result, "BRPlayerID", local.getplayerDetails.BRPlayerID)>
                        <cfset QuerySetCell(local.result, "PlayerID", local.getplayerDetails.PlayerID)>
                        <cfset QuerySetCell(local.result, "Firstname", local.getplayerDetails.Firstname)>
                        <cfset QuerySetCell(local.result, "Nickname", local.getplayerDetails.Nickname)>
                        <cfset QuerySetCell(local.result, "Lastname", local.getplayerDetails.Lastname)>
                        <cfset QuerySetCell(local.result, "CSR", local.getplayerDetails.CSR)>
                        <cfset QuerySetCell(local.result, "Age", local.getplayerDetails.Age)>
                        <cfset QuerySetCell(local.result, "Weight", local.getplayerDetails.Weight)>
                        <cfset QuerySetCell(local.result, "Height", local.getplayerDetails.Height)>
                        <cfset QuerySetCell(local.result, "Handed", local.getplayerDetails.Handed)>
                        <cfset QuerySetCell(local.result, "Footed", local.getplayerDetails.Footed)>
                        <cfset QuerySetCell(local.result, "FormLevel", local.getplayerDetails.FormLevel)>
                        <cfset QuerySetCell(local.result, "EnergyLevel", local.getplayerDetails.EnergyLevel)>
                        <cfset QuerySetCell(local.result, "AgressionLevel", local.getplayerDetails.AgressionLevel)>
                        <cfset QuerySetCell(local.result, "DisciplineLevel", local.getplayerDetails.DisciplineLevel)>
                        <cfset QuerySetCell(local.result, "LeadershipLevel", local.getplayerDetails.LeadershipLevel)>
                        <cfset QuerySetCell(local.result, "ExperienceLevel", local.getplayerDetails.ExperienceLevel)>
                        <cfset QuerySetCell(local.result, "Team", local.getplayerDetails.Team)>
                        <cfset QuerySetCell(local.result, "DateAdded", local.getplayerDetails.DateAdded)>
                        <cfset QuerySetCell(local.result, "DateLastUpdated", local.getplayerDetails.DateLastUpdated)>
                        <cfset QuerySetCell(local.result, "StaminaLevel", local.StaminaLevel)>
                        <cfset QuerySetCell(local.result, "AttackLevel",  local.AttackLevel)>
                        <cfset QuerySetCell(local.result, "TechniqueLevel",  local.TechniqueLevel)>
                        <cfset QuerySetCell(local.result, "JumpingLevel",  local.JumpingLevel)>
                        <cfset QuerySetCell(local.result, "AgilityLevel",  local.AgilityLevel)>
                        <cfset QuerySetCell(local.result, "HandlingLevel",  local.HandlingLevel)>
                        <cfset QuerySetCell(local.result, "Defenselevel",  local.Defenselevel)>
                        <cfset QuerySetCell(local.result, "StrengthLevel",  local.StrengthLevel)>
                        <cfset QuerySetCell(local.result, "SpeedLevel",  local.SpeedLevel)>
                        <cfset QuerySetCell(local.result, "KickingLevel",  local.KickingLevel)>
                    
						<cfset QuerySetCell(local.result, "StaminaLevelTitle", local.StaminaLevelTitle)>
                        <cfset QuerySetCell(local.result, "AttackLevelTitle",  local.AttackLevelTitle)>
                        <cfset QuerySetCell(local.result, "TechniqueLevelTitle",  local.TechniqueLevelTitle)>
                        <cfset QuerySetCell(local.result, "JumpingLevelTitle",  local.JumpingLevelTitle)>
                        <cfset QuerySetCell(local.result, "AgilityLevelTitle",  local.AgilityLevelTitle)>
                        <cfset QuerySetCell(local.result, "HandlingLevelTitle",  local.HandlingLevelTitle)>
                        <cfset QuerySetCell(local.result, "DefenselevelTitle",  local.DefenselevelTitle)>
                        <cfset QuerySetCell(local.result, "StrengthLevelTitle",  local.StrengthLevelTitle)>
                        <cfset QuerySetCell(local.result, "SpeedLevelTitle",  local.SpeedLevelTitle)>
                        <cfset QuerySetCell(local.result, "KickingLevelTitle",  local.KickingLevelTitle)>
                        
                        <cfset QuerySetCell(local.result, "FormLevelTitle", local.FormLevelTitle)>
                        <cfset QuerySetCell(local.result, "EnergyLevelTitle", local.EnergyLevelTitle)>
                        <cfset QuerySetCell(local.result, "AgressionLevelTitle", local.AgressionLevelTitle)>
                        <cfset QuerySetCell(local.result, "DisciplineLevelTitle", local.DisciplineLevelTitle)>
                        <cfset QuerySetCell(local.result, "LeadershipLevelTitle", local.LeadershipLevelTitle)>
                        <cfset QuerySetCell(local.result, "ExperienceLevelTitle", local.ExperienceLevelTitle)>
                        
                        <cfset QuerySetCell(local.result, "AddedByUser", local.AddedByUser)>
                        <cfset QuerySetCell(local.result, "LastUpdatedByUser", local.LastUpdatedByUser)>
                        
                        <cfset QuerySetCell(local.result, "Country", local.Country)>
                        <cfset QuerySetCell(local.result, "CountryID", local.getplayerDetails.CountryID)>
                        <cfset QuerySetCell(local.result, "injured", local.getplayerDetails.injured)>
                       
            </cfif>
                            
            <cfcatch type="any">
                <cfset local.result.success = false>
                <cfset local.result.output = "Database error - please contact IT support">
                <cfdump var="#cfcatch#">
            </cfcatch>
		</cftry>
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getMyTeamPlayers" returntype="query" access="public" hint="returns a list of all the players in a selected team">
		<cfargument name="data" type="struct" required="false">
        <cfargument name="teamID" type="numeric" required="false" default="0">
		
		<cfset var local = structNew()>
		
		<cfquery name="local.result" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	*
			from	LeagueTeamPlayers ltp
            <cfif arguments.teamID neq 0>
            where	ltp.teamID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.teamID#">
            </cfif>
		</cfquery>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getaTeamPlayers" returntype="query" access="public" hint="returns a list of all the players in a selected team">
		<cfargument name="teamID" type="numeric" required="false" default="0">
		
		<cfset var local = structNew()>
		
		<cfquery name="local.result" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	distinct pl.Firstname,
                    pl.Lastname,
                    pl.PlayerID
			from	LeaguePlayers pl
            INNER JOIN LeagueTeamPlayers tp
            ON		pl.playerID = tp.PlayerID
            <cfif arguments.teamID neq 0>
            where	tp.teamID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.teamID#">
            </cfif>
		</cfquery>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getaTeamPositions" returntype="query" access="public" hint="returns a list of all the positions for a selected team">
		<cfargument name="data" type="struct" required="false">
        <cfargument name="teamID" type="numeric" required="false" default="0">
		
		<cfset var local = structNew()>
		
		<cfquery name="local.result" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	*
			from	Positions p left outer join LeagueTeamPlayers ltp
            on		p.positionID = ltp.positionID
            <cfif arguments.teamID neq 0>
            where	ltp.teamID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.teamID#">
            </cfif>
		</cfquery>
		
		<cfreturn local.result>
	</cffunction>
   
    <cffunction name="getTeamsAndPositions" returntype="query" access="public" hint="returns a query with necessary information on teams the player is not associated with yet">
    	<cfargument name="userID" type="numeric" required="false" default="#getFactory().get('login').model.getUser().user.userID#">
		<cfargument name="playerID" type="numeric" required="false" default="0">
        
		<cfset var local = structNew()>
        
        <!--- first get any teams where the player has been added --->
        <cfquery name="local.teamslinked" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
        	select	ltp.teamID
            from	LeagueTeamPlayers ltp
            where	ltp.playerID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.playerID#">
		</cfquery>
		
		<cfquery name="local.teams" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
        	select	t.TeamTitle,
            		t.TeamID,
            		p.PositionTitle,
                    p.PositionID,
                    pl.Firstname,
                    pl.Lastname
            from	 (((LeagueTeams t INNER JOIN LeagueTeamPlayers tp 
            ON 		 t.TeamID = tp.TeamID)
            INNER JOIN Positions p ON tp.PositionID = p.PositionID)
            left outer join LeaguePlayers pl
            on tp.PlayerID = pl.PlayerID)
            <cfif arguments.userID neq 0>
            where	t.userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.userID#">
            </cfif>
            <!--- and if the list of teams the user is part of is not empty --->
			<cfif ListLen(ValueList(local.teamslinked.teamID))>
            and		t.TeamID NOT IN (#ValueList(local.teamslinked.teamID)#)
            </cfif>
            and		p.PositionID<>16
            and		p.PositionID<>17
            order by t.TeamTitle,p.PositionID
		</cfquery>
        
		<cfreturn local.teams>
	</cffunction>

    <cffunction name="getAvailablePositions" returntype="query" access="public" hint="returns a query with all available positions in a team">
    	<cfargument name="userID" type="numeric" required="false" default="#getFactory().get('login').model.getUser().user.userID#">
		<cfargument name="teamID" type="numeric" required="false" default="0">
        
		<cfset var local = structNew()>
        
        <!--- first get any teams where the player has been added --->
        <cfquery name="local.availablePositions" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
        	select	ltp.positionID,
                    p.positionTitle
            from	LeagueTeamPlayers ltp
            INNER JOIN Positions p ON ltp.positionID = p.PositionID
            where	ltp.playerID = <cfqueryparam cfsqltype="cf_sql_numeric" value="0">
            and     ltp.teamID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.teamID#">
		</cfquery>
		
		<cfreturn local.availablePositions>
	</cffunction>
    
    <cffunction name="getBlankPlayerFields" returntype="string" access="public" hint="returns a list of all the default player fields from the Players table">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		
		<cfset local.emptyPlayer = getplayerDetails()>
        <cfset local.fieldList = "">
        
        
        <cfloop list="#local.emptyPlayer.columnList#" index="local.col">
        	<cfif local.col neq "playerID" OR local.col neq "dateadded" OR local.col neq "datelastupdated">
        		<cfset local.fieldList = listAppend(local.fieldList,local.col)>
            </cfif>
        </cfloop>
		
		<cfreturn local.fieldList>
	</cffunction>
    
    <cffunction name="checkifPlayerExists" returntype="numeric" access="public" hint="returns the id of a specific player from the database">
    	<cfargument name="firstname" type="string" required="true" default="">
        <cfargument name="lastname" type="string" required="true" default="">
		
		<cfset var local = structNew()>
		<cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
        
		<cfquery name="local.checkifPlayerExists" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	lp.PlayerID
			from	LeaguePlayers lp
			where	lp.firstname = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.firstname#">
            and		lp.lastname = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.lastname#">
            and		lp.AddedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
            and		lp.SoldorFired = <cfqueryparam cfsqltype="cf_sql_numeric" value="0">
		</cfquery>
		
        <cfif local.checkifPlayerExists.recordcount>
        	<cfset local.PlayerID = local.checkifPlayerExists.playerID>
        <cfelse>
        	<cfset local.PlayerID = 0>
        </cfif>
        
		<cfreturn local.PlayerID>
	</cffunction>
    
    <cffunction name="updatePlayerPosition" access="public" returntype="struct" hint="adds a player to an existing team">
		<cfargument name="teamID" type="numeric" required="true" default="0">
        <cfargument name="positionID" type="numeric" required="true" default="0">
        <cfargument name="oldPlayer" type="numeric" required="true" default="0">
        <cfargument name="newPlayer" type="numeric" required="true" default="0">
        <cfargument name="canduplicate" type="boolean" required="true" default="false">
        
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        
        <cfset local.result.success = true>
		
		<cftry>	
        	<!--- Not dealing with captain or kicker position --->
        	<cfif NOT arguments.canduplicate>
				<!--- get current position of player moving into this one --->
                <cfquery datasource="#getFactory().get("session").model.get('SiteDatabase')#" name="local.getnewplayerposition">
                    select		ltp.PositionID
                    from		LeagueTeamPlayers ltp
                    where		ltp.PlayerID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.newPlayer#">
                    and			ltp.TeamID =  <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.teamID#">
                    and			ltp.positionID <> 16
                    and			ltp.positionID <>17
                </cfquery>
                
                <cfset local.switchPosition = local.getnewplayerposition.PositionID>
                
                <cfif Len(local.getnewplayerposition.PositionID) AND local.getnewplayerposition.recordcount>
                	<cfif local.switchPosition neq 0>
                        <cfquery datasource="#getFactory().get("session").model.get('SiteDatabase')#" name="local.updateOldPlayerPosition">
                            update		LeagueTeamPlayers
                            set			PlayerID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.oldPlayer#">
                            where		TeamID =  <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.teamID#">
                            and			PositionID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.switchPosition#">
                           
                        </cfquery>
                    <cfelse>
                    	<cfquery datasource="#getFactory().get("session").model.get('SiteDatabase')#" name="local.updateOldPlayerPosition">
                            delete
                            from		LeagueTeamPlayers 
                            where		PlayerID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.newPlayer#">
                            and		    TeamID =  <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.teamID#">
                            and			PositionID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.switchPosition#">
                        </cfquery>
                    </cfif>
                </cfif>
                
                <cfquery datasource="#getFactory().get("session").model.get('SiteDatabase')#" name="local.updateNewPlayerPosition">
                    update		LeagueTeamPlayers
                    set			PlayerID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.newPlayer#">
                    where		TeamID =  <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.teamID#">
                    and			PositionID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.positionID#">
                   
                </cfquery>
            <!--- kicker or captain...no need to switch...just update the player in the position --->
			<cfelse>
            	<cfquery datasource="#getFactory().get("session").model.get('SiteDatabase')#" name="local.updateOldPlayerPosition">
                    update		LeagueTeamPlayers
                    set			PlayerID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.newPlayer#">
                    where		TeamID =  <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.teamID#">
                    and			PositionID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.positionID#">
                   
                </cfquery>
            </cfif>
			<cfcatch type="any">
            	 <cfset local.result.success = false>
                <cfrethrow>
                <cfdump var="#cfcatch#">
            </cfcatch>
		</cftry>			
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="unassignPlayerPosition" access="public" returntype="struct" hint="adds a player to an existing team">
		<cfargument name="teamID" type="numeric" required="true" default="0">
        <cfargument name="positionID" type="numeric" required="true" default="0">
        <cfargument name="oldPlayer" type="numeric" required="true" default="0">
        <cfargument name="canduplicate" type="boolean" required="true" default="false">
        
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        
        <cfset local.result.success = true>
		
		<cftry>	
        	<!--- Not dealing with captain or kicker position --->
            <cfif NOT arguments.canduplicate>
                <cfquery datasource="#getFactory().get("session").model.get('SiteDatabase')#" name="local.resetOldPlayerPosition">
                    update		LeagueTeamPlayers
                    set			PlayerID = <cfqueryparam cfsqltype="cf_sql_numeric" value="0">
                    where		TeamID =  <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.teamID#">
                    and			PositionID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.positionID#">
                   
                </cfquery>
                
                <cfquery datasource="#getFactory().get("session").model.get('SiteDatabase')#" name="local.movetopool">
                    insert into	LeagueTeamPlayers
                                (PlayerID,
                                TeamID,
                                PositionID)
                    values		(<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.oldPlayer#">,
                                <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.teamID#">,
                                <cfqueryparam cfsqltype="cf_sql_numeric" value="0">)
                </cfquery>
            <!--- kicker or captain...no need to switch...just update the player in the position --->
            <cfelse>
            	<cfquery datasource="#getFactory().get("session").model.get('SiteDatabase')#" name="local.resetOldPlayerPosition">
                    update		LeagueTeamPlayers
                    set			PlayerID = <cfqueryparam cfsqltype="cf_sql_numeric" value="0">
                    where		TeamID =  <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.teamID#">
                    and			PositionID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.positionID#">
                   
                </cfquery>
            </cfif>
			<cfcatch type="any">
            	<cfdump var="#cfcatch#">
            	 <cfset local.result.success = false>
                <cfrethrow>
            </cfcatch>
		</cftry>			
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="addPlayertoTeamexisting" access="public" returntype="struct" hint="adds a player to an existing team">
		<cfargument name="teamID" type="numeric" required="true" default="0">
        <cfargument name="positionID" type="numeric" required="true" default="0">
        <cfargument name="playerID" type="numeric" required="true" default="0">
        
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        
        <cfset local.result.success = true>
		
		<cftry>	
        	<!--- if the user selected a position --->
        	<cfif arguments.positionID neq 0>
                <cfquery datasource="#getFactory().get("session").model.get('SiteDatabase')#" name="local.updateteamplayer">
                    update		LeagueTeamPlayers
                    set			PlayerID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.playerID#">
                    where		TeamID =  <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.teamID#">
                    and			PositionID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.positionID#">
                   
                </cfquery>
            <!--- if the user did not select a position --->
            <cfelse>
            	<cfquery datasource="#getFactory().get("session").model.get('SiteDatabase')#" name="local.updateteamplayer">
                    insert into	LeagueTeamPlayers
                    			(PlayerID,
                                TeamID,
                                PositionID)
                    values		(<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.playerID#">,
                    			<cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.teamID#">,
                                <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.positionID#">)
                </cfquery>
            </cfif>
			<cfcatch type="any">
            	 <cfset local.result.success = false>
                <cfrethrow>
            </cfcatch>
		</cftry>			
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="addPlayertoTeamnew" access="public" returntype="struct" hint="adds a player to a new team">
		<cfargument name="teamTitle" type="string" required="true" default="">
        <cfargument name="positionID" type="numeric" required="true" default="0">
        <cfargument name="positions" type="query" required="true" default="">
        <cfargument name="playerID" type="numeric" required="true" default="0">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        <cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
        
			<cflock name="newteamp" timeout="30" type="exclusive">
				<cftransaction action="begin">
					<cftry>
						<cfquery datasource="#getFactory().get("session").model.get('SiteDatabase')#" name="local.insert">
							insert into LeagueTeams
                            			(UserID,
                                        TeamTitle,
                                        DateAdded
										) 
                            values 		(
                                        <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">,
                                        <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.teamtitle#">,
                                        #CreateODBCDateTime(now())#
                                        )
						</cfquery>
	
						<cfset local.result.id = getFactory().get("databaseUtil").util.getLastTeamID(getFactory().get("session").model.get('SiteDatabase'), "LeagueTeams")>
                        <!--- now insert all of the positions for the team --->
                        <cfset positionInsert(positions=arguments.positions,teamID=local.result.id)>
                        <!--- now update row for specific player updated --->
                        	<cfset addPlayertoTeamexisting(teamID=local.result.id,positionID=arguments.positionID,playerID=arguments.playerID)>
                        
						<cftransaction action="commit"/>
						<cfset local.result.output = "New team added">
						
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
    
    <cffunction name="positionInsert" access="public" returntype="struct" hint="Inserts data regarding a player's position in a specific team">
		<cfargument name="positions" type="query" required="true">
        <cfargument name="teamID" type="numeric" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
		<cftry>	
            
        	<!--- first loop through the stats --->
            <cfloop query="arguments.positions">
            	<cfset local.positionID = #positionID#>
                 
                 <cfquery datasource="#getFactory().get("session").model.get('SiteDatabase')#" name="local.insertteamplayers">
                insert into LeagueTeamPlayers
                            (TeamID,
                            PlayerID,
                            PositionID
                            ) 
                values 		(
                            <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.teamID#">,
                            <cfqueryparam cfsqltype="cf_sql_numeric" value="0">,
                            <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.positionID#">
                            )
            	</cfquery>
                
            </cfloop>
            
			<cfcatch type="any">
                <cfrethrow>
            </cfcatch>
		</cftry>			
		
		<cfreturn local.result>
	</cffunction>

    <cffunction name="getemptyplayerDetails" returntype="query" access="public" hint="returns details for a specific player">
    	<cfargument name="playerID" type="numeric" required="true" default="0">
		
		<cfset var local = structNew()>
		
        <cfset local.result = QueryNew("PlayerID,FirstName,LastName,NickName,Age,CSR,Height,Weight,Handed,Footed,FormLevel,EnergyLevel,AgressionLevel,DisciplineLevel,LeadershipLevel,ExperienceLevel,Team,BRPlayerID,DateAdded,DateLastUpdated,StaminaLevel,AttackLevel,TechniqueLevel,JumpingLevel,AgilityLevel,HandlingLevel,Defenselevel,StrengthLevel,SpeedLevel,KickingLevel,country,injured","integer,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,integer,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar")>
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getFLELevels" returntype="query" access="public" hint="returns a list of all different form, leadership and experience levels">
		<cfargument name="data" type="struct" required="false">
        <cfargument name="levelID" type="numeric" required="false" default="0">
		
		<cfset var local = structNew()>
		
		<cfquery name="local.result" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	fl.LevelID,
            		fl.LevelTitle
			from	FLELevels fl
            <cfif arguments.levelID neq 0>
            where	fl.levelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.levelID#">
            </cfif>
			order by fl.LevelID
		</cfquery>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getEnergyLevels" returntype="query" access="public" hint="returns a list of all different agression levels">
		<cfargument name="data" type="struct" required="false">
        <cfargument name="levelID" type="numeric" required="false" default="0">
		
		<cfset var local = structNew()>
		
		<cfquery name="local.result" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	el.LevelID,
            		el.LevelTitle
			from	EnergyLevels el
            <cfif arguments.levelID neq 0>
            where	el.levelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.levelID#">
            </cfif>
			order by el.LevelID
		</cfquery>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getAgressionLevels" returntype="query" access="public" hint="returns a list of all different agression levels">
		<cfargument name="data" type="struct" required="false">
        <cfargument name="levelID" type="numeric" required="false" default="0">
		
		<cfset var local = structNew()>
		
		<cfquery name="local.result" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	al.LevelID,
            		al.LevelTitle
			from	AgressionLevels al
            <cfif arguments.levelID neq 0>
            where	al.levelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.levelID#">
            </cfif>
			order by al.LevelID
		</cfquery>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getDisciplineLevels" returntype="query" access="public" hint="returns a list of all different agression levels">
		<cfargument name="data" type="struct" required="false">
        <cfargument name="levelID" type="numeric" required="false" default="0">
		
		<cfset var local = structNew()>
		
		<cfquery name="local.result" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	dl.LevelID,
            		dl.LevelTitle
			from	DisciplineLevels dl
            <cfif arguments.levelID neq 0>
            where	dl.levelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.levelID#">
            </cfif>
			order by dl.LevelID
		</cfquery>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getAllStats" returntype="query" access="public" hint="returns a list of all types of stats levels">
		<cfargument name="data" type="struct" required="false">
        <cfargument name="userDatabase" type="string" required="false" default="#getFactory().get("session").model.get('SiteDatabase')#">
		
		<cfset var local = structNew()>
		
		<cfquery name="local.result" datasource="#arguments.userDatabase#">
			select	s.StatID,
            		s.StatTitle
			from	Stats s
			order by s.StatID
		</cfquery>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getStatsLevels" returntype="query" access="public" hint="returns a list of all stats levels">
		<cfargument name="data" type="struct" required="false">
        <cfargument name="levelID" type="numeric" required="false" default="0">
		
		<cfset var local = structNew()>
		
		<cfquery name="local.result" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	sl.LevelID,
            		sl.LevelTitle
			from	StatsLevels sl
            <cfif arguments.levelID neq 0>
            where	sl.levelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.levelID#">
            </cfif>
			order by sl.LevelID
		</cfquery>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getPositions" returntype="query" access="public" hint="returns a list of all the players in a selected team">
		<cfargument name="data" type="struct" required="false">
        
		<cfset var local = structNew()>
		
		<cfquery name="local.result" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	p.PositionID,
            		p.PositionTitle
			from	Positions p
            where	p.positionID <>16
            and		p.positionID<>17
            order by p.PositionID
		</cfquery>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getSearchPositions" returntype="query" access="public" hint="returns a list of all the players in a selected team">
		<cfargument name="data" type="struct" required="false">
        
		<cfset var local = structNew()>
		
		<cfquery name="local.result" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	p.PositionID,
            		p.PositionTitle
			from	Positions p
            where	p.positionID <=15
            order by p.PositionID
		</cfquery>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getOrderingOptions" returntype="string" access="public" hint="returns a list of all the fields a user could possibly order his search results by">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		
		<cfset local.emptyPlayer = getemptyplayerDetails()>
        <cfset local.allStats = getAllStats()>
        <cfset local.fieldList = "">
        
        <!--- fields from the players table --->
        <cfloop list="#local.emptyPlayer.columnList#" index="local.col">
        	<cfif local.col neq "playerID">
            	<cfset local.fieldList = listAppend(local.fieldList,local.col)>
            </cfif>
        </cfloop>
		
		<cfreturn local.fieldList>
	</cffunction>
    
    
    <cffunction name="checkFLELevels" returntype="numeric" access="public" hint="returns the id of a specific FLE level title">
    	<cfargument name="levelTitle" type="string" required="true" default="">
		
		<cfset var local = structNew()>
		
		<cfquery name="local.checkFLELevels" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	fl.levelID
			from	FLELevels fl
			where	fl.levelTitle = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.levelTitle#">
		</cfquery>
		
        <cfif local.checkFLELevels.recordcount>
        	<cfset local.levelID = local.checkFLELevels.levelID>
        <cfelse>
        	<cfset local.levelID = 0>
        </cfif>
        
		<cfreturn local.levelID>
	</cffunction>
    
    <cffunction name="checkEnergyLevels" returntype="numeric" access="public" hint="returns the id of a specific energy level title">
    	<cfargument name="levelTitle" type="string" required="true" default="">
		
		<cfset var local = structNew()>
		
		<cfquery name="local.checkEnergyLevels" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	el.levelID
			from	EnergyLevels el
			where	el.levelTitle = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.levelTitle#">
		</cfquery>
		
        <cfif local.checkEnergyLevels.recordcount>
        	<cfset local.levelID = local.checkEnergyLevels.levelID>
        <cfelse>
        	<cfset local.levelID = 0>
        </cfif>
        
		<cfreturn local.levelID>
	</cffunction>
    
    <cffunction name="checkAgressionLevels" returntype="numeric" access="public" hint="returns the id of a specific agression level title">
    	<cfargument name="levelTitle" type="string" required="true" default="">
		
		<cfset var local = structNew()>
		
		<cfquery name="local.checkAgressionLevels" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	al.levelID
			from	AgressionLevels al
			where	al.levelTitle = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.levelTitle#">
		</cfquery>
		
        <cfif local.checkAgressionLevels.recordcount>
        	<cfset local.levelID = local.checkAgressionLevels.levelID>
        <cfelse>
        	<cfset local.levelID = 0>
        </cfif>
        
		<cfreturn local.levelID>
	</cffunction>
    
    <cffunction name="checkDisciplineLevels" returntype="numeric" access="public" hint="returns the id of a specific discipline level title">
    	<cfargument name="levelTitle" type="string" required="true" default="">
		
		<cfset var local = structNew()>
		
		<cfquery name="local.checkDisciplineLevels" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	dl.levelID
			from	DisciplineLevels dl
			where	dl.levelTitle = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.levelTitle#">
		</cfquery>
		
        <cfif local.checkDisciplineLevels.recordcount>
        	<cfset local.levelID = local.checkDisciplineLevels.levelID>
        <cfelse>
        	<cfset local.levelID = 0>
        </cfif>
        
		<cfreturn local.levelID>
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
        
    <cffunction name="validatePlayerSearch" access="public" returntype="struct">
		<cfargument name="data" type="struct" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		<cfset local.result.errors = ArrayNew(1)>

		<cfset local.valUtil = getFactory().get("validationUtil").util>
		
        <cfif Len(arguments.data.BRPlayerID)>
			<cfset local.tmpError = local.valUtil.validate(
					"Player ID", arguments.data.BRPlayerID, "is-number"
			)>
			<cfif NOT local.tmpError.success>
				<cfset ArrayAppend(local.result.errors, local.tmpError.output)>
			</cfif>
        </cfif>
        
        <cfif Len(arguments.data.age)>
			<cfset local.tmpError = local.valUtil.validate(
                    "Age", arguments.data.age, "is-number"
            )>
            <cfif NOT local.tmpError.success>
                <cfset ArrayAppend(local.result.errors, local.tmpError.output)>
            </cfif>
        </cfif>
        
        <cfif Len(arguments.data.csr)>
			<cfset local.tmpError = local.valUtil.validate(
                    "CSR", arguments.data.csr, "is-number"
            )>
			<cfif NOT local.tmpError.success>
                <cfset ArrayAppend(local.result.errors, local.tmpError.output)>
            </cfif>
        </cfif>
        
        <cfif Len(arguments.data.height)>
			<cfset local.tmpError = local.valUtil.validate(
                    "Height", arguments.data.height, "is-number"
            )>
            <cfif NOT local.tmpError.success>
                <cfset ArrayAppend(local.result.errors, local.tmpError.output)>
            </cfif>
        </cfif>
        
        <cfif Len(arguments.data.weight)>
			<cfset local.tmpError = local.valUtil.validate(
                    "Weight", arguments.data.weight, "is-number"
            )>
            <cfif NOT local.tmpError.success>
                <cfset ArrayAppend(local.result.errors, local.tmpError.output)>
            </cfif>
		</cfif>	

		<cfreturn local.result>
	</cffunction>
    

    <cffunction name="validatepositions" access="public" returntype="struct">
		<cfargument name="data" type="struct" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		<cfset local.result.errors = ArrayNew(1)>

		<cfset local.valUtil = getFactory().get("validationUtil").util>

        <cftry>
		
            <!--- make sure that no 2 stats are the same for the same position --->
            <cfloop from="1" to="15" index="local.p">
                <cfif ((evaluate("arguments.data.stat_#local.p#_1") eq evaluate("arguments.data.stat_#local.p#_2")) OR (evaluate("arguments.data.stat_#local.p#_1") eq evaluate("arguments.data.stat_#local.p#_3")) OR (evaluate("arguments.data.stat_#local.p#_1") eq evaluate("arguments.data.stat_#local.p#_4"))) AND Len(evaluate("arguments.data.stat_#local.p#_1"))>
                    <cfset ArrayAppend(local.result.errors, "You selected the same stat more than once for position #local.p#")>
                <cfelseif ((evaluate("arguments.data.stat_#local.p#_2") eq evaluate("arguments.data.stat_#local.p#_1")) OR (evaluate("arguments.data.stat_#local.p#_2") eq evaluate("arguments.data.stat_#local.p#_3")) OR (evaluate("arguments.data.stat_#local.p#_2") eq evaluate("arguments.data.stat_#local.p#_4")))  AND Len(evaluate("arguments.data.stat_#local.p#_2"))>
                    <cfset ArrayAppend(local.result.errors, "You selected the same stat more than once for position #local.p#")>
                <cfelseif ((evaluate("arguments.data.stat_#local.p#_3") eq evaluate("arguments.data.stat_#local.p#_1")) OR (evaluate("arguments.data.stat_#local.p#_3") eq evaluate("arguments.data.stat_#local.p#_2")) OR (evaluate("arguments.data.stat_#local.p#_3") eq evaluate("arguments.data.stat_#local.p#_4"))) AND Len(evaluate("arguments.data.stat_#local.p#_3"))>
                    <cfset ArrayAppend(local.result.errors, "You selected the same stat more than once for position #local.p#")>
                <cfelseif ((evaluate("arguments.data.stat_#local.p#_4") eq evaluate("arguments.data.stat_#local.p#_1")) OR (evaluate("arguments.data.stat_#local.p#_4") eq evaluate("arguments.data.stat_#local.p#_2")) OR (evaluate("arguments.data.stat_#local.p#_4") eq evaluate("arguments.data.stat_#local.p#_3"))) AND Len(evaluate("arguments.data.stat_#local.p#_4"))>
                    <cfset ArrayAppend(local.result.errors, "You selected the same stat more than once for position #local.p#")>
                </cfif>
            </cfloop>

            <cfcatch type="any">
                <cfdump var="#cfcatch#">
            </cfcatch>

        </cftry>
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getPositionPlayerStats" returntype="query" access="public" hint="returns a list of all stats for positions for the National team">
		<cfargument name="data" type="struct" required="false">
        <cfargument name="positionID" type="numeric" required="true" default="0">
		
		<cfset var local = structNew()>
        <cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
		<cfquery name="local.result" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	lps.PositionID,
            		lps.StatID,
                    lps.OrderofRelevance
			from	LeaguePositionStats lps
            where	lps.PositionID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.positionID#">
            and		lps.userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
            order by lps.OrderofRelevance
		</cfquery>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getPositionPlayerMinWeight" returntype="numeric" access="public" hint="returns the minimum weight for player 1">
		<cfargument name="data" type="struct" required="false">
        <cfargument name="UserDatabase" type="string" required="true" default="#getFactory().get("session").model.get('SiteDatabase')#">
        <cfargument name="positionID" type="numeric" required="true" default="0">
		
		<cfset var local = structNew()>
        <cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
		<cfquery name="local.getvalue" datasource="#arguments.UserDatabase#">
			select	lps.MinWeight
			from	LeaguePositionSizes lps
            where	lps.PositionID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.positionID#">
            and		lps.userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
		</cfquery>
		
        <cfset local.result = local.getvalue.MinWeight>
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getPositionPlayerMaxHeight" returntype="numeric" access="public" hint="returns the minimum weight for player 1">
		<cfargument name="data" type="struct" required="false">
        <cfargument name="UserDatabase" type="string" required="true" default="#getFactory().get("session").model.get('SiteDatabase')#">
        <cfargument name="positionID" type="numeric" required="true" default="0">
		
		<cfset var local = structNew()>
        <cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
		<cfquery name="local.getvalue" datasource="#arguments.UserDatabase#">
			select	lps.MaxHeight
			from	LeaguePositionSizes lps
            where	lps.PositionID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.positionID#">
            and		lps.userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
		</cfquery>
		<cfset local.result = local.getvalue.MaxHeight>
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getPositionPlayerMinHeight" returntype="numeric" access="public" hint="returns the minimum weight for player 1">
		<cfargument name="data" type="struct" required="false">
        <cfargument name="UserDatabase" type="string" required="true" default="#getFactory().get("session").model.get('SiteDatabase')#">
        <cfargument name="positionID" type="numeric" required="true" default="0">
		
		<cfset var local = structNew()>
        <cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
		<cfquery name="local.getvalue" datasource="#arguments.UserDatabase#">
			select	lps.MinHeight
			from	LeaguePositionSizes lps
            where	lps.PositionID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.positionID#">
            and		lps.userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
		</cfquery>
		<cfset local.result = local.getvalue.MinHeight>
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="bestPositionUpdate" access="public" returntype="struct" hint="">
		<cfargument name="data" type="struct" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		<cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
            <cftry>
                <!--- first of all delete --->
                <cfquery datasource="#getFactory().get("session").model.get('SiteDatabase')#" name="local.delete">
                    delete
                    from	LeaguePositionStats
                    where	userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
                </cfquery>
                <!--- now re-insert --->
                
                <cfloop from="1" to="15" index="local.p">
                    <cfloop from="1" to="4" index="local.s">
                        <cfif Len(#evaluate('arguments.data.stat_#local.p#_#local.s#')#)>
                            <cfquery datasource="#getFactory().get("session").model.get('SiteDatabase')#" name="local.update">
                                insert into 	LeaguePositionStats
                                                (PositionID,
                                                StatID,
                                                OrderofRelevance,
                                                userID)
                                values			(<cfqueryparam cfsqltype="cf_sql_numeric" value="#local.p#">,
                                                <cfqueryparam cfsqltype="cf_sql_numeric" value="#evaluate('arguments.data.stat_#local.p#_#local.s#')#">,
                                                <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.s#">,
                                                <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">)
                            </cfquery>
                        </cfif>
                    </cfloop>
                </cfloop>
                
                <cfquery datasource="#getFactory().get("session").model.get('SiteDatabase')#" name="local.delete2">
                    delete
                    from	LeaguePositionSizes
                    where   userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
                </cfquery>
                
                <cfloop from="1" to="3" index="local.po">
                    <cfquery datasource="#getFactory().get("session").model.get('SiteDatabase')#" name="local.update">
                        insert into 	LeaguePositionSizes
                                        (PositionID,
                                        MinWeight,
                                        MaxHeight,
                                        userID)
                        values			(<cfqueryparam cfsqltype="cf_sql_numeric" value="#local.po#">,
                                        <cfqueryparam cfsqltype="cf_sql_numeric" value="#evaluate('arguments.data.minWeight_#local.po#')#">,
                                        <cfqueryparam cfsqltype="cf_sql_numeric" value="#evaluate('arguments.data.maxHeight_#local.po#')#">,
                                        <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">)
                    </cfquery>
                </cfloop>
                
                <cfloop from="4" to="5" index="local.po">
                    <cfquery datasource="#getFactory().get("session").model.get('SiteDatabase')#" name="local.update">
                        insert into 	LeaguePositionSizes
                                        (PositionID,
                                        MinHeight,
                                        userID)
                        values			(<cfqueryparam cfsqltype="cf_sql_numeric" value="#local.po#">,
                                        <cfqueryparam cfsqltype="cf_sql_numeric" value="#evaluate('arguments.data.minHeight_#local.po#')#">,
                                        <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">)
                    </cfquery>
                </cfloop>
                
                
                <cfset local.result.output = "Updated position stats">
                
                <cfcatch type="any">
                    <cfdump var="#cfcatch#">
                    <cfset local.result.success = false>
                    <cfset local.result.output = "Database error - please contact IT support">
                </cfcatch>
            </cftry>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="getAllPotentialPlayers" returntype="query" access="public" hint="returns a list of all the league players added by the user">
		
		<cfset var local = structNew()>
		
        <cfset local.teamDateCreated = #arguments.teamDateCreated#>
		<cfset local.teamDateCreated = #createDatetime(year(local.teamDateCreated),month(local.teamDateCreated),day(local.teamDateCreated),"00","00","01")#>
        
        <cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
		<cfquery name="local.result" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	distinct pl.Firstname,
                    pl.Lastname,
                    pl.PlayerID
			from	LeaguePlayers pl
            where 	AddedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
            and		(DateSoldorFired is NULL OR DateSoldorFired >= #local.teamDateCreated#)
		</cfquery>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="playerShortInsert" access="public" returntype="numeric" hint="">
		<cfargument name="FirstName" type="string" required="true">
        <cfargument name="LastName" type="string" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        
        <cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
					<cftry>
						<cfquery datasource="#getFactory().get("session").model.get('SiteDatabase')#" name="local.insert">
							insert into LeaguePlayers
                            			(FirstName,
                                        LastName,
                                        DateAdded,
                                        DateLastUpdated,
                                        AddedByUserID,
                                        LastUpdatedByUserID,
                                        soldOrFired,
                                        dateSoldOrFired
										) 
                            values 		(
                                        <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.FirstName#">,
                                        <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.LastName#">,
                                        #CreateODBCDateTime(now())#,
                                        #CreateODBCDateTime(now())#,
                                        <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">,
                                        <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">,
                                        1,
                                        #CreateODBCDateTime(now())#
                                        )
						</cfquery>
	                        
						<cfset local.result.output = "New sold or fired player added">
                        
                        <cfset local.result.id = getFactory().get("databaseUtil").util.getLastPlayerID(getFactory().get("session").model.get('SiteDatabase'), "LeaguePlayers")>
                        
						<cfcatch type="any">
                            <cfdump var="#cfcatch#">
							<cfset local.result.success = false>
							<cfset local.result.output = "Database error - please contact IT support">
						</cfcatch>
					</cftry>
		
		<cfreturn local.result.id>
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
    
    <cffunction name="checkifPlayerExistsall" returntype="numeric" access="public" hint="returns the id of a specific player from the database">
    	<cfargument name="firstname" type="string" required="true" default="">
        <cfargument name="lastname" type="string" required="true" default="">
		
		<cfset var local = structNew()>
		<cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
        
		<cfquery name="local.checkifPlayerExists" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	lp.PlayerID
			from	LeaguePlayers lp
			where	lp.firstname = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.firstname#">
            and		lp.lastname = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.lastname#">
            and		lp.AddedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
		</cfquery>
		
        <cfif local.checkifPlayerExists.recordcount>
        	<cfset local.PlayerID = local.checkifPlayerExists.playerID>
        <cfelse>
        	<cfset local.PlayerID = 0>
        </cfif>
        
		<cfreturn local.PlayerID>
	</cffunction>
    
    <cffunction name="checkcountry" returntype="numeric" access="public" hint="returns the id of a specific country">
    	<cfargument name="countryTitle" type="string" required="true" default="">
		
		<cfset var local = structNew()>
		
		<cfquery name="local.checkcountry" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	c.countryID
			from	Countries c
			where	c.countryTitle = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.countryTitle#">
		</cfquery>
		
        <cfif local.checkcountry.recordcount>
        	<cfset local.countryID = local.checkcountry.countryID>
        <cfelse>
        	<cfset local.countryID = 0>
        </cfif>
        
		<cfreturn local.countryID>
	</cffunction>
    
    <cffunction name="getCountryTitle" returntype="string" access="public" hint="returns the name of a country based on id">
    	<cfargument name="countryID" type="numeric" required="true" default="">
		
		<cfset var local = structNew()>
		
		<cfquery name="local.getCountryTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	c.countryTitle
			from	Countries c
			where	countryID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.countryID#">
		</cfquery>
        
		<cfreturn local.getCountryTitle.countryTitle>
	</cffunction>
    
    <cffunction name="getCountryID" returntype="numeric" access="public" hint="returns the name of a country based on CountryCode">
    	<cfargument name="CountryCode" type="string" required="true" default="">
        <cfargument name="userDatabase" type="string" required="false" default="">
		
		<cfset var local = structNew()>
		
		<cfquery name="local.getCountryID" datasource="#arguments.userDatabase#">
			select	c.countryID
			from	Countries c
			where	c.CountryCode = <c fqueryparam cfsqltype="cf_sql_char" value="#arguments.CountryCode#">
		</cfquery>
        
		<cfreturn local.getCountryID.countryID>
	</cffunction>
    
    <cffunction name="sellOrFirePlayer" access="public" returntype="struct" hint="">
		<cfargument name="playerID" type="numeric" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
        <cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
					<cftry>
						<cfquery datasource="#getFactory().get("session").model.get('SiteDatabase')#" name="local.update">
							update 	leaguePlayers
                            set		SoldorFired = <cfqueryparam cfsqltype="cf_sql_numeric" value="1">,
                            		DateSoldorFired = #CreateODBCDateTime(now())#,
                                    DateLastUpdated = #CreateODBCDateTime(now())#,
                                    LastUpdatedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
							where PlayerID = #arguments.playerID#
						</cfquery>
                        						
						<cfset local.result.output = "Sold or Fired player (#arguments.playerID#)">
						                        
						<cfcatch type="any">
                            <cfdump var="#cfcatch#">
							<cfset local.result.success = false>
							<cfset local.result.output = "Database error - please contact IT support">
						</cfcatch>
					</cftry>
		
		<cfreturn local.result>
	</cffunction>
    
    
    <cffunction name="getStatLevelTitle" returntype="string" access="public" hint="returns the title of a specific statlevel">
		<cfargument name="levelID" type="numeric" required="false" default="0">
		<cfargument name="UserDatabase" type="string" required="false" default="">
        
		<cfset var local = structNew()>
		<cfquery name="local.result" datasource="#arguments.UserDatabase#" maxrows="1">
        select 	sl.LevelTitle
        from	StatsLevels sl
        where	sl.levelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.levelID#">
        
        </cfquery>
		
		<cfreturn local.result.LevelTitle>
	</cffunction>
    
    <!---
    <cffunction name="resetAllData" access="public" returntype="struct">
		
        <cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        <cfset local.result.success = true>
        
        <cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
		<cftry>
        	<!--- DEAL WITH THE PLAYERS --->
            <cfquery name="local.getPlayers" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                select	lp.PlayerID
                from	LeaguePlayers lp
                where 	lp.AddedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
            </cfquery>
			<!--- delete the user's players --->
            <cfloop query="local.getPlayers">
				<cfset local.deletePlayers = deletePlayer(playerID)>
            </cfloop>
            
            <!--- DEAL WITH THE MATCHES --->
            <cfquery name="local.getMatches" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                select	lm.MatchID
                from	LeagueMatches lm
                where	lm.userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
            </cfquery>
            <!--- delete the user's matches --->
            <cfloop query="local.getMatches">
				<cfset local.deleteMatches = getFactory().get("leagueMatches").model.deleteMatch(MatchID)>
            </cfloop>
            
            
            <!--- DEAL WITH THE TEAMS --->
            <cfquery name="local.getTeams" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                select	lt.TeamID
                from	LeagueTeams lt
                where	lt.userID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
            </cfquery>
            <!--- delete the user's teams --->
            <cfloop query="local.getTeams">
				<cfset local.deleteTeams = getFactory().get("leagueTeams").model.deleteTeam(TeamID)>
            </cfloop>
            
			<cfcatch type="any">
				<cfset local.result.success = false>
                <cfset local.result.output = "Database error - please contact IT support">
			</cfcatch>
		</cftry>
        <cfreturn local.result>
	</cffunction>
    --->
    
    <cffunction name="getAllValidPlayersForUser" returntype="string" access="public" hint="returns a list of all players from the database">
		<cfargument name="userID" type="numeric" required="false" default="0">
        <cfargument name="userDatabase" type="string" required="false" default="">
		<cfset var local = structNew()>
		        
        <cfquery name="local.getAllPlayersForUser" datasource="#arguments.userDatabase#">
            select	lp.BRPlayerID
            from	LeaguePlayers lp
            where 	lp.AddedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.userID#">
            and		lp.SoldorFired = <cfqueryparam cfsqltype="cf_sql_numeric" value="0">
        </cfquery>
                
        <cfset local.result = valuelist(local.getAllPlayersForUser.BRPlayerID)>
        
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="setSoldorFired" returntype="any" access="public" hint="updates the SoldorFired status of a player">
		<cfargument name="userID" type="numeric" required="false" default="0">
        <cfargument name="BRPlayerID" type="numeric" required="false" default="0">
        
		<cfset var local = structNew()>
        <cfset local.result = getFactory().getResult()>
		        
        <cfquery name="local.getAllPlayersForUser" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
            update	LeaguePlayers 
            set		SoldorFired = <cfqueryparam cfsqltype="cf_sql_numeric" value="1">,
            		DateSoldOrFired = #now()#
            where 	AddedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.userID#">
            and		BRPlayerID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.BRPlayerID#">
        </cfquery>
                        
		<cfreturn local.result>
	</cffunction>
    
    
    <cffunction name="getplayerDetailsFromBRPlayerID" returntype="query" access="public" hint="returns details for a specific player">
    	<cfargument name="BRPlayerID" type="numeric" required="true" default="0">
        <cfargument name="userDatabase" type="string" required="false" default="">
        <cfargument name="userID" type="numeric" required="false" default="0">
		
		<cfset var local = structNew()>
        
		<cftry>
		<cfquery name="local.getplayerDetails" datasource="#arguments.userDatabase#">
			select	*
			from	LeaguePlayers lp
			where	lp.BRPlayerID = #arguments.BRPlayerID#
            and 	lp.AddedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.userID#">
		</cfquery>
        	<cfcatch type="any">
            	<cfdump var="#cfcatch#">
                <cfdump var="#arguments.playerID#">
            </cfcatch>
		</cftry>
        
		<cfreturn local.getplayerDetails>
	</cffunction>
    
    
    <cffunction name="getAllPlayersLastHistory" returntype="array" access="public" hint="returns information about what has changed on the last update">
        <cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		
        <cfset local.allplayers = getAllPlayers()>
        <cfset local.finalplayers = arrayNew(1)>
        <cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
        <cfset local.userDatabase = getFactory().get("session").model.get('SiteDatabase')>
        
        <cfloop query="local.allplayers">
        	<cfset local.p = structNew()>
            <cfset local.p.fullname = firstname & " " & lastname>
            <cfset local.p.playerID = playerID>
            <cfset local.changes = structNew()>
            <cfset local.changes.positive = arrayNew(1)>
            <cfset local.changes.negative = arrayNew(1)>
            <cfset local.changes.standard = arrayNew(1)>
            
            <!--- get last bit of history (but not current) --->
            <cfquery name="local.lastupdate" datasource="#getFactory().get("session").model.get('SiteDatabase')#" maxrows="1">
                select	*
                from	LeaguePlayersHistory lph
                where	lph.PlayerID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#PlayerID#">
                and		lph.BRPlayerID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#BRPlayerID#">
                and		lph.AddedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
                <!--- we don't want to get the current record --->
                and		lph.brt_timestamp <> <cfqueryparam cfsqltype="cf_sql_char" value="#brt_timestamp#">
                order by historyID DESC
            </cfquery>
            
            
            <!--- only worth checking if there is a previous record! :) --->
            <cfif local.lastupdate.recordcount>
            
				<!--- now compare --->
                <cfif age neq local.lastupdate.age>
                	<cfset ArrayAppend(local.changes.standard, "The player is now #age# years old!")>
                </cfif>
                <cfif csr neq local.lastupdate.csr>
                	<cfset local.csrdiff = csr-local.lastupdate.csr>
                    <cfif local.csrdiff gt 0>
                    	<cfset ArrayAppend(local.changes.positive, "The player's CSR has gone up (+#local.csrdiff#)")>
                    <cfelseif local.csrdiff lt 0>
                    	<cfset ArrayAppend(local.changes.negative, "The player's CSR has gone down (#local.csrdiff#)")>
                    </cfif>
                </cfif>
                <cfif salary neq local.lastupdate.salary>
                	<cfset local.salarydiff = salary-local.lastupdate.salary>
                    <cfif local.salarydiff gt 0>
                    	<cfset ArrayAppend(local.changes.positive, "The player's salary has gone up (+$#local.salarydiff#)")>
                    <cfelseif local.salarydiff lt 0>
                    	<cfset ArrayAppend(local.changes.negative, "The player's salary has gone down (-$#Abs(local.salarydiff)#)")>
                    </cfif>
                </cfif>
                <cfif Height neq local.lastupdate.Height>
                	<cfset ArrayAppend(local.changes.standard, "The player is now #Height# cms tall!")>
                </cfif>
                <cfif Weight neq local.lastupdate.Weight>
                	<cfset ArrayAppend(local.changes.standard, "The player is now weighing #Weight# kgs!")>
                </cfif>
                
                
                <cfif FormLevel neq local.lastupdate.FormLevel>
                	<cfquery name="local.getpreviousFormLevelTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#" maxrows="1">
                    select 	fl.LevelTitle
                    from	FLELevels fl
                    where	fl.LevelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.lastupdate.FormLevel#">
                    </cfquery>
                	<cfset local.previousformleveltitle = local.getpreviousFormLevelTitle.LevelTitle>
                    <cfset local.formleveldiff = formlevel-local.lastupdate.FormLevel>
                    <cfif local.formleveldiff gt 0>
                    	<cfset ArrayAppend(local.changes.positive, "The player's form has gone from #local.previousformleveltitle# to #formleveltitle# (+#local.formleveldiff#)")>
                    <cfelseif local.formleveldiff lt 0>
                    	<cfset ArrayAppend(local.changes.negative, "The player's form has gone from #local.previousformleveltitle# to #formleveltitle# (#local.formleveldiff#)")>
                    </cfif>
                </cfif>
                <cfif EnergyLevel neq local.lastupdate.EnergyLevel>
                	<cfquery name="local.getpreviousenergyLevelTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#" maxrows="1">
                    select 	fl.LevelTitle
                    from	FLELevels fl
                    where	fl.LevelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.lastupdate.energyLevel#">
                    </cfquery>
                	<cfset local.previousenergyleveltitle = local.getpreviousenergyLevelTitle.LevelTitle>
                    <cfset local.energyleveldiff = energylevel-local.lastupdate.energyLevel>
                    <cfif local.energyleveldiff gt 0>
                    	<cfset ArrayAppend(local.changes.positive, "The player's energy has gone from #local.previousenergyleveltitle# to #energyleveltitle# (+#local.energyleveldiff#)")>
                    <cfelseif local.energyleveldiff lt 0>
                    	<cfset ArrayAppend(local.changes.negative, "The player's energy has gone from #local.previousenergyleveltitle# to #energyleveltitle# (#local.energyleveldiff#)")>
                    </cfif>
                </cfif>
                <cfif AgressionLevel neq local.lastupdate.AgressionLevel>
                	<cfquery name="local.getpreviousagressionLevelTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#" maxrows="1">
                    select 	fl.LevelTitle
                    from	FLELevels fl
                    where	fl.LevelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.lastupdate.agressionLevel#">
                    </cfquery>
                	<cfset local.previousagressionleveltitle = local.getpreviousagressionLevelTitle.LevelTitle>
                    <cfset local.agressionleveldiff = agressionlevel-local.lastupdate.agressionLevel>
                    <cfif local.agressionleveldiff gt 0>
                    	<cfset ArrayAppend(local.changes.positive, "The player's agression has gone from #local.previousagressionleveltitle# to #agressionleveltitle# (+#local.agressionleveldiff#)")>
                    <cfelseif local.agressionleveldiff lt 0>
                    	<cfset ArrayAppend(local.changes.negative, "The player's agression has gone from #local.previousagressionleveltitle# to #agressionleveltitle# (#local.agressionleveldiff#)")>
                    </cfif>
                </cfif>
                <cfif DisciplineLevel neq local.lastupdate.DisciplineLevel>
                	<cfquery name="local.getpreviousdisciplineLevelTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#" maxrows="1">
                    select 	fl.LevelTitle
                    from	FLELevels fl
                    where	fl.LevelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.lastupdate.disciplineLevel#">
                    </cfquery>
                	<cfset local.previousdisciplineleveltitle = local.getpreviousdisciplineLevelTitle.LevelTitle>
                    <cfset local.disciplineleveldiff = disciplinelevel-local.lastupdate.disciplineLevel>
                    <cfif local.disciplineleveldiff gt 0>
                    	<cfset ArrayAppend(local.changes.positive, "The player's discipline has gone from #local.previousdisciplineleveltitle# to #disciplineleveltitle# (+#local.disciplineleveldiff#)")>
                    <cfelseif local.disciplineleveldiff lt 0>
                    	<cfset ArrayAppend(local.changes.negative, "The player's discipline has gone from #local.previousdisciplineleveltitle# to #disciplineleveltitle# (#local.disciplineleveldiff#)")>
                    </cfif>
                </cfif>
                <cfif LeadershipLevel neq local.lastupdate.LeadershipLevel>
                	<cfquery name="local.getpreviousleadershipLevelTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#" maxrows="1">
                    select 	fl.LevelTitle
                    from	FLELevels fl
                    where	fl.LevelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.lastupdate.leadershipLevel#">
                    </cfquery>
                	<cfset local.previousleadershipleveltitle = local.getpreviousleadershipLevelTitle.LevelTitle>
                    <cfset local.leadershipleveldiff = leadershiplevel-local.lastupdate.leadershipLevel>
                    <cfif local.leadershipleveldiff gt 0>
                    	<cfset ArrayAppend(local.changes.positive, "The player's leadership has gone from #local.previousleadershipleveltitle# to #leadershipleveltitle# (+#local.leadershipleveldiff#)")>
                    <cfelseif local.leadershipleveldiff lt 0>
                    	<cfset ArrayAppend(local.changes.negative, "The player's leadership has gone from #local.previousleadershipleveltitle# to #leadershipleveltitle# (#local.leadershipleveldiff#)")>
                    </cfif>
                </cfif>
                <cfif ExperienceLevel neq local.lastupdate.ExperienceLevel>
                	<cfquery name="local.getpreviousexperienceLevelTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#" maxrows="1">
                    select 	fl.LevelTitle
                    from	FLELevels fl
                    where	fl.LevelID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.lastupdate.experienceLevel#">
                    </cfquery>
                	<cfset local.previousexperienceleveltitle = local.getpreviousexperienceLevelTitle.LevelTitle>
                    <cfset local.experienceleveldiff = experiencelevel-local.lastupdate.experienceLevel>
                    <cfif local.experienceleveldiff gt 0>
                    	<cfset ArrayAppend(local.changes.positive, "The player's experience has gone from #local.previousexperienceleveltitle# to #experienceleveltitle# (+#local.experienceleveldiff#)")>
                    <cfelseif local.experienceleveldiff lt 0>
                    	<cfset ArrayAppend(local.changes.negative, "The player's experience has gone from #local.previousexperienceleveltitle# to #experienceleveltitle# (#local.experienceleveldiff#)")>
                    </cfif>
                </cfif>
                <cfif Injured neq local.lastupdate.Injured>
                	<cfif injured and NOT local.lastupdate.Injured>
                    	<cfset ArrayAppend(local.changes.negative, "The player is now injured")>
                    <cfelse>
                    	<cfset ArrayAppend(local.changes.positive, "The player is no longer injured")>
                    </cfif>
                </cfif>
                
                <cfif agilityLevel neq local.lastupdate.agilityLevel>
                	<cfset local.previousAgilityLevelTitle = getStatLevelTitle(local.lastupdate.agilityLevel,local.UserDatabase)>
                    <cfset local.agilitydiff = agilityLevel-local.lastupdate.agilityLevel>
                    <cfif local.agilitydiff gt 0>
                    	<cfset ArrayAppend(local.changes.positive, "The player's agility has gone from #AgilityLevelTitle# to #local.previousAgilityLevelTitle# (+#local.agilitydiff#)")>
                    <cfelseif local.agilitydiff lt 0>
                    	<cfset ArrayAppend(local.changes.negative, "The player's agility has gone from #AgilityLevelTitle# to #local.previousAgilityLevelTitle# (#local.agilitydiff#)")>
                    </cfif>
                </cfif>
                <cfif attackLevel neq local.lastupdate.attackLevel>
                	<cfset local.previousattackLevelTitle = getStatLevelTitle(local.lastupdate.attackLevel,local.UserDatabase)>
                    <cfset local.attackdiff = attackLevel-local.lastupdate.attackLevel>
                    <cfif local.attackdiff gt 0>
                    	<cfset ArrayAppend(local.changes.positive, "The player's attack has gone from #attackLevelTitle# to #local.previousattackLevelTitle# (+#local.attackdiff#)")>
                    <cfelseif local.attackdiff lt 0>
                    	<cfset ArrayAppend(local.changes.negative, "The player's attack has gone from #attackLevelTitle# to #local.previousattackLevelTitle# (#local.attackdiff#)")>
                    </cfif>
                </cfif>
                <cfif defenseLevel neq local.lastupdate.defenseLevel>
                	<cfset local.previousdefenseLevelTitle = getStatLevelTitle(local.lastupdate.defenseLevel,local.UserDatabase)>
                    <cfset local.defensediff = defenseLevel-local.lastupdate.defenseLevel>
                    <cfif local.defensediff gt 0>
                    	<cfset ArrayAppend(local.changes.positive, "The player's defense has gone from #defenseLevelTitle# to #local.previousdefenseLevelTitle# (+#local.defensediff#)")>
                    <cfelseif local.defensediff lt 0>
                    	<cfset ArrayAppend(local.changes.negative, "The player's defense has gone from #defenseLevelTitle# to #local.previousdefenseLevelTitle# (#local.defensediff#)")>
                    </cfif>
                </cfif>
                <cfif handlingLevel neq local.lastupdate.handlingLevel>
                	<cfset local.previoushandlingLevelTitle = getStatLevelTitle(local.lastupdate.handlingLevel,local.UserDatabase)>
                    <cfset local.handlingdiff = handlingLevel-local.lastupdate.handlingLevel>
                    <cfif local.handlingdiff gt 0>
                    	<cfset ArrayAppend(local.changes.positive, "The player's handling has gone from #handlingLevelTitle# to #local.previoushandlingLevelTitle# (+#local.handlingdiff#)")>
                    <cfelseif local.handlingdiff lt 0>
                    	<cfset ArrayAppend(local.changes.negative, "The player's handling has gone from #handlingLevelTitle# to #local.previoushandlingLevelTitle# (#local.handlingdiff#)")>
                    </cfif>
                </cfif>
                <cfif jumpingLevel neq local.lastupdate.jumpingLevel>
                	<cfset local.previousjumpingLevelTitle = getStatLevelTitle(local.lastupdate.jumpingLevel,local.UserDatabase)>
                    <cfset local.jumpingdiff = jumpingLevel-local.lastupdate.jumpingLevel>
                    <cfif local.jumpingdiff gt 0>
                    	<cfset ArrayAppend(local.changes.positive, "The player's jumping has gone from #jumpingLevelTitle# to #local.previousjumpingLevelTitle# (+#local.jumpingdiff#)")>
                    <cfelseif local.jumpingdiff lt 0>
                    	<cfset ArrayAppend(local.changes.negative, "The player's jumping has gone from #jumpingLevelTitle# to #local.previousjumpingLevelTitle# (#local.jumpingdiff#)")>
                    </cfif>
                </cfif>
                <cfif kickingLevel neq local.lastupdate.kickingLevel>
                	<cfset local.previouskickingLevelTitle = getStatLevelTitle(local.lastupdate.kickingLevel,local.UserDatabase)>
                    <cfset local.kickingdiff = kickingLevel-local.lastupdate.kickingLevel>
                    <cfif local.kickingdiff gt 0>
                    	<cfset ArrayAppend(local.changes.positive, "The player's kicking has gone from #kickingLevelTitle# to #local.previouskickingLevelTitle# (+#local.kickingdiff#)")>
                    <cfelseif local.kickingdiff lt 0>
                    	<cfset ArrayAppend(local.changes.negative, "The player's kicking has gone from #kickingLevelTitle# to #local.previouskickingLevelTitle# (#local.kickingdiff#)")>
                    </cfif>
                </cfif>
                <cfif speedLevel neq local.lastupdate.speedLevel>
                	<cfset local.previousspeedLevelTitle = getStatLevelTitle(local.lastupdate.speedLevel,local.UserDatabase)>
                    <cfset local.speeddiff = speedLevel-local.lastupdate.speedLevel>
                    <cfif local.speeddiff gt 0>
                    	<cfset ArrayAppend(local.changes.positive, "The player's speed has gone from #speedLevelTitle# to #local.previousspeedLevelTitle# (+#local.speeddiff#)")>
                    <cfelseif local.speeddiff lt 0>
                    	<cfset ArrayAppend(local.changes.negative, "The player's speed has gone from #speedLevelTitle# to #local.previousspeedLevelTitle# (#local.speeddiff#)")>
                    </cfif>
                </cfif>
                <cfif staminaLevel neq local.lastupdate.staminaLevel>
                	<cfset local.previousstaminaLevelTitle = getStatLevelTitle(local.lastupdate.staminaLevel,local.UserDatabase)>
                    <cfset local.staminadiff = staminaLevel-local.lastupdate.staminaLevel>
                    <cfif local.staminadiff gt 0>
                    	<cfset ArrayAppend(local.changes.positive, "The player's stamina has gone from #staminaLevelTitle# to #local.previousstaminaLevelTitle# (+#local.staminadiff#)")>
                    <cfelseif local.staminadiff lt 0>
                    	<cfset ArrayAppend(local.changes.negative, "The player's stamina has gone from #staminaLevelTitle# to #local.previousstaminaLevelTitle# (#local.staminadiff#)")>
                    </cfif>
                </cfif>
                <cfif strengthLevel neq local.lastupdate.strengthLevel>
                	<cfset local.previousstrengthLevelTitle = getStatLevelTitle(local.lastupdate.strengthLevel,local.UserDatabase)>
                    <cfset local.strengthdiff = strengthLevel-local.lastupdate.strengthLevel>
                    <cfif local.strengthdiff gt 0>
                    	<cfset ArrayAppend(local.changes.positive, "The player's strength has gone from #strengthLevelTitle# to #local.previousstrengthLevelTitle# (+#local.strengthdiff#)")>
                    <cfelseif local.strengthdiff lt 0>
                    	<cfset ArrayAppend(local.changes.negative, "The player's strength has gone from #strengthLevelTitle# to #local.previousstrengthLevelTitle# (#local.strengthdiff#)")>
                    </cfif>
                </cfif>
                <cfif techniqueLevel neq local.lastupdate.techniqueLevel>
                	<cfset local.previoustechniqueLevelTitle = getStatLevelTitle(local.lastupdate.techniqueLevel,local.UserDatabase)>
                    <cfset local.techniquediff = techniqueLevel-local.lastupdate.techniqueLevel>
                    <cfif local.techniquediff gt 0>
                    	<cfset ArrayAppend(local.changes.positive, "The player's technique has gone from #techniqueLevelTitle# to #local.previoustechniqueLevelTitle# (+#local.techniquediff#)")>
                    <cfelseif local.techniquediff lt 0>
                    	<cfset ArrayAppend(local.changes.negative, "The player's technique has gone from #techniqueLevelTitle# to #local.previoustechniqueLevelTitle# (#local.techniquediff#)")>
                    </cfif>
                </cfif>
        	
            <!--- no previous record for the player --->
            <cfelse>
                <cfset ArrayAppend(local.changes.standard, "There is no previous data for this player")>
            </cfif>
            
            <cfset structInsert(local.p,"changes",local.changes)>
            <cfset ArrayAppend(local.finalplayers, local.p)>
        </cfloop>
        		               
		
		<cfreturn local.finalplayers>
	</cffunction>
    
    
    <cffunction name="getlastUpdateDate" returntype="string" access="public" hint="returns the date of the last update for league players for the user">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		
        <cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
            <cfquery name="local.getlastdate" datasource="#getFactory().get("session").model.get('SiteDatabase')#" maxrows="1">
                select	lp.dateLastUpdated
                from	LeaguePlayers lp
                where 	lp.AddedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
                and		lp.SoldorFired = <cfqueryparam cfsqltype="cf_sql_numeric" value="0">
                order by lp.dateLastUpdated DESC
            </cfquery>
            
            <cfreturn local.getlastdate.dateLastUpdated>
            
    </cffunction>

    <cffunction name="getAllStatsNames" returntype="query" access="public" hint="returns a list of all types of stats levels">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		
		<cfquery name="local.result" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	s.StatID,
            		s.StatTitle
			from	Stats s
			order by s.StatTitle
		</cfquery>
		
		<cfreturn local.result>
	</cffunction>

    <cffunction name="getPlayerReport" returntype="query" access="public" hint="returns information about a specific player">
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
		
        <cfset local.result = QueryNew("PlayerID,FirstName,LastName,OpponentName,MatchDate,manofTheMatch,expectationID,expectationTitle,PlayerPotentialID,PlayerPotentialTitle,PositionID,PositionTitle,stars","integer,varchar,varchar,varchar,varchar,varchar,integer,varchar,integer,varchar,integer,varchar,varchar")>
        
        <cfloop query="local.player">
            
            <cfset local.PlayerID = PlayerID>
            <cfset local.FirstName = FirstName>
            <cfset local.LastName = LastName>
            
            <cfquery name="local.matchesforPlayer" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                select	mp.matchID,
                		mp.manofTheMatch,
                        mp.statLevelID,
                        mp.potentialID,
                        mp.PlayerExpectationID,
                        mp.PlayerPotentialID,
                        mp.stars,
                        mp.positionID,
                        m.matchDate,
                        m.opponentName
                from	LeagueMatchPlayers mp
                INNER JOIN LeagueMatches m
                ON		mp.matchID = m.matchID
                where	mp.playerID = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.PlayerID#">
                and		mp.didPlay = <cfqueryparam cfsqltype="CF_SQL_BIT" value="1">
                and		mp.matchID IN (<cfqueryparam cfsqltype="cf_sql_char" value="#valuelist(local.mymatches.matchID)#" list="true">)
            </cfquery>
            
            <cfloop query="local.matchesforPlayer">
				<cfset QueryAddRow(local.result, 1)>
                <cfset QuerySetCell(local.result, "PlayerID", local.PlayerID)>
                <cfset QuerySetCell(local.result, "FirstName", local.FirstName)>
                <cfset QuerySetCell(local.result, "LastName", local.LastName)>
                <cfset QuerySetCell(local.result, "OpponentName", OpponentName)>
                <cfset QuerySetCell(local.result, "MatchDate", MatchDate)>
                <cfset QuerySetCell(local.result, "manofTheMatch", manofTheMatch)>
                <!--- old way --->
                <cfif PlayerExpectationID neq 0>
                    <cfquery name="local.getexpectationTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                        select	pe.PlayerExpectationTitle
                        from	PlayerExpectations pe
                        where	pe.PlayerExpectationID = <cfqueryparam cfsqltype="cf_sql_char" value="#PlayerExpectationID#">
                    </cfquery>
                    
                    <cfset QuerySetCell(local.result, "expectationID", PlayerExpectationID)>
                    <cfset QuerySetCell(local.result, "expectationTitle", local.getexpectationTitle.PlayerExpectationTitle)>
                <!--- new way --->
                <cfelse>
                	<cfquery name="local.getexpectationTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                        select	pe.PlayerExpectationTitle
                        from	PlayerExpectations pe
                        where	pe.PlayerExpectationID = <cfqueryparam cfsqltype="cf_sql_char" value="#potentialID#">
                    </cfquery>
                    
                    <cfset QuerySetCell(local.result, "expectationID", potentialID)>
                    <cfset QuerySetCell(local.result, "expectationTitle", local.getexpectationTitle.PlayerExpectationTitle)>
                </cfif>
                
                <cfset QuerySetCell(local.result, "PlayerPotentialID", PlayerPotentialID)>
                
                <cfquery name="local.getpotentialTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                    select	pp.PlayerPotentialTitle
                    from	PlayerPotentials pp
                    where	pp.PlayerPotentialID = <cfqueryparam cfsqltype="cf_sql_char" value="#PlayerPotentialID#">
                </cfquery>
                
                <cfset QuerySetCell(local.result, "PlayerPotentialTitle", local.getpotentialTitle.PlayerPotentialTitle)>   
                
                <cfquery name="local.getPositionTitle" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
                    select	p.PositionTitle
                    from	Positions p
                    where	p.PositionID = <cfqueryparam cfsqltype="cf_sql_char" value="#PositionID#">
                </cfquery>
                
                <cfset QuerySetCell(local.result, "PositionID", PositionID)>
                <cfset QuerySetCell(local.result, "PositionTitle", local.getPositionTitle.PositionTitle)>    
                
                <!--- new way --->
                <cfif stars neq 0>
					<cfset QuerySetCell(local.result, "stars", stars)>
                    <!--- old way --->
                <cfelse>
                	<cfset local.statLevelID = statLevelID>
                    <cfset local.stars = (statLevelID-1)/2>
                    <cfif local.stars lt 10>
                    	<cfset local.stars = "0#local.stars#">
                    </cfif>
                	<cfset QuerySetCell(local.result, "stars", local.stars)>
                </cfif>
        	</cfloop>        
        </cfloop>

        <cfquery dbtype="query" name="local.resultinOrder">
            select	*	  
            from	[local].result
            order by MatchDate DESC
        </cfquery>
        
		<cfreturn local.resultinOrder>
	</cffunction>

    <cffunction name="getPlayerDetailsReport" returntype="query" access="public" hint="returns information about a specific player">
		<cfargument name="playerID" type="numeric" required="false" default="0">
        
		<cfset var local = structNew()>
		
		<cfquery name="local.player" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	lp.playerID,
            		lp.firstname,
            		lp.lastname
            from	LeaguePlayers lp
            where	lp.playerID = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.playerID#">
		</cfquery>
                
		<cfreturn local.player>
	</cffunction>

    <cffunction name="getPlayerHistoryReport" returntype="query" access="public" hint="returns history for a specific player">
		<cfargument name="playerID" type="numeric" required="false" default="0">
        <cfargument name="periodCovered" type="string" required="false" default="">
        <cfargument name="seasonFrom" type="string" required="false" default="">
        <cfargument name="seasonTo" type="string" required="false" default="">
        <cfargument name="roundFrom" type="string" required="false" default="">
        <cfargument name="roundTo" type="string" required="false" default="">
        <cfargument name="dateFrom" type="string" required="false" default="">
        <cfargument name="dateTo" type="string" required="false" default="">
        
		<cfset var local = structNew()>
		<cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
        
        <cfif Len(arguments.dateFrom) AND Len(arguments.dateTo)>
			<cfset local.dateFrom = #createDatetime(year(arguments.dateFrom),month(arguments.dateFrom),day(arguments.dateFrom),"00","00","00")#>
            <cfset local.dateTo = #createDatetime(year(arguments.dateTo),month(arguments.dateTo),day(arguments.dateTo),"23","59","59")#>
            
            <cfset local.unixDate = createDateTime("1970","01","01","00","00","00")>
            
            <cfset local.converteddateFrom = DateDiff("s", local.unixDate, local.dateFrom)>
            <cfset local.converteddateTo = DateDiff("s", local.unixDate, local.dateTo)>
		</cfif>
                
        <cfquery name="local.playerHistory" datasource="#getFactory().get("session").model.get('SiteDatabase')#">
			select	lph.csr,
            		lph.formlevel,
                    lph.agressionLevel,
                    lph.leadershipLevel,
                    lph.energyLevel,
                    lph.disciplineLevel,
                    lph.experienceLevel,
                    lph.staminaLevel,
                    lph.handlingLevel,
                    lph.attackLevel,
                    lph.defenseLevel,
                    lph.techniqueLevel,
                    lph.strengthLevel,
                    lph.jumpingLevel,
                    lph.speedLevel,
                    lph.agilityLevel,
                    lph.kickingLevel,
                    lph.brt_timestamp,
                    lph.brt_day,
                    lph.brt_round,
                    lph.brt_season
            from	LeaguePlayersHistory lph
            where	lph.playerID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.playerID#">
            and		lph.AddedByUserID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.userID#">
            <cfif arguments.periodCovered eq "Current Season">
            and		lph.brt_season = <cfqueryparam cfsqltype="cf_sql_numeric" value="#getcurrentSeason()#">
            <cfelseif arguments.periodCovered eq "Set of Seasons">
            and		lph.brt_season >= <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.seasonFrom#">
            and		lph.brt_season <= <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.seasonTo#">
            <cfelseif arguments.periodCovered eq "Set of Rounds">
            and		lph.brt_season = <cfqueryparam cfsqltype="cf_sql_numeric" value="#getcurrentSeason()#">
            and		lph.brt_round >= <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.roundFrom#">
            and		lph.brt_round <= <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.roundTo#">
            <cfelseif arguments.periodCovered eq "Set of Dates">
            and		lph.brt_timestamp >= <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.converteddateFrom#">
            and		lph.brt_timestamp <= <cfqueryparam cfsqltype="cf_sql_numeric" value="#local.converteddateTo#">
            </cfif>
            order by lph.brt_timestamp ASC
		</cfquery>
        		
        <cfset local.result = QueryNew("PlayerDate,csr,formlevel,agressionLevel,leadershipLevel,energyLevel,disciplineLevel,experienceLevel,staminaLevel,handlingLevel,attackLevel,defenseLevel,techniqueLevel,strengthLevel,jumpingLevel,speedLevel,agilityLevel,kickingLevel,theday,theround,theseason","date,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer,integer")>
        
        <cfloop query="local.playerHistory">
        	
            <cfset local.unixDate = createDateTime("1970","01","01","00","00","00")>
			<cfset local.PlayerDate = dateAdd("s", brt_timestamp, local.unixDate)>
            
            <cfset QueryAddRow(local.result, 1)>
			<cfset QuerySetCell(local.result, "PlayerDate", "#local.PlayerDate#")>
            <cfset QuerySetCell(local.result, "csr", csr)>
            <cfset QuerySetCell(local.result, "formlevel", formlevel)>
            <cfset QuerySetCell(local.result, "agressionLevel", agressionLevel)>
            <cfset QuerySetCell(local.result, "leadershipLevel", leadershipLevel)>
            <cfset QuerySetCell(local.result, "energyLevel", energyLevel)>
            <cfset QuerySetCell(local.result, "disciplineLevel", disciplineLevel)>
            <cfset QuerySetCell(local.result, "experienceLevel", experienceLevel)>
            <cfset QuerySetCell(local.result, "staminaLevel", staminaLevel)>
            <cfset QuerySetCell(local.result, "handlingLevel", handlingLevel)>
            <cfset QuerySetCell(local.result, "attackLevel", attackLevel)>
            <cfset QuerySetCell(local.result, "defenseLevel", defenseLevel)>
            <cfset QuerySetCell(local.result, "techniqueLevel", techniqueLevel)>
            <cfset QuerySetCell(local.result, "strengthLevel", strengthLevel)>
            <cfset QuerySetCell(local.result, "jumpingLevel", jumpingLevel)>
            <cfset QuerySetCell(local.result, "speedLevel", speedLevel)>
            <cfset QuerySetCell(local.result, "agilityLevel", agilityLevel)>
            <cfset QuerySetCell(local.result, "kickingLevel", kickingLevel)>
            <cfset QuerySetCell(local.result, "theday", brt_day)>
            <cfset QuerySetCell(local.result, "theround", brt_round)>
            <cfset QuerySetCell(local.result, "theseason", brt_season)>
        </cfloop>
        <cfreturn local.result>
	</cffunction>
    
</cfcomponent>