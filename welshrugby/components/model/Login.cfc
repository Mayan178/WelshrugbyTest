<cfcomponent name="login" extends="parent" hint="Model, queries and logic for login">

	<cffunction name="init" returntype="login" access="public">
		<cfset var local = structNew()>

		<cfset super.init()>
		
		<cfset local.cfcPath = getDirectoryFromPath(getCurrentTemplatePath())>
		<cffile action="read" file="#local.cfcPath#..\..\config\#application.core.get('configFolder')#\LoginMessages.xml" variable="local.rawData">
		<cfset local.xml = xmlParse(local.rawData)>
		
		<cfset variables.messages = StructNew()>
		
		<cfloop from="1" to="#ArrayLen(local.xml.loginmessages.message)#" index="local.m">
			<cfloop list="#StructKeyList(local.xml.loginmessages.message[local.m].xmlAttributes)#" index="local.key">
				<cfset local.messages = ArrayNew(1)>

				<cfloop from="1" to="#ArrayLen(local.xml.loginmessages.message[local.m].container)#" index="local.c">
					  <cfset local.message = structNew()>
						<cfif NOT StructKeyExists(local.message,"title")>
							<cfset StructInsert(local.message, "title",local.xml.loginmessages.message[local.m].container[local.c].xmlAttributes.title)>
						</cfif>
						<cfif NOT StructKeyExists(local.message,"summary")>
							<cfset StructInsert(local.message, "summary",local.xml.loginmessages.message[local.m].container[local.c].xmlAttributes.summary)>
						</cfif>
						<cfset ArrayAppend(local.messages, local.message)>
				</cfloop>
				
				<cfif NOT StructKeyExists(variables.messages,local.xml.loginmessages.message[local.m].xmlAttributes[local.key])>
					<cfset StructInsert(variables.messages, local.xml.loginmessages.message[local.m].xmlAttributes[local.key], local.messages)>
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfreturn this/>
	</cffunction>

	<cffunction name="isLoggedIn" access="public" returntype="boolean" hint="Checking if the current user is logged in">
		<cfset var local = structNew()>
		<cfset local.loginVars = getLoginVariables()>

		<cfif StructKeyExists(local.loginVars, "userID") AND Len(local.loginVars.userID)>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>

	<cffunction name="login" access="public" returntype="struct" hint="Trying to login user based on data provided">
		<cfargument name="username" type="string" required="true">
		<cfargument name="password" type="string" required="false" default="">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
		<cfset local.check = loginAccountExists(arguments.username, arguments.password)>
        
		<!--- user exists, set up session variables --->
		<cfif local.check.exists>
			<cfset local.result.success = true>
            
			<!--- set login variables --->
			<cfset setLoginVariables(
					sessionID=session.CFID,
					userID=local.check.user.userID,
					username=arguments.username,
					password=arguments.password,
					securityLevelID=local.check.user.securityLevelID,
					lastloggedin=local.check.user.lastloggedin,
					country=local.check.user.countryName,
					AccessKey=local.check.user.AccessKey,
					TeamID=local.check.user.TeamID,
					countryTeamID=local.check.user.countryTeamID,
					expires=1
					
			)>
            
            <!--- now update the last logged in date in the database for the user --->
            <cfset  resetLastLoggedIn(local.check.user.userID)>
            
            <!--- now set up value for the database --->
            <cfset  getFactory().get("session").model.set("SiteDatabase",local.check.user.countryDatabase)>
            
            <!--- Set default template to league --->
            <cfset getFactory().get("session").model.setSiteView("League")>
            
		<!--- user not found --->
		<cfelse>
        	
            <!--- add the failed login details to the FailedLogins table --->
            <cfset  addFailedLogin(arguments.username,arguments.password)>
            
			<!--- user not recognised --->
			<cfset local.result.output = "Sorry, your username and password are not recognised">
			<cfset local.result.success = false>
		</cfif>
 
		<cfreturn local.result>
	</cffunction>

	<cffunction name="loginAccountExists" returntype="struct" access="public" hint="Determine whether an account exists or not">
		<cfargument name="username" type="string" required="true" hint="Username">
		<cfargument name="password" type="string" required="false" default="" hint="Password">
		
		<cfset var local = structNew()>
		<cfset local.result = structNew()>
		
		<!--- get the user --->
		<cfset local.check = getUser(arguments.username, arguments.password)>
		
		<cfif local.check.success>
			<!--- user exists --->
			<cfset local.result = local.check>
		<cfelse>
			<!--- no user found --->
			<cfset local.result.exists = false>
		</cfif>
		
		<cfreturn local.result>
	</cffunction>

	<cffunction name="setLoginVariables" access="public" returntype="void" hint="Setting session variables">
		<cfargument name="sessionID" type="string" required="false" default="#now()#">
		<cfargument name="userID" type="string" required="false" default="#now()#">
		<cfargument name="username" type="string" required="false" default="#now()#">
		<cfargument name="password" type="string" required="false" default="">
        <cfargument name="securityLevelID" type="string" required="false" default="#now()#">        
        <cfargument name="AccessKey" type="string" required="false" default="#now()#">
        <cfargument name="TeamID" type="string" required="false" default="#now()#">
        <cfargument name="CountryTeamID" type="string" required="false" default="#now()#">
        
		<cfargument name="expires" type="any" required="false" default="1">
		
		<cfif arguments.expires neq "NOW">
            <cfset getFactory().get("session").model.set("userID", arguments.userID)>
            <cfset getFactory().get("session").model.set("username", arguments.username)>
            <cfset getFactory().get("session").model.set("password", arguments.password)>
            <cfset getFactory().get("session").model.set("securityLevelID", arguments.securityLevelID)>
            <cfset getFactory().get("session").model.set("lastloggedIn", arguments.lastloggedIn)>
            <cfset getFactory().get("session").model.set("country", arguments.country)>
            
            <cfset getFactory().get("session").model.set("AccessKey", arguments.AccessKey)>
            <cfset getFactory().get("session").model.set("TeamID", arguments.TeamID)>
            <cfset getFactory().get("session").model.set("CountryTeamID", arguments.CountryTeamID)>
        <cfelse>
            <cfset getFactory().get("session").model.delete("userID")>
            <cfset getFactory().get("session").model.delete("username")>
            <cfset getFactory().get("session").model.delete("password")>
            <cfset getFactory().get("session").model.delete("securityLevelID")>
            <cfset getFactory().get("session").model.delete("lastloggedIn")>
            <cfset getFactory().get("session").model.delete("country")>
            
            <cfset getFactory().get("session").model.delete("AccessKey")>
            <cfset getFactory().get("session").model.delete("TeamID")>
            <cfset getFactory().get("session").model.delete("CountryTeamID")>
        </cfif>
		
	</cffunction>

	<cffunction name="getLoginVariables" access="public" returntype="any" output="false" hint="Getting session variables">
		<cfset var local = structNew()>

		<cfsilent>
			<cfset local.vars = structNew()>
	
			<cfloop list="userID,username,password,lastloggedIn,redMaxLevel,greenMaxLevel,securityLevelID,country,AccessKey,TeamID,CountryTeamID" index="local.var">
				<cfset StructInsert(local.vars, local.var, getFactory().get("session").model.get(local.var))>
			</cfloop>

			<cfreturn local.vars>
		</cfsilent>
	</cffunction>


	<cffunction name="getUser" access="public" returntype="struct" hint="Gets a user's details based on data provided">
		<cfargument name="username" type="string" required="false" default="#getFactory().get('session').model.get('username')#">
		<cfargument name="password" type="string" required="false" default="#getFactory().get('session').model.get('password')#">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		<cfset local.result.success = false>
        
        <cftry>
            <cfquery datasource="#getFactory().getDatasource('adminSecurity')#" name="local.getUser">
                select 	s.userID,
                		s.username,
                		s.userPassword,
                        s.accessKey,
                        s.teamID,
                        s.lastLoggedIn,
                        s.redMaxLevel,
                        s.greenMaxLevel,
                        s.securityLevelID,
                        s.countryID,
                        s.leagueLogo,
                        s.under20sLogo,
                        sc.countryName,
                        sc.countryLogo,
                        sc.countryDatabase,
                        sc.countryStyleSheet,
                        sc.countryTeamID
                from 	Security s INNER JOIN SecurityCountries sc
                ON		s.CountryID = sc.CountryID
                where 	s.username = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.username#">
                and		s.userpassword = <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.password#">
            </cfquery>
		
			<cfif local.getUser.recordcount>
            	<cfset local.data = structNew()>
            	<cfloop list="#local.getUser.columnList#" index="local.col">
                	
					<cfset StructInsert(local.data, local.col, local.getUser[local.col][local.getUser.currentRow])>
                    
                </cfloop>
                <cfset local.result.user = local.data>
                 
                <cfset local.result.success = true>
                <cfset local.result.exists = true>
            <cfelse>
                <cfset local.result.success = false>
            </cfif>
            
            <cfcatch type="any">
                <cfset local.result.success = false>
                <cfdump var="#cfcatch#">
            </cfcatch>
        </cftry>
        
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="resetLastLoggedIn" access="public" output="no" returntype="void" hint="Updating the last login date in the db for the current user">
		<cfargument name="userID" type="string" required="false" default="#getFactory().get('session').model.get('userID')#">
		
		<cfquery datasource="#getFactory().getDatasource('adminSecurity')#" name="local.update">
            update 	Security
            set		LastLoggedIn = #now()#
            where	userID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userID#">
        </cfquery>
	</cffunction>
    
    <cffunction name="addFailedLogin" access="public" returntype="void" hint="keeping trace of failed attempts to login">
		<cfargument name="username" type="string" required="false" default="">
        <cfargument name="password" type="string" required="false" default="">
		
        <cftry>
            <cfquery datasource="#getFactory().getDatasource('adminSecurity')#" name="local.update">
                insert into	FailedLogins
                            (
                            FailedUsername,
                            FailedPassword,
                            FailedIPAddress,
                            FailedDate
                            )
                values		(
                            <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.username#">,
                            <cfqueryparam cfsqltype="cf_sql_char" value="#arguments.password#">,
                            <cfqueryparam cfsqltype="cf_sql_char" value="#cgi.REMOTE_ADDR#">,
                            #now()#
                            )
            </cfquery>
            
            <cfcatch type="any">
                <cfdump var="#cfcatch#"><cfabort>
            </cfcatch>
            
        </cftry>
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
	
</cfcomponent>