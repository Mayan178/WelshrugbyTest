<cfcomponent name="StringUtil">
	<cffunction name="init" returntype="stringUtil" access="public">
		<cfreturn this/>
	</cffunction>
	
	<cffunction name="capCase" access="public" returntype="string">
		<cfargument name="word" required="true" type="string">
		
		<cfset var local = structNew()>
		<cfset local.cap = true>
		
		<cfset local.retWord = "">
		<cfloop from="1" to="#Len(arguments.word)#" index="local.i">
			<cfset local.let = Mid(arguments.word, local.i, 1)>

			<cfif Len(Trim(local.let))>
				<cfif local.cap>
					<cfset local.retWord = local.retWord & uCase(local.let)>
					<cfset local.cap = false>
				<cfelse>
					<cfset local.retWord = local.retWord & lCase(local.let)>
				</cfif>
			<cfelse>
				<cfset local.retWord = local.retWord & " ">
				<cfset local.cap = true>
			</cfif>

		</cfloop>
		<cfreturn local.retWord>
	</cffunction>

	<cffunction name="stripSpecial" access="public" returntype="string">
		<cfargument name="input" type="string" required="true">
		<cfargument name="preserveSpaces" type="boolean" required="false" default="false">
		<cfargument name="removeDots" type="boolean" required="false" default="false">

		<cfset var local = structNew()>
		<!--- replace all special characters except "." --->
		<cfif arguments.preserveSpaces>
			<cfset local.regExp = "[^a-zA-Z0-9\. ]">
		<cfelse>
			<cfset local.regExp = "[^a-zA-Z0-9\.]">
		</cfif>
		<cfset local.output = ReReplaceNoCase(arguments.input, "#local.regExp#", "", "ALL")>
        
        <!--- now replace "." with "-" --->
		<cfif arguments.removeDots>
        	<cfset local.output = ReplaceNoCase(local.output, ".", "", "ALL")>
        </cfif>

		<cfreturn local.output>
	</cffunction>

	<cffunction name="serialize" access="public" returntype="string">
		<cfargument name="theInput" type="any" required="true">
		
		<cfset var local = structNew()>
		<cfset local.output = "">
		
		<cfset local.byteOutStream = CreateObject("java", "java.io.ByteArrayOutputStream").init()>
		<cfset local.objOutputStream = CreateObject("java", "java.io.ObjectOutputStream").init(local.byteOutStream)>
		<cfset local.objOutputStream.writeObject(arguments.theInput)>
		<cfset local.output = local.byteOutStream.toByteArray()>
		<cfset local.output = toBase64(local.output)>

		<cfreturn local.output>
	</cffunction>

	<cffunction name="deserialize" access="public" returntype="any">
		<cfargument name="theInput" type="any" required="true" hint="Serialized using serialize() in this CFC">
		
		<cfset var local = structNew()>
		<cfset local.output = "">

		<cfset local.byteInStream = CreateObject("java", "java.io.ByteArrayInputStream").init(toBinary(arguments.theInput))>
		<cfset local.objInputStream = CreateObject("java", "java.io.ObjectInputStream").init(local.byteInStream)>
		<cfset local.output = local.objInputStream.readObject()>

		<cfreturn local.output>
	</cffunction>

	<cffunction name="isString" access="public" returntype="boolean">
		<cfargument name="value" type="string" required="true">

		<cfif isArray(arguments.value) OR isStruct(arguments.value) OR isXML(arguments.value) OR isQuery(arguments.value)>
			<cfreturn false>
		<cfelse>
			<cfreturn true>
		</cfif>
	</cffunction>

<!---cfscript>	
if(attributes.action EQ "fromCF"){
	byteOutStream = CreateObject("java", "java.io.ByteArrayOutputStream").init();
	objOutputStream = CreateObject("java", "java.io.ObjectOutputStream").init(byteOutStream);
	objOutputStream.writeObject(attributes.input);
	caller[attributes.output] = byteOutStream.toByteArray();
}else{
	byteInStream = CreateObject("java", "java.io.ByteArrayInputStream").init(attributes.input);
	objInputStream = CreateObject("java", "java.io.ObjectInputStream").init(byteInStream);
	caller[attributes.output] = objInputStream.readObject();	
}
</cfscript--->

</cfcomponent>