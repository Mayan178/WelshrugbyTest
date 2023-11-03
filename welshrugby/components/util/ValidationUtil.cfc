<cfcomponent name="validationUtil" hint="Provides validation" extends="welshrugby.parent">
	<cffunction name="init" returntype="validationUtil" access="public">
		<cfset super.init()>
		<cfreturn this/>
	</cffunction>
	
	<cffunction name="validate" access="public" returntype="struct">
		<cfargument name="fieldName" type="string" required="true" hint="A plain text name of the field for example 'Expiry Date'">
		<cfargument name="fieldValue" type="string" required="true" hint="The actual value to validate">
		<cfargument name="validationList" type="string" required="true" hint="A comma-seperated list of validation rules. These are listed in the CFSWITCH">
		<!--- other arguments may be specified, so generalise them--->
		<cfargument name="extraArg1" type="any" required="false">
		<cfargument name="extraArg2" type="any" required="false">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()> <!--- This is just a structure, but has a few values set by default --->

		<!--- loop through the list of rules and record error for the first broken rule --->
		<cfloop list="#arguments.validationList#" index="local.rule">
			<cfswitch expression="#local.rule#">
				<!--- ensures that the fieldValue actually has something in it--->
				<cfcase value="has-length">
					<cfif Len(arguments.fieldValue) eq 0>
						<cfset local.result.output = "#arguments.fieldName# must be filled in">
					</cfif>
				</cfcase>
                <!--- ensures that the fieldValue is a number --->
				<cfcase value="is-number">
					<cfif NOT LSIsNumeric(arguments.fieldValue)>
						<cfset local.result.output = "#arguments.fieldName# is not a number">
					</cfif>
				</cfcase>
				<!--- ensures that the fieldValue is an email address --->
				<cfcase value="is-email">
					<cfif NOT REFindNocase("^[_a-z0-9-]+(\.[_a-z0-9-]+)*@[a-z0-9-]+(\.[a-z0-9-]+)*\.(([a-z]{2,3})|(aero|coop|info|museum|name))$", arguments.fieldValue)>
						<cfset local.result.output = "#arguments.fieldName# must be a valid email address">
					</cfif>
				</cfcase>
				<!--- ensures that fieldValue is equal to the value in extraArg2 - which has its own label in extraArg1 --->
				<cfcase value="is-equal-to">
					<cfif arguments.fieldValue neq arguments.extraArg2>
						<cfset local.result.output = "#arguments.fieldName# and #arguments.extraArg1# must match">
					</cfif>
				</cfcase>
			</cfswitch>
			<!--- only display one error at a time to avoid doubling-up --->
			<cfif Len(local.result.output)>
				<cfbreak>
			</cfif>
		</cfloop>
		
		<!--- if the output has something in it then there has been an error --->
		<cfif Len(local.result.output)>
			<cfset local.result.success = false>
		</cfif>
		<cfreturn local.result>
	</cffunction>
</cfcomponent>