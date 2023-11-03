<cfcomponent name="icicle" extends="parent" hint="Main 'runner' for the framework">

	<cffunction name="init" access="public" returntype="icicle">
		<cfset super.init()>
		<cfreturn this/>
	</cffunction>
	
	<cffunction name="run" access="public" returntype="void">
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		<cfset local.execution = structNew()>
		<cfset local.execution.start = getTickCount()>

		<cfset local.component = request.scope.get("component")>
		<cfset local.method = request.scope.get("method")>
        <!---
        <cfdump var="component...#local.component#">
        <cfdump var="method---#local.method#">
		--->
        
		<cfset local.results =  StructNew()>
        <cfset local.debug = false>

		<!--- record a two-step history of user visit locations --->
		<cfif getFactory().get("Session").model.get("currentURL") neq request.scope.get("SCRIPT_NAME")
				AND request.scope.get("SCRIPT_NAME") neq "/favicon.ico"
		>
			<cfset getFactory().get("session").model.set("lastURL", getFactory().get("Session").model.get("currentURL"))>
			<cfset getFactory().get("session").model.set("currentURL", request.scope.get("SCRIPT_NAME"))>
		</cfif>
        
        <cftry>
			<!--- Log the page request into the Stats database --->
            <cfcatch type="any">
                <!--- if we do not log a request, it is annoying but not the end of the world, so carry on --->
                <cfif local.debug>
                <cfdump var="Cannot log page request for #request.scope.get('script_name')#" expand="false">
                </cfif>
            </cfcatch>
        </cftry>
	<!---<cfdump var="http://#request.scope.get('server_name')##request.scope.get('script_name')#">
		<cfabort>--->
        <!---<cflocation addtoken="false" url="http://#request.scope.get('server_name')##request.scope.get('script_name')#">--->
        
        <cfif getFactory().get("session").model.exists("storedscopevalue")>
			<cfset local.newScope = getFactory().get("session").model.get("storedscopevalue")>
            <cfloop list="#structKeyList(local.newScope)#" index="local.fld">
                <cfif local.fld neq "HTTPS">
                    <cfset request.scope.set(local.fld, local.newScope[local.fld])>
                </cfif>
            </cfloop>
            <cfset getFactory().get("session").model.delete("storedscopevalue")>
        </cfif>
        

		<!--- Ensure that the component exists in the Factory. if it doesn't, we're looking at a CMS--->
		<cfif getFactory().exists(local.component)>
			<!--- <cfoutput><p>Template method: #getFactory().get("cms").model.getTemplateMethod()#, component: #local.component#, method: #local.method#</p></cfoutput> --->
			<cftry>
				<cfif NOT request.scope.get("VIEW_METHOD")>
                	<cfif local.debug>
					<cfdump var="Processing as as call to a Factory controller" expand="no">
                    </cfif>
					<cfset local.obj = getFactory().get(local.component).controller>
				<cfelse>
                	<cfif local.debug>
                	<cfdump var="Processing as as call to a Factory view" expand="no">
                    </cfif>
					<cfset local.obj = getFactory().get(local.component).view>
				</cfif>                
                
                <cfif local.component eq "user" AND (local.method eq "showUsers" OR local.method eq "deleteUser" OR local.method eq "editUser" OR local.method eq "addUser") AND getFactory().get("login").model.getUser().user.securityLevelID lt 4>
					<cfset local.result.output = getFactory().get("httpUtil").util.metaredirect(
						"/",
						getFactory().get("template").view.success("You do not have access to this part of the website", "").output,
						5
                    )>
				<cfelse>
					<cfset local.scopevalue = request.scope.get()>
                    	
					<cfinvoke component="#local.obj#" method="#local.method#" returnvariable="local.result">
						<cfinvokeargument name="data" value="#local.scopevalue#">
						<cfinvokeargument name="icicleAuth" value="1">
					</cfinvoke>
				</cfif>
	
				<cfset StructInsert(local.results, "main", local.result)>

				<cfset local.result.output = getFactory().get("template").view.display(
						method="#local.component#",data=local.results, wrapper=false).output>
	
				<cfcatch type="any">
                	<cfif local.debug>
                	<cfdump var="Error calling #local.component#.#local.method#()" expand="no">
                    </cfif>
				</cfcatch>
			</cftry>
	
			<cfif local.result.restrictOutput>
				<cfsetting showdebugoutput="false">
			</cfif>

			<cfset local.execution.stop = getTickCount()>
			<cfset local.execution.milliseconds = local.execution.stop - local.execution.start>
            <cfif local.debug>
            <cfdump var="Execution time was #local.execution.milliseconds#ms" expand="no">
            </cfif>
			

		<cfelse>
			
			<cftry>
					<cfset local.result = getFactory().getResult()>
					<cfset StructInsert(local.result, "main", getFactory().getResult())>
					<cfset local.result.main.output = getFactory().get("template").view.failure("Unable to show you that page", "Sorry, the page you are looking for doesn't seem to exist").output>
					<cfset local.result.output = getFactory().get("template").view.display(method="default", data=local.result, wrapper=false).output>
					<!---<cfset local.result.output = local.result.output & request.monitor.report()>--->
				
				<cfcatch type="any">
                	<cfif local.debug>
					<cfdump var="#cfcatch#"><cfdump var="#request.scope.get()#">
                    </cfif>
					<cftry>
                    	<cfif local.debug>
                    	<cfdump var="Iceberg CMS produced an error displaying #request.scope.get('script_name')# into the #getFactory().get("cms").model.getTemplateMethod()# template" expand="no">
                        </cfif>
						<cfcatch type="any">
                        	<cfif local.debug>
                        	<cfdump var="#cfcatch#" expand="no">
                            </cfif>
						</cfcatch>
					</cftry>
				</cfcatch>
			</cftry>
		</cfif>

		<cfoutput>#local.result.output#</cfoutput>
	</cffunction>

</cfcomponent>