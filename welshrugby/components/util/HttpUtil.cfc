<cfcomponent name="httpUtil" hint="Provides functionality for anything to do with HTTP or page locations">

	<cffunction name="init" returntype="httpUtil" access="public">
		<cfreturn this/>
	</cffunction>

	<cffunction name="metaRedirect" hint="Redirects a user to another page after a certain period of time via client-side meta tag" returntype="string">
		<cfargument name="URL" type="string" required="true">
		<cfargument name="message" type="string" required="false" default="">
		<cfargument name="period" default="0" type="numeric" required="false">
		<cfargument name="showManual" default="true" type="boolean" required="false">

		<cfset var local = structNew()>

		<cfsavecontent variable="local.output">
			<cfhtmlhead text='<meta http-equiv="Refresh" content="#arguments.period#;URL=#arguments.URL#">'>
			<cfif Len(arguments.message)>
				<cfoutput>
					#arguments.message#
					<cfif arguments.showManual>
                    <div align="left">
						<br>If you are not redirected, please <a href="#arguments.URL#" class="redirect">Click here</a>
                    </div>
					</cfif>
				</cfoutput>
			</cfif>
		</cfsavecontent>
		
		<cfreturn local.output>
	</cffunction>

	<cffunction name="instantRedirect" hint="Redirects using cflocation for an instant push. Do not use near Client variable set/gets" returntype="string">
		<cfargument name="URL" type="string" required="true">

		<cfset var local = structNew()>
		<cfset local.debug = false>

		<cfif NOT local.debug>
			<cflocation url="#arguments.url#" addtoken="false">
		<cfelse>
			<cfoutput><p>#metaRedirect(arguments.url, "Debug turned on in HTTPUtil - Test Mode", 1)#</p></cfoutput>
		</cfif>

		<cfreturn "">
	</cffunction>

	<cffunction name="isURL" hint="Determines whether a passed-in string is a real URL or not (syntactically)" access="public" returntype="boolean">
		<cfargument name="testURL" type="string" required="true">
		
		<cfif (Len(arguments.testURL) gt 5 AND Left(arguments.testURL,5) eq "http:")
				OR (Len(arguments.testURL) gt 1 AND Left(arguments.testURL,1) eq "/")
		>
			<cfreturn true>
		<cfelse>
			<cfreturn false>
		</cfif>
	</cffunction>

</cfcomponent>
