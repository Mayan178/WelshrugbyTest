<cfcomponent name="htmlUtil" hint="Contains various HTML-related functions">
	<cfset variables.filter = "">

	<cffunction name="init" access="public" returntype="htmlUtil">
		<cfset var local = structNew()>

		<cfreturn this/>
	</cffunction>

	<cffunction name="stripHTML" access="public" returntype="string">
		<cfargument name="input" type="string" required="true">
		<cfargument name="extraTags" type="string" required="false" default="">
		<cfargument name="stripAll" type="boolean" required="false" default="false">

		<cfset var local = structNew()>

		<cfif arguments.stripAll>
			<cfset local.theString = ReReplaceNoCase(arguments.input, "<[^>]*>", "", "ALL")>
		<cfelse>
			<cfset local.stripTags = ListAppend("span,u", arguments.extraTags)>
			<cfset local.theString = arguments.input>
			<cfset local.theString = reReplaceNoCase(local.theString, "<\s*(p|font|st1|span|tr|th|div|li|ul|ol)\s+.*?>", "<\1>", "ALL")>
			<cfset local.theString = reReplaceNocase(local.theString, "<\/?\s*FONT[^>]*>", "", "all")>
			<cfset local.theString = reReplaceNocase(local.theString, "<\/?\s*st1.*?[^>]*>", "", "all")>
			<cfset local.theString = reReplaceNocase(local.theString, "<\/?\s*o\:p[^>]*>", "", "all")>
			<!--- EXTRA stuff for XML cfset local.theString = reReplaceNoCase(local.theString, "(<\s*span\s*>\s*<\s*/\s*span\s*>|<\?xml\s*:\s*namespace.*?>|<\s*/?\s*o\s*:\s*p\s*>)", "", "ALL")--->
	
			<cfloop list="#local.stripTags#" index="local.tag">
				<cfset local.theString = reReplaceNoCase(local.theString, "</?#Trim(local.tag)#[^>]*>", "", "ALL")>
			</cfloop>
	
			<!--- strip attributes
			<cfset local.theString = reReplaceNoCase(local.theString, 'class\s*=?\s*"?(MsoNormal|MsoTableGrid)"?', "", "ALL")>
			<cfset local.theString = reReplaceNoCase(local.theString, 'style\s*=?\s*"?[^"]*?"', "", "ALL")>
			 --->
		</cfif>

		<cfreturn local.theString>
	</cffunction>
</cfcomponent>
