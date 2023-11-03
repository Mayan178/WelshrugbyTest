<cfcomponent name="home" extends="parent" hint="View for home">
	<cffunction name="init" returntype="home" access="public">
		<cfset var local = structNew()>

		<cfset super.init()>
		<cfreturn this/>
	</cffunction>

	<cffunction name="default" access="public" returntype="struct" hint="Default view for the home component">
		<cfargument name="data" type="struct" required="true">
		
		<cfset var local = structNew()>

		<cfset local.result = getFactory().getResult()>
        
        <cfset local.listofPlayers = "">
        <cfloop query="arguments.data.top10CSR">
			<cfset local.listofPlayers = listappend(local.listofPlayers,playerid)>
		</cfloop>
        <cfset local.lastPlayer = listlast(local.listofPlayers)>
        
        <cfsavecontent variable="local.result.output">
			<cfoutput>
                <div id="top10">
            	<!---intro text --->
				<div id="introductorytext">Latest News:</div>
                <br />
				<strong>#dateformat(now(),"dd/mm/yy")#:</strong> You now have #getFactory().get("leagueplayers").model.getAllPlayers().recordcount# players on your League side!<br/>
                <br />
				<br />
                <cfif arguments.data.top10CSR.recordcount>
					<h4>Top 10 CSR Players</h4>
				</cfif>
                <div class="container-fluid w-100">
					<cfloop query="arguments.data.top10CSR">
						<!--- PLAYER INDIVIDUAL INFO --->
						#getFactory().get("leagueplayers").view.individualPlayer( BRplayerID=BRplayerID,playerID=playerID,firstName=firstName,nickName=nickName,lastname=lastname,CSR=CSR,weight=weight,height=height,age=age,top1=top1,top2=top2,top3=top3,top4=top4,best1=best1,best2=best2,best3=best3,best4=best4,shortversion=true,best5=best5,shortversion=true,caneditDelete=true,country=country,injured=injured).output#
						<!--- END OF PLAYER INDIVIDUAL INFO --->   
					</cfloop>
				</div>
            	</div>    
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction> 
   
    <cffunction name="fadingNews" access="public" returntype="struct" hint="">
		<cfargument name="title" type="string" required="true" hint="Title to be displayed as the header of the div">
		<cfargument name="id" type="string" required="true" hint="ID of the DIV - needs to be unique">
		<cfargument name="xmlUrl" type="string" required="true" hint="Absolute OR Relative - retrieval done server-side so no proxy needed. This MUST be an RSS feed">
		<cfargument name="width" type="string" required="false" default="150px">
		<cfargument name="height" type="string" required="false" default="100px">

		<!--- Combination of best-practice and my normal-practice --->

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

		<!--- Determine the absolute URL from the relative URL if necessary--->

		<cfset local.xmlUrl = "http://www.wru.co.uk/wrugeneralnews.xml">
		
		<cfset local.result.success = true>

		<cftry>
			<cfhttp url="#local.xmlUrl#" method="get" result="local.xmlRaw" timeout="5" throwonerror="true"/>
			
			<cfset local.xmlData = XmlParse(local.xmlRaw.fileContent)>

			<cfset local.data = getFactory().get("dataTypeConvert").util.xmlToStruct(local.xmlData).rss.channel.item>

			<cfsavecontent variable="local.result.output">
				<cfoutput>
					<div id="#arguments.id#" style="width:#arguments.width#;height:#arguments.height#">
						<h2>#arguments.title#</h2>
						<div id="#arguments.id#-non-js">
							<cfloop from="1" to="#arrayLen(local.data)#" index="local.i">
								<h3>#local.data[local.i].title# : <em>#DateFormat(local.data[local.i].pubDate, "dd mmmm yyyy")#</em></h3>
                                <div id="newsmore">
                                <a href="#local.data[local.i].link#" target="_blank">Read more&nbsp;&gt;&gt;</a>
                                </div>
                                <br /><br />
							</cfloop>
						</div>
						<div id="#arguments.id#-js" style="display:none">
							<cfloop from="1" to="#arrayLen(local.data)#" index="local.i">
								<div id="#arguments.id#-story-#local.i#" style="display:none">
									<h3>#local.data[local.i].title# : <nobr><em>#DateFormat(local.data[local.i].pubDate, "dd mmmm yyyy")#</em></nobr></h3>
									<div id="newsmore">
                                    <a href="#local.data[local.i].link#" target="_blank"><strong>Read more&nbsp;&gt;&gt;</strong></a>
                                    </div>
                                    <br /><br />
								</div>
							</cfloop>
						</div>
						<div class="clear"></div>
					</div>
					<script type="text/javascript">
						Element.hide('#arguments.id#-non-js');
						Element.show('#arguments.id#-js');
						rssTickerContent = Array(#arrayLen(local.data)#);
						rssTickerStart(1);

						function rssTickerStart(id) {
							if (id > 1) {
								Effect.Fade('#arguments.id#-story-' + (id-1));
							} else if (id == 0) {
								Effect.Fade('#arguments.id#-story-' + #arrayLen(local.data)#);
								id = id + 1;
							}
							setTimeout(function() {
								Effect.Appear('#arguments.id#-story-'+id);
							}, 1000); <!--- this is a pause between fade out and fade in --->
							if (id == #arrayLen(local.data)#)
								nextId = 0;
							else
								nextId = id+1;
							setTimeout('rssTickerStart(' + nextId + ')',7000); <!--- this is how long it waits with a news item visible --->
						}
					</script>
				</cfoutput>
			</cfsavecontent>

			<cfcatch type="any">
				<cfset local.result.success = false>
			</cfcatch>
		</cftry>

		<cfreturn local.result>

	</cffunction>
   
</cfcomponent>