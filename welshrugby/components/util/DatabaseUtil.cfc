<cfcomponent name="databaseUtil">
	<cffunction name="init" access="public" returntype="databaseUtil">
		<cfreturn this/>
	</cffunction>

	<cffunction name="getLastID" access="public" returntype="numeric">
		<cfargument name="datasource" required="true" type="string">
		<cfargument name="table" required="true" type="string">
		<cfargument name="where" required="false" type="string" default="">
		
		<!--- Very unusual for me not to use local structure, but I think it is fractionally faster --->
		<cfset var getLastID = "">

		<cfquery name="getLastID" datasource="#arguments.datasource#">
			select max(id) as [id]
			from #arguments.table#
			<cfif Len(arguments.where)>
				#arguments.where#
			</cfif>
		</cfquery>

		<cfreturn getLastID.ID>
	</cffunction>
    
    <cffunction name="getLastPlayerID" access="public" returntype="numeric">
		<cfargument name="datasource" required="true" type="string">
		<cfargument name="table" required="true" type="string">
		<cfargument name="where" required="false" type="string" default="">
		
		<!--- Very unusual for me not to use local structure, but I think it is fractionally faster --->
		<cfset var getLastID = "">

		<cfquery name="getLastID" datasource="#arguments.datasource#">
			select max(playerID) as [id]
			from #arguments.table#
			<cfif Len(arguments.where)>
				#arguments.where#
			</cfif>
		</cfquery>

		<cfreturn getLastID.id>
	</cffunction>
    
    <cffunction name="getLastTeamID" access="public" returntype="numeric">
		<cfargument name="datasource" required="true" type="string">
		<cfargument name="table" required="true" type="string">
		<cfargument name="where" required="false" type="string" default="">
		
		<!--- Very unusual for me not to use local structure, but I think it is fractionally faster --->
		<cfset var getLastID = "">

		<cfquery name="getLastID" datasource="#arguments.datasource#">
			select max(teamID) as [id]
			from #arguments.table#
			<cfif Len(arguments.where)>
				#arguments.where#
			</cfif>
		</cfquery>

		<cfreturn getLastID.id>
	</cffunction>
    
    <cffunction name="getLastUserID" access="public" returntype="numeric">
		<cfargument name="datasource" required="true" type="string">
		<cfargument name="table" required="true" type="string">
		<cfargument name="where" required="false" type="string" default="">
		
		<!--- Very unusual for me not to use local structure, but I think it is fractionally faster --->
		<cfset var getLastID = "">

		<cfquery name="getLastID" datasource="#arguments.datasource#">
			select max(userID) as [id]
			from #arguments.table#
			<cfif Len(arguments.where)>
				#arguments.where#
			</cfif>
		</cfquery>

		<cfreturn getLastID.id>
	</cffunction>
    
    
    <cffunction name="getLastMatchID" access="public" returntype="numeric">
		<cfargument name="datasource" required="true" type="string">
		<cfargument name="table" required="true" type="string">
		<cfargument name="where" required="false" type="string" default="">
		
		<!--- Very unusual for me not to use local structure, but I think it is fractionally faster --->
		<cfset var getLastID = "">

		<cfquery name="getLastID" datasource="#arguments.datasource#">
			select max(matchID) as [id]
			from #arguments.table#
			<cfif Len(arguments.where)>
				#arguments.where#
			</cfif>
		</cfquery>

		<cfreturn getLastID.id>
	</cffunction>
    
    <cffunction name="getLastHistoryID" access="public" returntype="numeric">
		<cfargument name="datasource" required="true" type="string">
		<cfargument name="table" required="true" type="string">
		<cfargument name="where" required="false" type="string" default="">
		
		<!--- Very unusual for me not to use local structure, but I think it is fractionally faster --->
		<cfset var getLastID = "">

		<cfquery name="getLastID" datasource="#arguments.datasource#">
			select max(historyID) as [id]
			from #arguments.table#
			<cfif Len(arguments.where)>
				#arguments.where#
			</cfif>
		</cfquery>

		<cfreturn getLastID.id>
	</cffunction>
	
	<cffunction name="getQueryRow" access="public" returntype="query" hint="Returns a new query containing row <rownum> of <inquery>">
		<cfargument name="inQuery" type="query" required="true">
		<cfargument name="rowNum" type="numeric" required="true">

		<cfset var local = structNew()>
		<cfset local.outQuery = QueryNew(arguments.inQuery.columnList)>
		<cfset QueryAddRow(local.outQuery, 1)>
		<cfloop list="#arguments.inQuery.columnList#" index="local.col">
			<cfset QuerySetCell(local.outQuery, local.col, arguments.inQuery[local.col][arguments.rowNum])>
		</cfloop>

		<cfreturn local.outQuery>
	</cffunction>
</cfcomponent>