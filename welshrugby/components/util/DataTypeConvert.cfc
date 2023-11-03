<cfcomponent name="dataTypeConvert" hint="Convert data type to data type using various functions" extends="welshrugby.parent">

	<cffunction name="init" returntype="datatypeconvert" access="public">
		<cfset super.init()>
		<cfreturn this/>
	</cffunction>

	<cffunction name="queryToArray" access="public" returntype="array">
		<cfargument name="theQuery" required="true" type="query">
		<cfargument name="columnList" required="false" type="string" default="#arguments.theQuery.columnList#" hint="You can restrict the columns returned">

		<cfset var local = structNew()>
		<cfset local.result = ArrayNew(1)>

		<cfloop from="1" to="#arguments.theQuery.recordCount#" index="local.i">
			<cfset local.record = structNew()>
			<cfloop list="#arguments.columnList#" index="local.col">
				<cfset local.record[local.col] = arguments.theQuery[local.col][local.i]>
			</cfloop>
			<cfset ArrayAppend(local.result, local.record)>
		</cfloop>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="QueryToStruct" access="public" returntype="struct" hint="Converts a query to struct.">
		<cfargument name="query"      required="yes" type="query"  hint="The query to convert.">
		<cfargument name="primaryKey" required="no"  type="string" hint="Column name that contains the primary key." default="">
		<cfargument name="columnList" required="no"  type="string" hint="Comma-delimited list of the query columns." default="">

		<cfset var local = structNew()>
		<cfset local.result = structNew()>

		<!--- determine query column names --->
		<cfif Len(arguments.columnList)>
			<cfset local.cols = Replace(arguments.columnList, " ", "")>
		<cfelse>
			<cfset local.cols = arguments.query.columnList>
		</cfif>
		
		<!--- remove primary key --->
		<cfif Len(arguments.primaryKey)>
			<cfset local.pkPosition = ListFindNoCase(local.cols, arguments.primaryKey)>
			<cfif local.pkPosition>
				<cfset local.cols = ListDeleteAt(local.cols, local.pkPosition)>
			</cfif>
		</cfif>
		
		<cfset local.cols = ListToArray(local.cols)>

		<!--- loop thru rows --->
		<cfloop from="1" to="#arguments.query.recordCount#" index="local.i">
			<cfif Len(arguments.primaryKey)>
				<cfset local.key = arguments.query[arguments.primaryKey][local.i]>
			<cfelse>
				<cfset local.key = local.i>
			</cfif>
			
			<cfset StructInsert(local.result, local.key, StructNew())>
			
			<cfloop from="1" to="#ArrayLen(local.cols)#" index="local.n">
				<!---cfoutput><p style="font-weight:bold">#local.i#/#local.n#/#local.cols[local.n]# = #local.key# / #arguments.query[local.cols[local.n]][local.i]#</p></cfoutput--->
				<cfset StructInsert(local.result[local.key], local.cols[local.n], arguments.query[local.cols[local.n]][local.i])>
			</cfloop>
		</cfloop>
		
		<cfreturn local.result>
	</cffunction>

	<cffunction name="XmlToStruct" access="public" output="yes" returntype="struct" hint="Converts a XML document object or a XML file to struct.">
		<!--- Function Arguments --->
		<cfargument name="xmlObj"  required="no" type="any" hint="Parsed XML document object. Required if argument file is not set.">
		<cfargument name="file"    required="no" type="string" hint="Pathname or URL of the XML file to read. Required if argument xmlObj is not set." default="">
		<cfargument name="charset" required="no" type="string" default="UTF-8" hint="The character encoding in which the XML file contents is encoded.">

		<cfset var local = structNew()>
		<cfset local.dataStruct = StructNew()>
		<cfset local.debug = false>

		<!--- if passed in filename, read the file in --->
		<cfif Len(arguments.file)>
			<cfset local.xmlData = XmlParseFile(arguments.file, arguments.charset)>
		<cfelse>
			<cfset local.xmlData = arguments.xmlObj>
		</cfif>

		<!--- local.xmlData now contains the XML data in CF format --->
		<!--- skip the xmlRoot element --->
		<cfif StructKeyExists(local.xmlData, "xmlRoot")>
			<cfset StructInsert(local.dataStruct, local.xmlData.xmlRoot.xmlName, XmlToStruct(local.xmlData.xmlRoot))>
			<cfset local.dataStruct[local.xmlData.xmlRoot.xmlName].attributes = StructNew()>
			<!--- record attributes --->
			<cfloop list="#StructKeyList(local.xmlData.xmlRoot.xmlAttributes)#" index="local.attr">
				<cfset StructInsert(local.dataStruct[local.xmlData.xmlRoot.xmlName].attributes, local.attr, local.xmlData.xmlRoot.xmlAttributes[local.attr])>
			</cfloop>
		<cfelse>
			<!--- Set parent text to dataStruct --->
			<cfset local.parentName = UCase(getFactory().get("stringUtil").util.stripSpecial(local.xmlData.xmlName))>
			<cfset local.parentText = Trim(local.xmlData.xmlText)>
			<cfset local.childrenCount = ArrayLen(local.xmlData.xmlChildren)>

			<cfif local.debug>
				<cfoutput><h1>#local.parentName# / #local.parentText# / #local.childrenCount#</h1></cfoutput>
			</cfif>

			<cfloop from="1" to="#local.childrenCount#" index="local.i">
				<cfset local.name = local.xmlData.xmlChildren[local.i].xmlName>
				<cfset local.text = local.xmlData.xmlChildren[local.i].xmlText>
				<cfset local.tmpChildData = local.xmlData.xmlChildren[local.i].xmlChildren>

				<cfif local.debug>
					<cfoutput><h2>Child #local.i#: #local.name# / #local.text#</h2></cfoutput>
				</cfif>

				<cfset local.items = structNew()>
				<!--- loop through child items --->
				<cfloop from="1" to="#ArrayLen(local.xmlData.xmlChildren[local.i])#" index="local.c">
					<cfset local.child = local.xmlData.xmlChildren[local.i][local.c]>
					<cfif local.debug>
						<cfoutput><p>Sub-child #local.c#</p></cfoutput>
					</cfif>
					<cfif ArrayLen(local.child.xmlChildren)>
						<cfset local.tmpChildConvert = xmlToStruct(local.child)>
						<cfif StructCount(local.tmpChildConvert) ge 1>
							<cfloop list="#StructKeyList(local.tmpChildConvert)#" index="local.key">
								<cfif isStruct(local.tmpChildConvert[local.key]) AND StructCount(local.tmpChildConvert[local.key]) eq 1>
									<cftry>
									<cfset local.items[local.key] = local.tmpChildConvert[local.key][local.key]>
									<cfcatch type="any">
										<!---cfoutput><p>#local.key#.#local.key# has had a problem in local.tmpChildConvert: <cfdump var="#local.tmpChildConvert#"></p></cfoutput--->
									</cfcatch>
									</cftry>
								<cfelse>
									<cfset local.items[local.key] = local.tmpChildConvert[local.key]>
								</cfif>
							</cfloop>
						<cfelse>
							<!--- pick-up of branch end --->
							<cftry>
								<cfset StructInsert(local.items, local.child.xmlName, local.tmpChildConvert[local.child.xmlName])>
								<cfcatch type="any">
									<cfdump var="#local.items#">
									<cfdump var="#local.child#">
									<cfdump var="#local.tmpChildConvert#">
									<cfabort>
								</cfcatch>
							</cftry>
						</cfif>
					<cfelse>
						<!--- branch end --->
						<cfset StructInsert(local.items, local.child.xmlName, Trim(local.child.xmlText))>
					</cfif>
				</cfloop>

				<cfif local.debug>
					<cfoutput><hr></cfoutput>
				</cfif>

				<!--- We don't want to nest identical struct keys.
					So, we check to see if there is only a single element in the items struct,
					then check to see if that single key is the same as local.name, the name of the parent.
					If they are the same, we knock a level out by inserting the (single) value in the items struct
					rather than the struct itself.
				--->
				
				<cfif NOT StructKeyExists(local.dataStruct, local.name)>
					<cfif StructCount(local.items) eq 1 AND StructKeyList(local.items) eq local.name>
						<cfset local.dataStruct[local.name] = local.items[local.name]>
					<cfelse>
						<cfset StructInsert(local.dataStruct, local.name, local.items)>
					</cfif>
				<cfelse>
					<cfif NOT isArray(local.dataStruct[local.name])>
						<!--- the current dataStruct has the local.name key with an existing value, but only one --->
						<!--- get the current value --->
						<cfset local.tmpItem = local.dataStruct[local.name]>
						<!--- wipe over the value with an array and add the old item back as an array element --->
						<cfset local.dataStruct[local.name] = ArrayNew(1)>
						<cfset ArrayAppend(local.dataStruct[local.name], local.tmpItem)>

						<!--- add the current items struct to the array --->
						<cfif StructCount(local.items) eq 1 AND StructKeyList(local.items) eq local.name>
							<cfset ArrayAppend(local.dataStruct[local.name], local.items[local.name])>
						<cfelse>
							<cfset ArrayAppend(local.dataStruct[local.name], local.items)>
						</cfif>
					<cfelse>
						<!--- already got an array there with at least 2 items in it, so just append--->
						<cfif StructCount(local.items) eq 1 AND StructKeyList(local.items) eq local.name>
							<cfset ArrayAppend(local.dataStruct[local.name], local.items[local.name])>
						<cfelse>
							<cfset ArrayAppend(local.dataStruct[local.name], local.items)>
						</cfif>
					</cfif>
				</cfif>

				<!--- dump a specific item
				<cfif local.debug AND local.name eq "promotion">
					<cfdump var="#local.datastruct#">
				</cfif> --->
			</cfloop>
		</cfif>

		<cfreturn local.dataStruct>
	</cffunction>

	<cffunction name="xmlToStructNew" returntype="struct" access="public">
		<cfargument name="raw" type="any" required="true">

		<cfset var local = structNew()>
		<cfset local.debug = false>

		<!--- Thou shalt not allow infinite loops in a recursive function --->
		<cfparam name="request.wibble" default="0">
		<cfset local.maxWibble = 99999>

		<!--- work out the keys to loop through to avoid type-inconsistencies --->
		<cfif isArray(arguments.raw)>
			<cfset local.keys = "">
			<cfloop from="1" to="#ArrayLen(arguments.raw)#" index="local.i">
				<cfset local.keys = ListAppend(local.keys, local.i)>
			</cfloop>
		<cfelse>
			<cfset local.keys = structKeyList(arguments.raw)>
		</cfif>

		<!--- DEBUG --->
		<cfif request.wibble++ gt local.maxWibble>
			<cfoutput><p style="font-weight:bold">Infinite loop in xmlToStruct() (recursive)</p></cfoutput>
			<cfdump var="#arguments.raw#" expand="false" label="arguments.raw">
			<cfoutput><p>Keys: #local.keys#</p></cfoutput>

			<cfset local.obj = createObject("component", "glacier.com.util.stackTrace").init()>
			<cfset local.obj.trace()>
			<cfdump var="#local.obj.get()#" expand="false" label="trace">

			<cfthrow type="application" message="Infinite loop in recursive function xmlToStruct()">
			<cfabort>
		</cfif>

		<!--- prepare data struct to return --->
		<cfset local.data = structNew()>
		
		<cfloop list="#local.keys#" index="local.key">
			<!--- work out the canonical name - raw could be an array, could be struct, could be XML --->
			<cfif isNumeric(local.key) AND isArray(arguments.raw)>
				<cfset local.name = arguments.raw[local.key].xmlName>
			<cfelse>
				<cfset local.name = local.key>
			</cfif>

			<!--- DEBUG 
			<cfoutput><p>#local.name#</p></cfoutput>
			--->

			<!--- if element already exists, shuffle it into the first element of an array and reassign --->
			<cfif StructKeyExists(local.data, local.name) AND NOT isArray(local.data[local.name])>
				<cfset local.tmp = arrayNew(1)>
				<cfset ArrayAppend(local.tmp, local.data[local.name])>
				<cfset local.data[local.name] = local.tmp>
			</cfif>

			<cfset local.prepare = StructNew()>

			<!--- record xml attributes --->
			<cfif StructCount(arguments.raw[local.key].xmlAttributes)>
				<cfloop list="#StructKeyList(arguments.raw[local.key].xmlAttributes)#" index="local.a">
					<cfset local.prepare[local.a] = arguments.raw[local.key].xmlAttributes[local.a]>
				</cfloop>
			</cfif>

			<!--- Get the data from the next level down but do not keep it if there is nothing at the deeper level --->
			<cfif ArrayLen(arguments.raw[local.key].xmlChildren)>
				<cfset local.prepare.children = xmlToStructNew(arguments.raw[local.key].xmlChildren)>
				<cfif StructIsEmpty(local.prepare.children)>
					<cfset StructDelete(local.prepare, "children")>
				</cfif>
			</cfif>

			<!--- Move children up one level, but do it from the parent otherwise you destroy too much --->
			<cfif isStruct(local.prepare) AND StructKeyExists(local.prepare, "children")>
				<cfloop list="#StructKeyList(local.prepare.children)#" index="local.c">
					<cfset local.prepare[local.c] = local.prepare.children[local.c]>
				</cfloop>
				<cfset StructDelete(local.prepare, "children")>
			</cfif>

			<!--- record the xmlText value --->
			<cfif Len(Trim(arguments.raw[local.key].xmlText))>
				<cfif StructCount(local.prepare)>
					<cfset local.prepare.text = arguments.raw[local.key].xmlText>
				<cfelse>
					<cfset local.prepare = arguments.raw[local.key].xmlText>
				</cfif>
			</cfif>
			
			<!--- Assumption: single XML elements to be treated like a struct, multiple XML elements with same name are treated as array of struct --->
			<!--- work out whether we just stick it in as a single struct or whether there is an array of elements already being built --->
			<cfif StructKeyExists(local.data, local.name) AND isArray(local.data[local.name])>
				<cfset ArrayAppend(local.data[local.name], local.prepare)>
			<cfelseif isStruct(local.prepare) AND StructIsEmpty(local.prepare)>
				<cfset local.data[local.name] = "">
			<cfelse>
				<cfset local.data[local.name] = local.prepare>
			</cfif>
		</cfloop>
		<cfreturn local.data>
	</cffunction>

	<cffunction name="xmlFileToStruct" returntype="struct" access="public" hint="Reads in an XML file and passes it to xmlToStruct() for conversion">
		<cfargument name="filename" type="any" required="true" hint="Fully-qualified path name to .xml file">

		<cfset var local = structNew()>

		<cffile action="read" file="#arguments.filename#" variable="local.raw">
		<cfset local.xml = xmlParse(local.raw)>
		<cfset local.struct = xmlToStructNew(local.xml)>

		<cfreturn local.struct>
	</cffunction>

	<cffunction name="convertXMLtoStruct" returntype="struct" access="public">
		<cfargument name="raw" type="any" required="true">

		<cfset var local = structNew()>

		<!--- Thou shalt not allow infinite loops in a recursive function --->
		<cfparam name="request.wibble" default="0">
		<cfif request.wibble++ gt 9999>
			<cfabort showerror="Infinite loop in recursive function convertXMLtoStruct()">
		</cfif>

		<!--- prepare data struct to return --->
		<cfset local.data = structNew()>
		
		<!--- work out the keys to loop through to avoid type-inconsistencies --->
		<cfif isStruct(arguments.raw)>
			<cfset local.keys = structKeyList(arguments.raw)>
		<cfelseif isArray(arguments.raw)>
			<cfset local.keys = "">
			<cfloop from="1" to="#ArrayLen(arguments.raw)#" index="local.i">
				<cfset local.keys = ListAppend(local.keys, local.i)>
			</cfloop>
		<cfelse>
			<cfset local.keys = structKeyList(arguments.raw)>
		</cfif>

		<cfloop list="#local.keys#" index="local.key">

			<!--- work out the canonical name - raw could be an array, could be struct, could be XML --->
			<cfif isNumeric(local.key) AND isArray(arguments.raw)>
				<cfset local.name = arguments.raw[local.key].xmlName>
			<cfelse>
				<cfset local.name = local.key>
			</cfif>

			<!--- if element already exists, shuffle it into the first element of an array and reassign --->
			<cfif StructKeyExists(local.data, local.name) AND NOT isArray(local.data[local.name])>
				<cfset local.tmp = arrayNew(1)>
				<cfset ArrayAppend(local.tmp, local.data[local.name])>
				<cfset local.data[local.name] = local.tmp>
			</cfif>

			<cfset local.prepare = StructNew()>
			<!---cfset local.prepare.name = local.name--->
			
			<!--- record xml attributes --->
			<cfif StructCount(arguments.raw[local.key].xmlAttributes)>
				<cfloop list="#StructKeyList(arguments.raw[local.key].xmlAttributes)#" index="local.a">
					<cfset local.prepare[local.a] = arguments.raw[local.key].xmlAttributes[local.a]>
				</cfloop>
			</cfif>

			<!--- Get the data from the next level down but do not keep it if there is nothing at the deeper level --->
			<cfset local.prepare.children = convertXMLtoStruct(arguments.raw[local.key].xmlChildren)>
			<cfif StructIsEmpty(local.prepare.children)>
				<cfset StructDelete(local.prepare, "children")>
			</cfif>

			<!--- Move children up one level, but do it from the parent otherwise you destroy too much --->
			<cfif isStruct(local.prepare) AND StructKeyExists(local.prepare, "children")>
				<cfloop list="#StructKeyList(local.prepare.children)#" index="local.c">
					<cfset local.prepare[local.c] = local.prepare.children[local.c]>
				</cfloop>
				<cfset StructDelete(local.prepare, "children")>
			</cfif>

			<!--- Assumption: single XML elements to be treated like a struct, multiple XML elements with same name are treated as array of struct --->
			<!--- work out whether we just stick it in as a single struct or whether there is an array of elements already being built --->
			<cfif StructKeyExists(local.data, local.name) AND isArray(local.data[local.name])>
				<cfset ArrayAppend(local.data[local.name], local.prepare)>
			<cfelse>
				<cfset local.data[local.name] = local.prepare>
			</cfif>
		</cfloop>
		
		<cfreturn local.data>
	</cffunction>

	<!--- -------------------------------------------------- --->
	<!--- RemoveInvalidChar --->
	<cffunction name="RemoveInvalidChar" access="private" output="no" returntype="string" hint="Replace all non-ascii characters from XML name.">

		<!--- Function Arguments --->
		<cfargument name="string" required="yes" type="string"  hint="String with the XML name.">

		<cfscript>

			arguments.string = Replace(arguments.string, ":", "_", "ALL");             // Replace character before prefix
			arguments.string = REReplace(arguments.string, "[^[:ascii]]", "_", "ALL"); // Replace all non-ascii character

			/* Return string */
			return arguments.string;

		</cfscript>

	</cffunction>


	<cffunction name="ListDeleteDuplicates" access="private" returnType="string">
		<cfargument name="theList" type="string" required="true">
		<cfargument name="delimiter" type="string" required="false" default=",">
		
		<cfset var local = StructNew()>

		<cfset local.returnValue = "">
		<cfset local.arrayList = ListToArray(arguments.theList, arguments.delimiter)>
		
		<cfloop from="1" to="#ArrayLen(local.arrayList)#" index="local.i">
			<cfif NOT ListFind(local.returnValue, local.arrayList[local.i], arguments.delimiter)>
				<cfset local.returnValue = ListAppend(local.returnValue, local.arrayList[local.i], arguments.delimiter)>
			</cfif>
		</cfloop>
		<cfreturn local.returnValue>
	</cffunction>

	<cffunction name="queryRowToStruct" access="public" returntype="struct">
		<cfargument name="data" type="query" required="true">
		<cfargument name="row" type="numeric" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = structNew()>
		
		<cfloop list="#arguments.data.columnList#" index="local.col">
			<cfset local.result[local.col] = arguments.data[local.col][arguments.row]>
		</cfloop>
		
		<cfreturn local.result>
	</cffunction>
</cfcomponent>




