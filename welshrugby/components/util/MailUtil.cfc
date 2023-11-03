<cfcomponent name="mailUtil" extends="welshrugby.parent">
	<cffunction name="init" access="public" returntype="mailUtil">
		<cfreturn this/>
	</cffunction>

	<cffunction name="sendEmail" access="public" returntype="boolean">
		<cfargument name="from" required="false" type="string" default="#application.core.get('adminEmail')#">
		<cfargument name="fromName" required="false" type="string" default="#application.core.get('adminEmailName')#">
		<cfargument name="to" required="true" type="string">
		<cfargument name="subject" required="false" type="string" default="">
        <cfargument name="body" required="false" type="string" default="">
        <cfargument name="document" required="false" type="string" default="">
		<cfargument name="bcc" required="false" type="string" default="">
        
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		<cfset local.result.success = true>
		
        <cfset local.allowemail = true>
        
        <cfif local.allowemail>
            <cftry>
            
                <cfif Len(arguments.document)>
                	<cfif Len(arguments.bcc)>
                        <cfmail
                            from="#arguments.fromName# <#arguments.from#>"
                            to="#arguments.to#"
                            subject="#arguments.subject#"
                            mimeattach="#arguments.document#"
                            bcc="#arguments.bcc#"
                        >
                                <cfmailparam name="Message-Id" value="<#createUUID()#@globalcables.net>">
                                <cfmailparam name="Reply-To" value="#arguments.from#">
                                <cfmailparam name="MIME-Version" value="1.0">
                                
                            <cfoutput>#arguments.body#</cfoutput>
                        </cfmail>
                    <cfelse>
                    	<cfmail
                            from="#arguments.fromName# <#arguments.from#>"
                            to="#arguments.to#"
                            subject="#arguments.subject#"
                            mimeattach="#arguments.document#"
                        >
                                <cfmailparam name="Message-Id" value="<#createUUID()#@globalcables.net>">
                                <cfmailparam name="Reply-To" value="#arguments.from#">
                                <cfmailparam name="MIME-Version" value="1.0">
                                
                            <cfoutput>#arguments.body#</cfoutput>
                        </cfmail>
                    </cfif>
                <cfelse>
                    <cfmail
                        from="#arguments.fromName# <#arguments.from#>"
                        to="#arguments.to#"
                        subject="#arguments.subject#"
                    >
                            <cfmailparam name="Message-Id" value="<#createUUID()#@globalcables.net>">
                            <cfmailparam name="Reply-To" value="#arguments.from#">
                            <cfmailparam name="MIME-Version" value="1.0">
                            
                        <cfoutput>#arguments.body#</cfoutput>
                    </cfmail>
    
                </cfif>
                <cfcatch type="any">
                    <cfset local.result.success = false>
                    <cfset local.result.error = "There was an error sending an email. #cfcatch.Detail#">
                </cfcatch>
            </cftry>
        <cfelse>
        	<cfset local.result.success = true>
        </cfif>
		<cfreturn local.result.success>
	</cffunction>
	
</cfcomponent>