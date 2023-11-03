<cfcomponent name="home" extends="parent" hint="Model, queries and logic for home">

	<cffunction name="init" returntype="home" access="public">
		<cfset var local = structNew()>

		<cfset super.init()>
		
		<cfset local.cfcPath = getDirectoryFromPath(getCurrentTemplatePath())>
		<cffile action="read" file="#local.cfcPath#..\..\config\#application.core.get('configFolder')#\HomeMessages.xml" variable="local.rawData">
		<cfset local.xml = xmlParse(local.rawData)>
		
		<cfset variables.messages = StructNew()>
		
		<cfloop from="1" to="#ArrayLen(local.xml.homemessages.message)#" index="local.m">
			<cfloop list="#StructKeyList(local.xml.homemessages.message[local.m].xmlAttributes)#" index="local.key">
				
				<cfset local.messages = ArrayNew(1)>

				<cfloop from="1" to="#ArrayLen(local.xml.homemessages.message[local.m].container)#" index="local.c">
					  <cfset local.message = structNew()>
						<cfif NOT StructKeyExists(local.message,"title")>
							<cfset StructInsert(local.message, "title",local.xml.homemessages.message[local.m].container[local.c].xmlAttributes.title)>
						</cfif>
						<cfif NOT StructKeyExists(local.message,"summary")>
							<cfset StructInsert(local.message, "summary",local.xml.homemessages.message[local.m].container[local.c].xmlAttributes.summary)>
						</cfif>
						
						<cfset ArrayAppend(local.messages, local.message)>
				</cfloop>
				
				<cfif NOT StructKeyExists(variables.messages,local.xml.homemessages.message[local.m].xmlAttributes[local.key])>
					<cfset StructInsert(variables.messages, local.xml.homemessages.message[local.m].xmlAttributes[local.key], local.messages)>
				</cfif>
			</cfloop>
		</cfloop>
        
		<cfreturn this/>
	</cffunction>
    
    <cffunction name="getLeagueTable" access="public" returntype="string" hint="Returns title for a message">
		<cfset var local = structNew()>
		
		<cfif Len(variables.leaguetable)>
			<cfreturn variables.leaguetable>
		<cfelse>
			<cfreturn "">
		</cfif>
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