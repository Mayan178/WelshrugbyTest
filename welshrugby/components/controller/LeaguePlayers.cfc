<cfcomponent name="leagueplayers" extends="parent" hint="Controller for league players">
	<cffunction name="init" returntype="leagueplayers" access="public">
		<cfset super.init()>
		<cfset variables.breadcrumb = "View All Players|leagueplayers">
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
        <!--- user logged in, show all league players added by the user --->
		<cfelse>
            <cfset local.result = allPlayers(data=arguments.data)>
		</cfif>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="allPlayers" access="public" returntype="struct" hint="Displays a full list of all the players">
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

        <!--- user logged in --->
		<cfelse>
            
        	<!--- get the list of all players --->
            <cfset local.data.allPlayers = getModel().getAllPlayers()>
            
            <cfset getFactory().get("session").model.set("returnURL", "/leagueplayers")>
			<cfset local.result = getView().display(method="default", data=local.data)>
            <cfset local.result.title = "View All Players">
            <cfset local.result.breadcrumb = variables.breadcrumb>
            
		</cfif>
		
		<cfreturn local.result>
	</cffunction>
        
    <cffunction name="search" access="public" returntype="struct" hint="Search page">
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
        <!--- user logged in --->
		<cfelse>
        	<!--- user is resetting search criteria. Delete values from the session scope --->
            <cfif StructKeyExists(arguments.data,"reset") AND arguments.data.reset>
            	<cfif StructKeyExists(session.welshrugby,"mySearchCriteria")>
                	<cfset getFactory().get("session").model.delete("mySearchCriteria")>
                </cfif>
            </cfif>
            
			<cfset local.data = arguments.data>
            <!--- get the stats --->
            <cfset local.data.stats = getModel().getAllStats()>
            
            <!--- user has performed a search and errors were brought up --->
            <cfif StructKeyExists(session.welshrugby,"mySearchCriteria") AND StructKeyExists(getFactory().get("session").model.get("mySearchCriteria"),"errors")>
            	
                <cfset local.data.position = getFactory().get("session").model.get("mySearchCriteria").position>
                
                <cfif Len(getFactory().get("session").model.get("mySearchCriteria").firstname)>
                	<cfset local.data.firstname = getFactory().get("session").model.get("mySearchCriteria").firstname>
                <cfelse>
					<cfset local.data.firstname="">
                </cfif>
                
                <cfif Len(getFactory().get("session").model.get("mySearchCriteria").nickname)>
                	<cfset local.data.nickname = getFactory().get("session").model.get("mySearchCriteria").nickname>
                <cfelse>
                	<cfset local.data.nickname="">
                </cfif>
                
                <cfif Len(getFactory().get("session").model.get("mySearchCriteria").lastname)>
                	<cfset local.data.lastname = getFactory().get("session").model.get("mySearchCriteria").lastname>
                <cfelse>
                	<cfset local.data.lastname="">
                </cfif>
                
                <cfif Len(getFactory().get("session").model.get("mySearchCriteria").BRPlayerID)>
                	<cfset local.data.BRPlayerID = getFactory().get("session").model.get("mySearchCriteria").BRPlayerID>
                <cfelse>
                	<cfset local.data.BRPlayerID="">
                </cfif>
                
                <cfif Len(getFactory().get("session").model.get("mySearchCriteria").team)>
                	<cfset local.data.team = getFactory().get("session").model.get("mySearchCriteria").team>
                <cfelse>
                	<cfset local.data.team="">
                </cfif>
                
                <cfif Len(getFactory().get("session").model.get("mySearchCriteria").ageType)>
                	<cfset local.data.ageType = getFactory().get("session").model.get("mySearchCriteria").ageType>
                <cfelse>
                	<cfset local.data.ageType="minimum">
                </cfif>
                
                <cfif Len(getFactory().get("session").model.get("mySearchCriteria").age)>
                	<cfset local.data.age = getFactory().get("session").model.get("mySearchCriteria").age>
                <cfelse>
                	<cfset local.data.age="0">
                </cfif>
                
                <cfif Len(getFactory().get("session").model.get("mySearchCriteria").CSR)>
                	<cfset local.data.CSR = getFactory().get("session").model.get("mySearchCriteria").CSR>
                <cfelse>
                	<cfset local.data.CSR="0">
                </cfif>
                
                <cfif Len(getFactory().get("session").model.get("mySearchCriteria").height)>
                	<cfset local.data.height = getFactory().get("session").model.get("mySearchCriteria").height>
                <cfelse>
                	<cfset local.data.height="0">
                </cfif>
                
                <cfif Len(getFactory().get("session").model.get("mySearchCriteria").weight)>
                	<cfset local.data.weight = getFactory().get("session").model.get("mySearchCriteria").weight>
                <cfelse>
                	<cfset local.data.weight="0">
                </cfif>
                
                
                <cfset local.data.footed = getFactory().get("session").model.get("mySearchCriteria").footed>
                <cfset local.data.handed = getFactory().get("session").model.get("mySearchCriteria").handed>
                <cfset local.data.formLevel = getFactory().get("session").model.get("mySearchCriteria").formLevel>
                <cfset local.data.energyLevel = getFactory().get("session").model.get("mySearchCriteria").energyLevel>
                <cfset local.data.agressionLevel = getFactory().get("session").model.get("mySearchCriteria").agressionLevel>
                <cfset local.data.disciplineLevel = getFactory().get("session").model.get("mySearchCriteria").disciplineLevel>
                <cfset local.data.leadershipLevel = getFactory().get("session").model.get("mySearchCriteria").leadershipLevel>
                <cfset local.data.experienceLevel = getFactory().get("session").model.get("mySearchCriteria").experienceLevel>
                
                <cfset local.data.staminaLevel = getFactory().get("session").model.get("mySearchCriteria").staminaLevel>
                <cfset local.data.handlingLevel = getFactory().get("session").model.get("mySearchCriteria").handlingLevel>
                <cfset local.data.attackLevel = getFactory().get("session").model.get("mySearchCriteria").attackLevel>
                <cfset local.data.defenseLevel = getFactory().get("session").model.get("mySearchCriteria").defenseLevel>
                <cfset local.data.techniqueLevel = getFactory().get("session").model.get("mySearchCriteria").techniqueLevel>
                <cfset local.data.strengthLevel = getFactory().get("session").model.get("mySearchCriteria").strengthLevel>
                <cfset local.data.jumpingLevel = getFactory().get("session").model.get("mySearchCriteria").jumpingLevel>
                <cfset local.data.speedLevel = getFactory().get("session").model.get("mySearchCriteria").speedLevel>
                <cfset local.data.agilityLevel = getFactory().get("session").model.get("mySearchCriteria").agilityLevel>
                <cfset local.data.kickingLevel = getFactory().get("session").model.get("mySearchCriteria").kickingLevel>
                <cfset local.data.country = getFactory().get("session").model.get("mySearchCriteria").country>
                
                <cfset local.data.orderBy = getFactory().get("session").model.get("mySearchCriteria").orderBy>
                <cfset local.data.orderType = getFactory().get("session").model.get("mySearchCriteria").orderType>
                
                <cfif StructKeyExists(getFactory().get("session").model.get("mySearchCriteria"),"errors") AND ArrayLen(getFactory().get("session").model.get("mySearchCriteria").errors)>
                	<cfset local.data.errors = getFactory().get("session").model.get("mySearchCriteria").errors>
                </cfif>
            <!--- no errors returned or no search yet --->   
            <cfelse>
            	
                <!--- if already done a search, want to keep the search criteria --->
                <cfif StructKeyExists(session.welshrugby,"mySearchCriteria")>
                	<cfif Len(getFactory().get("session").model.get("mySearchCriteria").position)>
						<cfset local.data.position = getFactory().get("session").model.get("mySearchCriteria").position>
                    <cfelse>
						<cfset local.data.position="0">
                    </cfif>
                
                	<cfif Len(getFactory().get("session").model.get("mySearchCriteria").firstname)>
                		<cfset local.data.firstname = getFactory().get("session").model.get("mySearchCriteria").firstname>
                    <cfelse>
                    	<cfset local.data.firstname="">
                    </cfif>
                    <cfif Len(getFactory().get("session").model.get("mySearchCriteria").nickname)>
                    	<cfset local.data.nickname = getFactory().get("session").model.get("mySearchCriteria").nickname>
                    <cfelse>
                    	<cfset local.data.nickname="">
                    </cfif>
                    <cfif Len(getFactory().get("session").model.get("mySearchCriteria").lastname)>
                    	<cfset local.data.lastname = getFactory().get("session").model.get("mySearchCriteria").lastname>
                    <cfelse>
                    	<cfset local.data.lastname="">
                    </cfif>
                    <cfif Len(getFactory().get("session").model.get("mySearchCriteria").BRPlayerID)>
                    	<cfset local.data.BRPlayerID = getFactory().get("session").model.get("mySearchCriteria").BRPlayerID>
                    <cfelse>
                    	<cfset local.data.BRPlayerID="0">
                    </cfif>
                    <cfif Len(getFactory().get("session").model.get("mySearchCriteria").team)>
                    	<cfset local.data.team = getFactory().get("session").model.get("mySearchCriteria").team>
                    <cfelse>
                    	<cfset local.data.team="">
                    </cfif>
                    <cfif Len(getFactory().get("session").model.get("mySearchCriteria").ageType)>
                    	<cfset local.data.ageType = getFactory().get("session").model.get("mySearchCriteria").ageType>
                    <cfelse>
                    	<cfset local.data.ageType="">
                    </cfif>
                    
                    <cfif Len(getFactory().get("session").model.get("mySearchCriteria").age)>
                    	<cfset local.data.age = getFactory().get("session").model.get("mySearchCriteria").age>
                    <cfelse>
                    	<cfset local.data.age="">
                    </cfif>
                    <cfif Len(getFactory().get("session").model.get("mySearchCriteria").CSR)>
                    	<cfset local.data.CSR = getFactory().get("session").model.get("mySearchCriteria").CSR>
                    <cfelse>
                    	<cfset local.data.CSR="10000">
                    </cfif>
                    <cfif Len(getFactory().get("session").model.get("mySearchCriteria").height)>
                    	<cfset local.data.height = getFactory().get("session").model.get("mySearchCriteria").height>
                    <cfelse>
                    	<cfset local.data.height="170">
                    </cfif>
                    <cfif Len(getFactory().get("session").model.get("mySearchCriteria").weight)>
                    	<cfset local.data.weight = getFactory().get("session").model.get("mySearchCriteria").weight>
                    <cfelse>
                    	<cfset local.data.weight="80">
                    </cfif>
                    <cfif Len(getFactory().get("session").model.get("mySearchCriteria").footed)>
                    	<cfset local.data.footed = getFactory().get("session").model.get("mySearchCriteria").footed>
                    <cfelse>
                    	<cfset local.data.footed="">
                    </cfif>
                    <cfif Len(getFactory().get("session").model.get("mySearchCriteria").handed)>
                    	<cfset local.data.handed = getFactory().get("session").model.get("mySearchCriteria").handed>
                    <cfelse>
                    	<cfset local.data.handed = "">
                    </cfif>
                    <cfif Len(getFactory().get("session").model.get("mySearchCriteria").formLevel)>
                    	<cfset local.data.formLevel = getFactory().get("session").model.get("mySearchCriteria").formLevel>
                    <cfelse>
                    	<cfset local.data.formLevel="Min. Form">
                    </cfif>
                    <cfif Len(getFactory().get("session").model.get("mySearchCriteria").energyLevel)>
                    	<cfset local.data.energyLevel = getFactory().get("session").model.get("mySearchCriteria").energyLevel>
                    <cfelse>
						<cfset local.data.energyLevel="Min. Energy">
                    </cfif>
                    <cfif Len(getFactory().get("session").model.get("mySearchCriteria").agressionLevel)>
						<cfset local.data.agressionLevel = getFactory().get("session").model.get("mySearchCriteria").agressionLevel>
                    <cfelse>
						<cfset local.data.agressionLevel="Min. Agression">
                    </cfif>
                    <cfif Len(getFactory().get("session").model.get("mySearchCriteria").disciplineLevel)>
						<cfset local.data.disciplineLevel = getFactory().get("session").model.get("mySearchCriteria").disciplineLevel>
                    <cfelse>
						<cfset local.data.disciplineLevel="Min. Discipline">
                    </cfif>
                    <cfif Len(getFactory().get("session").model.get("mySearchCriteria").leadershipLevel)>
                    	<cfset local.data.leadershipLevel = getFactory().get("session").model.get("mySearchCriteria").leadershipLevel>
                    <cfelse>
						<cfset local.data.leadershipLevel="Min. Leadership">
                    </cfif>
                    <cfif Len(getFactory().get("session").model.get("mySearchCriteria").experienceLevel)>
                    	<cfset local.data.experienceLevel = getFactory().get("session").model.get("mySearchCriteria").experienceLevel>
                    <cfelse>
						<cfset local.data.experienceLevel="Min. Experience">
                    </cfif>
                    <cfif Len(getFactory().get("session").model.get("mySearchCriteria").staminaLevel)>
                    	<cfset local.data.staminaLevel = getFactory().get("session").model.get("mySearchCriteria").staminaLevel>
                    <cfelse>
                    	<cfset local.data.staminaLevel = "Min. Stamina">
                   	</cfif>
                    <cfif Len(getFactory().get("session").model.get("mySearchCriteria").attackLevel)>
                    	<cfset local.data.attackLevel = getFactory().get("session").model.get("mySearchCriteria").attackLevel>
                    <cfelse>
                    	<cfset local.data.attackLevel = "Min. Attack">
                    </cfif>
                    <cfif Len(getFactory().get("session").model.get("mySearchCriteria").techniqueLevel)>
                    	<cfset local.data.techniqueLevel = getFactory().get("session").model.get("mySearchCriteria").techniqueLevel>
                    <cfelse>
                    	<cfset local.data.techniqueLevel = "Min. Technique">
                    </cfif>
                    <cfif Len(getFactory().get("session").model.get("mySearchCriteria").jumpingLevel)>
                    	<cfset local.data.jumpingLevel = getFactory().get("session").model.get("mySearchCriteria").jumpingLevel>
                    <cfelse>
                    	<cfset local.data.jumpingLevel = "Min. Jumping">
                    </cfif>
                    <cfif Len(getFactory().get("session").model.get("mySearchCriteria").agilityLevel)>
                    	<cfset local.data.agilityLevel = getFactory().get("session").model.get("mySearchCriteria").agilityLevel>
                    <cfelse>
                    	<cfset local.data.agilityLevel = "Min. Agility">
                    </cfif>
                    <cfif Len(getFactory().get("session").model.get("mySearchCriteria").handlingLevel)>
                    	<cfset local.data.handlingLevel = getFactory().get("session").model.get("mySearchCriteria").handlingLevel>
                    <cfelse>
                    	<cfset local.data.handlingLevel = "Min. Handling">
                    </cfif>
                    <cfif Len(getFactory().get("session").model.get("mySearchCriteria").defenseLevel)>
                    	<cfset local.data.defenseLevel = getFactory().get("session").model.get("mySearchCriteria").defenseLevel>
                    <cfelse>
                    	<cfset local.data.defenseLevel = "Min. Defense">
                    </cfif>
                    <cfif Len(getFactory().get("session").model.get("mySearchCriteria").strengthLevel)>
                    	<cfset local.data.strengthLevel = getFactory().get("session").model.get("mySearchCriteria").strengthLevel>
                    <cfelse>
                    	<cfset local.data.strengthLevel = "Min. Strength">
                    </cfif>
                    <cfif Len(getFactory().get("session").model.get("mySearchCriteria").speedLevel)>
                    	<cfset local.data.speedLevel = getFactory().get("session").model.get("mySearchCriteria").speedLevel>
                    <cfelse>
                    	<cfset local.data.speedLevel = "Min. Speed">
                    </cfif>
                    <cfif Len(getFactory().get("session").model.get("mySearchCriteria").kickingLevel)>
                    	<cfset local.data.kickingLevel = getFactory().get("session").model.get("mySearchCriteria").kickingLevel>
                    <cfelse>
                    	<cfset local.data.kickingLevel = "Min. Kicking">
                    </cfif>
                    
                    <cfif Len(getFactory().get("session").model.get("mySearchCriteria").country)>
                    	<cfset local.data.country = getFactory().get("session").model.get("mySearchCriteria").country>
                    <cfelse>
                    	<cfset local.data.country = "">
                    </cfif>
                    <cfif Len(getFactory().get("session").model.get("mySearchCriteria").orderBy)>
                    	<cfset local.data.orderBy = getFactory().get("session").model.get("mySearchCriteria").orderBy>
                    <cfelse>
                    	<cfset local.data.orderBy = "CSR">
                    </cfif>
                    <cfif Len(getFactory().get("session").model.get("mySearchCriteria").orderType)>
                    	<cfset local.data.orderType = getFactory().get("session").model.get("mySearchCriteria").orderType>
                    <cfelse>
                    	<cfset local.data.orderType = "DESC">
                    </cfif>
                <!--- first time around --->   
                <cfelse>
                	<cfset local.data.position="">
					<cfset local.data.firstname="">
                    <cfset local.data.nickname="">
                    <cfset local.data.lastname="">
                    <cfset local.data.BRPlayerID="">
                    <cfset local.data.team="">
                    <cfset local.data.ageType="minimum">
                    <cfset local.data.age="">
                    <cfset local.data.CSR="10000">
                    <cfset local.data.height="170">
                    <cfset local.data.weight="80">
                    <cfset local.data.footed="">
                    <cfset local.data.handed="">
                    <cfset local.data.formLevel="Min. Form">
                    <cfset local.data.energyLevel="Min. Energy">
                    <cfset local.data.agressionLevel="Min. Agression">
                    <cfset local.data.disciplineLevel="Min. Discipline">
                    <cfset local.data.leadershipLevel="Min. Leadership">
                    <cfset local.data.experienceLevel="Min. Experience">
                    
                    <cfset local.data.country="">
                    
                    <cfloop query="local.data.stats">
                        <cfif NOT StructKeyExists(local.data,"#StatTitle#level")>
                            <cfset StructInsert(local.data,"#StatTitle#level","Min. #StatTitle#")>
                        </cfif>
                    </cfloop>
                    
                    <cfset local.data.orderBy = "CSR">
                    <cfset local.data.orderType = "DESC">
                </cfif>
            </cfif>
            
			<cfset local.result = getView().display(method="search", data=local.data)>
			<!--- override breadcrumb ??? --->
            <cfset local.result.title = "Search for Players">
            <cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "Search for Players|search")>
			<cfset local.result.breadcrumb = variables.breadcrumb>
		</cfif>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="searchResults" access="public" returntype="struct" hint="Displays search results">
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
        <!--- user logged in --->
		<cfelse>

            <!--- just searched --->
            <cfif StructKeyExists(arguments.data, "processSearch")>
            	<!--- first of all delete session if there --->
                <cfif StructKeyExists(session.welshrugby,"mySearchCriteria")>
                	<cfset getFactory().get("session").model.delete("mySearchCriteria")>
                </cfif>
                
				<cfset local.data = arguments.data>
                <!--- validation on data submitted --->
                <cfset local.validation = getModel().validatePlayerSearch(local.data)>
                
                <!--- validation fails, send back to search page --->
				<cfif ArrayLen(local.validation.errors)>
                	<cfset local.data.errors = local.validation.errors>
                    
                    <!--- store the search values into a session variables --->
                    <cfif NOT StructKeyExists(session.welshrugby,"mySearchCriteria")>
                        <cfset getFactory().get("session").model.set("mySearchCriteria", local.data)>
                    <cfelse>
                        <cfset getFactory().get("session").model.delete("mySearchCriteria")>
                        <cfset getFactory().get("session").model.set("mySearchCriteria", local.data)>
                    </cfif>
                    
                    <!--- redirect to the search form --->
                    <cfset getFactory().get("session").model.set("returnURL", "/leagueplayers/search")>
                    <cfset local.result.output = getFactory().get("httpUtil").util.instantRedirect(getFactory().get("session").model.get("returnURL"))>
                    
                <!--- validation ok, show results --->
                <cfelse>
                    
					<!--- get the search results --->
                    <cfset local.data.searchResults = getModel().getsearchResults(arguments.data)>
                    
                    <!--- store the search values into a session variables --->
                    <cfif NOT StructKeyExists(session.welshrugby,"mySearchCriteria")>
                        <cfset getFactory().get("session").model.set("mySearchCriteria", local.data)>
                    <cfelse>
                        <cfset getFactory().get("session").model.delete("mySearchCriteria")>
                        <cfset getFactory().get("session").model.set("mySearchCriteria", local.data)>
                    </cfif>
                    
                    <cfset getFactory().get("session").model.set("returnURL", "/leagueplayers/searchResults")>
					<cfset local.result = getView().display(method="searchResults", data=local.data)>
                    <cfset local.result.title = "Search Results for ">
                    <cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "Search for Players|search")>
                    <cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "Search Results|searchResults")>
                    <cfset local.result.breadcrumb = variables.breadcrumb>
                    
                </cfif>
             
            <!--- user is re-ordering data or editing --->   
            <cfelse> 
            	
                <cfset local.data = arguments.data>
                
                <cfif StructKeyExists(getFactory().get("session").model.get("mySearchCriteria"),"position") AND Len(getFactory().get("session").model.get("mySearchCriteria").position)>
					<cfset local.data.position = getFactory().get("session").model.get("mySearchCriteria").position>
                <cfelse>
                    <cfset local.data.position="">
                </cfif>
                
            	<cfif Len(getFactory().get("session").model.get("mySearchCriteria").firstname)>
                	<cfset local.data.firstname = getFactory().get("session").model.get("mySearchCriteria").firstname>
                <cfelse>
					<cfset local.data.firstname="">
                </cfif>
                
                <cfif StructKeyExists(getFactory().get("session").model.get("mySearchCriteria"),"nickname") AND Len(getFactory().get("session").model.get("mySearchCriteria").nickname)>
                	<cfset local.data.nickname = getFactory().get("session").model.get("mySearchCriteria").nickname>
                <cfelse>
                	<cfset local.data.nickname="">
                </cfif>
                
                <cfif Len(getFactory().get("session").model.get("mySearchCriteria").lastname)>
                	<cfset local.data.lastname = getFactory().get("session").model.get("mySearchCriteria").lastname>
                <cfelse>
                	<cfset local.data.lastname="">
                </cfif>
                
                <cfif StructKeyExists(getFactory().get("session").model.get("mySearchCriteria"),"BRPlayerID") AND Len(getFactory().get("session").model.get("mySearchCriteria").BRPlayerID)>
                	<cfset local.data.BRPlayerID = getFactory().get("session").model.get("mySearchCriteria").BRPlayerID>
                <cfelse>
                	<cfset local.data.BRPlayerID="">
                </cfif>

                <cfif StructKeyExists(getFactory().get("session").model.get("mySearchCriteria"),"team") AND Len(getFactory().get("session").model.get("mySearchCriteria").team)>
                	<cfset local.data.team = getFactory().get("session").model.get("mySearchCriteria").team>
                <cfelse>
                	<cfset local.data.team="">
                </cfif>
                
                <cfif Len(getFactory().get("session").model.get("mySearchCriteria").ageType)>
                	<cfset local.data.ageType = getFactory().get("session").model.get("mySearchCriteria").ageType>
                <cfelse>
                	<cfset local.data.ageType="minimum">
                </cfif>
                
                <cfif Len(getFactory().get("session").model.get("mySearchCriteria").age)>
                	<cfset local.data.age = getFactory().get("session").model.get("mySearchCriteria").age>
                <cfelse>
                	<cfset local.data.age="">
                </cfif>
                
                <cfif StructKeyExists(getFactory().get("session").model.get("mySearchCriteria"),"CSR") AND Len(getFactory().get("session").model.get("mySearchCriteria").CSR)>
                	<cfset local.data.CSR = getFactory().get("session").model.get("mySearchCriteria").CSR>
                <cfelse>
                	<cfset local.data.CSR="">
                </cfif>
                
                <cfif Len(getFactory().get("session").model.get("mySearchCriteria").height)>
                	<cfset local.data.height = getFactory().get("session").model.get("mySearchCriteria").height>
                <cfelse>
                	<cfset local.data.height="">
                </cfif>
                
                <cfif Len(getFactory().get("session").model.get("mySearchCriteria").weight)>
                	<cfset local.data.weight = getFactory().get("session").model.get("mySearchCriteria").weight>
                <cfelse>
                	<cfset local.data.weight="">
                </cfif>
                
                <cfset local.data.footed = getFactory().get("session").model.get("mySearchCriteria").footed>
                <cfset local.data.handed = getFactory().get("session").model.get("mySearchCriteria").handed>
                <cfset local.data.formLevel = getFactory().get("session").model.get("mySearchCriteria").formLevel>
                <cfset local.data.energyLevel = getFactory().get("session").model.get("mySearchCriteria").energyLevel>
                <cfset local.data.agressionLevel = getFactory().get("session").model.get("mySearchCriteria").agressionLevel>
                <cfset local.data.disciplineLevel = getFactory().get("session").model.get("mySearchCriteria").disciplineLevel>
                <cfset local.data.leadershipLevel = getFactory().get("session").model.get("mySearchCriteria").leadershipLevel>
                <cfset local.data.experienceLevel = getFactory().get("session").model.get("mySearchCriteria").experienceLevel>
                
                <cfif StructKeyExists(getFactory().get("session").model.get("mySearchCriteria"),"staminaLevel")>
					<cfset local.data.staminaLevel = getFactory().get("session").model.get("mySearchCriteria").staminaLevel>
                <cfelse>
                	<cfset local.data.staminaLevel = "">
                </cfif>
                
                <cfif StructKeyExists(getFactory().get("session").model.get("mySearchCriteria"),"handlingLevel")>
					<cfset local.data.handlingLevel = getFactory().get("session").model.get("mySearchCriteria").handlingLevel>
                <cfelse>
                	<cfset local.data.handlingLevel = "">
                </cfif>

                <cfif StructKeyExists(getFactory().get("session").model.get("mySearchCriteria"),"attackLevel")>
					<cfset local.data.attackLevel = getFactory().get("session").model.get("mySearchCriteria").attackLevel>
                <cfelse>
                	<cfset local.data.attackLevel = "">
                </cfif>

                <cfif StructKeyExists(getFactory().get("session").model.get("mySearchCriteria"),"defenseLevel")>
					<cfset local.data.defenseLevel = getFactory().get("session").model.get("mySearchCriteria").defenseLevel>
                <cfelse>
                	<cfset local.data.defenseLevel = "">
                </cfif>

                <cfif StructKeyExists(getFactory().get("session").model.get("mySearchCriteria"),"techniqueLevel")>
					<cfset local.data.techniqueLevel = getFactory().get("session").model.get("mySearchCriteria").techniqueLevel>
                <cfelse>
                	<cfset local.data.techniqueLevel = "">
                </cfif>

                <cfif StructKeyExists(getFactory().get("session").model.get("mySearchCriteria"),"strengthLevel")>
					<cfset local.data.strengthLevel = getFactory().get("session").model.get("mySearchCriteria").strengthLevel>
                <cfelse>
                	<cfset local.data.strengthLevel = "">
                </cfif>

                <cfif StructKeyExists(getFactory().get("session").model.get("mySearchCriteria"),"jumpingLevel")>
					<cfset local.data.jumpingLevel = getFactory().get("session").model.get("mySearchCriteria").jumpingLevel>
                <cfelse>
                	<cfset local.data.jumpingLevel = "">
                </cfif>

                <cfif StructKeyExists(getFactory().get("session").model.get("mySearchCriteria"),"speedLevel")>
					<cfset local.data.speedLevel = getFactory().get("session").model.get("mySearchCriteria").speedLevel>
                <cfelse>
                	<cfset local.data.speedLevel = "">
                </cfif>

                <cfif StructKeyExists(getFactory().get("session").model.get("mySearchCriteria"),"agilityLevel")>
					<cfset local.data.agilityLevel = getFactory().get("session").model.get("mySearchCriteria").agilityLevel>
                <cfelse>
                	<cfset local.data.agilityLevel = "">
                </cfif>

                <cfif StructKeyExists(getFactory().get("session").model.get("mySearchCriteria"),"kickingLevel")>
					<cfset local.data.kickingLevel = getFactory().get("session").model.get("mySearchCriteria").kickingLevel>
                <cfelse>
                	<cfset local.data.kickingLevel = "">
                </cfif>
                
                <cfif StructKeyExists(getFactory().get("session").model.get("mySearchCriteria"),"country")>
					<cfset local.data.country = getFactory().get("session").model.get("mySearchCriteria").country>
                <cfelse>
                	<cfset local.data.country = "">
                </cfif>
                
				<cfif request.scope.exists("doreorderSearch")>

					<cfset local.data.orderby = arguments.data.orderby>
                    <cfset local.data.orderType =  arguments.data.orderType>
                <cfelse>
                	<cfset local.data.orderby = getFactory().get("session").model.get("mySearchCriteria").orderby>
                    <cfset local.data.orderType =  getFactory().get("session").model.get("mySearchCriteria").orderType>
                </cfif>
                
                <!--- get the search results --->
                <cfset local.data.searchResults = getModel().getsearchResults(local.data)>
                
                <cfset local.data.stats = getModel().getAllStats()>
                
                <!--- store the search values into a session variables --->
				<cfset getFactory().get("session").model.delete("mySearchCriteria")>
				<cfset getFactory().get("session").model.set("mySearchCriteria", local.data)>
                
                <cfset getFactory().get("session").model.set("returnURL", "/leagueplayers/searchResults")>
                <cfset local.result = getView().display(method="searchResults", data=local.data)>
                <cfset local.result.title = "Search Results for ">
                <cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "Search for Players|search")>
                <cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "Search Results|searchResults")>
                <cfset local.result.breadcrumb = variables.breadcrumb>
            
            </cfif>
		</cfif>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="playerDetails" access="public" returntype="struct" hint="Displays details for individual players">
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
        <!--- user is logged in --->
		<cfelse>
        	
        	<!--- get the search results --->
            <cfset local.data.playerDetails = getModel().getplayerDetails(arguments.data.playerID)>
            
            <cfset local.data.stats = getModel().getAllStats()>
            
			<cfset local.result = getView().display(method="playerDetails", data=local.data)>
            <cfset local.result.title = "#local.data.playerDetails.firstname# #local.data.playerDetails.lastname#">
            <cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "#local.data.playerDetails.firstname# #local.data.playerDetails.lastname#|playerDetails")>
			<cfset local.result.breadcrumb = variables.breadcrumb>
            
            <cfset getFactory().get("session").model.set("returnURL", "/leagueplayers/playerDetails/playerID/#arguments.data.playerID#")>
            
		</cfif>
		
		<cfreturn local.result>
	</cffunction>
        
    <cffunction name="addToTeam" access="public" returntype="struct" hint="Controller for adding a player to a team">
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
        <!--- user is logged in --->
		<cfelse>
            <cfset local.data = arguments.data>
            <!--- inserting data into the db --->
            <cfset local.result.addplayerToTeam = getModel().addPlayertoTeamexisting(teamID=local.data.teamID,positionID=local.data.positionID,playerID=local.data.playerID)>
                
            <cfif local.result.addplayerToTeam.success>
                <cfset getFactory().get("session").model.set("returnURL", "/leagueplayers")>
                <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
                    getFactory().get("session").model.get("returnURL"),
                    getFactory().get("template").view.success(getModel().getMessage("success","4","title"), local.result.output,"50%").output, 1
                )>
                
            <cfelse>
                <cfset getFactory().get("session").model.set("returnURL", "/leagueplayers")>
                <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
                    getFactory().get("session").model.get("returnURL"),
                    getFactory().get("template").view.failure(getModel().getMessage("failure","5","title"), local.result.output,"50%").output, 3
                )>
            </cfif>
        </cfif>
                    
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="showPlayerDetails" access="public" returntype="struct" hint="Controller for showing a player's details">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        <cfset local.result.restrictOutput = true>
        
        
		<!--- get the player's info --->
        <!--- if existing --->
        <cfif arguments.data.playerID neq 0>
        	<cfset local.data.myPlayer = getModel().getaspecificPlayer(playerID=arguments.data.playerID)>

            <cfset local.data.myPlayerExistingTeams = getModel().getaspecificPlayerTeams(playerID=arguments.data.playerID)>
            <cfset local.existingTeams = "">
            <cfloop query="local.data.myPlayerExistingTeams">
                <cfset local.existingTeams = listAppend(local.existingTeams,teamID)>
            </cfloop>

            <!--- get the list of all of the user's teams --->
            <cfset local.data.allUserTeams = getFactory().get("leagueplayers").model.getallMyTeams()>
            <cfset local.data.potentialTeams = "">

             <cfloop query="local.data.allUserTeams">
                <cfif NOT listFindNoCase(local.existingTeams,teamID)>
                    <cfset local.data.potentialTeams = listAppend(local.data.potentialTeams,teamID)>
                </cfif>
            </cfloop>
        </cfif>
        
        <!--- get stat info --->
        <cfset local.data.stats = getModel().getAllStats()>

        <cfset local.result.output = getView().display(method="showPlayerDetails", data=local.data).output>
        
		<cfreturn local.result>
	</cffunction>

    <cffunction name="addMyPlayerToTeam" access="public" returntype="struct" hint="Controller for showing the form to add a player to a team">
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
        <!--- user is logged in --->
		<cfelse>
            <cfset local.data = arguments.data>

            <cfset local.data.getTeamsAndPositions = getmodel().getTeamsAndPositions(playerID=local.data.playerID)>

            <cfset local.basicPlayerDetails = getmodel().getaspecificPlayer(playerID=local.data.playerID)>

            <cfset local.playerName = "#local.basicPlayerDetails.firstName# #local.basicPlayerDetails.lastName#">
            
            <cfset local.result.title = "Add #local.playerName# to a Team ">
            <cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "Add #local.playerName# #local.data.getTeamsAndPositions.lastName# to a Team|addMyPlayerToTeam")>
            <cfset local.result.breadcrumb = variables.breadcrumb>

            <cfset local.result.output = getView().display(method="addMyPlayerToTeam", data=local.data, playerID=local.data.playerID).output>
       
        </cfif>
		<cfreturn local.result>
	</cffunction>

    <cffunction name="getMatchingPositions" access="public" returntype="struct" hint="Controller for showing positions available in the team we are adding the player to">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        <cfset local.result.restrictOutput = true>

        <!--- if the user is not logged in, he/she cannot see the homepage...so redirect to login page --->
		<cfif NOT getFactory().get("login").model.isLoggedIn()>
        	<cfset getFactory().get("session").model.set("returnURL", "/login")>
            <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
			getFactory().get("session").model.get("returnURL"),
			getFactory().get("template").view.failure(getModel().getMessage("failure","3","title"),"","50%").output,
			1
			)>
        <!--- user is logged in --->
		<cfelse>
            <cfset local.data = arguments.data>

            <cfset local.data.getAvailablePositions = getmodel().getAvailablePositions(teamID=local.data.teamID)>
                       
            <cfset local.result.output = getView().display(method="getMatchingPositions", data=local.data).output>
       
        </cfif>
		<cfreturn local.result>
	</cffunction>
        
    <cffunction name="positionStats" access="public" returntype="struct" hint="Controller for changing league position stats">
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
        <!--- user is logged in --->
		<cfelse>
        	<cfset local.data = arguments.data>
                <!--- data submitted (user updated their stats) --->
				<cfif StructKeyExists(arguments.data, "doSubmit")>
        			
                    <!--- put through validation make sure that the same stat has not been submitted twice for the same position--->
                    <cfset local.validation = getModel().validatepositions(local.data)>
                    <!--- there has been an error. No change in step --->
					<cfif ArrayLen(local.validation.errors)>
                        <cfset local.data.errors = local.validation.errors>
                        
                        <cfloop from="1" to="15" index="local.p">
                        	<cfloop from="1" to="4" index="local.s">
                            	<cfparam name="local.data.stat_#local.p#_#local.s#" default="#evaluate('arguments.data.stat_#local.p#_#local.s#')#">
                            </cfloop>
                        </cfloop>
                        
                        <cfset local.data.allpositions = getModel().getSearchPositions()>
                        
						<cfset local.result.output = getView().display(method="positionStats", data=local.data).output>
                        <cfset local.result.title = "Position Stats">
                        <cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "Position Stats|positionStats")>
                        <cfset local.result.breadcrumb = variables.breadcrumb>
                        
                    <!--- validated --->
                    <cfelse>
                    	<!--- updating the db --->
						<cfset local.result.update = getModel().bestPositionUpdate(
                                data=local.data
                        )>
            			
                        <cfif local.result.update.success>
                        	
                            <cfset getFactory().get("session").model.set("returnURL", "/leagueplayers/positionStats")>
                            <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
                                getFactory().get("session").model.get("returnURL"),
                                getFactory().get("template").view.success(getModel().getMessage("success","12","title"), local.result.output,"50%").output, 1
                            )>
                        <cfelse>
                            <cfset getFactory().get("session").model.set("returnURL", "/leagueplayers/positionStats")>
                            <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
                                getFactory().get("session").model.get("returnURL"),
                                getFactory().get("template").view.failure(getModel().getMessage("failure","13","title"), local.result.output,"50%").output, 1
                            )>
                        </cfif>
                	</cfif>
                <!--- first time around. User sees the form to enable them to update their stats --->
                <cfelse>
                	
                    <cftry>
					<cfset local.position1Stats = getModel().getPositionPlayerStats(positionID=1)>
                    <cfloop query="local.position1Stats">
                        <cfparam name="local.data.stat_1_#OrderofRelevance#" default="#statID#">
                    </cfloop>
                    
                    <cfset local.position2Stats = getModel().getPositionPlayerStats(positionID=2)>
                    <cfloop query="local.position2Stats">
                        <cfparam name="local.data.stat_2_#OrderofRelevance#" default="#statID#">
                    </cfloop>

                    <cfset local.position3Stats = getModel().getPositionPlayerStats(positionID=3)>
                    <cfloop query="local.position3Stats">
                        <cfparam name="local.data.stat_3_#OrderofRelevance#" default="#statID#">
                    </cfloop>

                    <cfset local.position4Stats = getModel().getPositionPlayerStats(positionID=4)>
                    <cfloop query="local.position4Stats">
                        <cfparam name="local.data.stat_4_#OrderofRelevance#" default="#statID#">
                    </cfloop>
                    
                    <cfset local.position5Stats = getModel().getPositionPlayerStats(positionID=5)>
                    <cfloop query="local.position5Stats">
                        <cfparam name="local.data.stat_5_#OrderofRelevance#" default="#statID#">
                    </cfloop>
                    
                    <cfset local.position6Stats = getModel().getPositionPlayerStats(positionID=6)>
                    <cfloop query="local.position6Stats">
                        <cfparam name="local.data.stat_6_#OrderofRelevance#" default="#statID#">
                    </cfloop>
                    
                    <cfset local.position7Stats = getModel().getPositionPlayerStats(positionID=7)>
                    <cfloop query="local.position7Stats">
                        <cfparam name="local.data.stat_7_#OrderofRelevance#" default="#statID#">
                    </cfloop>
                    
                    <cfset local.position8Stats = getModel().getPositionPlayerStats(positionID=8)>
                    <cfloop query="local.position8Stats">
                        <cfparam name="local.data.stat_8_#OrderofRelevance#" default="#statID#">
                    </cfloop>
                    
                    <cfset local.position9Stats = getModel().getPositionPlayerStats(positionID=9)>
                    <cfloop query="local.position9Stats">
                        <cfparam name="local.data.stat_9_#OrderofRelevance#" default="#statID#">
                    </cfloop>
                    
                    <cfset local.position10Stats = getModel().getPositionPlayerStats(positionID=10)>
                    <cfloop query="local.position10Stats">
                        <cfparam name="local.data.stat_10_#OrderofRelevance#" default="#statID#">
                    </cfloop>
                    
                    <cfset local.position11Stats = getModel().getPositionPlayerStats(positionID=11)>
                    <cfloop query="local.position11Stats">
                        <cfparam name="local.data.stat_11_#OrderofRelevance#" default="#statID#">
                    </cfloop>
                    
                    <cfset local.position12Stats = getModel().getPositionPlayerStats(positionID=12)>
                    <cfloop query="local.position12Stats">
                        <cfparam name="local.data.stat_12_#OrderofRelevance#" default="#statID#">
                    </cfloop>
                    
                    <cfset local.position13Stats = getModel().getPositionPlayerStats(positionID=13)>
                    <cfloop query="local.position13Stats">
                        <cfparam name="local.data.stat_13_#OrderofRelevance#" default="#statID#">
                    </cfloop>
                    
                    <cfset local.position14Stats = getModel().getPositionPlayerStats(positionID=14)>
                    <cfloop query="local.position14Stats">
                        <cfparam name="local.data.stat_14_#OrderofRelevance#" default="#statID#">
                    </cfloop>
                    
                    <cfset local.position15Stats = getModel().getPositionPlayerStats(positionID=15)>
                    <cfloop query="local.position15Stats">
                        <cfparam name="local.data.stat_15_#OrderofRelevance#" default="#statID#">
                    </cfloop>
                    
                    <cfset local.data.minWeight_1 = getModel().getPositionPlayerMinWeight(positionID=1)>
                    <cfset local.data.maxHeight_1 = getModel().getPositionPlayerMaxHeight(positionID=1)>
                    
                    <cfset local.data.minWeight_2 = getModel().getPositionPlayerMinWeight(positionID=2)>
                    <cfset local.data.maxHeight_2 = getModel().getPositionPlayerMaxHeight(positionID=2)>
                    
                    <cfset local.data.minWeight_3 = getModel().getPositionPlayerMinWeight(positionID=3)>
                    <cfset local.data.maxHeight_3 = getModel().getPositionPlayerMaxHeight(positionID=3)>
                    
                    <cfset local.data.minHeight_4 = getModel().getPositionPlayerMinHeight(positionID=4)>
                    
                    <cfset local.data.minHeight_5 = getModel().getPositionPlayerMinHeight(positionID=5)>
                    
                    <cfset local.data.allpositions = getModel().getSearchPositions()>
                    
                    <cfset local.result.output = getView().display(method="positionStats", data=local.data).output>
                    <cfset local.result.title = "Position Stats">
                    <cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "Position Stats|positionStats")>
                    <cfset local.result.breadcrumb = variables.breadcrumb>

                        <cfcatch type="any">
                        <cfoutput>#cfcatch#</cfoutput>
                        </cfcatch>
                    </cftry>
                </cfif>
		</cfif>

		<cfreturn local.result>
	</cffunction>
    

<!--- FUNCTIONS NO LONGER USED
    <cffunction name="reset" access="public" returntype="struct" hint="Controller for resetting all the league side data">
		<cfargument name="data" type="struct" required="false">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        
        <!--- if the user is not logged in, he/she cannot see the homepage...so redirect to login page --->
		<cfif NOT getFactory().get("login").model.isLoggedIn()>
            <cfset getFactory().get("session").model.set("returnURL", "/login")>
            <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
			getFactory().get("session").model.get("returnURL"),
			getFactory().get("template").view.failure(getModel().getMessage("failure","2","title"),"","50%").output,
			1
			)>
		<cfelse>
        	<cfset local.data = arguments.data>
            
				<cfif StructKeyExists(arguments.data, "resetAll")>
						<cfset local.result.resetAllData = getModel().resetAllData(
                                data=local.data
                        )>
            			
                        <cfif local.result.resetAllData.success>
                            <cfset getFactory().get("session").model.set("returnURL", "/")>
                            <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
                                getFactory().get("session").model.get("returnURL"),
                                getFactory().get("template").view.success(getModel().getMessage("success","14","title"), local.result.output,"50%").output, 1
                            )>
                        <cfelse>
                            <cfset getFactory().get("session").model.set("returnURL", "/")>
                            <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
                                getFactory().get("session").model.get("returnURL"),
                                getFactory().get("template").view.failure(getModel().getMessage("failure","15","title"), local.result.output,"50%").output, 1
                            )>
                        </cfif>
                <cfelse>
                	
                    <cfset local.result.output = getView().display(method="reset", data=local.data).output>
                    <cfset local.result.title = "Reset Your League Squad Data">
                    <cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "Reset Your League Squad Data|reset")>
                    <cfset local.result.breadcrumb = variables.breadcrumb>
                </cfif>
		</cfif>
        
		<cfreturn local.result>
	</cffunction>
    
    <!--- function to schedule to run every tuesday at about 2pm --->
    <cffunction name="scheduledImportData" returntype="struct" access="public" hint="goes and gets the data from BOR for league players in each user's team">
		<cfargument name="data" type="struct" required="true">
		
		<cfset var local = structNew()>

		<cfset local.result = getFactory().getResult()>
        
        <cfset local.todayDayofWeek = DayOfWeekAsString(dayofweek(now()))>
        
        <cfif local.todayDayofWeek eq "tuesday" OR local.todayDayofWeek eq "thursday" OR local.todayDayofWeek eq "sunday">
        
			<!--- get all users from the database --->
            <cfset local.allUsers = getFactory().get("user").model.getallUsersforAPI()>
            <!--- loop through all users details --->
            <cfloop query="local.allUsers">
                <cfset local.UserDatabase = countryDatabase>
                <!--- set up value for url to call for the user --->
                <cfset local.apiURL = "http://api.blackoutrugby.com/?d=#getFactory().getSetting('developerID')#&dk=#getFactory().getSetting('developerKey')#&r=p&teamid=#teamID#&#AccessKey#&lea=1">
                 
                 <!--- do http request for api for user --->
                 <cfhttp url="#local.apiURL#" method="get" result="local.userTeamData" timeout="10" throwonerror="true"/>
                 
                 <!--- only carry on if the response is ok --->
                 <cfif local.userTeamData.statuscode eq "200 OK">
                    <cfset local.responseContent = local.userTeamData.filecontent>
                    
                    <!--- now parse the xml data --->
                    <cfset local.xml = xmlParse(local.responseContent)>
                    
                    <!--- no errors...process as normal --->
                    <cfif NOT StructKeyExists(local.xml.blackoutrugby_api_response,"error")>
                        <cfset local.data = getFactory().get("dataTypeConvert").util.xmlToStruct(local.xml).blackoutrugby_api_response>
                        
                        <cfset local.userPlayers = local.data.player>
                        <cfset local.brtTimeStamp = local.data.attributes.brt_timestamp>
                        <cfset local.brtDay = local.data.attributes.day>
                        <cfset local.brtRound = local.data.attributes.round>
                        <cfset local.brtSeason = local.data.attributes.season>
                        
                        <!--- first of all, get list of existing players for the user in the database --->
                        <cfset local.listofexistingplayers = getFactory().get("leaguePlayers").model.getAllValidPlayersForUser(userID,local.UserDatabase)>
                                            
                        <cfset local.listofPlayersinResponse = "">
                        
                        <!--- loop through the array of players --->
                        <cfloop from="1" to="#arrayLen(local.userPlayers)#" index="local.p">
                            <cfset local.playerData = structNew()>
                            <cfset local.listofPlayersinResponse = listappend(local.listofPlayersinResponse,local.userPlayers[local.p].id)>
                            
                            <!--- gather data to go into the main table and history table --->
                            <cfset local.playerData.BRPlayerID = local.userPlayers[local.p].id>
                            <cfset local.playerData.BRTeamID = local.userPlayers[local.p].teamid>
                            <cfset local.playerData.FirstName = local.userPlayers[local.p].fname>
                            <cfset local.playerData.LastName = local.userPlayers[local.p].lname>
                            
                            <cfset local.playerData.nickName = "">
                            
                            <cfset local.playerData.age = local.userPlayers[local.p].age>
                            <cfset local.playerData.csr = local.userPlayers[local.p].csr>
                            <cfset local.playerData.salary = local.userPlayers[local.p].salary>
                            <cfset local.playerData.height = local.userPlayers[local.p].height>
                            <cfset local.playerData.weight = local.userPlayers[local.p].weight>
                            
                            <cfset local.playerData.formLevel = local.userPlayers[local.p].form>
                            <cfset local.playerData.energyLevel = local.userPlayers[local.p].energy>
                            <cfset local.playerData.AgressionLevel = local.userPlayers[local.p].aggression>
                            <cfset local.playerData.disciplineLevel = local.userPlayers[local.p].discipline>
                            <cfset local.playerData.leadershipLevel = local.userPlayers[local.p].leadership>
                            <cfset local.playerData.experienceLevel = local.userPlayers[local.p].experience>
                            <!--- DOUBLE CHECK THIS!!! --->	
                            <cfif local.userPlayers[local.p].injured neq "0">
                                <!---
                                <cfset local.unixDate = createDateTime("1970","01","01","00","00","00")>
                                <cfset local.playerData.InjuredDatetoCheck = dateAdd("s", local.userPlayers[local.p].injured, local.unixDate)>
                                --->            
                                <cfset local.playerData.InjuredDate = local.userPlayers[local.p].injured>
                                <cfif local.playerData.InjuredDate gt local.brtTimeStamp>
                                    <cfset local.playerData.Injured = "1">
                                <cfelse>
                                    <cfset local.playerData.Injured = "0">
                                </cfif>
                            <cfelse>
                                <cfset local.playerData.InjuredDate = "">
                                <cfset local.playerData.Injured = "0">
                            </cfif>
                            <!--- DOUBLE CHECK THIS!!! --->	
                            <cfif local.userPlayers[local.p].contract neq "0">
                                <!---
                                <cfset local.unixDate = createDateTime("1970","01","01","00","00","00")>
                                <cfset local.playerData.contractDatetoCheck = dateAdd("s", local.userPlayers[local.p].contract, local.unixDate)>
                                --->
                                <cfset local.playerData.contractDate = local.userPlayers[local.p].contract>
                                <cfset local.playerData.contract = "1">
                            <cfelse>
                                <cfset local.playerData.contractDate = "">
                                <cfset local.playerData.contract = "0">
                            </cfif>
                            
                            <cfif local.userPlayers[local.p].jersey neq "255">
                                <cfset local.playerData.jersey = local.userPlayers[local.p].jersey>
                            <cfelse>
                                <cfset local.playerData.jersey = "0">
                            </cfif>
                            
                            <cfset local.playerData.handed = local.userPlayers[local.p].hand>
                            <cfset local.playerData.footed = local.userPlayers[local.p].foot>
                            <cfset local.playerData.nationality = local.userPlayers[local.p].nationality>
                            
                            <!--- get the id for the country --->
                            <cfset local.playerData.countryID = getFactory().get("leaguePlayers").model.getCountryID(local.playerData.nationality,local.UserDatabase)>                        
                            
                            <cfset local.playerData.youthid = local.userPlayers[local.p].youthid>
                            
                            <!--- DOUBLE CHECK THIS!!! --->	
                            <cfif local.userPlayers[local.p].joined neq "0">
                            <!---
                                <cfset local.unixDate = createDateTime("1970","01","01","00","00","00")>
                                <cfset local.playerData.joinedDatetoCheck = dateAdd("s", local.userPlayers[local.p].joined, local.unixDate)>
                                --->
                                <cfset local.playerData.joinedDate = local.userPlayers[local.p].joined>
                            <cfelse>
                                <cfset local.playerData.joinedDate = "">
                            </cfif>
                            
                            <!--- now, deal with the stats --->
                            <cfset local.playerData.agilityLevel = local.userPlayers[local.p].agility>
                            <cfset local.playerData.attackLevel = local.userPlayers[local.p].attack>
                            <cfset local.playerData.defenseLevel = local.userPlayers[local.p].defense>
                            <cfset local.playerData.handlingLevel = local.userPlayers[local.p].handling>
                            <cfset local.playerData.jumpingLevel = local.userPlayers[local.p].jumping>
                            <cfset local.playerData.kickingLevel = local.userPlayers[local.p].kicking>
                            <cfset local.playerData.speedLevel = local.userPlayers[local.p].speed>
                            <cfset local.playerData.staminaLevel = local.userPlayers[local.p].stamina>
                            <cfset local.playerData.strengthLevel = local.userPlayers[local.p].strength>
                            <cfset local.playerData.techniqueLevel = local.userPlayers[local.p].technique>
                            
                            <cfset local.playerData.brt_timestamp = local.brtTimeStamp>
                            <cfset local.playerData.brt_day = local.brtDay>
                            <cfset local.playerData.brt_round = local.brtRound>
                            <cfset local.playerData.brt_season = local.brtSeason>
                            
                            <!--- does the player already exists in the db for the user --->
                            <!--- if the playerID is found in existing players, then update --->
                            <cfif listfindNoCase(local.listofexistingplayers,local.playerData.BRPlayerID)>
                                <!--- we only want to update the data if something has changed!!! --->
                                <!--- get existing data for the player --->
                                <cfset local.existingp = getFactory().get("leaguePlayers").model.getplayerDetailsFromBRPlayerID(local.playerData.BRPlayerID,local.UserDatabase,userID)>
                                
                                <cfset local.needtoUpdatePlayer = false>
                                
                                <cfif local.playerData.BRPlayerID neq local.existingp.BRPlayerID>
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.BRTeamID neq local.existingp.BRTeamID>
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.FirstName neq local.existingp.FirstName>
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.LastName neq local.existingp.LastName>     
                                    <cfset local.needtoUpdatePlayer = true>            
                                <cfelseif local.playerData.nickName neq local.existingp.nickName> 
                                    <cfset local.needtoUpdatePlayer = true>                       
                                <cfelseif local.playerData.age neq local.existingp.age>   
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.csr neq local.existingp.csr>
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.salary neq local.existingp.salary>
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.height neq local.existingp.height>
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.weight neq local.existingp.weight>
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.formLevel neq local.existingp.formLevel>
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.energyLevel neq local.existingp.energyLevel>
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.AgressionLevel neq local.existingp.AgressionLevel>
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.disciplineLevel neq local.existingp.disciplineLevel>
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.leadershipLevel neq local.existingp.leadershipLevel>
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.experienceLevel neq local.existingp.experienceLevel>
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.InjuredDate neq local.existingp.InjuredDate>
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.Injured neq local.existingp.Injured>
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.contractDate neq local.existingp.contractDate>
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.contract neq local.existingp.contract>  
                                    <cfset local.needtoUpdatePlayer = true>               
                                <cfelseif local.playerData.jersey neq local.existingp.jersey>
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.handed neq local.existingp.handed>
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.footed neq local.existingp.footed>
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.nationality neq local.existingp.nationality> 
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.countryID neq local.existingp.countryID> 
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.youthid neq local.existingp.youthid> 
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.joinedDate neq local.existingp.joinedDate> 
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.agilityLevel neq local.existingp.agilityLevel> 
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.attackLevel neq local.existingp.attackLevel> 
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.defenseLevel neq local.existingp.defenseLevel> 
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.handlingLevel neq local.existingp.handlingLevel> 
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.jumpingLevel neq local.existingp.jumpingLevel> 
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.kickingLevel neq local.existingp.kickingLevel> 
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.speedLevel neq local.existingp.speedLevel> 
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.staminaLevel neq local.existingp.staminaLevel> 
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.strengthLevel neq local.existingp.strengthLevel> 
                                    <cfset local.needtoUpdatePlayer = true>
                                <cfelseif local.playerData.techniqueLevel neq local.existingp.techniqueLevel> 
                                    <cfset local.needtoUpdatePlayer = true>
                                </cfif>
                                    
                                <!--- need to update --->
                                <cfif local.needtoUpdatePlayer>
                                    <cfset getFactory().get("leaguePlayers").model.updatePlayer(userID,local.playerData,local.UserDatabase)>
                                </cfif>
                                    
                                    
                                <!--- playerID not found in the db, we need to add the player, stats, player history and stats history --->
                                <cfelse>
                                    <cfset getFactory().get("leaguePlayers").model.playerInsert(userID,local.playerData,local.UserDatabase)>
                                </cfif>
        
                            </cfloop>
                            
                            <!--- loop through existing players, and if they are not in the xml response, set as soldorfired --->
                            <cfloop list="#local.listofexistingplayers#" index="local.existingp">
                                <!--- if an existing db player is not found in the list of players we get from the response, it is either sold or fired --->
                                <cfif NOT listfindNoCase(local.listofPlayersinResponse,local.existingp)>
                                    <cfset getFactory().get("leaguePlayers").model.setSoldorFired(userID,local.existingp)>
                                </cfif>
                            </cfloop>
                            
                        <!--- errors, stored error somewhere against the user in the database --->
                        <cfelse>
                        <cfset local.userError = local.xml.blackoutrugby_api_response.error.XmlText>
                        
                        <!--- now do a bit or error handling and insert into db against the userid --->
                        <cfif local.userError eq "No valid players found">
                            <!--- this would happen when the teamid is wrong --->
                            <cfset local.newError = "There was a problem updating your Team details. Please check the Team ID in Your Profile">
                        <cfelseif local.userError eq "Member key is incorrect">
                            <!--- this would happen when the teamid is wrong --->
                            <cfset local.newError = "There was a problem updating your Team details. Please check the Access Key in Your Profile">
                        <cfelse>
                            <cfset local.newError = "">
                        </cfif>
                        
                        <!--- if the error can be identified, insert into the db --->
                        <cfif Len(local.newError)>
                            <cfset getFactory().get("user").model.insertUserError(userID,local.newError,"league",left(local.userError,255),teamID,"0")>
                        </cfif>
                        
                    </cfif>                
                 </cfif>
                 
            </cfloop>
        
        </cfif>
    	<cfreturn local.result>
	</cffunction>

<cffunction name="importPlayerData" returntype="struct" access="public" hint="goes and gets the data from BOR for a specific player belonging to the user">
		<cfargument name="data" type="struct" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        <cfset local.success = 1>
        
         <cftry>
        
            <cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
            <cfset local.UserDatabase = #getFactory().get("session").model.get('SiteDatabase')#>
            <cfset local.AccessKey = #getFactory().get("session").model.get('AccessKey')#>
            <cfparam name="arguments.data.shortversion" default="0">
            
            <!--- set up value for url to call for the user --->
            <cfset local.apiURL = "http://api.blackoutrugby.com/?d=#getFactory().getSetting('developerID')#&dk=#getFactory().getSetting('developerKey')#&r=p&playerid=#arguments.data.BRPlayerID#&#local.AccessKey#&lea=1">
             
             <!--- do http request for api for user --->
             <cfhttp url="#local.apiURL#" method="get" result="local.userPlayerUpdate" timeout="5" throwonerror="true"/>
             
             <!--- only carry on if the response is ok --->
             <cfif local.userPlayerUpdate.statuscode eq "200 OK">
                <cfset local.responseContent = local.userPlayerUpdate.filecontent>
                
                <!--- now parse the xml data --->
                <cfset local.xml = xmlParse(local.responseContent)>
                
                <!--- no errors...process as normal --->
                <cfif NOT StructKeyExists(local.xml.blackoutrugby_api_response,"error")>
                    <cfset local.data = getFactory().get("dataTypeConvert").util.xmlToStruct(local.xml).blackoutrugby_api_response>
                    
                    <cfset local.brtTimeStamp = local.data.attributes.brt_timestamp>
                    <cfset local.brtDay = local.data.attributes.day>
                    <cfset local.brtRound = local.data.attributes.round>
                    <cfset local.brtSeason = local.data.attributes.season>
                                                            
					<cfset local.playerData = structNew()>
                        
					<!--- gather data to go into the main table and history table --->
                    <cfset local.playerData.BRPlayerID = local.data.player.id>
                    <cfset local.playerData.BRTeamID = local.data.player.teamid>
                    <cfset local.playerData.FirstName = local.data.player.fname>
                    <cfset local.playerData.LastName = local.data.player.lname>
                    
                    <cfset local.playerData.nickName = "">
                        
					<cfset local.playerData.age = local.data.player.age>
                    <cfset local.playerData.csr = local.data.player.csr>
                    <cfset local.playerData.salary = local.data.player.salary>
                    <cfset local.playerData.height = local.data.player.height>
                    <cfset local.playerData.weight = local.data.player.weight>
                        
					<cfset local.playerData.formLevel = local.data.player.form>
                    <cfset local.playerData.energyLevel = local.data.player.energy>
                    <cfset local.playerData.AgressionLevel = local.data.player.aggression>
                    <cfset local.playerData.disciplineLevel = local.data.player.discipline>
                    <cfset local.playerData.leadershipLevel = local.data.player.leadership>
                    <cfset local.playerData.experienceLevel = local.data.player.experience>
                    
					<!--- DOUBLE CHECK THIS!!! --->	
                    <cfif local.data.player.injured neq "0">
                        <!---
                        <cfset local.unixDate = createDateTime("1970","01","01","00","00","00")>
                        <cfset local.playerData.InjuredDatetoCheck = dateAdd("s", local.data.player.injured, local.unixDate)>
                        --->            
                        <cfset local.playerData.InjuredDate = local.data.player.injured>
                        <cfif local.playerData.InjuredDate gt local.brtTimeStamp>
                            <cfset local.playerData.Injured = "1">
                        <cfelse>
                            <cfset local.playerData.Injured = "0">
                        </cfif>
                    <cfelse>
                        <cfset local.playerData.InjuredDate = "">
                        <cfset local.playerData.Injured = "0">
                    </cfif>
					<!--- DOUBLE CHECK THIS!!! --->	
                    <cfif local.data.player.contract neq "0">
                        <!---
                        <cfset local.unixDate = createDateTime("1970","01","01","00","00","00")>
                        <cfset local.playerData.contractDatetoCheck = dateAdd("s", local.data.player.contract, local.unixDate)>
                        --->
                        <cfset local.playerData.contractDate = local.data.player.contract>
                        <cfset local.playerData.contract = "1">
                    <cfelse>
                        <cfset local.playerData.contractDate = "">
                        <cfset local.playerData.contract = "0">
                    </cfif>
                    
                    <cfif local.data.player.jersey neq "255">
                        <cfset local.playerData.jersey = local.data.player.jersey>
                    <cfelse>
                        <cfset local.playerData.jersey = "0">
                    </cfif>
                        
					<cfset local.playerData.handed = local.data.player.hand>
                    <cfset local.playerData.footed = local.data.player.foot>
                    <cfset local.playerData.nationality = local.data.player.nationality>
                    
                    <!--- get the id for the country --->
                    <cfset local.playerData.countryID = getFactory().get("leaguePlayers").model.getCountryID(local.playerData.nationality,local.UserDatabase)>                        
                        
					<cfset local.playerData.youthid = local.data.player.youthid>
                        
					<!--- DOUBLE CHECK THIS!!! --->	
                    <cfif local.data.player.joined neq "0">
                    <!---
                        <cfset local.unixDate = createDateTime("1970","01","01","00","00","00")>
                        <cfset local.playerData.joinedDatetoCheck = dateAdd("s", local.data.player.joined, local.unixDate)>
                        --->
                        <cfset local.playerData.joinedDate = local.data.player.joined>
                    <cfelse>
                        <cfset local.playerData.joinedDate = "">
                    </cfif>
                        
					<!--- now, deal with the stats --->
                    <cfset local.playerData.agilityLevel = local.data.player.agility>
                    <cfset local.playerData.attackLevel = local.data.player.attack>
                    <cfset local.playerData.defenseLevel = local.data.player.defense>
                    <cfset local.playerData.handlingLevel = local.data.player.handling>
                    <cfset local.playerData.jumpingLevel = local.data.player.jumping>
                    <cfset local.playerData.kickingLevel = local.data.player.kicking>
                    <cfset local.playerData.speedLevel = local.data.player.speed>
                    <cfset local.playerData.staminaLevel = local.data.player.stamina>
                    <cfset local.playerData.strengthLevel = local.data.player.strength>
                    <cfset local.playerData.techniqueLevel = local.data.player.technique>
                    
                    <cfset local.playerData.brt_timestamp = local.brtTimeStamp>
					<cfset local.playerData.brt_day = local.brtDay>
                    <cfset local.playerData.brt_round = local.brtRound>
                    <cfset local.playerData.brt_season = local.brtSeason>
                        
                    <cfset getFactory().get("leaguePlayers").model.updatePlayer(local.userID,local.playerData,local.UserDatabase)>
                    
                        
                        
				<!--- errors, stored error somewhere against the user in the database --->
                <cfelse>
                    <cfset local.userError = local.xml.blackoutrugby_api_response.error.XmlText>
                    
                    <!--- now do a bit or error handling and insert into db against the userid --->
					<cfif local.userError eq "No valid players found">
                        <!--- this would happen when the teamid is wrong --->
                        <cfset local.newError = "There was a problem updating details for player #arguments.data.BRPlayerID#. Please check the Team ID in Your Profile">
                    <cfelseif local.userError eq "Member key is incorrect">
                        <!--- this would happen when the teamid is wrong --->
                        <cfset local.newError = "There was a problem updating details for player #arguments.data.BRPlayerID#. Please check the Access Key in Your Profile">
                    <cfelse>
                        <cfset local.newError = "">
                    </cfif>
                    
                    <!--- if the error can be identified, insert into the db --->
                    <cfif Len(local.newError)>
                        <cfset getFactory().get("user").model.insertUserError(userID,local.newError,"league",left(local.userError,255),getFactory().get("session").model.get('TeamID'),arguments.data.BRPlayerID)>
                    </cfif>
                    
                    <cfset local.success = 0>
                </cfif>   
                             
         </cfif>
         
         <cfif local.success>
         	<!--- delete any previous errors stored in session scrope --->
			<cfif getFactory().get("session").model.exists("userErrorsLeague")>
                <cfset getFactory().get("session").model.delete("userErrorsLeague")> 
            </cfif>
            
         	<cfset local.updatedPlayer = getModel().getplayerUpdatedDetails(BRplayerID=local.playerData.BRplayerID)>
            
         	<cfset local.result.output = getView().display(method="individualPlayer", BRplayerID=local.updatedPlayer.BRplayerID,playerID=local.updatedPlayer.playerID,firstName=local.updatedPlayer.firstName,nickName=local.updatedPlayer.nickName,lastname=local.updatedPlayer.lastname,CSR=local.updatedPlayer.CSR,weight=local.updatedPlayer.weight,height=local.updatedPlayer.height,age=local.updatedPlayer.age,top1=local.updatedPlayer.top1,top2=local.updatedPlayer.top2,top3=local.updatedPlayer.top3,top4=local.updatedPlayer.top4,best1=local.updatedPlayer.best1,best2=local.updatedPlayer.best2,best3=local.updatedPlayer.best3,best4=local.updatedPlayer.best4,best5=local.updatedPlayer.best5,setNo=1,country=local.updatedPlayer.country,injured=local.updatedPlayer.injured,dopadding=true,shortversion=arguments.data.shortversion).output>
         <cfelse>
         	<cfsavecontent variable="local.result.output">
            <cfoutput>
            <div id="errortext">
            There was a problem with the update. Please, check your Access Key.
            </div>
            </cfoutput>
            </cfsavecontent>
         </cfif>
         
         <cfcatch type="any">
         	<cfsavecontent variable="local.result.output">
            <cfoutput>
            <div id="errortext">
            There was a problem with the update. Please, check your Access Key.
            </div>
            </cfoutput>
            </cfsavecontent>
            <cfset local.success = 0>
        </cfcatch>
    </cftry>
    <cfset local.result.restrictOutput = true>  
    <cfreturn local.result>
</cffunction>

<cffunction name="importTeamData" returntype="struct" access="public" hint="goes and gets the data from BOR for all the league players">
		<cfargument name="data" type="struct" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        <cfset local.success = 1>
        
        <cftry>
        
        	<cfset local.userID = #getFactory().get('login').model.getUser().user.UserID#>
            <cfset local.UserDatabase = #getFactory().get("session").model.get('SiteDatabase')#>
            <cfset local.AccessKey = #getFactory().get("session").model.get('AccessKey')#>
            <cfset local.TeamID = #getFactory().get("session").model.get('TeamID')#>
            
            <cfparam name="arguments.data.homepage" default="false">
            
        	<!--- set up value for url to call for the user --->
            <cfset local.apiURL = "http://api.blackoutrugby.com/?d=#getFactory().getSetting('developerID')#&dk=#getFactory().getSetting('developerKey')#&r=p&teamid=#local.TeamID#&#local.AccessKey#&lea=1">
             
             <!--- do http request for api for user --->
             <cfhttp url="#local.apiURL#" method="get" result="local.userTeamData" timeout="10" throwonerror="true"/>
             
             <!--- only carry on if the response is ok --->
             <cfif local.userTeamData.statuscode eq "200 OK">
             	<cfset local.responseContent = local.userTeamData.filecontent>
                
                <!--- now parse the xml data --->
                <cfset local.xml = xmlParse(local.responseContent)>
                
                <!--- no errors...process as normal --->
                <cfif NOT StructKeyExists(local.xml.blackoutrugby_api_response,"error")>
                	<cfset local.data = getFactory().get("dataTypeConvert").util.xmlToStruct(local.xml).blackoutrugby_api_response>
                    
                    <cfset local.userPlayers = local.data.player>
                    <cfset local.brtTimeStamp = local.data.attributes.brt_timestamp>
                    <cfset local.brtDay = local.data.attributes.day>
                    <cfset local.brtRound = local.data.attributes.round>
                    <cfset local.brtSeason = local.data.attributes.season>
                    
                    <!--- first of all, get list of existing players for the user in the database --->
                    <cfset local.listofexistingplayers = getFactory().get("leaguePlayers").model.getAllValidPlayersForUser(local.userID,local.UserDatabase)>
                                        
                    <cfset local.listofPlayersinResponse = "">
                    
                    <!--- loop through the array of players --->
                    <cfloop from="1" to="#arrayLen(local.userPlayers)#" index="local.p">
                    	<cfset local.playerData = structNew()>
                        <cfset local.listofPlayersinResponse = listappend(local.listofPlayersinResponse,local.userPlayers[local.p].id)>
                        
                    	<!--- gather data to go into the main table and history table --->
                        <cfset local.playerData.BRPlayerID = local.userPlayers[local.p].id>
                        <cfset local.playerData.BRTeamID = local.userPlayers[local.p].teamid>
                        <cfset local.playerData.FirstName = local.userPlayers[local.p].fname>
                        <cfset local.playerData.LastName = local.userPlayers[local.p].lname>
                        
                        <cfset local.playerData.nickName = "">
                        
                    	<cfset local.playerData.age = local.userPlayers[local.p].age>
                        <cfset local.playerData.csr = local.userPlayers[local.p].csr>
                        <cfset local.playerData.salary = local.userPlayers[local.p].salary>
                        <cfset local.playerData.height = local.userPlayers[local.p].height>
                        <cfset local.playerData.weight = local.userPlayers[local.p].weight>
                        
                        <cfset local.playerData.formLevel = local.userPlayers[local.p].form>
                        <cfset local.playerData.energyLevel = local.userPlayers[local.p].energy>
                        <cfset local.playerData.AgressionLevel = local.userPlayers[local.p].aggression>
                        <cfset local.playerData.disciplineLevel = local.userPlayers[local.p].discipline>
                        <cfset local.playerData.leadershipLevel = local.userPlayers[local.p].leadership>
                        <cfset local.playerData.experienceLevel = local.userPlayers[local.p].experience>
                        <!--- DOUBLE CHECK THIS!!! --->	
                        <cfif local.userPlayers[local.p].injured neq "0">
                        	<!---
                        	<cfset local.unixDate = createDateTime("1970","01","01","00","00","00")>
							<cfset local.playerData.InjuredDatetoCheck = dateAdd("s", local.userPlayers[local.p].injured, local.unixDate)>
                			--->            
                            <cfset local.playerData.InjuredDate = local.userPlayers[local.p].injured>
                            <cfif local.playerData.InjuredDate gt local.brtTimeStamp>
								<cfset local.playerData.Injured = "1">
                            <cfelse>
                            	<cfset local.playerData.Injured = "0">
                            </cfif>
                        <cfelse>
                        	<cfset local.playerData.InjuredDate = "">
                            <cfset local.playerData.Injured = "0">
                        </cfif>
                        <!--- DOUBLE CHECK THIS!!! --->	
                        <cfif local.userPlayers[local.p].contract neq "0">
                        	<!---
                        	<cfset local.unixDate = createDateTime("1970","01","01","00","00","00")>
							<cfset local.playerData.contractDatetoCheck = dateAdd("s", local.userPlayers[local.p].contract, local.unixDate)>
                            --->
                            <cfset local.playerData.contractDate = local.userPlayers[local.p].contract>
                            <cfset local.playerData.contract = "1">
                        <cfelse>
                        	<cfset local.playerData.contractDate = "">
                            <cfset local.playerData.contract = "0">
                        </cfif>
                        
                        <cfif local.userPlayers[local.p].jersey neq "255">
							<cfset local.playerData.jersey = local.userPlayers[local.p].jersey>
                        <cfelse>
                        	<cfset local.playerData.jersey = "0">
                        </cfif>
                        
                        <cfset local.playerData.handed = local.userPlayers[local.p].hand>
                        <cfset local.playerData.footed = local.userPlayers[local.p].foot>
                        <cfset local.playerData.nationality = local.userPlayers[local.p].nationality>
                        
                        <!--- get the id for the country --->
                        <cfset local.playerData.countryID = getFactory().get("leaguePlayers").model.getCountryID(local.playerData.nationality,local.UserDatabase)>                        
                        
                        <cfset local.playerData.youthid = local.userPlayers[local.p].youthid>
                        
                        <!--- DOUBLE CHECK THIS!!! --->	
                        <cfif local.userPlayers[local.p].joined neq "0">
                        <!---
                        	<cfset local.unixDate = createDateTime("1970","01","01","00","00","00")>
							<cfset local.playerData.joinedDatetoCheck = dateAdd("s", local.userPlayers[local.p].joined, local.unixDate)>
                            --->
                            <cfset local.playerData.joinedDate = local.userPlayers[local.p].joined>
                        <cfelse>
                        	<cfset local.playerData.joinedDate = "">
                        </cfif>
                        
                        <!--- now, deal with the stats --->
                        <cfset local.playerData.agilityLevel = local.userPlayers[local.p].agility>
                        <cfset local.playerData.attackLevel = local.userPlayers[local.p].attack>
                        <cfset local.playerData.defenseLevel = local.userPlayers[local.p].defense>
                        <cfset local.playerData.handlingLevel = local.userPlayers[local.p].handling>
                        <cfset local.playerData.jumpingLevel = local.userPlayers[local.p].jumping>
                        <cfset local.playerData.kickingLevel = local.userPlayers[local.p].kicking>
                        <cfset local.playerData.speedLevel = local.userPlayers[local.p].speed>
                        <cfset local.playerData.staminaLevel = local.userPlayers[local.p].stamina>
                        <cfset local.playerData.strengthLevel = local.userPlayers[local.p].strength>
                        <cfset local.playerData.techniqueLevel = local.userPlayers[local.p].technique>
                        
                        <cfset local.playerData.brt_timestamp = local.brtTimeStamp>
                        <cfset local.playerData.brt_day = local.brtDay>
                        <cfset local.playerData.brt_round = local.brtRound>
                        <cfset local.playerData.brt_season = local.brtSeason>
 						
                        <!--- does the player already exists in the db for the user --->
                        <!--- if the playerID is found in existing players, then update --->
                        <cfif listfindNoCase(local.listofexistingplayers,local.playerData.BRPlayerID)>
                        	<!--- we only want to update the data if something has changed!!! --->
                            <!--- get existing data for the player --->
                            <cfset local.existingp = getFactory().get("leaguePlayers").model.getplayerDetailsFromBRPlayerID(local.playerData.BRPlayerID,local.UserDatabase,local.userID)>
                            
                            <cfset local.needtoUpdatePlayer = false>
                            
                            <cfif local.playerData.BRPlayerID neq local.existingp.BRPlayerID>
                            	<cfset local.needtoUpdatePlayer = true>
							<cfelseif local.playerData.BRTeamID neq local.existingp.BRTeamID>
                            	<cfset local.needtoUpdatePlayer = true>
                            <cfelseif local.playerData.FirstName neq local.existingp.FirstName>
                            	<cfset local.needtoUpdatePlayer = true>
                            <cfelseif local.playerData.LastName neq local.existingp.LastName>     
                            	<cfset local.needtoUpdatePlayer = true>            
                            <cfelseif local.playerData.nickName neq local.existingp.nickName> 
                            	<cfset local.needtoUpdatePlayer = true>                       
                            <cfelseif local.playerData.age neq local.existingp.age>   
                            	<cfset local.needtoUpdatePlayer = true>
                            <cfelseif local.playerData.csr neq local.existingp.csr>
                            	<cfset local.needtoUpdatePlayer = true>
                            <cfelseif local.playerData.salary neq local.existingp.salary>
                            	<cfset local.needtoUpdatePlayer = true>
                            <cfelseif local.playerData.height neq local.existingp.height>
                            	<cfset local.needtoUpdatePlayer = true>
                            <cfelseif local.playerData.weight neq local.existingp.weight>
                            	<cfset local.needtoUpdatePlayer = true>
                            <cfelseif local.playerData.formLevel neq local.existingp.formLevel>
                            	<cfset local.needtoUpdatePlayer = true>
                            <cfelseif local.playerData.energyLevel neq local.existingp.energyLevel>
                            	<cfset local.needtoUpdatePlayer = true>
                            <cfelseif local.playerData.AgressionLevel neq local.existingp.AgressionLevel>
                            	<cfset local.needtoUpdatePlayer = true>
                            <cfelseif local.playerData.disciplineLevel neq local.existingp.disciplineLevel>
                            	<cfset local.needtoUpdatePlayer = true>
                            <cfelseif local.playerData.leadershipLevel neq local.existingp.leadershipLevel>
                            	<cfset local.needtoUpdatePlayer = true>
                            <cfelseif local.playerData.experienceLevel neq local.existingp.experienceLevel>
                            	<cfset local.needtoUpdatePlayer = true>
                            <cfelseif local.playerData.InjuredDate neq local.existingp.InjuredDate>
                            	<cfset local.needtoUpdatePlayer = true>
							<cfelseif local.playerData.Injured neq local.existingp.Injured>
                            	<cfset local.needtoUpdatePlayer = true>
                            <cfelseif local.playerData.contractDate neq local.existingp.contractDate>
                            	<cfset local.needtoUpdatePlayer = true>
                            <cfelseif local.playerData.contract neq local.existingp.contract>  
                            	<cfset local.needtoUpdatePlayer = true>               
                            <cfelseif local.playerData.jersey neq local.existingp.jersey>
                            	<cfset local.needtoUpdatePlayer = true>
                            <cfelseif local.playerData.handed neq local.existingp.handed>
                            	<cfset local.needtoUpdatePlayer = true>
                            <cfelseif local.playerData.footed neq local.existingp.footed>
                            	<cfset local.needtoUpdatePlayer = true>
                            <cfelseif local.playerData.nationality neq local.existingp.nationality> 
                            	<cfset local.needtoUpdatePlayer = true>
                            <cfelseif local.playerData.countryID neq local.existingp.countryID> 
                            	<cfset local.needtoUpdatePlayer = true>
                            <cfelseif local.playerData.youthid neq local.existingp.youthid> 
                            	<cfset local.needtoUpdatePlayer = true>
                            <cfelseif local.playerData.joinedDate neq local.existingp.joinedDate> 
                            	<cfset local.needtoUpdatePlayer = true>
                            <cfelseif local.playerData.agilityLevel neq local.existingp.agilityLevel> 
                            	<cfset local.needtoUpdatePlayer = true>
                            <cfelseif local.playerData.attackLevel neq local.existingp.attackLevel> 
                            	<cfset local.needtoUpdatePlayer = true>
                            <cfelseif local.playerData.defenseLevel neq local.existingp.defenseLevel> 
                            	<cfset local.needtoUpdatePlayer = true>
                            <cfelseif local.playerData.handlingLevel neq local.existingp.handlingLevel> 
                            	<cfset local.needtoUpdatePlayer = true>
                            <cfelseif local.playerData.jumpingLevel neq local.existingp.jumpingLevel> 
                            	<cfset local.needtoUpdatePlayer = true>
                            <cfelseif local.playerData.kickingLevel neq local.existingp.kickingLevel> 
                            	<cfset local.needtoUpdatePlayer = true>
                            <cfelseif local.playerData.speedLevel neq local.existingp.speedLevel> 
                            	<cfset local.needtoUpdatePlayer = true>
                            <cfelseif local.playerData.staminaLevel neq local.existingp.staminaLevel> 
                            	<cfset local.needtoUpdatePlayer = true>
                            <cfelseif local.playerData.strengthLevel neq local.existingp.strengthLevel> 
                            	<cfset local.needtoUpdatePlayer = true>
                            <cfelseif local.playerData.techniqueLevel neq local.existingp.techniqueLevel> 
                            	<cfset local.needtoUpdatePlayer = true>
                            </cfif>
                                
                            <!--- need to update --->
                            <cfif local.needtoUpdatePlayer>
                            	<cfset getFactory().get("leaguePlayers").model.updatePlayer(local.userID,local.playerData,local.UserDatabase)>
                            </cfif>
                                
                                
                            <!--- playerID not found in the db, we need to add the player, stats, player history and stats history --->
                            <cfelse>
                                <cfset getFactory().get("leaguePlayers").model.playerInsert(local.userID,local.playerData,local.UserDatabase)>
                            </cfif>
    
                        </cfloop>
                        
                        <!--- loop through existing players, and if they are not in the xml response, set as soldorfired --->
                        <cfloop list="#local.listofexistingplayers#" index="local.existingp">
                            <!--- if an existing db player is not found in the list of players we get from the response, it is either sold or fired --->
                            <cfif NOT listfindNoCase(local.listofPlayersinResponse,local.existingp)>
                                <cfset getFactory().get("leaguePlayers").model.setSoldorFired(local.userID,local.existingp)>
                            </cfif>
                        </cfloop>
                        
                    <!--- errors, stored error somewhere against the user in the database --->
                    <cfelse>
						<cfset local.userError = local.xml.blackoutrugby_api_response.error.XmlText>
                        
                        <!--- now do a bit or error handling and insert into db against the userid --->
                        <cfif local.userError eq "No valid players found">
                            <!--- this would happen when the teamid is wrong --->
                            <cfset local.newError = "There was a problem updating your Team details. Please check the Team ID in Your Profile">
                        <cfelseif local.userError eq "Member key is incorrect">
                            <!--- this would happen when the teamid is wrong --->
                            <cfset local.newError = "There was a problem updating your Team details. Please check the Access Key in Your Profile">
                        <cfelse>
                            <cfset local.newError = "">
                        </cfif>
                        
                        <!--- if the error can be identified, insert into the db --->
                        <cfif Len(local.newError)>
                            <cfset getFactory().get("user").model.insertUserError(userID,local.newError,"league",left(local.userError,255),local.TeamID,"0")>
                        </cfif>
                    	<cfset local.success = 0>
                	</cfif>                
             	</cfif>
                
             <cfif local.success>
				<!--- delete any previous errors stored in session scrope --->
                <cfif getFactory().get("session").model.exists("userErrorsLeague")>
                	<cfset getFactory().get("session").model.delete("userErrorsLeague")> 
                </cfif>
                
                <cfif arguments.data.homepage>
                	<cfset local.data.top10CSR = getModel().gettop10CSR()>
                    <cfset local.result.output = getFactory().get("home").view.display(method="default", data=local.data).output>
                <cfelse>
                	<cfset local.data.allPlayers = getModel().getAllPlayers()>
					<cfset local.result.output = getView().display(method="default", data=local.data).output>
                </cfif>
             <cfelse>
                <cfsavecontent variable="local.result.output">
                <cfoutput>
                <div id="errortext">
                There was a problem with the update. Please, check your Access Key and Team ID.
                </div>
                </cfoutput>
                </cfsavecontent>
             </cfif>
             
             <cfcatch type="any">
             	<cfsavecontent variable="local.result.output">
                <cfoutput>
                <div id="errortext">
                There was a problem with the update. Please, check your Access Key and Team ID.
                </div>
                </cfoutput>
                </cfsavecontent>
            	<cfset local.success = 0>
        	</cfcatch>
    </cftry>
             
    <cfset local.result.restrictOutput = true>  
    <cfreturn local.result>
</cffunction>

--->

<cffunction name="updatechanges" access="public" returntype="struct" hint="Controller for viewing the changes that occur on last update">
		<cfargument name="data" type="struct" required="false">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        <!--- user is not logged in. Redirect to login page --->
		<cfif NOT getFactory().get("login").model.isLoggedIn()>
            <cfset getFactory().get("session").model.set("returnURL", "/login")>
            <cfset local.result.output = getFactory().get("httpUtil").util.metaRedirect(
			getFactory().get("session").model.get("returnURL"),
			getFactory().get("template").view.failure(getModel().getMessage("failure","1","title"),"","50%").output,
			1
			)>
        <!--- user is logged in --->
		<cfelse>
        	<cfset local.data = arguments.data>
			<cfset local.data.players = getModel().getAllPlayersLastHistory()>
            <cfset local.data.lastUpdateDate = getModel().getlastUpdateDate()>
            <cfset local.result.output = getView().display(method="updatechanges", data=local.data).output>
            <cfset local.result.title = "Changes on last Update">
            <cfset variables.breadcrumb = ListAppend(variables.breadcrumb, "Changes on last Update|updatechanges")>
            <cfset local.result.breadcrumb = variables.breadcrumb>
		</cfif>		

		<cfreturn local.result>
	</cffunction>

    

</cfcomponent>