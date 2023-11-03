<cfcomponent name="formFactory" extends="parent" hint="Controller for formFactory">
	<cffunction name="init" returntype="formFactory" access="public">
		<cfset var local = structNew()>

		<cfset super.init()>
		
		<cfset local.cfcPath = getDirectoryFromPath(getCurrentTemplatePath())>
		<cffile action="read" file="#local.cfcPath#..\..\config\#application.core.get('configFolder')#\FormFactoryMessage.xml" variable="local.rawData">
		<cfset local.xml = xmlParse(local.rawData)>
		
		<cfset variables.messages = StructNew()>
		
		<cfloop from="1" to="#ArrayLen(local.xml.formfactorymessages.message)#" index="local.m">
			<cfloop list="#StructKeyList(local.xml.formfactorymessages.message[local.m].xmlAttributes)#" index="local.key">
				
				<cfset local.messages = ArrayNew(1)>
				
				<cfloop from="1" to="#ArrayLen(local.xml.formfactorymessages.message[local.m].container)#" index="local.c">
					<cfset local.message = structNew()>
					<cfif NOT StructKeyExists(local.message,"title")>
						<cfset StructInsert(local.message, "title",local.xml.formfactorymessages.message[local.m].container[local.c].xmlAttributes.title)>
					</cfif>
					<cfif NOT StructKeyExists(local.message,"summary")>
						<cfset StructInsert(local.message, "summary",local.xml.formfactorymessages.message[local.m].container[local.c].xmlAttributes.summary)>
					</cfif>
					
					<cfset ArrayAppend(local.messages, local.message)>
				</cfloop>
				
				<cfif NOT StructKeyExists(variables.messages,local.xml.formfactorymessages.message[local.m].xmlAttributes[local.key])>
					<cfset StructInsert(variables.messages, local.xml.formfactorymessages.message[local.m].xmlAttributes[local.key], local.messages)>
				</cfif>
			</cfloop>
		</cfloop>
		
		<cfreturn this/>
	</cffunction>

	<cffunction name="default" access="public" returntype="struct" hint="Default behaviour for this component">
		<cfargument name="data" type="struct" required="false">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

		<cfreturn local.result>
	</cffunction>    
    
    <cffunction name="accessKey" access="public" returntype="struct" hint="Display handler to print out accessKey input block">
		<cfargument name="value" type="string" required="false" default="">
		<cfargument name="editMode" type="boolean" required="false" default="true" hint="Determines whether edit handlers are shown">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

        <cfset local.result.output = inputText(id="accessKey", label="Your Access Key", value=arguments.value, required="true", editMode=arguments.editMode, password=false,class="long").output>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="inputRadio" access="public" returntype="struct" hint="Generic handler to output radio button options">
		<cfargument name="id" type="string" required="true" hint="Name/ID for the field - must be unique">
		<cfargument name="fieldTitle" type="string" required="false" hint="The text to display for the group" default="">
		<cfargument name="label" type="string" required="false" hint="The fieldlabel text">
		<cfargument name="options" type="string" required="true" hint="Comma-delimited list of | delimited label/value pairs for radio options">
		<cfargument name="value" type="string" required="false" default="" hint="The current selected value must match value in arguments.options">
		<cfargument name="hint" type="string" required="false" hint="The secondary help text">
		<cfargument name="required" type="boolean" required="false" default="false">
		<cfargument name="editMode" type="boolean" required="false" default="true">
		<cfargument name="isInline" type="boolean" required="false" default="true">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

		<cfsavecontent variable="local.result.output">
			<cfoutput>
				<!--- editing --->
				<cfif arguments.editMode>
					<div class="form-group row my-3">
						<div class="col md-3">#arguments.fieldTitle#</div>
						<!--- inline --->
						<cfif arguments.isInline>
							<cfset local.i = 0>
							<cfloop list="#arguments.options#" index="local.option">
								<cfset local.i++>
								<cfset local.label = listGetAt(local.option,1,"|")>
								<cfset local.value = listGetAt(local.option,2,"|")>
								<div class="col">
									<input type="radio" id="#arguments.id#_#local.label#"
										name="#arguments.id#"
										<cfif arguments.value eq local.value>
											CHECKED
										</cfif>
										value="#local.value#"
										<cfif local.i eq 1 AND arguments.required>
										class="radio validate-one-required"
										<cfelse>
										class="radio"
										</cfif>
									>&nbsp;#local.label#
								</div>
							</cfloop>
						<!--- not inline but vertical --->
						<cfelse>
							<div class="col md-9">
								<cfset local.i = 0>
								<cfloop list="#arguments.options#" index="local.option">
									<cfset local.i++>
									<cfset local.label = listGetAt(local.option,1,"|")>
									<cfset local.value = listGetAt(local.option,2,"|")>
									<input type="radio" id="#arguments.id#_#local.label#"
										name="#arguments.id#"
										<cfif arguments.value eq local.value>
											CHECKED
										</cfif>
										value="#local.value#"
										<cfif local.i eq 1 AND arguments.required>
										class="radio validate-one-required"
										<cfelse>
										class="radio"
										</cfif>
									>&nbsp;#local.label#<br/>
								</cfloop>
							</div>
						</cfif>
					</div>
				<!--- only viewing --->
				<cfelse>
					<div class="row">
						<div class="col">
							<cfloop list="#arguments.options#" index="local.option">
								<cfset local.label = listGetAt(local.option,1,"|")>
								<cfset local.value = listGetAt(local.option,2,"|")>
								<cfif arguments.value eq local.value>
									#local.label#
									<cfbreak>
								</cfif>
							</cfloop>
						</div>
					</div>
				</cfif>
			</cfoutput>
		</cfsavecontent>
		<cfreturn local.result>
	</cffunction>
	
    <!--- The generic functions --->
    <cffunction name="inputSelect" access="private" returntype="struct" hint="Generic handler to output an input type select field">
		<cfargument name="selectid" type="string" required="true" hint="Name/ID for the field">
		<cfargument name="label" type="string" required="true" hint="The fieldlabel text">
		<cfargument name="hint" type="string" required="false" default="" hint="The secondary help text">
		<cfargument name="data" type="array" required="true" hint="Array of structs with label/value pairs">
		<cfargument name="value" type="string" required="false" default="" hint="The current value - matches to a label of a pair in data">
		<cfargument name="required" type="boolean" required="false" default="false">
		<cfargument name="editMode" type="boolean" required="false" default="true" hint="Determines whether edit handlers are shown">
		<cfargument name="hidden" type="boolean" required="false" default="false" hint="Determines whether, if editMode is false, the input type=hidden tag is used instead of a normal output">
		<cfargument name="trigger" type="string" required="false" hint="Name of Javascript function called onchange" default="">
        <cfargument name="novalue" type="string" required="false" default="Please select">
        <cfargument name="novalueID" type="string" required="false" default="">
        		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

		<cftry>
			<cfsavecontent variable="local.result.output">
				<cfoutput>
					<div class="form-floating mb-3 mt-3">						
						<select id="#arguments.selectid#" class="form-select" name="#arguments.selectid#" <cfif Len(arguments.trigger)>onchange="#arguments.trigger#()"</cfif>  <cfif arguments.required> required </cfif>>
						<option value="#arguments.novalueID#">#arguments.novalue#</option>
						<cfloop from="1" to="#ArrayLen(arguments.data)#" index="local.i">
							<option value="#arguments.data[local.i].value#" <cfif arguments.value eq arguments.data[local.i].value> selected</cfif>>#arguments.data[local.i].label#</option>
						</cfloop>
						</select>
						<cfif arguments.editMode>
						<label for="#arguments.selectid#">#arguments.label#</label>
						</cfif>
						<div class="valid-feedback">Valid.</div>
						<div class="invalid-feedback">Please fill out this field.</div>
					</div>					
				</cfoutput>
			</cfsavecontent>

			<cfcatch type="any">
				<cfdump var="#cfcatch#">
			</cfcatch>
		</cftry>
		<cfreturn local.result>
	</cffunction>

    <cffunction name="inputText" access="private" returntype="struct" hint="Generic handler to output a text input field">
		<cfargument name="id" type="string" required="true" hint="Name/ID for the field">
		<cfargument name="label" type="string" required="true" hint="The fieldlabel text">
		<cfargument name="value" type="string" required="false" default="" hint="Current value of the field">
		<cfargument name="required" type="boolean" required="false" default="false">
		<cfargument name="hint" type="string" required="false" default="" hint="The secondary help text">
		<cfargument name="email" type="boolean" required="false" default="false" hint="Treat field as an email address field">
		<cfargument name="editMode" type="boolean" required="false" default="true" hint="Determines whether edit handlers are shown">
		<cfargument name="hidden" type="boolean" required="false" default="false" hint="Determines whether, if editMode is false, the input type=hidden tag is used instead of a normal output">
		<cfargument name="size" type="numeric" required="false" default="0">
        <cfargument name="password" type="boolean" required="false" default="false">
		<cfargument name="placeholder" type="string" required="false" default="" hint="Any text to appear as a placeholder for the input">
		<cfargument name="loginScreen" type="boolean" required="false" default="false">

		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

		<cfsavecontent variable="local.result.output">
			<cfoutput>
				<div class="form-floating mb-3 mt-3">
					<!--- able to edit --->
					<cfif arguments.editMode>
						<input type="<cfif arguments.password>password<cfelse>text</cfif>" class="form-control" id="#arguments.id#" name="#arguments.id#" value="#arguments.value#" <cfif arguments.size>size="#arguments.size#" maxlength="#arguments.size#"</cfif> class="form-control" aria-describedby=#arguments.id#Help" placeholder="Enter your #arguments.label#" <cfif arguments.required> required</cfif>>
						<label for="#arguments.id#">#arguments.label#</label>
						<cfif Len(arguments.hint)>
							<small id="#arguments.id#Help" class="form-text text-muted">#arguments.hint#</small>
						</cfif>
						<!--- required, make use of the bootstrap validation messages --->
						<cfif arguments.required>
							<div class="valid-feedback">Valid.</div>
							<div class="invalid-feedback">Please fill out this field.</div>
						</cfif>
					<!--- not able to edit. Only viewing allowed --->
					<cfelse>
						<!--- anything that is not a password --->
						<cfif NOT arguments.password>
							<cfset local.value = arguments.value>
						<!--- if password, replace all characters by * for display --->
						<cfelse>
							<cfset local.value = RepeatString("*", Len(arguments.value))>
						</cfif>

						<input type="<cfif arguments.password>password<cfelse>text</cfif>" readonly class="form-control-plaintext" id="#arguments.id#" value="#local.value#">
					</cfif>
				</div>				
			</cfoutput>
		</cfsavecontent>
		<cfreturn local.result>
	</cffunction>

	<cffunction name="inputTextArea" access="private" returntype="struct" hint="Generic handler to output a textarea field">
		<cfargument name="id" type="string" required="true" hint="Name/ID for the field">
		<cfargument name="label" type="string" required="true" hint="The fieldlabel text">
		<cfargument name="value" type="string" required="false" default="" hint="Current value of the field">
		<cfargument name="required" type="boolean" required="false" default="false">
		<cfargument name="hint" type="string" required="false" default="" hint="The secondary help text">
		<cfargument name="editMode" type="boolean" required="false" default="true" hint="Determines whether edit handlers are shown">
		<cfargument name="hidden" type="boolean" required="false" default="false" hint="Determines whether, if editMode is false, the input type=hidden tag is used instead of a normal output">
		<cfargument name="rows" type="numeric" required="false" default="0">
		<cfargument name="cols" type="numeric" required="false" default="0">
		<cfargument name="maxLength" type="numeric" required="false" default="0">
        <cfargument name="help" type="boolean" required="false" default="false">        
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

		<cfsavecontent variable="local.result.output">
			<cfoutput>
				<div class="form-floating mb-3 mt-3">
					<textarea class="form-control" id="#arguments.id#" name="#arguments.id#" style="height: 400px" <cfif arguments.required>required</cfif>>#arguments.value#</textarea>
					<label for="#arguments.id#">#arguments.label#</label>
					<!--- if item is required, use Bootstrap for validation messages --->
					<cfif arguments.required>
						<div class="valid-feedback">Valid.</div>
						<div class="invalid-feedback">Please fill out this field.</div>
					</cfif>
					<!--- show help if dealing with playerDetails when adding a match's data --->
					<cfif arguments.id eq "PlayersRatings">
						<small id="#arguments.id#Help" class="form-text text-muted">
								<button type="button" class="btn btn-dark mt-2 text-white" id="PlayersRatingsAsk">Need help</button>

								<div id="PlayersRatingsHelpTxt" style="display:none;">
									#addPlayersRatingsHelp().output#
								</div>

								<script>
									$(document).ready(function(){
										$("##PlayersRatingsAsk").click(function(){
											$("##PlayersRatingsHelpTxt").slideToggle(); 
										});
									});
								</script>
								
						</small>
					</cfif>
				</div>					
			</cfoutput>
		</cfsavecontent>
		<cfreturn local.result>
	</cffunction>
        
    <cffunction name="inputDate" access="private" returntype="struct" hint="Generic handler to output a date input field">
		<cfargument name="id" type="string" required="true" hint="Name/ID for the field">
		<cfargument name="label" type="string" required="true" hint="The fieldlabel text">
		<cfargument name="value" type="string" required="false" default="" hint="Current value of the field">
		<cfargument name="required" type="boolean" required="false" default="false">
		<cfargument name="hint" type="string" required="false" default="" hint="The secondary help text">
		<cfargument name="editMode" type="boolean" required="false" default="true" hint="Determines whether edit handlers are shown">
		<cfargument name="hidden" type="boolean" required="false" default="false" hint="Determines whether, if editMode is false, the input type=hidden tag is used instead of a normal output">
        		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        
		<cfsavecontent variable="local.result.output">
			<cfoutput>
				<div class="form-floating mb-3 mt-3">
					<!--- editing the date --->
					<cfif arguments.editMode>
							<input type="date" class="form-control" id="#arguments.id#" name="#arguments.id#" value="#arguments.value#" <cfif arguments.required> required</cfif> aria-describedby=#arguments.id#Help">
							<label for="#arguments.id#">#arguments.label#</label>		
							<cfif Len(arguments.hint)>
								<small id="#arguments.id#Help" class="form-text text-muted">#arguments.hint#</small>
							</cfif>
							<div class="valid-feedback">Valid.</div>
							<div class="invalid-feedback">Please fill out this field.</div>
					<!--- only displaying the date --->
					<cfelse>
						<cfset local.value = arguments.value>
						<input type=date" readonly class="form-control-plaintext" id="#arguments.id#" value="#local.value#">
					</cfif>
				</div>			
				                            
			</cfoutput>
		</cfsavecontent>
		<cfreturn local.result>
	</cffunction>
    
	<cffunction name="inputRange" access="private" returntype="struct" hint="Generic handler to output a range input field">
        <cfargument name="id" type="string" required="true" hint="Name/ID for the field">
        <cfargument name="label" type="string" required="true" hint="The fieldlabel text">
        <cfargument name="value" type="string" required="false" default="" hint="Current value of the field">

        <cfargument name="required" type="boolean" required="false" default="false">
        <cfargument name="hint" type="string" required="false" default="" hint="The secondary help text">

        <cfargument name="editMode" type="boolean" required="false" default="true" hint="Determines whether edit handlers are shown">
        <cfargument name="hidden" type="boolean" required="false" default="false" hint="Determines whether, if editMode is false, the input type=hidden tag is used instead of a normal output">

        
        <cfset var local = structNew()>
        <cfset local.result = getFactory().getResult()>

        <cfsavecontent variable="local.result.output">
                <cfoutput>
					<label for="#arguments.id#">#arguments.label#</label>
					<!--- if editing --->
					<cfif arguments.editMode>
							<input type="range" class="form-range" min="#arguments.minimum#" max="#arguments.maximum#" step="#arguments.stepping#" id="#arguments.id#" name="#arguments.id#"  value="#arguments.value#" <cfif arguments.showrange> onInput="$('##rangeval#arguments.id#').html($(this).val())" </cfif>>
							<cfif arguments.showrange>
							<span id="rangeval#arguments.id#">#arguments.value#</span>
							</cfif>
					<!--- if only viewing --->
					<cfelse>
							#arguments.value#                  
					</cfif>
                </cfoutput>
        </cfsavecontent>
        <cfreturn local.result>
	</cffunction>	
    
    <cffunction name="teamID" access="public" returntype="struct" hint="Display handler to print out teamID input block">
		<cfargument name="value" type="string" required="false" default="">
		<cfargument name="editMode" type="boolean" required="false" default="true" hint="Determines whether edit handlers are shown">
        
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

        <cfset local.result.output = inputText(id="teamID", label="Team ID", value=arguments.value, required="true", editMode=arguments.editMode, password=false,class="long").output>

		<cfreturn local.result>
	</cffunction>
        
    <cffunction name="age" access="public" returntype="struct" hint="Display handler to print out age input block">
		<cfargument name="selectid" type="string" required="false" default="age">
		<cfargument name="label" type="string" required="false" default="Minimum Age">
		<cfargument name="value" type="string" required="false" hint="Current age">
		<cfargument name="editMode" type="boolean" required="false" default="true" hint="Determines whether edit handlers are shown">
        <cfargument name="required" type="boolean" required="false" default="true" hint="Determines whether required field or not">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        <cfset local.ages = getFactory().get("leagueplayers").model.getAges()>

		<cfif Len(arguments.value)>
			<cfset local.value = arguments.value>
		<cfelse>
			<cfset local.value = "">
		</cfif>

		<!--- build array of structs dataset to use in inputSelect --->
		<cfset local.data = ArrayNew(1)>
		<cfloop query="local.ages">
			<cfset local.str = {label=local.ages.age, value=local.ages.age}>
			<cfset ArrayAppend(local.data, local.str)>
		</cfloop>

		<cfset local.result.output = inputSelect(selectid="#arguments.selectid#", label="#arguments.label#",
				required=arguments.required, data=local.data, value=local.value, editMode=arguments.editMode).output>

		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="ageSearch" access="public" returntype="struct" hint="Display handler to print out age input block">
		<cfargument name="selectid" type="string" required="false" default="age">
		<cfargument name="label" type="string" required="false" default="Age">
		<cfargument name="value" type="string" required="false" hint="Current age">
		<cfargument name="editMode" type="boolean" required="false" default="true" hint="Determines whether edit handlers are shown">
        <cfargument name="required" type="boolean" required="false" default="true" hint="Determines whether required field or not">
		<cfargument name="valueradio" type="string" required="false" hint="minimum or maximum">
        
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
        <cfset local.ages = getFactory().get("leagueplayers").model.getAges()>

		<cfif Len(arguments.value)>
			<cfset local.value = arguments.value>
		<cfelse>
			<cfset local.value = "0">
		</cfif>

		<!--- build array of structs dataset to use in inputSelect --->
		<cfset local.data = ArrayNew(1)>
		<cfloop query="local.ages">
			<cfset local.str = {label="#local.ages.age#", value=local.ages.age}>
			<cfset ArrayAppend(local.data, local.str)>
		</cfloop>
        
		<cfset local.options = "Min|minimum,Max|maximum">
		
        <cfsavecontent variable="local.result.output">
			<cfoutput>
				
				<div class="form-group row my-3">	
					<label for="#arguments.selectid#">#arguments.label#</label>
					<cfset local.i = 0>
					<cfloop list="#local.options#" index="local.option">
						<cfset local.i++>
						<cfset local.label = listGetAt(local.option,1,"|")>
						<cfset local.value = listGetAt(local.option,2,"|")>
						<div class="form-floating mb-3 mt-4 col">
							<input type="radio" id="ageType_#local.label#"
								name="ageType"
								<cfif arguments.valueradio eq local.value>
									CHECKED
								</cfif>
								value="#local.value#"
								<cfif local.i eq 1 AND arguments.required>
								class="radio validate-one-required"
								<cfelse>
								class="radio"
								</cfif>
							>&nbsp;#local.label#
						</div>
					</cfloop>
					<div class="form-floating mb-3 mt-3 col">
						<select id="#arguments.selectid#" class="form-select" name="#arguments.selectid#">
						<option value="0">Please Select</option>
						<cfloop from="1" to="#ArrayLen(local.data)#" index="local.i">
							<option value="#local.data[local.i].value#" <cfif arguments.value eq local.data[local.i].value> selected</cfif>>#local.data[local.i].label#</option>
						</cfloop>
						</select>
						<label for="#arguments.selectid#">#arguments.label#</label>
					</div>
				</div>
			</cfoutput>
		</cfsavecontent>
        
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="position" access="public" returntype="struct" hint="Display handler to print out position drop-down list block">
		<cfargument name="selectid" type="string" required="false" default="position">
		<cfargument name="label" type="string" required="false" default="Position">
		<cfargument name="value" type="string" required="false" hint="Current position">
		<cfargument name="editMode" type="boolean" required="false" default="true" hint="Determines whether edit handlers are shown">
        <cfargument name="required" type="boolean" required="false" default="true" hint="Determines whether required field or not">
        <cfargument name="trigger" type="string" required="false" hint="Name of a javascript function called on change" default="">
        
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
		<cfset local.positions = getFactory().get("leagueplayers").model.getSearchPositions()>
        
		<cfif Len(arguments.value)>
			<cfset local.value = arguments.value>
		<cfelse>
			<cfset local.value = "">
		</cfif>

		<!--- build array of structs dataset to use in inputSelect --->
		<cfset local.data = ArrayNew(1)>
		<cfloop query="local.positions">
        	<cfset local.str = {label="#positionID#-#positionTitle#", value=positionID}>
            <cfset ArrayAppend(local.data, local.str)>
		</cfloop>

        <cfset local.result.output = inputSelect(selectid="#arguments.selectid#", label="#arguments.label#",
				required=arguments.required, data=local.data, value=local.value, editMode=arguments.editMode, novalue="Any Position").output>

		<cfreturn local.result>
	</cffunction>
    
	<cffunction name="MatchTeamRatings" access="public" returntype="struct" hint="Display handler to print out match ratings values">
		<cfargument name="data" type="struct" required="true">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

		<!--- work out how many rows --->
		<cfset local.totalSets = Ceiling(arguments.data.availableTeamRatingsStats.recordCount / 3)>
		<cftry>
			<cfsavecontent variable="local.result.output">
				<cfoutput>
					<cfloop from="1" to="#local.totalSets#" index="local.setNo">
						<div class="form-group row">
							<cfset local.fromRow = ((local.setNo-1) * 3) + 1>
							<cfset local.toRow = Min(arguments.data.availableTeamRatingsStats.recordcount, local.fromRow + 3 - 1)>
							<cfloop from="#local.fromRow#" to="#local.toRow#" index="local.r">
								<div class="form-group col-md-4">
									#inputRange(id = "MatchTeamRatings_#Evaluate("#arguments.data.availableTeamRatingsStats.statID[local.r]#")#", label = "#arguments.data.availableTeamRatingsStats.statTitle[local.r]#", minimum = 0, maximum = 10, stepping = 0.5, value="#Evaluate("arguments.data.MatchTeamRatings_[#arguments.data.availableTeamRatingsStats.statID[local.r]#]")#", showrange = true).output#
								</div>
							</cfloop>
						</div>
					</cfloop>
				</cfoutput>
			</cfsavecontent>
			<cfcatch type="any">
				<cfdump var="#cfcatch#">
			</cfcatch>
		</cftry>
		<cfreturn local.result>
	</cffunction>
        
    <cffunction name="PlayersRatings" access="public" returntype="struct" hint="Display handler to print out match players ratings textarea block">
		<cfargument name="value" type="string" required="false" default="">
		<cfargument name="editMode" type="boolean" required="false" default="true" hint="Determines whether edit handlers are shown">
        <cfargument name="required" type="boolean" required="false" default="true" hint="Determines whether required field or not">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		<cfset local.result.output = inputTextArea(id="PlayersRatings", label="Players Ratings", value=arguments.value, required=arguments.required, editMode=arguments.editMode,help=true).output>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="addPlayersRatingsHelp" access="public" returntype="struct" hint="displays some help text for pasting in data">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

		<cfsavecontent variable="local.displayFromHome">
			<cfoutput>
				1. Freddie Perkin<br />
                Reputable (Below potential),
                2. Geraint Davies<br />
                Satisfactory (Below potential),
                3. Diarmuid Feeney<br />
                Decent (Below potential),
                4. Morgan Ellis<br />
                Satisfactory (Below potential),
                5. Gabriel Jefferys<br />
                Average (Below potential),
                6. Ethan Buel<br />
                Reputable (Below potential),
                7. Elliot Caddock<br />
                Princely (Above potential),
                8. Michael Price<br />
                Impressive (To potential),
                9. Luke Ash<br />
                Admirable (Below potential),
                10. Archie Adams<br />
                Admirable (Below potential),
                11. Callum Bathoe<br />
                Reputable (Below potential),
                12. Stephen Morse<br />
                Sumptuous (Above potential),
                13. Milton Boyd<br />
                Admirable (Below potential),
                14. Reece Tubridy<br />
                Reputable (Below potential),
                15. Dale Whittier<br />
                Impressive (Above potential),
                16. Reece Davies<br />
                Did not play,
                17. Bevan Kiffin<br />
                Did not play,
                18. Mitchell Powell<br />
                Did not play,
                19. Alan O'Halloran<br />
                Did not play,
                20. Aaron Richmond<br />
                Did not play,
                21. Kieran Elias<br />
                Did not play,
                22. Derfel Connah<br />
                Did not play
			</cfoutput>
		</cfsavecontent>

		<cfsavecontent variable="local.displayFromAway">
			<cfoutput>
				Owain Bowne .1<br />
                Decent (Below potential),
                Joshua Prosser .2<br />
                Average (Below potential),
                Declan Jenkins .3<br />
                Average (Below potential),
                Jordan Wigley .4<br />
                Average (Below potential),
                Lucas Evans .5<br />
                Average (Below potential),
                Zak Williams .6<br />
                Average (Below potential),
                Mohammad Owen .7<br />
                Average (Below potential),
                Bert Mannering .8<br />
                Moderate (Below potential),
                James Jehu .9<br />
                Decent (To potential),
                Tyler Dawson .10<br />
                Satisfactory (Below potential),
                Heilyn Dillingham .11<br />
                Reputable (Below potential),
                Deiniol Fulke .12<br />
                Satisfactory (Below potential),
                Mark Powell .13<br />
                Average (Below potential),
                John Scott .14<br />
                Average (Below potential),
                Cameron Huntington .15<br />
                Decent (Below potential),
                Reece Davies .16<br />
                Did not play,
                Bevan Kiffin .17<br />
                Did not play,
                Mitchell Powell .18<br />
                Did not play,
                Alan O'Halloran .19<br />
                Did not play,
                Aaron Richmond .20<br />
                Did not play,
                Kieran Elias .21<br />
                Did not play,
                Derfel Connah .22<br />
                Did not play
			</cfoutput>
		</cfsavecontent>
		
		<cfsavecontent variable="local.result.output">
			<cfoutput>
            #getFactory().get("template").view.defaultStyleHeader().output#
            <div style="padding:10px;text-align:left;">
				<h4>Please, paste in data in the following format:</h4>
                <br />
                <br />
                <h5>If you were playing home:</h5>
                #HTMLEditFormat(local.displayFromHome)#
                <br />
                <br />
                <h5>If you were playing away:</h5>
                #HTMLEditFormat(local.displayFromAway)#
                <br />
                <br />
            </div>
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>
	
	 <cffunction name="RedMaxLevel" access="public" returntype="struct" hint="Display handler to print out red max level input block on the current user's profile">
		<cfargument name="selectid" type="string" required="false" default="RedMaxLevel">
		<cfargument name="label" type="string" required="false" default="Use Red Up To">
		<cfargument name="value" type="string" required="false" hint="Current red max level">
		<cfargument name="editMode" type="boolean" required="false" default="true" hint="Determines whether edit handlers are shown">
        <cfargument name="required" type="boolean" required="false" default="true" hint="Determines whether required field or not">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
		<cfif Len(arguments.value)>
			<cfset local.value = arguments.value>
		<cfelse>
			<cfset local.value = "">
		</cfif>
		
        <cfset local.stats = getFactory().get("leagueplayers").model.getStatsLevels()>
        
		<!--- build array of structs dataset to use in inputSelect --->
		<cfset local.data = ArrayNew(1)>
		<cfloop query="local.stats">
			<cfset local.str = {label="#levelID#-#levelTitle#", value="#levelID#"}>
			<cfset ArrayAppend(local.data, local.str)>
		</cfloop>

        <cfset local.result.output = inputSelect(selectid="#arguments.selectid#", label="#arguments.label#",
				required=arguments.required, data=local.data, value=local.value, editMode=arguments.editMode,class="long").output>

		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="GreenMaxLevel" access="public" returntype="struct" hint="Display handler to print out green max level input block on the current user's profile">
		<cfargument name="selectid" type="string" required="false" default="GreenMaxLevel">
		<cfargument name="label" type="string" required="false" default="Use Green Up To">
		<cfargument name="value" type="string" required="false" hint="Current green max level">
		<cfargument name="editMode" type="boolean" required="false" default="true" hint="Determines whether edit handlers are shown">
        <cfargument name="required" type="boolean" required="false" default="true" hint="Determines whether required field or not">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
		<cfif Len(arguments.value)>
			<cfset local.value = arguments.value>
		<cfelse>
			<cfset local.value = "">
		</cfif>
		
        <cfset local.stats = getFactory().get("leagueplayers").model.getStatsLevels()>
        
		<!--- build array of structs dataset to use in inputSelect --->
		<cfset local.data = ArrayNew(1)>
		<cfloop query="local.stats">
			<cfset local.str = {label="#levelID#-#levelTitle#", value="#levelID#"}>
			<cfset ArrayAppend(local.data, local.str)>
		</cfloop>

        <cfset local.result.output = inputSelect(selectid="#arguments.selectid#", label="#arguments.label#",
				required=arguments.required, data=local.data, value=local.value, editMode=arguments.editMode,class="long").output>

		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="scoringHome" access="public" returntype="struct" hint="Display handler to print out scoring when game at home">
		<cfargument name="scoreHome" type="numeric" required="false" default="0">
        <cfargument name="otherScoreHome" type="numeric" required="false" default="0">
		<cfargument name="editMode" type="boolean" required="false" default="true" hint="Determines whether edit handlers are shown">
        <cfargument name="required" type="boolean" required="false" default="true" hint="Determines whether required field or not">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		<cfsavecontent variable="local.result.output">
			<cfoutput>
				<div class="form-group row">
					<div class="col-md-4">
						 #display(method="inputText", id="scoreHome", label="Your Team's Score", value=arguments.scoreHome, required=true, scoreHomeHelp="Your Team's Score").output#
					</div>
					<div class="col-md-4">
						#display(method="inputText", id="otherScoreHome", label="Your Opponent's Score", value=arguments.otherScoreHome, required=true, otherScoreHomeHelp="Your Opponent's Score").output#
					</div>
				</div>
			</cfoutput>
		</cfsavecontent>
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="scoringAway" access="public" returntype="struct" hint="Display handler to print out scoring when game is away">
		<cfargument name="scoreAway" type="numeric" required="false" default="0">
        <cfargument name="otherScoreAway" type="numeric" required="false" default="0">
		<cfargument name="editMode" type="boolean" required="false" default="true" hint="Determines whether edit handlers are shown">
        <cfargument name="required" type="boolean" required="false" default="true" hint="Determines whether required field or not">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		<cfsavecontent variable="local.result.output">
			<cfoutput>
				<div class="form-group row">
					<div class="col-md-4">
						 #display(method="inputText", id="otherScoreAway", label="Your Opponent's Score", value=arguments.otherScoreAway, required=false, otherScoreAwayHelp="Your Opponent's Score").output#

					</div>
					<div class="col-md-4">
						#display(method="inputText", id="scoreAway", label="Your Team's Score", value=arguments.scoreAway, required=false, scoreAwayHelp="Your Team's Score").output#
					</div>
				</div>
			</cfoutput>
		</cfsavecontent>
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="MatchAttendance" access="public" returntype="struct" hint="Display handler to print out all Attendance input blocks">
		<cfargument name="AttendanceStanding" type="numeric" required="false" default="0">
		<cfargument name="AttendanceUncovered" type="numeric" required="false" default="0">
		<cfargument name="AttendanceCovered" type="numeric" required="false" default="0">
		<cfargument name="AttendanceMembers" type="numeric" required="false" default="0">
		<cfargument name="AttendanceVIP" type="numeric" required="false" default="0">
		<cfargument name="editMode" type="boolean" required="false" default="true" hint="Determines whether edit handlers are shown">
        <cfargument name="required" type="boolean" required="false" default="true" hint="Determines whether required field or not">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		<cftry>
			<cfsavecontent variable="local.result.output">
				<cfoutput>
					<div class="form-group row">
						<div class="form-group col-md-4">
							<div class="form-floating mb-3 mt-3">
								<input type="text" class="form-control" id="AttendanceStanding" name="AttendanceStanding" placeholder="0" value="#arguments.AttendanceStanding#">
								<label for="AttendanceStanding">Standing</label>
							</div>
						</div>
						<div class="form-group col-md-4">
							<div class="form-floating mb-3 mt-3">
								<input type="text" class="form-control" id="AttendanceUncovered" name="AttendanceUncovered" placeholder="0" value="#arguments.AttendanceUncovered#">
								<label for="AttendanceUncovered">Uncovered</label>
							</div>
						</div>
						<div class="form-group col-md-4">
							<div class="form-floating mb-3 mt-3">
								<input type="text" class="form-control" id="AttendanceCovered" name="AttendanceCovered" placeholder="0" value="#arguments.AttendanceCovered#">
								<label for="AttendanceCovered">Covered</label>
							</div>
						</div>
					</div>
					<div class="form-group row">
						<div class="form-group col-md-4">
							<div class="form-floating mb-3 mt-3">
								<input type="text" class="form-control" id="AttendanceMembers" name="AttendanceMembers" placeholder="0" value="#arguments.AttendanceMembers#">
								<label for="AttendanceMembers">Members</label>
							</div>
						</div>
							<div class="form-group col-md-4">
								<div class="form-floating mb-3 mt-3">
								<input type="text" class="form-control" id="AttendanceVIP" name="AttendanceVIP" placeholder="0" value="#arguments.AttendanceVIP#">
								<label for="AttendanceVIP">CorporateVIP</label>
							</div>
						</div>
					</div>
				</cfoutput>
			</cfsavecontent>
			<cfcatch type="any">
				<cfdump var="#cfcatch#">
			</cfcatch>
		</cftry>
		<cfreturn local.result>
	</cffunction>

    <cffunction name="playerReport" access="public" returntype="struct" hint="Display handler to print out player drop-down list block">
		<cfargument name="selectid" type="string" required="false" default="playerID">
		<cfargument name="label" type="string" required="false" default="">
		<cfargument name="value" type="string" required="false" hint="Current position">
		<cfargument name="editMode" type="boolean" required="false" default="true" hint="Determines whether edit handlers are shown">
        <cfargument name="required" type="boolean" required="false" default="true" hint="Determines whether required field or not">
        <cfargument name="trigger" type="string" required="false" hint="Name of a javascript function called on change" default="">
        
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
        <cfset local.players = getFactory().get("leagueplayers").model.getReportPlayers()>

		<cfif Len(arguments.value)>
			<cfset local.value = arguments.value>
		<cfelse>
			<cfset local.value = "">
		</cfif>

		<!--- build array of structs dataset to use in inputSelect --->
		<cfset local.data = ArrayNew(1)>
		<cfloop query="local.players">
        	<cfset local.str = {label="#firstname#-#lastname#", value=playerID}>
            <cfset ArrayAppend(local.data, local.str)>
		</cfloop>
		
		<cfset local.result.output = inputSelect(selectid="#arguments.selectid#", label="#arguments.label#",
				required=arguments.required, data=local.data, value=local.value, editMode=arguments.editMode, novalue="Any Player").output>

		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="matchReport" access="public" returntype="struct" hint="Display handler to print out match drop-down list block">
		<cfargument name="selectid" type="string" required="false" default="match1">
		<cfargument name="label" type="string" required="false" default="Match 1">
		<cfargument name="value" type="string" required="false" hint="Current Match">
		<cfargument name="editMode" type="boolean" required="false" default="true" hint="Determines whether edit handlers are shown">
        <cfargument name="required" type="boolean" required="false" default="true" hint="Determines whether required field or not">
        <cfargument name="trigger" type="string" required="false" hint="Name of a javascript function called on change" default="">
        
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
        <cfset local.matches = getFactory().get("leaguematches").model.getMyMatches()>

		<cfif Len(arguments.value)>
			<cfset local.value = arguments.value>
		<cfelse>
			<cfset local.value = "">
		</cfif>

		<!--- build array of structs dataset to use in inputSelect --->
		<cfset local.datam = ArrayNew(1)>
		<cfloop query="local.matches">
        	<cfset local.str = {label="Match vs #opponentName# on #dateformat(matchdate,"dd/mm/yy")#", value=matchID}>
            <cfset ArrayAppend(local.datam, local.str)>
		</cfloop>
		
		<cfset local.result.output = inputSelect(selectid="#arguments.selectid#", label="#arguments.label#",
				required=arguments.required, data=local.datam, value=local.value, editMode=arguments.editMode, novalue="Please Select").output>
        
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="periodCoveredReportBlock" access="public" returntype="struct" hint="Generates the period covered block of code">
		<cfargument name="periodCovered" type="string" required="true" hint="The value of the periodCovered drop-down list">
		<cfargument name="seasonFrom" type="string" required="true" hint="The value of the seasonFrom drop-down list">
        <cfargument name="seasonTo" type="string" required="true" hint="The value of the seasonTo drop-down list">
        <cfargument name="roundFrom" type="string" required="true" hint="The value of the roundFrom drop-down list">
        <cfargument name="roundTo" type="string" required="true" hint="The value of the roundTo drop-down list">
        <cfargument name="dateFrom" type="string" required="true" hint="The value of the dateFrom drop-down list">
        <cfargument name="dateTo" type="string" required="true" hint="The value of the dateTo drop-down list">
		
        <cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

		<cfset local.data = ArrayNew(1)>
		<cfset local.str = {label="All", value=""}>
        <cfset ArrayAppend(local.data, local.str)>
		<cfset local.str = {label="Current Season", value="Current Season"}>
        <cfset ArrayAppend(local.data, local.str)>
        <cfset local.str = {label="Set of Seasons", value="Set of Seasons"}>
        <cfset ArrayAppend(local.data, local.str)>
        <cfset local.str = {label="Set of Rounds (from Current Season)", value="Set of Rounds"}>
        <cfset ArrayAppend(local.data, local.str)>
        <cfset local.str = {label="Set of Dates", value="Set of Dates"}>
        <cfset ArrayAppend(local.data, local.str)>
                                
		<cfsavecontent variable="local.result.output">
			<cfoutput>
			#display(method="inputSelect",selectid="periodCovered", label="Period Covered",
			 data=local.data, value=arguments.periodCovered, novalue="Select a Team").output#
                        
                <div id="setofSeasons" style="display:none">
                #display(method="setofSeasons",seasonFrom=arguments.seasonFrom, seasonTo=arguments.seasonTo, editMode=true).output#
                </div>
                
                <div id="setofRounds" style="display:none">
                #display(method="setofRounds",roundFrom=arguments.roundFrom, roundTo=arguments.roundTo, editMode=true).output#
                </div>
                
                <div id="setofDates" style="display:none">
                #display(method="setofDates",dateFrom=arguments.dateFrom, dateTo=arguments.dateTo, editMode=true).output#
                </div>
                
				<script type="text/javascript">
					 $(document).ready(function() {
                        $("##periodCovered").on("change", function(){ 
                            var selperiodCovered = $(this).val();
							if (selperiodCovered == "")
							{
								$("##setofSeasons").hide();
								$("##setofRounds").hide();
								$("##setofDates").hide();
							}
							if (selperiodCovered == "Current Season")
							{
								$("##setofSeasons").hide();
								$("##setofRounds").hide();
								$("##setofDates").hide();
							}
							if (selperiodCovered == "Set of Seasons")
							{
								$("##setofSeasons").show();
								$("##setofRounds").hide();
								$("##setofDates").hide();
							}
							if (selperiodCovered == "Set of Rounds")
							{
								$("##setofSeasons").hide();
								$("##setofRounds").show();
								$("##setofDates").hide();
							}
							if (selperiodCovered == "Set of Dates")
							{
								$("##setofSeasons").hide();
								$("##setofRounds").hide();
								$("##setofDates").show();
							}
                        });
                    });
				</script>
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>
        
    <cffunction name="setofSeasons" access="public" returntype="struct" hint="Display handler to print out seasonfrom and seasonto drop-down lists">
		<cfargument name="seasonFrom" type="string" required="true" hint="The value of the seasonFrom drop-down list">
        <cfargument name="seasonTo" type="string" required="true" hint="The value of the seasonTo drop-down list">
		<cfargument name="editMode" type="boolean" required="false" default="true" hint="Determines whether edit handlers are shown">
        
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
        <cfset local.firstseason = getFactory().get("LeagueReports").model.getFirstSeason()>        
        <cfset local.lastseason = getFactory().get("LeagueReports").model.getLastSeason()>  

		<!--- build array of structs dataset to use in inputSelect --->
		<cfset local.dataseasons = ArrayNew(1)>
		<cfloop from="#local.firstseason#" to="#local.lastseason#" index="local.option">
			<cfset local.str = {label=local.option, value=local.option}>
			<cfset ArrayAppend(local.dataseasons, local.str)>
		</cfloop>
        
		<cfsavecontent variable="local.result.output">
			<cfoutput>
				#display(method="inputSelect",selectid="seasonFrom", label="From",
			 data=local.dataseasons, value=arguments.seasonFrom, novalue="Please Select").output#

				#display(method="inputSelect",selectid="seasonTo", label="To",
			 data=local.dataseasons, value=arguments.seasonTo, novalue="Please Select").output#
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="setofRounds" access="public" returntype="struct" hint="Display handler to print out roundFrom and roundTo drop-down lists">
		<cfargument name="roundFrom" type="string" required="true" hint="The value of the roundFrom drop-down list">
        <cfargument name="roundTo" type="string" required="true" hint="The value of the roundTo drop-down list">
		<cfargument name="editMode" type="boolean" required="false" default="true" hint="Determines whether edit handlers are shown">
        
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        
        <cfset local.firstround = getFactory().get("LeagueReports").model.getFirstRound()>        
        <cfset local.lastround = getFactory().get("LeagueReports").model.getLastRound()>  

		<!--- build array of structs dataset to use in inputSelect --->
		<cfset local.datarounds = ArrayNew(1)>
		<cfloop from="#local.firstround#" to="#local.lastround#" index="local.option">
			<cfset local.str = {label=local.option, value=local.option}>
			<cfset ArrayAppend(local.datarounds, local.str)>
		</cfloop>
	
		<cfsavecontent variable="local.result.output">
			<cfoutput>
				<div id="roundFromInvalid" style="display:none; color:red;"></div>
				#display(method="inputSelect",selectid="roundFrom", label="From",
			 data=local.datarounds, value=arguments.roundFrom, novalue="Please Select").output#
                        
				#display(method="inputSelect",selectid="roundTo", label="To",
			 data=local.datarounds, value=arguments.roundTo, novalue="Please Select").output#
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="setofDates" access="public" returntype="struct" hint="Display handler to print out roundFrom and roundTo drop-down lists">
		<cfargument name="dateFrom" type="string" required="true" hint="The value of the dateFrom drop-down list">
        <cfargument name="dateTo" type="string" required="true" hint="The value of the dateTo drop-down list">
		<cfargument name="editMode" type="boolean" required="false" default="true" hint="Determines whether edit handlers are shown">
        
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		        		
		<cfsavecontent variable="local.result.output">
			<cfoutput>
				<div id="dateFromInvalid" style="display:none; color:red;"></div>
				 #getFactory().get("formFactory").view.display(method="inputDate", id="dateFrom", label="Date From", value=arguments.dateFrom).output#
				<div id="dateToInvalid" style="display:none; color:red;"></div>
				#getFactory().get("formFactory").view.display(method="inputDate", id="dateTo", label="Date To", value=arguments.dateTo).output#
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>
    
</cfcomponent>