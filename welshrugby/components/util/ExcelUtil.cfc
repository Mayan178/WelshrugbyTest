<cfcomponent name="excelUtil" hint="Functions regarding reading/writing excel spreadsheet files" extends="welshrugby.parent">
	<cffunction name="init" returntype="excelUtil" access="public">
		<cfset super.init()>
		<cfreturn this/>
	</cffunction>
	
	<cffunction name="getExcelSheet" access="public" output="true" returntype="query">
		<cfargument name="filename" required="true" type="string" />
		<cfargument name="sheetName" required="true" type="string" />
		
		<cfset var local = structNew()>
		<cfset local.replString = "[\##\. \/\(\)-]">
	
		<!---
			Create the uninitialized Workbook class. Remember, this
			method CreateJExcelObject() just uses a Class Loader to
			load the Workbook class from the locally stored JAR file.
			This method automatically prepends "jxl." to all class
			calls, so do NOT include it in this method call.
		--->
		<cfset local.objWorkbook = CreateJExcelObject("Workbook") />
	 
		<!---
			Get the workbook from the given file. This workbook
			may contain multiple sheets.
		--->
		<cfset local.objWorkbook = local.objWorkbook.GetWorkbook(
			CreateObject( "java", "java.io.File" ).Init(arguments.filename)
		)/>
	 
		<!---
			Create an object to keep track of all the sheet / cell
			data. We are, essentially going to store the excel
			sheets in an array and the data in a query.
		--->
		<cfset local.arrWorkbook = ArrayNew(1) />
	 
		<!---
			Loop over the number of sheets in the workbook. We need to
			get the number of sheets in the workbook. Be careful! The
			GetSheets() method doesn't return a number (like the later
			used GetColumns() or GetRows()); instead, it returns an
			array of actual jxl.Sheet objects.
		--->
		<!---
			Create a blank query for this excel data sheet.
			We could create the number of columns right now,
			but I think it will be easier to add columns as
			we go.
		--->
		<cfset local.qData = QueryNew("") />
	
		<!--- Store this data query into the workbook array. --->
		<cfset ArrayAppend(local.arrWorkbook, local.qData) />
	
		<!---
			Get the current sheet. Remember that since we are
			getting the sheet by index and we are getting it
			through a JAVA method, we need to use zero-based
			indexes (unlike ColdFusion which is one-based).
		--->
		<cfset local.objSheet = local.objWorkbook.GetSheet(arguments.sheetName)>
		<!---
			Loop over the columns and rows. As we loop over the
			columns, we are going to add a column to the data
			query and then add the row values. This should allow
			us to easily create the computed names such as
			COLUMN1, COLUMN2, COLUMN3.
		--->
		<cfset local.numColumns = local.objSheet.getColumns()>
		<cfset local.columnsKey = ArrayNew(1)>

		<cfloop from="1" to="#local.objSheet.getRows()#" index="local.row">
	
			<cfif local.row eq 1>
				<cfloop from="1" to="#local.numColumns#" index="local.col">
					<cfset local.colName = Trim(ReReplaceNoCase(
						local.objSheet.GetCell(
							JavaCast( "int", local.col - 1 ),
							JavaCast( "int", local.row - 1 )
						).GetContents(),
						local.replString, "", "ALL"
					))>
					<cfset ArrayAppend(local.columnsKey, local.colName)>

					<cfif Len(local.colName)>
						<cfset QueryAddColumn(local.qData, local.ColName, "CF_SQL_VARCHAR", ArrayNew(1))/>
					</cfif>
				</cfloop>
			<cfelse>
				<cfset QueryAddRow(local.qData, 1) /><!--- yes, it's slow, but it is either that or have to work out blank rows, which will take as long--->
				<cfloop from="1" to="#local.numColumns#" index="local.col">
					<!--- For the record, this doesn't  f&^%ng work
					<cfset local.colName = listGetAt(local.qData.columnList, local.col)>
					--->

					<!--- 	This one is OTT					
						<cfset local.colName = ReReplaceNoCase(
							local.objSheet.GetCell(
								JavaCast( "int", local.col - 1 ),
								JavaCast( "int", 0 )
							).GetContents(),
							local.replString, "", "ALL"
						)>
					--->
					
					<!--- So, instead we get the keys to the column into an array when the first row is populated and then use that --->
					<cfset local.colName = local.columnsKey[local.col]>
					<cftry>
						<cfif Len(local.colName)>
							<!--- Set the query data. --->
							<cfset local.value = Trim(local.objSheet.GetCell(
								JavaCast( "int", local.col - 1 ),
								JavaCast( "int", local.row - 1 )
								).GetContents())
							>
							<cfif Len(local.value)>
								<cfset QuerySetCell(local.qData, local.colName, local.value, local.row-1)>
							</cfif>
						</cfif>
						<cfcatch type="any">
						</cfcatch>
					</cftry>

				</cfloop>
			</cfif>
		</cfloop>
	
		<cfset local.objWorkbook.Close() />

		<cfreturn local.arrWorkbook[1]>
	</cffunction>
	
	<cffunction name="CreateJExcelObject" access="public" returntype="any" output="false">
		<cfargument name="Class" type="string" required="true" />
	 
		<!--- Define the local scope. --->
		<cfset var LOCAL = StructNew() />
	 
		<!---
			Initialize the URL object to point to the current
			directory. In this case we are pointing using the file
			system, NOT the web browser, hence the "file:" prefix.
			This URL can point to any part of the file system
			irrelevant of the web-accessible parts of the system.
			This will happen on the server size, not the client side
			(of course) and therefore is not dependent on
			web-accessibility. In this case, we are hard-coding the
			path to the JExcel JAR file, however this is a path that
			could easily be passed in.
		--->
		<cfset LOCAL.Url = CreateObject( "java", "java.net.URL" ).Init(
			JavaCast("string", "file:" & getFactory().getSetting("jarPath") & "jxl.jar" )
		) />
	 
	 
		<!---
			Get an array of URL objects. Since we cannot do this
			directly, (delcare an array of java object types), we will
			have to do this using the reflect array class. We can pass
			this class a Java class definition and ask it to create an
			array of that type for us.
		--->
		<cfset LOCAL.ArrayCreator = CreateObject("java", "java.lang.reflect.Array") />
	 
		<!---
			Ask the reflect array service to create an array of URL
			objects. Get the class definition from the URL object we
			created previously. When we create the array, we need to
			create it with the length of 1 so that we can add the URL
			to it next.
		--->
		<cfset LOCAL.URLArray = LOCAL.ArrayCreator.NewInstance(
			LOCAL.Url.GetClass(), JavaCast("int", 1)
		) />
	 
	 
		<!---
			Now, we need to set the URLs into the array. This array
			will be used for the initialization of the URL class loader
			and will need to contain all the URLs that we need. Since
			we cannot work with these types of array directly in
			ColdFusion, we need to ask our array creator object to do
			the setting for us.
	 
			My hope was that we did NOT have to use this SET method. I
			had hoped that I could call the AddURL() method on the
			URLClassLoader itself. Unforutnately, that method is
			Protected and I do not have permissions to access it.
			Hence, all of the URLs that we want to load have to be
			passed in during the initialization process.
		--->
		<cfset LOCAL.ArrayCreator.Set(LOCAL.URLArray, JavaCast( "int", 0 ), LOCAL.Url) />
	 
	 
		<!---
			Now, we want to create a URL class loader to load in the
			Java classes that we have locally. In order to initialize
			this class, we need to pass it the URL array that we just
			created. Keep in mind that it contains all the URLs that
			we want to load.
		--->
		<cfset LOCAL.ClassLoader = CreateObject("java", "java.net.URLClassLoader").Init(LOCAL.URLArray)/>
	 
	 
		<!---
			Use the JavaProxy object as demonstrated by Mark Mandel
			and his JavaLoader.cfc. This will create a Java class
			that has not been initialized. You can use the returned
			class as a static class or you can call the INIT() method
			on it with the appropriate arguments.
		--->
		<cfset local.proxy = CreateObject("java", "coldfusion.runtime.java.JavaProxy").Init(
				LOCAL.ClassLoader.LoadClass(("jxl." & ARGUMENTS.Class)))>
		<cfreturn local.proxy />
	</cffunction>

	<cffunction name="queriesToXLS" hint="I create a XLS workbook from a struct of queries" access="public">
		<cfargument name="inQueries" type="struct" required="true">
		<cfargument name="columnOrder" type="struct" required="false" default="#StructNew()#" hint="Struct of lists of columns in the order they should be output">
		<cfargument name="columnAlias" type="struct" required="false" default="#StructNew()#" hint="Struct of lists of column aliases in the order they should be output, to match columnOrder">

		<cfset var local = structNew()>
		<cfset local.outStream = createObject("java","java.io.ByteArrayOutputStream").init()>
		<cfset local.workbook = createObject("java","jxl.Workbook")>
		<cfset local.ws = createObject("java","jxl.WorkbookSettings").init()>
		<cfset local.locale = createObject("java","java.util.Locale").init("en","EN")>
		<cfset local.labelObj = createObject("java","jxl.write.Label")>
		<cfset local.numberObj = createObject("java","jxl.write.Number")>
		<cfset local.ws.setLocale(local.locale)>
		<cfset local.ws.setArrayGrowSize(JavaCast("int",1000))>

		<cfset local.workbook = local.workbook.createWorkbook(local.outStream, local.ws)>

		<cfloop from="1" to="#StructCount(arguments.inQueries)#" index="local.i">

			<cfset local.sheetName = structKeyList(arguments.inQueries[local.i])>
			<cfset local.sheetQuery = arguments.inQueries[local.i][structKeyList(arguments.inQueries[local.i])]>
			<cfset local.sheet = local.workBook.createSheet(local.sheetname, toString(local.i-1))>

			<cfif NOT StructIsEmpty(arguments.columnOrder) AND Len(arguments.columnOrder[local.i])>
				<cfset local.columnList = arguments.columnOrder[local.i]>
			<cfelse>
				<cfset local.columnList = local.sheetQuery.columnList>
			</cfif>

			<cfif NOT StructIsEmpty(arguments.columnAlias) AND Len(arguments.columnAlias[local.i])>
				<cfset local.columnLabels = arguments.columnAlias[local.i]>
			<cfelse>
				<cfset local.columnLabels = local.columnList>
			</cfif>
			<!--- output column headers --->
			<cfloop from="1" to="#ListLen(local.columnList)#" index="local.qCol">
				<cfset local.thisLabel = local.labelObj.init(
						toString(val(local.qCol)-1), 0, listGetAt(local.columnLabels, local.qCol))>
				<cfset local.sheet.addCell(local.thisLabel)>
			</cfloop>

			<cfloop from="1" to="#local.sheetQuery.recordCount#" index="local.qRow">
				<cfloop from="1" to="#ListLen(local.columnList)#" index="local.qCol">
					<cfset local.realValue = local.sheetQuery[listGetAt(local.columnlist, local.qCol)][local.qRow]>
					<cfset local.value = trim(local.realValue)>

						<cfset local.thisLabel = local.labelObj.init(
								toString(val(local.qCol)-1),
								toString(local.qRow),
								toString(local.value)
						)>
					
					<cfset local.sheet.addCell(local.thisLabel)>


				</cfloop>
			</cfloop>
		</cfloop>
		
		<cfset local.workbook.write()>
		<cfset local.outStream.flush()>
		<cfset local.workbook.close()>
		
		<cfreturn local.outStream.toByteArray()>
	</cffunction>

	<cffunction name="queryToCSV" hint="Converts a single query to a text string suitable for outputting to .csv file. Comma-delimited. Text denoted by double-quotes" returntype="string" access="public">
		<cfargument name="data" type="query" required="true">
		<cfargument name="columnOrder" type="string" required="false" default="#arguments.data.columnList#">
		<cfargument name="columnAlias" type="string" required="false" default="#arguments.columnOrder#">
		<cfargument name="printColumns" type="boolean" required="false" default="false">

		<cfset var local = structNew()>
		<cfset local.CSV = "">

		<cfif arguments.printcolumns>
			<cfset local.rowCSV = "">
			<cfloop list="#arguments.columnAlias#" index="local.ali">
				<cfset local.rowCSV = ListAppend(local.rowCSV, '"#local.ali#"')>
			</cfloop>
			<cfset local.rowCSV = local.rowCSV & chr(10)>
			<cfset local.CSV = local.CSV & local.rowCSV>
		</cfif>
		
		<cfloop query="arguments.data">
			<cfset local.rowCSV = "">
			<cfloop list="#arguments.columnOrder#" index="local.col">
				<cfset local.value = arguments.data[local.col][arguments.data.currentRow]>
				<cfset local.rowCSV = ListAppend(local.rowCSV, '"#local.value#"')>
			</cfloop>
			<cfif arguments.data.currentRow neq arguments.data.recordCount>
				<cfset local.rowCSV = local.rowCSV & chr(10)>
			</cfif>
			<cfset local.CSV = local.CSV & local.rowCSV>
		</cfloop>

		<cfreturn local.csv>
	</cffunction>
</cfcomponent>
