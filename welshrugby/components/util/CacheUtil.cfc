<cfcomponent name="cacheUtil" hint="Handles cache for the cf_iceCache tag" extends="welshrugby.parent">

	<cfset variables.debug = false>

	<cffunction name="init" returntype="cacheUtil" access="public">
		<cfset super.init()>
		
		<cfif (NOT StructKeyExists(application, "cache")) OR request.scope.exists("reload")>
			<cfset startUp()>
		</cfif>

		<cfset variables.enabled = getFactory().getSetting("cacheEnabled")>

		<cfreturn this/>
	</cffunction>

	<cffunction name="startUp" returntype="void" access="private">
    	<cfset local.debug = false>
		<cfset application.cache = structNew()>
		<cfset application.cache.storage = structNew()>
		<cfset application.cache.size = 0>
		<cfset application.cache.maxSize = getFactory().getSetting("maxCacheSize")>
		<cfset application.cache.renewalTimeSpan = createTimeSpan(0,1,0,0)>
		<cfset application.cache.expirationLog = StructNew()> <!--- Logs the expiration datetimes against uuid and keys --->
		<cfif local.debug>
			<cfdump var="Cache Initialised">
        </cfif>
	</cffunction>

	<cffunction name="create" access="public" returntype="struct" hint="inserts cache">
		<cfargument name="key" required="true" type="string">
		<cfargument name="bikey" required="true" type="string">
		<cfargument name="trikey" required="true" type="string">
		<cfargument name="content" required="true" type="any">
		<cfargument name="timespan" required="false" type="numeric" default="#CreateTimeSpan(0,6,0,0)#">
	
		<cfset var local = structNew()>

		<cfset local.result = StructNew()>
        
        <cfset local.debug = false>

		<!--- build the tree beneath the eventual key --->
		<!--- Ensure existance of primary key --->
		<cfif NOT StructKeyExists(application.cache.storage, arguments.key)>
			<cfset StructInsert(application.cache.storage, arguments.key, StructNew())>
            <cfif local.debug>
				<cfdump var="Primary storage key #arguments.key# created">
            </cfif>
		</cfif>
		<!--- Ensure existence of secondary key --->
		<cfif NOT StructKeyExists(application.cache.storage[arguments.key], arguments.bikey)>
			<cfset StructInsert(application.cache.storage[arguments.key], arguments.bikey, StructNew())>
            <cfif local.debug>
            	<cfdump var="Secondary storage key #arguments.bikey# created in #arguments.key#">
            </cfif>
		</cfif>

		<!--- Prepare packet with expiration date and actual content --->
		<cfset local.packet = structNew()>
		<cfset local.packet.uuid = "X" & createUUID()>
		<cfset local.packet.content = arguments.content>
		
		<!--- Count and compress (if possible) content --->
		<cfif NOT isQuery(local.packet.content) AND NOT isArray(local.packet.content) AND NOT isStruct(local.packet.content)>
			<!--- If the content is a string, compress it and make a note of it's size... --->
			<cfset local.packet.content = compress(local.packet.content)>
		</cfif>

		<cfset local.packet.size = sizeContent(local.packet.content)>

		<!--- Insert the cache value --->
		<cfif variables.enabled>
			<cfset changeSize(local.packet.size)>
			<cfset local.lockname = getLockname(arguments.key, arguments.bikey, arguments.trikey)>
			<cflock name="#local.lockname#" timeout="60" type="exclusive">
				<cfset application.cache.storage[arguments.key][arguments.bikey][arguments.trikey] = local.packet>
			</cflock>
			
            <cfif local.debug>
            	<cfdump var="Content inserted into #arguments.key#/#arguments.bikey#/#arguments.trikey#">
            </cfif>

			<!--- log the cache so you can work out, later, what the oldest cache is --->
			<cfset local.log = structNew()>
			<cfset local.log.uuid = local.packet.uuid>
			<cfloop list="key,bikey,trikey" index="local.field">
				<cfset local.log[local.field] = arguments[local.field]>
			</cfloop>
			<cfset local.log.expires = now() + arguments.timespan>
			<cfset application.cache.expirationLog[local.log.uuid] = local.log>
		</cfif>

		<!--- Return the content as it's been compressed already (waste not, want not) --->
		<cfset local.result.output = local.packet.content>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="get" access="public" returntype="struct">
		<cfargument name="key" required="true" type="string">
		<cfargument name="bikey" required="true" type="string">
		<cfargument name="trikey" required="true" type="string">
		<cfargument name="updateExpiry" required="false" type="boolean" default="true">
		
		<cfset var local = structNew()>
		<cfset local.result = structNew()>
		<cfset local.result.exists = false>
		<cfset local.result.content = "">
        <cfset local.debug=false>

		<cfif StructKeyExists(application.cache.storage, arguments.key)>
			<cfif StructKeyExists(application.cache.storage[arguments.key], arguments.bikey)>
				<cfif StructKeyExists(application.cache.storage[arguments.key][arguments.bikey], arguments.trikey)>

					<cfset local.lockname = getLockname(arguments.key, arguments.bikey, arguments.trikey)>
					<cflock name="#local.lockname#" timeout="60" type="readOnly">
						<cfset local.cacheRecord = application.cache.storage[arguments.key][arguments.bikey][arguments.trikey]>
	
						<cfset local.result.exists = true>
						<!--- no need to compress - it was compressed coming in --->
						<cfset local.result.output = local.cacheRecord.content>
						<!--- renew --->
						<cfif arguments.updateExpiry>
							<cfset application.cache.expirationLog[local.cacheRecord.uuid].expires = now() + application.cache.renewalTimeSpan>
						</cfif>
						
                        <cfif local.debug>
                        	<cfdump var="Found content at #arguments.key#/#arguments.bikey#/#arguments.trikey#">
                        </cfif>
					</cflock>
				</cfif>
			</cfif>
		</cfif>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="compress" access="private" returntype="string">
		<cfargument name="content" type="string" required="true">

		<cfset var local = structNew()>
		<cfset local.content = reReplace(arguments.content, chr(9),"", "all" )>
		<cfset local.content = reReplace(local.content, "    ","", "all" )>
		<cfset local.content = reReplace(local.content, chr(13)&chr(10)&chr(13)&chr(10),chr(13)&chr(10), "all" )>
		<cfset local.content = reReplace(local.content, chr(10)&chr(13)," ", "all" )>
		<cfset local.content = reReplace(local.content, "[[:space:]]{2,}", " ", "ALL")>

		<cfreturn local.content>
	</cffunction>

	<cffunction name="delete" access="public" returntype="void">
		<cfargument name="key" required="true" type="string">
		<cfargument name="bikey" required="false" type="string" default="">
		<cfargument name="trikey" required="false" type="string" default="">

		<cfset var local = structNew()>
		<!--- let's try not to delete a cache that is not there! --->
		
		<cfif StructKeyExists(application.cache.storage, arguments.key)>
			<cfif Len(arguments.bikey) eq 0>
				<!--- delete the entire primary-key --->
				<cfloop list="#StructKeyList(application.cache.storage[arguments.key])#" index="local.bikey">
					<cfset delete(arguments.key, local.bikey)>
				</cfloop>
				<cfset StructDelete(application.cache.storage, arguments.key)>
			<cfelseif StructKeyExists(application.cache.storage[arguments.key], arguments.bikey)>
				<cfif Len(arguments.trikey) eq 0>
					<!--- delete the entire bi-key --->
					<cfloop list="#StructKeyList(application.cache.storage[arguments.key][arguments.bikey])#" index="local.trikey">
						<cfset delete(arguments.key, arguments.bikey, local.trikey)>
					</cfloop>
					<cfset StructDelete(application.cache.storage[arguments.key], arguments.bikey)>
				<cfelseif StructKeyExists(application.cache.storage[arguments.key][arguments.bikey], arguments.trikey)>
					<!--- delete the trinary-key and reduce the current cache size record appropriately --->
					<cfset changeSize(0-sizeContent(application.cache.storage[arguments.key][arguments.bikey][arguments.trikey]))>
					<cfset local.lockname = getLockname(arguments.key, arguments.bikey, arguments.trikey)>
					<cflock name="#local.lockname#" timeout="60" type="exclusive">
						<cfset StructDelete(application.cache.storage[arguments.key][arguments.bikey], arguments.trikey)>
					</cflock>
				</cfif>
			</cfif>
		</cfif>
	</cffunction>

	<cffunction name="clear" access="public" returntype="void">
		<cfset startUp()>
	</cffunction>

	<cffunction name="purge" access="public" returntype="struct" hint="Purges cache of expired content and ensures that the maximum size of the cache is handled in a clean way">
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

		<cfset local.expire = getExpirationLog()>
		<cfset local.keyOrder = StructSort(local.expire, "numeric", "asc", "expires")>

		<cfloop from="1" to="#ArrayLen(local.keyOrder)#" index="local.i">
			<cfset local.uuid = local.keyOrder[local.i]>
			<cfif local.expire[local.uuid].expires lt now()>
				<cfset delete(local.expire[local.uuid].key, local.expire[local.uuid].bikey, local.expire[local.uuid].trikey)>
			</cfif>
		</cfloop>
		
		<cfsavecontent variable="local.result.output">
			<cfoutput><p>Current size of cache: #(getSize()/1000)#k. Max permitted size: #(application.cache.maxSize/1000)#k</p></cfoutput>
			<cfif getSize() gt application.cache.maxSize>
				<cfset local.deleteAmount = getSize()-application.cache.maxSize>
				<cfoutput><p>Cache will need to purge #(local.deleteAmount/1000)#k</p></cfoutput>
	
				<cfset local.expire = getExpirationLog()>
				<cfset local.keyOrder = StructSort(local.expire, "numeric", "asc", "expires")>
	
				<cfset local.deletions = "">
				<cfset local.size = 0>
				<cfloop from="1" to="#ArrayLen(local.keyOrder)#" index="local.i">
					<cfset local.uuid = local.keyOrder[local.i]>
					<!--- this ensures we always delete one more key in the cache than we need to - sympathetic memory management --->
					<cfset local.deletions = ListAppend(local.deletions, local.uuid)>
					
					<cfset local.cacheSize = sizeContent(get(local.expire[local.uuid].key, local.expire[local.uuid].bikey, local.expire[local.uuid].trikey, false))>

					<cfset local.size = local.size + local.cacheSize>
					<cfif local.size gt local.deleteAmount>
						<cfbreak>
					</cfif>
				</cfloop>

				<cfoutput><p>Purge will delete #ListLen(local.deletions)# items from cache</p></cfoutput>				
				<cfloop list="#local.deletions#" index="local.uuid">
					<cfset local.keys = local.expire[local.uuid]>

					<!---cfoutput>Deleting keys from cache: #local.keys.key#/#local.keys.bikey#/#local.keys.trikey#<br></cfoutput--->
					<cfset delete(local.keys.key, local.keys.bikey, local.keys.trikey)>
				</cfloop>
			<cfelse>
				<cfset local.deleteAmount = 0>
				<cfset local.deletions = "">
			</cfif>
		</cfsavecontent>
		
        <cfif local.debug>
        	<cfdump var="local.result.output">
        </cfif>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="dump" access="public" returntype="void">
		<cfdump var="#application.cache.storage#">
	</cffunction>

	<cffunction name="snapshot" access="public" returntype="struct">
		<cfreturn application.cache.storage>
	</cffunction>

	<cffunction name="getExpirationLog" access="public" returntype="struct">
		<cfreturn application.cache.expirationLog>
	</cffunction>

	<cffunction name="getSize" access="public" returntype="numeric">
		<cfreturn application.cache.size>
	</cffunction>

	<cffunction name="changeSize" access="private" returntype="numeric">
		<cfargument name="value" type="numeric" required="true">

		<cfset application.cache.size = application.cache.size + arguments.value>
		<cfreturn application.cache.size> 	
	</cffunction>

	<cffunction name="getLockName" access="private" returntype="string">
		<cfargument name="key" required="true" type="string">
		<cfargument name="bikey" required="false" type="string" default="">
		<cfargument name="trikey" required="false" type="string" default="">

		<cfset var local = structNew()>
		<cfset local.lockName = "cacheStorage">
		<cfset local.lockName = local.lockName & getFactory().get("stringUtil").util.stripSpecial(arguments.key)>
		<cfset local.lockName = local.lockName & getFactory().get("stringUtil").util.stripSpecial(arguments.bikey)>
		<cfset local.lockName = local.lockName & getFactory().get("stringUtil").util.stripSpecial(arguments.trikey)>
		
		<cfreturn local.lockName>
	</cffunction>

	<cffunction name="sizeContent" access="private" returntype="numeric">
		<cfargument name="content" type="any" required="true">

		<cfset var local = structNew()>
<cfreturn 3000>
		<cftry>
			<cfset local.size = Len(arguments.content.toString())>
			<cfcatch type="any">
				<cfset local.size = 3000><!--- default size of a packet that can't be measured --->
			</cfcatch>
		</cftry>
		
		<cfreturn local.size>
	</cffunction>

</cfcomponent>