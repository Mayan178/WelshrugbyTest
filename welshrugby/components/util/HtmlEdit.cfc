<cfcomponent name="htmlEdit" output="false" hint="Create an instance of the FCKeditor">
	<!--- Mix of FCK supplied functions and wrapper-functions --->

	<cfset variables.debug = false>
	
	<!--- START FUNCTIONS --->
	<cffunction name="init" access="public" returntype="htmlEdit">
		<cfreturn this/>
	</cffunction>

	<cffunction name="wysiwyg" access="public" returntype="string">
		<cfargument name="name" type="string" required="true">
		<cfargument name="value" type="string" required="false" default="">
		<cfargument name="width" type="string" required="false" default="730">
		<cfargument name="height" type="numeric" required="false" default="400">

		<cfset var local = structNew()>

		<cfset local.basePath = "/fckeditor/">
		<cfset local.basePath = "/fckeditor_2_6_1/">
		<cfset this.instanceName = arguments.name>
		<cfset this.value = arguments.value>
		<cfset this.basePath = local.basePath>
		<cfset this.width = arguments.width>
		<cfset this.height = arguments.height>
		<cfset this.ToolbarSet = "NoneBasic">
        
		<cfsavecontent variable="local.output">
			<cfoutput>#create()#</cfoutput>
		</cfsavecontent>
		<cfreturn local.output>
	</cffunction>

    <cffunction name="shortWysiwyg" access="public" returntype="string">
		<cfargument name="name" type="string" required="true">
		<cfargument name="value" type="string" required="false" default="">
		<cfargument name="width" type="string" required="false" default="300">
		<cfargument name="height" type="numeric" required="false" default="100">

		<cfset var local = structNew()>

		<cfset local.basePath = "/fckeditor/">
		<cfset this.instanceName = arguments.name>
		<cfset this.value = arguments.value>
		<cfset this.basePath = local.basePath>
		<cfset this.width = arguments.width>
		<cfset this.height = arguments.height>
		<cfset this.ToolbarSet = "ShortBasic">
		<cfsavecontent variable="local.output">
			<cfoutput>#create()#</cfoutput>
		</cfsavecontent>
		<cfreturn local.output>
	</cffunction>

	<!--- END OF FUNCTIONS--->
	
	<!--- START OF FCK-supplied FUNCTIONS --->
	<cffunction name="Create" access="public" output="true" returntype="void" hint="Outputs the editor HTML in the place where the function is called">
		<cfoutput>#CreateHtml()#</cfoutput>
	</cffunction>

	<cffunction name="CreateHtml" access="public" output="false" returntype="string" hint="Retrieves the editor HTML">
		<cfparam name="this.instanceName" type="string" />
		<cfparam name="this.width" type="string" default="100%" />
		<cfparam name="this.height" type="string" default="200" />
		<cfparam name="this.toolbarSet" type="string" default="Default" />
		<cfparam name="this.value" type="string" default="" />
		<cfparam name="this.basePath" type="string" default="/fckeditor/" />
		<cfparam name="this.checkBrowser" type="boolean" default="true" />
		<cfparam name="this.config" type="struct" default="#structNew()#" />
	
		<cfscript>
			// display the html editor or a plain textarea?
			if( isCompatible() )
				return getHtmlEditor();
			else
				return getTextArea();
		</cfscript>
	</cffunction>

	<cffunction name="isCompatible"
		access="private"
		output="false"
		returnType="boolean"
		hint="Check browser compatibility via HTTP_USER_AGENT, if checkBrowser is true"
	>
		<cfscript>
			var sAgent = lCase( cgi.HTTP_USER_AGENT );
			var stResult = "";
			var sBrowserVersion = "";
		
			// do not check if argument "checkBrowser" is false
			if( not this.checkBrowser )
				return true;
		
			return FCKeditor_IsCompatibleBrowser();
		</cfscript>
	</cffunction>

	<cffunction name="getTextArea" access="private" output="false" returnType="string" hint="Create a textarea field for non-compatible browsers.">
		<cfset var result = "" />
		<cfset var sWidthCSS = "" />
		<cfset var sHeightCSS = "" />
	
		<cfscript>
			if( Find( "%", this.width ) gt 0)
				sWidthCSS = this.width;
			else
				sWidthCSS = this.width & "px";
		
			if( Find( "%", this.width ) gt 0)
				sHeightCSS = this.height;
			else
				sHeightCSS = this.height & "px";
		
			result = "<textarea name=""#this.instanceName#"" rows=""4"" cols=""40"" style=""width: #sWidthCSS#; height: #sHeightCSS#"">#HTMLEditFormat(this.value)#</textarea>" & chr(13) & chr(10);
		</cfscript>
		<cfreturn result />
	</cffunction>

	<cffunction name="getHtmlEditor" access="private" output="false" returnType="string" hint="Create the html editor instance for compatible browsers.">
		<cfset var sURL = "" />
		<cfset var result = "" />
	
		<cfscript>
			// try to fix the basePath, if ending slash is missing
			if( len( this.basePath) and right( this.basePath, 1 ) is not "/" )
				this.basePath = this.basePath & "/";
		
			// construct the url
			sURL = this.basePath & "editor/fckeditor.html?InstanceName=" & this.instanceName;
		
			// append toolbarset name to the url
			if( len( this.toolbarSet ) )
				sURL = sURL & "&amp;Toolbar=" & this.toolbarSet;
		</cfscript>
		
		<cfscript>
			result = result & "<input type=""hidden"" id=""#this.instanceName#"" name=""#this.instanceName#"" value=""#HTMLEditFormat(this.value)#"" style=""display:none"" />" & chr(13) & chr(10);
			result = result & "<input type=""hidden"" id=""#this.instanceName#___Config"" value=""#GetConfigFieldString()#"" style=""display:none"" />" & chr(13) & chr(10);
			result = result & "<iframe id=""#this.instanceName#___Frame"" src=""#sURL#"" width=""#this.width#"" height=""#this.height#"" frameborder=""0"" scrolling=""no""></iframe>" & chr(13) & chr(10);
		</cfscript>

		<cfreturn result />
	</cffunction>

	<cffunction name="GetConfigFieldString" access="private" output="false" returnType="string" hint="Create configuration string: Key1=Value1&Key2=Value2&... (Key/Value:HTML encoded)">
		<cfset var sParams = "" />
		<cfset var key = "" />
		<cfset var fieldValue = "" />
		<cfset var fieldLabel = "" />
		<cfset var lConfigKeys = "" />
		<cfset var iPos = "" />
	
		<cfscript>
		/**
		 * CFML doesn't store casesensitive names for structure keys, but the configuration names must be casesensitive for js.
		 * So we need to find out the correct case for the configuration keys.
		 * We "fix" this by comparing the caseless configuration keys to a list of all available configuration options in the correct case.
		 * changed 20041206 hk@lwd.de (improvements are welcome!)
		 */
		lConfigKeys = lConfigKeys & "CustomConfigurationsPath,EditorAreaCSS,ToolbarComboPreviewCSS,DocType";
		lConfigKeys = lConfigKeys & ",BaseHref,FullPage,Debug,AllowQueryStringDebug,SkinPath";
		lConfigKeys = lConfigKeys & ",PreloadImages,PluginsPath,AutoDetectLanguage,DefaultLanguage,ContentLangDirection";
		lConfigKeys = lConfigKeys & ",ProcessHTMLEntities,IncludeLatinEntities,IncludeGreekEntities,ProcessNumericEntities,AdditionalNumericEntities";
		lConfigKeys = lConfigKeys & ",FillEmptyBlocks,FormatSource,FormatOutput,FormatIndentator";
		lConfigKeys = lConfigKeys & ",StartupFocus,ForcePasteAsPlainText,AutoDetectPasteFromWord,ForceSimpleAmpersand";
		lConfigKeys = lConfigKeys & ",TabSpaces,ShowBorders,SourcePopup,ToolbarStartExpanded,ToolbarCanCollapse";
		lConfigKeys = lConfigKeys & ",IgnoreEmptyParagraphValue,FloatingPanelsZIndex,TemplateReplaceAll,TemplateReplaceCheckbox";
		lConfigKeys = lConfigKeys & ",ToolbarLocation,ToolbarSets,EnterMode,ShiftEnterMode,Keystrokes";
		lConfigKeys = lConfigKeys & ",ContextMenu,BrowserContextMenuOnCtrl,FontColors,FontNames,FontSizes";
		lConfigKeys = lConfigKeys & ",FontFormats,StylesXmlPath,TemplatesXmlPath,SpellChecker,IeSpellDownloadUrl";
		lConfigKeys = lConfigKeys & ",SpellerPagesServerScript,FirefoxSpellChecker,MaxUndoLevels,DisableObjectResizing,DisableFFTableHandles";
		lConfigKeys = lConfigKeys & ",LinkDlgHideTarget,LinkDlgHideAdvanced,ImageDlgHideLink,ImageDlgHideAdvanced,FlashDlgHideAdvanced";
		lConfigKeys = lConfigKeys & ",ProtectedTags,BodyId,BodyClass,DefaultLinkTarget,CleanWordKeepsStructure";
		lConfigKeys = lConfigKeys & ",LinkBrowser,LinkBrowserURL,LinkBrowserWindowWidth,LinkBrowserWindowHeight,ImageBrowser";
		lConfigKeys = lConfigKeys & ",ImageBrowserURL,ImageBrowserWindowWidth,ImageBrowserWindowHeight,FlashBrowser,FlashBrowserURL";
		lConfigKeys = lConfigKeys & ",FlashBrowserWindowWidth,FlashBrowserWindowHeight,LinkUpload,LinkUploadURL,LinkUploadWindowWidth";
		lConfigKeys = lConfigKeys & ",LinkUploadWindowHeight,LinkUploadAllowedExtensions,LinkUploadDeniedExtensions,ImageUpload,ImageUploadURL";
		lConfigKeys = lConfigKeys & ",ImageUploadAllowedExtensions,ImageUploadDeniedExtensions,FlashUpload,FlashUploadURL,FlashUploadAllowedExtensions";
		lConfigKeys = lConfigKeys & ",FlashUploadDeniedExtensions,SmileyPath,SmileyImages,SmileyColumns,SmileyWindowWidth,SmileyWindowHeight";
	
		for( key in this.config )
		{
			iPos = listFindNoCase( lConfigKeys, key );
			if( iPos GT 0 )
			{
				if( len( sParams ) )
					sParams = sParams & "&amp;";
	
				fieldValue = this.config[key];
				fieldName = listGetAt( lConfigKeys, iPos );
	
				// set all boolean possibilities in CFML to true/false values
				if( isBoolean( fieldValue) and fieldValue )
					fieldValue = "true";
				else if( isBoolean( fieldValue) )
					fieldValue = "false";
	
				sParams = sParams & HTMLEditFormat( fieldName ) & '=' & HTMLEditFormat( fieldValue );
			}
		}
		return sParams;
		</cfscript>
	
	</cffunction>

	<cffunction name="FCKeditor_IsCompatibleBrowser" returntype="boolean" access="public" hint="This function came from fckutils.cfm">
		<cfset var local = structNew()>
		<cfscript>
			local.sAgent = lCase( cgi.HTTP_USER_AGENT );
			local.isCompatibleBrowser = false;
		
			// check for Internet Explorer ( >= 5.5 )
			if( find( "msie", local.sAgent ) and not find( "mac", local.sAgent ) and not find( "opera", local.sAgent ) )
			{
				// try to extract IE version
				local.stResult = reFind( "msie ([5-9]\.[0-9])", local.sAgent, 1, true );
				if( arrayLen( local.stResult.pos ) eq 2 )
				{
					// get IE Version
					local.sBrowserVersion = mid( local.sAgent, local.stResult.pos[2], local.stResult.len[2] );
					if( local.sBrowserVersion GTE 5.5 )
						local.isCompatibleBrowser = true;
				}
			}
			// check for Gecko ( >= 20030210+ )
			else if( find( "gecko/", local.sAgent ) )
			{
				// try to extract Gecko version date
				local.stResult = reFind( "gecko/(200[3-9][0-1][0-9][0-3][0-9])", local.sAgent, 1, true );
				if( arrayLen( local.stResult.pos ) eq 2 )
				{
					// get Gecko build (i18n date)
					local.sBrowserVersion = mid( local.sAgent, local.stResult.pos[2], local.stResult.len[2] );
					if( local.sBrowserVersion GTE 20030210 )
						local.isCompatibleBrowser = true;
				}
			}
			else if( find( "opera/", local.sAgent ) )
			{
				// try to extract Opera version
				local.stResult = reFind( "opera/([0-9]+\.[0-9]+)", local.sAgent, 1, true );
				if( arrayLen( local.stResult.pos ) eq 2 )
				{
					if ( mid( local.sAgent, local.stResult.pos[2], local.stResult.len[2] ) gte 9.5)
						local.isCompatibleBrowser = true;
				}
			}
			else if( find( "applewebkit", local.sAgent ) )
			{
				// try to extract Gecko version date
				local.stResult = reFind( "applewebkit/([0-9]+)", local.sAgent, 1, true );
				if( arrayLen( local.stResult.pos ) eq 2 )
				{
					if( mid( local.sAgent, local.stResult.pos[2], local.stResult.len[2] ) gte 522 )
						local.isCompatibleBrowser = true;
				}
			}
			return local.isCompatibleBrowser;
		</cfscript>
	</cffunction>
	<!--- END OF FCK-supplied FUNCTIONS --->

</cfcomponent>