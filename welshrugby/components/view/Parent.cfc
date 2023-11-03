<cfcomponent name="parent" hint="Parent for Views" extends="welshrugby.parent">
	<cffunction name="init" returntype="parent" access="public">
		<cfset super.init()>
		<cfreturn this/>
	</cffunction>

	<!--- parent for all views --->
	<cffunction name="display" returntype="struct" hint="Wrapper for display handlers, including getting the data">
		<cfargument name="id" type="string" required="false" default="" hint="Triggers call to get() function to return something">
		<cfargument name="data" type="any" required="false" default="" hint="Could be struct, xml or array">
		<cfargument name="method" type="string" required="false" default="default">
		<cfargument name="wrapper" type="boolean" required="false" default="true">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		<cfset local.debug = false>
		<cftry>
			<!--- make sure we carry through any additional arguments specified --->
			<cfset local.extraArgs = "">
			<cfloop list="#StructKeyList(arguments)#" index="local.arg">
				<cfif NOT ListFindNoCase("data,method", local.arg)>
					<cfset local.extraArgs = ListAppend(local.extraArgs, local.arg)>
				</cfif>
			</cfloop>

			<cfif isStruct(arguments.data)>
				<cfset local.data = arguments.data>
			<cfelseif isArray(arguments.data)>
				<cfset local.data = arguments.data>
			<cfelseif isQuery(arguments.data)>
				<cfset local.data = arguments.data>
			<cfelseif arguments.data neq "">
				<cfset local.data = arguments.data>
			<cfelse>
				<cfset local.data = structNew()>
			</cfif>

			<cfcatch type="any">
				<cftry>
                	<cfif local.debug>
                    	<cfdump var="Error calling display method #arguments.method# in #getName()#">
                    </cfif>
					<cfcatch type="any">
                    	<cfif local.debug>
                    	<cfdump var="Error calling display method #arguments.method# in unknown object">
                    </cfif>
					</cfcatch>
				</cftry>
			</cfcatch>
		</cftry>

		<!--- invoke the requested object display rule --->
		<cftry>
			<cfinvoke method="#arguments.method#" returnvariable="local.tmpResult">
				<cfif StructKeyExists(local, "data")>
					<cfinvokeargument name="data" value="#local.data#">
				</cfif>
				<cfloop list="#local.extraArgs#" index="local.arg">
					<cfinvokeargument name="#local.arg#" value="#arguments[local.arg]#">
				</cfloop>
			</cfinvoke>
			<cfset local.result = local.tmpResult>

			<cfcatch type="any">
            	<cfif local.debug>
                	<cfdump var="Function &quot;#arguments.method#&quot; not found inside &quot;#getName()#&quot; view">
                </cfif>
			</cfcatch>
		</cftry>
		<cfset local.tmpOutput = local.result.output>

		<cfsavecontent variable="local.result.output">
			<cfif arguments.wrapper>
				<cfoutput><div class="#getObjectType()#"><div class="#arguments.method#"></cfoutput>
			</cfif>

			<cfoutput>
				#local.tmpOutput#
			</cfoutput>

			<cfif arguments.wrapper>
				<cfoutput><div class="clear"></div></div><div class="clear"></div></div></cfoutput>
			</cfif>
		</cfsavecontent>
		<cfreturn local.result>
	</cffunction>
</cfcomponent>