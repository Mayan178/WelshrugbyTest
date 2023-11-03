<cfcomponent name="template" extends="parent" hint="Site template">

	<cffunction name="init" returntype="template" access="public">
		<cfset super.init()>

		<!--- load file-based xml into this CFC--->
		<cfset local.cfcPath = getDirectoryFromPath(getCurrentTemplatePath())>
		<cffile action="read" file="#local.cfcPath#..\..\config\#application.core.get('configFolder')#\Template.xml" variable="local.rawData">
		<cfset local.xml = xmlParse(local.rawData)>

		<!--- load into config --->
		<cfset variables.config = structNew()>
		<cfset variables.config.templates = structNew()>
		<cfset variables.config.templateOrder = "">
		<cfloop from="1" to="#ArrayLen(local.xml.templates.template)#" index="local.i">
			<cfset local.template = structNew()>
			<cfset local.name = local.xml.templates.template[local.i].xmlAttributes.name>

			<cfset local.template.containerOrder = "">
			<cfset local.template.containers = StructNew()>
			<cfloop from="1" to="#ArrayLen(local.xml.templates.template[local.i].container)#" index="local.c">
				<cfset StructInsert(local.template.containers, local.xml.templates.template[local.i].container[local.c].xmlAttributes.name, local.xml.templates.template[local.i].container[local.c].xmlAttributes.hint)>
				<cfset local.template.containerOrder = ListAppend(local.template.containerOrder, local.xml.templates.template[local.i].container[local.c].xmlAttributes.name)>
			</cfloop>
			
			<cfset StructInsert(variables.config.templates, local.name, local.template)>
			<cfset variables.config.templateOrder = ListAppend(variables.config.templateOrder, local.name)>
		</cfloop>

		<cfreturn this/>
	</cffunction>
    
    <!--- template used only for the login page --->
    <cffunction name="default" returntype="struct" access="public" hint="Defining whether user sees loging page or homepage">
		<cfargument name="data" type="struct" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
        <!--- if the user is logged in --->
        <cfif NOT getFactory().get("login").model.isLoggedIn()>
			<cfset local.result.output = login(arguments.data).output>
        <!--- if the user is not logged in --->
        <cfelse>
        	<cfset local.result.output = home(arguments.data).output>
        </cfif>

		<cfreturn local.result>
	</cffunction>

    <!--- template used only for the login page --->
    <cffunction name="login" returntype="struct" access="public" hint="Layout for the login page">
		<cfargument name="data" type="struct" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

		<cfsavecontent variable="local.result.output">
				<cfoutput>
					#defaultLoginHeader(arguments.data).output#
					<!--- content of the login template --->
                    <div class="container-fluid">

                        <!--- default image for the login page --->
                        <div class="container-fluid text-center mb-0 py-5" style="border-bottom: 4px solid ##000000;">
                            <div class="container">
                                <img src="/res/img/logos/default.jpg" class="img-fluid" alt="Login">
                            </div>
                        </div>
                        <!--- end of default image for the login page --->

                        <!--- container for the top bar --->
                        <div class="container-fluid mt-1 pt-0" style="background-color:##000000;">
                           <div class="row">
                                <div class="col pl-md-10">
                                    <div class="text-start text-white">#dateformat(now(),'dd mmmm yyyy')#</div>
                                </div>
                                <div class="col pr-md-10">
                                    &nbsp;
                                </div>
                            </div>
                        </div>
                        <!--- end of container for the top bar --->

                        <div class="container-fluid" style="border:1px solid ##000000;">          
                             <div class="row">
                                <!--- main content on the left --->                      
                                <div class="col-sm-8 col-md-6 col-lg-6 col-xl-6 mx-20" id="mainloginleft">
                                    <div class="login-form">
                                        <cfif Len(arguments.data.main.title)>
                                            <h3>#arguments.data.main.title#</h3>
                                        </cfif>
                                        <!--- form section...what will come from the login component --->
                                        #arguments.data.main.output#
                                    </div>
                                </div>
                                <!--- side info on the right --->
                                <div class="col-sm-4 col-md-6 col-lg-6 col-xl-6 pl-ml-20 text-end" id="mainloginright">
                                    <p>
                                        <strong>If you have any questions, get in touch!</strong>
                                        <br /><br />
                                        <a href="mailto:salle_marie@hotmail.com">my email</a>
                                    </p>  
                                </div>
                            </div>
                        </div>
                    </div>
					#defaultFooter().output#
				</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>    
        
    <cffunction name="branding" returntype="struct" access="public" hint="Returning branding for current view">
		<cfargument name="data" type="struct" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
        <cfsavecontent variable="local.result.logo">
            <cfoutput>
                <img src="/res/img/logos/league/#getFactory().get("session").model.get("siteLogo")#" class="img-fluid" alt="League">
            </cfoutput>
        </cfsavecontent>

            <cfset local.result.colour = "##4966A6">

		<cfreturn local.result>
	</cffunction>

    <cffunction name="adminLinks" returntype="struct" access="public" hint="Returning any Admin side links the user is allowed to see">
		<cfargument name="data" type="struct" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        
            <cfsavecontent variable="local.result.output">
                <cfif getFactory().get('login').model.getUser().user.securityLevelID gte 4>
                    <cfoutput>
                    <div id="mainrightadmin">
                        <h4>Admin</h4>
                        <div class="mainrightadminlastlink"><a href="/user/showUsers">View Users</a></div>
                    </div>
                    </cfoutput>
                </cfif>  
            </cfsavecontent>
        
		<cfreturn local.result>
	</cffunction>

    <cffunction name="quickLinks" returntype="struct" access="public" hint="Returning any quick side links the user is allowed to see">
		<cfargument name="data" type="struct" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        
        <cfsavecontent variable="local.result.output">
            <cfoutput>
                <div id="mainrightquick">
                    <h4>Quick Links</h4>
                    <div class="mainrightquicklink"><a href="/leagueplayers/updatechanges">View Changes on last Update</a></div>
                    <div class="mainrightquicklink"><a href="/leagueplayers">View All Players</a></div>
                    <div class="mainrightquicklink"><a href="/leagueplayers/search">Search for Players</a></div>
                    <div class="mainrightquicklink"><a href="/leaguematches/addMatch">Add a Match</a></div> 
                    <div class="mainrightquicklink"><a href="/leagueteams/addTeam">Add a Team</a></div>  
                </div>
            </cfoutput>
        </cfsavecontent>
        
		<cfreturn local.result>
	</cffunction>

    <cffunction name="personalLinks" returntype="struct" access="public" hint="Returning any personal side links the user is allowed to see">
		<cfargument name="data" type="struct" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        
        <cfsavecontent variable="local.result.output">
            <cfoutput>
                <div id="mainrightpersonal">
                    <h4>Personal Details</h4>
                    <div class="mainrightpersonallink"><a href="/user/profile">My Details</a></div>
                    <div class="mainrightpersonallastlink"><a href="/leagueteams/myteams">My Teams</a></div>
                    <div class="mainrightpersonallastlink"><a href="/leaguematches/mymatches">My Matches</a></div>
                    <div class="mainrightpersonallastlink"><a href="/leaguereports/myreports">My Reports</a></div>
                    <div class="mainrightadminlastlink"><a href="/leagueplayers/positionStats">Position Stats</a></div>
                </div>
            </cfoutput>
        </cfsavecontent>
        
		<cfreturn local.result>
	</cffunction>
    

	<!--- types of template --->
	<cffunction name="home" returntype="struct" access="public" hint="Displaying the homepage">
		<cfargument name="data" type="struct" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        <cfset local.last10Added = getFactory().get("leagueplayers").model.getlast10Added()>

        <cfset local.branding = branding(arguments.data)>

        <cfset local.adminLinks = adminLinks(arguments.data).output>
        <cfset local.quickLinks = quickLinks(arguments.data).output>
        <cfset local.personalLinks = personalLinks(arguments.data).output>        

		<cfsavecontent variable="local.result.output">
            <cfoutput>
                #defaultHeader(arguments.data).output#
                <!--- content of the home template --->
                <div class="container-fluid">
                    <!--- image matching league level --->
                    <div class="container-fluid text-center mb-0 py-5" style="border-bottom: 4px solid #local.branding.colour#; border-left: 1px solid #local.branding.colour#; border-right: 1px solid #local.branding.colour#; border-top: 1px solid #local.branding.colour#;">
                        <div class="container">
                            #local.branding.logo#
                        </div>
                    </div>
                    
                    <!--- container for the navigation bar --->
                    <div class="container-fluid mt-1 pt-0" style="background-color:#local.branding.colour#;">
                        <div class="row">
                            <div class="col pl-md-10 w-80">
                                <div class="text-start text-white">#dateformat(now(),'dd mmmm yyyy')#</div>
                            </div>
                            <div class="col pr-md-10  w-20 text-end">
                                <cfif getFactory().get("login").model.isLoggedIn()>
                                    <a class="text-end text-white text-decoration-none" href="/login/logout" title="Log Out">Log Out</a>
                                </cfif>
                            </div>
                        </div>
                    </div>
                    <!--- end of container for the navigation bar --->
                
                    <div class="container-fluid" style="border:1px solid #local.branding.colour#;">
                        <!--- display breadcrumb navigation --->
                        <div class="container-fluid w-100 px-0 mx-0 my-2">
                        #display(method="bcrumb", encoded=arguments.data.main.breadcrumb).output#
                        </div>
                        <!--- end of breadcrumb navigation --->

                        <!--- main content of page --->
                        <div class="row text-start">
                            <div class="col-sm-8 col-md-6 col-lg-7 col-xl-9 pl-ml-20 float-started">
                                    <cfif Len(arguments.data.main.title)>
                                    <h3>#arguments.data.main.title#</h3>
                                </cfif>
                                    #arguments.data.main.output#
                            </div>
                            
                            <div class="col-sm-auto col-md-auto col-lg-auto col-xl-auto mx-20 float-end">
                                <div class="text-start admin-side-link">
                                    <!--- show Admin information if Admin rights --->
                                    <cfif getFactory().get('login').model.getUser().user.securityLevelID gte 4>
                                        #local.adminLinks#
                                    </cfif>    
                                    <!--- quick links --->
                                    #local.quickLinks#
                                    <!--- show personal details --->
                                    #local.personalLinks#
                                    <!--- NEWS --->
                                    <cfif getFactory().get("home").view.fadingNews("Rugby Union News", "homepageNews", "/home/rssfeed").success>
                                        <div align="center">
                                            <div id="homepageNewsWrapper" align="center">
                                                #getFactory().get("home").view.fadingNews("Rugby Union News", "homepageNews", "/home/rssfeed").output#
                                                <div class="clear"></div>
                                            </div>
                                        </div>
                                    </cfif>
                                    <!--- END OF NEWS --->
                                </div>
                            </div>
                        </div>                                    	
                    </div>
                </div>
                #defaultFooter().output#
            </cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>	
    
    <cffunction name="leagueplayers" returntype="struct" access="public" hint="Layout for any leagueplayers pages">
		<cfargument name="data" type="struct" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
        
        <cfset local.last10Added = getFactory().get("leagueplayers").model.getlast10Added()>

        <cfset local.branding = branding(arguments.data)>

        <cfset local.adminLinks = adminLinks(arguments.data).output>
        <cfset local.quickLinks = quickLinks(arguments.data).output>
        <cfset local.personalLinks = personalLinks(arguments.data).output>
        
		<cfsavecontent variable="local.result.output">
        	<cfif NOT arguments.data.main.restrictOutput>
				<cfoutput>
					#defaultHeader(arguments.data).output#
					<!--- content of the league players template --->
                    <div class="container-fluid">
                         <!--- image matching level chosen (national, league or under 20s ) --->
                        <div class="container-fluid text-center mb-0 py-5" style="border-bottom: 4px solid #local.branding.colour#; border-left: 1px solid #local.branding.colour#; border-right: 1px solid #local.branding.colour#; border-top: 1px solid #local.branding.colour#;">
                            <div class="container">
                                #local.branding.logo#
                            </div>
                        </div>
                        <!--- end of image matching level chosen (national, league or under 20s ) --->
                        <!--- container for the navigation bar --->
                        <div class="container-fluid mt-1 pt-0" style="background-color:#local.branding.colour#;">
                            <div class="row">
                                <div class="col pl-md-10 w-80">
                                    <div class="text-start text-white">#dateformat(now(),'dd mmmm yyyy')#</div>
                                </div>
                                <div class="col pr-md-10  w-20 text-end">
                                    <cfif getFactory().get("login").model.isLoggedIn()>
                                        <a class="text-end text-white text-decoration-none" href="/login/logout" title="Log Out">Log Out</a>
                                    </cfif>
                                </div>
                            </div>
                        </div>
                        <!--- end of container for the navigation bar --->
                                
                        <div class="container-fluid" style="border:1px solid #local.branding.colour#;">
                            <!--- display breadcrumb navigation --->
                            <div class="container-fluid w-100 px-0 mx-0 my-2">
                            #display(method="bcrumb", encoded=arguments.data.main.breadcrumb).output#
                            </div>
                            <!--- end of breadcrumb navigation --->

                            <div class="row text-start">
                                <div class="col-sm-8 col-md-6 col-lg-7 col-xl-9 pl-ml-20 float-started">
                                     <cfif Len(arguments.data.main.title)>
                                        <h3>#arguments.data.main.title#</h3>
                                    </cfif>
                                        #arguments.data.main.output#
                                </div>
                                
                                <div class="col-sm-auto col-md-auto col-lg-auto col-xl-auto mx-20 float-end">
                                    <div class="text-start admin-side-link">
                                        <!--- show Admin information if Admin rights --->
                                        <cfif getFactory().get('login').model.getUser().user.securityLevelID gte 4>
                                            #local.adminLinks#
                                        </cfif>    
                                        <!--- quick links --->
                                        #local.quickLinks#
                                        <!--- show personal details --->
                                        #local.personalLinks#
                                        <!--- NEWS --->
                                        <cfif getFactory().get("home").view.fadingNews("Rugby Union News", "homepageNews", "/home/rssfeed").success>
                                            <div align="center">
                                                <div id="homepageNewsWrapper" align="center">
                                                    #getFactory().get("home").view.fadingNews("Rugby Union News", "homepageNews", "/home/rssfeed").output#
                                                    <div class="clear"></div>
                                                </div>
                                            </div>
                                        </cfif>
                                        <!--- END OF NEWS --->
                                    </div>
                                </div>
                            </div>   
                        </div>
                    </div>
					#defaultFooter().output#
				</cfoutput>
            <cfelse>
            	<cfoutput>
                    #leagueDivHeader().output#
					#arguments.data.main.output#
                    #defaultFooter().output#
				</cfoutput>
        	</cfif>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>    
    
    <cffunction name="user" returntype="struct" access="public" hint="Layout for any user pages">
		<cfargument name="data" type="struct" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

        <cfset local.branding = branding(arguments.data)>

        <cfset local.adminLinks = adminLinks(arguments.data).output>
        <cfset local.quickLinks = quickLinks(arguments.data).output>
        <cfset local.personalLinks = personalLinks(arguments.data).output>
        
		<cfsavecontent variable="local.result.output">
        	<cfif NOT arguments.data.main.restrictOutput>
				<cfoutput>
					#defaultHeader(arguments.data).output#
					<!--- content of the user template --->
                    <div class="container-fluid">
                         <!--- image matching league level --->
                        <div class="container-fluid text-center mb-0 py-5" style="border-bottom: 4px solid #local.branding.colour#; border-left: 1px solid #local.branding.colour#; border-right: 1px solid #local.branding.colour#; border-top: 1px solid #local.branding.colour#;">
                            <div class="container">
                                #local.branding.logo#
                            </div>
                        </div>

                        <!--- container for the navigation bar --->
                        <div class="container-fluid mt-1 pt-0" style="background-color:#local.branding.colour#;">
                            <div class="row">
                                <div class="col pl-md-10 w-80">
                                    <div class="text-start text-white">#dateformat(now(),'dd mmmm yyyy')#</div>
                                </div>
                                <div class="col pr-md-10  w-20 text-end">
                                    <cfif getFactory().get("login").model.isLoggedIn()>
                                        <a class="text-end text-white text-decoration-none" href="/login/logout" title="Log Out">Log Out</a>
                                    </cfif>
                                </div>
                            </div>
                        </div>
                        <!--- end of container for the navigation bar --->

                        <div class="container-fluid" style="border:1px solid #local.branding.colour#;">
                            <!--- display breadcrumb navigation --->
                            <div class="container-fluid w-100 px-0 mx-0 my-2">
                            #display(method="bcrumb", encoded=arguments.data.main.breadcrumb).output#
                            </div>
                            <!--- end of breadcrumb navigation --->

                            <div class="row text-start">
                                <div class="col-sm-8 col-md-6 col-lg-7 col-xl-9 pl-ml-20 float-started">
                                     <cfif Len(arguments.data.main.title)>
                                        <h3>#arguments.data.main.title#</h3>
                                    </cfif>
                                        #arguments.data.main.output#
                                </div>
                                
                                <div class="col-sm-auto col-md-auto col-lg-auto col-xl-auto mx-20 float-end">
                                    <div class="text-start admin-side-link">
                                        <!--- show Admin information if Admin rights --->
                                        <cfif getFactory().get('login').model.getUser().user.securityLevelID gte 4>
                                            #local.adminLinks#
                                        </cfif>    
                                        <!--- quick links --->
                                        #local.quickLinks#
                                        <!--- show personal details --->
                                        #local.personalLinks#
                                        <!--- NEWS --->
                                        <cfif getFactory().get("home").view.fadingNews("Rugby Union News", "homepageNews", "/home/rssfeed").success>
                                            <div align="center">
                                                <div id="homepageNewsWrapper" align="center">
                                                    #getFactory().get("home").view.fadingNews("Rugby Union News", "homepageNews", "/home/rssfeed").output#
                                                    <div class="clear"></div>
                                                </div>
                                            </div>
                                        </cfif>
                                        <!--- END OF NEWS --->
                                    </div>
                                </div>
                            </div>   

                        </div>
                    </div>
					#defaultFooter().output#
				</cfoutput>
            <cfelse>
           		<cfoutput>
					#arguments.data.main.output#
				</cfoutput>
            </cfif>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="leagueteams" returntype="struct" access="public" hint="Layout for any leagueteams pages">
		<cfargument name="data" type="struct" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

        <cfset local.branding = branding(arguments.data)>

        <cfset local.adminLinks = adminLinks(arguments.data).output>
        <cfset local.quickLinks = quickLinks(arguments.data).output>
        <cfset local.personalLinks = personalLinks(arguments.data).output>

        
		<cfsavecontent variable="local.result.output">
        	<cfif NOT arguments.data.main.restrictOutput>
				<cfoutput>
					#defaultHeader(arguments.data).output#
					<!--- content of the league teams template --->
                    <div class="container-fluid">
                        
                        <!--- image matching league level --->
                        <div class="container-fluid text-center mb-0 py-5" style="border-bottom: 4px solid #local.branding.colour#; border-left: 1px solid #local.branding.colour#; border-right: 1px solid #local.branding.colour#; border-top: 1px solid #local.branding.colour#;">
                            <div class="container">
                                #local.branding.logo#
                            </div>
                        </div>
                        <!--- container for the navigation bar --->
                        <div class="container-fluid mt-1 pt-0" style="background-color:#local.branding.colour#;">
                            <div class="row">
                                <div class="col pl-md-10 w-80">
                                    <div class="text-start text-white">#dateformat(now(),'dd mmmm yyyy')#</div>
                                </div>
                                <div class="col pr-md-10  w-20 text-end">
                                    <cfif getFactory().get("login").model.isLoggedIn()>
                                        <a class="text-end text-white text-decoration-none" href="/login/logout" title="Log Out">Log Out</a>
                                    </cfif>
                                </div>
                            </div>
                        </div>
                        <!--- end of container for the navigation bar --->
                    
                        <div class="container-fluid" style="border:1px solid #local.branding.colour#;">
                            <!--- display breadcrumb navigation --->
                            <div class="container-fluid w-100 px-0 mx-0 my-2">
                                #display(method="bcrumb", encoded=arguments.data.main.breadcrumb).output#
                            </div>
                            <!--- end of breadcrumb navigation --->

                            <!---
                           <div class="container-fluid w-100 px-0 mx-0 text-start">   
                                <cfif Len(arguments.data.main.title)>
                                    <h3>#arguments.data.main.title#</h3>
                                </cfif>
                                <!--- form section...what will come from the login component --->
                                #arguments.data.main.output#
                                <!--- end of form section --->
                            </div>
                            --->

                            <div class="row text-start">
                                <div class="col-sm-8 col-md-6 col-lg-7 col-xl-9 pl-ml-20 float-started">
                                     <cfif Len(arguments.data.main.title)>
                                        <h3>#arguments.data.main.title#</h3>
                                    </cfif>
                                        #arguments.data.main.output#
                                </div>
                                
                                <div class="col-sm-auto col-md-auto col-lg-auto col-xl-auto mx-20 float-end">
                                    <div class="text-start admin-side-link">
                                        <!--- show Admin information if Admin rights --->
                                        <cfif getFactory().get('login').model.getUser().user.securityLevelID gte 4>
                                            #local.adminLinks#
                                        </cfif>    
                                        <!--- quick links --->
                                        #local.quickLinks#
                                        <!--- show personal details --->
                                        #local.personalLinks#
                                        <!--- NEWS --->
                                        <cfif getFactory().get("home").view.fadingNews("Rugby Union News", "homepageNews", "/home/rssfeed").success>
                                            <div align="center">
                                                <div id="homepageNewsWrapper" align="center">
                                                    #getFactory().get("home").view.fadingNews("Rugby Union News", "homepageNews", "/home/rssfeed").output#
                                                    <div class="clear"></div>
                                                </div>
                                            </div>
                                        </cfif>
                                        <!--- END OF NEWS --->
                                    </div>
                                </div>
                            </div>   

                        </div>
                    </div>
					#defaultFooter().output#
				</cfoutput>
            <cfelse>
           		<cfoutput>
					#arguments.data.main.output#
				</cfoutput>
            </cfif>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="leagueMatches" returntype="struct" access="public" hint="Layout for any leagueMatches pages">
		<cfargument name="data" type="struct" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

        <cfset local.branding = branding(arguments.data)>

        <cfset local.adminLinks = adminLinks(arguments.data).output>
        <cfset local.quickLinks = quickLinks(arguments.data).output>
        <cfset local.personalLinks = personalLinks(arguments.data).output>
        
		<cfsavecontent variable="local.result.output">
        	<cfif NOT arguments.data.main.restrictOutput>
				<cfoutput>
					#defaultHeader(arguments.data).output#
					<!--- content of the league matches template --->
                    <div class="container-fluid">
                         <!--- image matching league level --->
                        <div class="container-fluid text-center mb-0 py-5" style="border-bottom: 4px solid #local.branding.colour#; border-left: 1px solid #local.branding.colour#; border-right: 1px solid #local.branding.colour#; border-top: 1px solid #local.branding.colour#;">
                            <div class="container">
                                #local.branding.logo#
                            </div>
                        </div>
                        <!--- container for the navigation bar --->
                        <div class="container-fluid mt-1 pt-0" style="background-color:#local.branding.colour#;">
                            <div class="row">
                                <div class="col pl-md-10 w-80">
                                    <div class="text-start text-white">#dateformat(now(),'dd mmmm yyyy')#</div>
                                </div>
                                <div class="col pr-md-10  w-20 text-end">
                                    <cfif getFactory().get("login").model.isLoggedIn()>
                                        <a class="text-end text-white text-decoration-none" href="/login/logout" title="Log Out">Log Out</a>
                                    </cfif>
                                </div>
                            </div>
                        </div>
                        <!--- end of container for the navigation bar --->
                    
                        <div class="container-fluid" style="border:1px solid #local.branding.colour#;">
                            <!--- display breadcrumb navigation --->
                            <div class="container-fluid w-100 px-0 mx-0 my-2">
                            #display(method="bcrumb", encoded=arguments.data.main.breadcrumb).output#
                            </div>
                            <!--- end of breadcrumb navigation --->


                            <div class="row text-start">
                                <div class="col-sm-8 col-md-6 col-lg-7 col-xl-9 pl-ml-20 float-started">
                                     <cfif Len(arguments.data.main.title)>
                                        <h3>#arguments.data.main.title#</h3>
                                    </cfif>
                                        #arguments.data.main.output#
                                </div>
                                
                                <div class="col-sm-auto col-md-auto col-lg-auto col-xl-auto mx-20 float-end">
                                    <div class="text-start admin-side-link">
                                        <!--- show Admin information if Admin rights --->
                                        <cfif getFactory().get('login').model.getUser().user.securityLevelID gte 4>
                                            #local.adminLinks#
                                        </cfif>    
                                        <!--- quick links --->
                                        #local.quickLinks#
                                        <!--- show personal details --->
                                        #local.personalLinks#
                                        <!--- NEWS --->
                                        <cfif getFactory().get("home").view.fadingNews("Rugby Union News", "homepageNews", "/home/rssfeed").success>
                                            <div align="center">
                                                <div id="homepageNewsWrapper" align="center">
                                                    #getFactory().get("home").view.fadingNews("Rugby Union News", "homepageNews", "/home/rssfeed").output#
                                                    <div class="clear"></div>
                                                </div>
                                            </div>
                                        </cfif>
                                        <!--- END OF NEWS --->
                                    </div>
                                </div>
                            </div>   

                        </div>
                    </div>
					#defaultFooter().output#
				</cfoutput>
            <cfelse>
           		<cfoutput>
					#arguments.data.main.output#
				</cfoutput>
            </cfif>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="leagueReports" returntype="struct" access="public" hint="Layout for any leagueReports pages">
		<cfargument name="data" type="struct" required="true">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

        <cfset local.branding = branding(arguments.data)>

        <cfset local.adminLinks = adminLinks(arguments.data).output>
        <cfset local.quickLinks = quickLinks(arguments.data).output>
        <cfset local.personalLinks = personalLinks(arguments.data).output>
        
		<cfsavecontent variable="local.result.output">
        	<cfif NOT arguments.data.main.restrictOutput>
				<cfoutput>
					#defaultHeader(arguments.data).output#
					<!--- content of the league reports template --->
                    <div class="container-fluid">
                         <!--- image matching league level --->
                        <div class="container-fluid text-center mb-0 py-5" style="border-bottom: 4px solid #local.branding.colour#; border-left: 1px solid #local.branding.colour#; border-right: 1px solid #local.branding.colour#; border-top: 1px solid #local.branding.colour#;">
                            <div class="container">
                                #local.branding.logo#
                            </div>
                        </div>
                        <!--- container for the navigation bar --->
                        <div class="container-fluid mt-1 pt-0" style="background-color:#local.branding.colour#;">
                            <div class="row">
                                <div class="col pl-md-10 w-80">
                                    <div class="text-start text-white">#dateformat(now(),'dd mmmm yyyy')#</div>
                                </div>
                                <div class="col pr-md-10  w-20 text-end">
                                    <cfif getFactory().get("login").model.isLoggedIn()>
                                        <a class="text-end text-white text-decoration-none" href="/login/logout" title="Log Out">Log Out</a>
                                    </cfif>
                                </div>
                            </div>
                        </div>
                        <!--- end of container for the navigation bar --->
                    
                        <div class="container-fluid" style="border:1px solid #local.branding.colour#;">
                            <!--- display breadcrumb navigation --->
                            <div class="container-fluid w-100 px-0 mx-0 my-2">
                            #display(method="bcrumb", encoded=arguments.data.main.breadcrumb).output#
                            </div>
                            <!--- end of breadcrumb navigation --->

                            <div class="row text-start">
                                <div class="col-sm-8 col-md-6 col-lg-7 col-xl-9 pl-ml-20 float-started">
                                     <cfif Len(arguments.data.main.title)>
                                        <h3>#arguments.data.main.title#</h3>
                                    </cfif>
                                        #arguments.data.main.output#
                                </div>
                                
                                <div class="col-sm-auto col-md-auto col-lg-auto col-xl-auto mx-20 float-end">
                                    <div class="text-start admin-side-link">
                                        <!--- show Admin information if Admin rights --->
                                        <cfif getFactory().get('login').model.getUser().user.securityLevelID gte 4>
                                            #local.adminLinks#
                                        </cfif>    
                                        <!--- quick links --->
                                        #local.quickLinks#
                                        <!--- show personal details --->
                                        #local.personalLinks#
                                        <!--- NEWS --->
                                        <cfif getFactory().get("home").view.fadingNews("Rugby Union News", "homepageNews", "/home/rssfeed").success>
                                            <div align="center">
                                                <div id="homepageNewsWrapper" align="center">
                                                    #getFactory().get("home").view.fadingNews("Rugby Union News", "homepageNews", "/home/rssfeed").output#
                                                    <div class="clear"></div>
                                                </div>
                                            </div>
                                        </cfif>
                                        <!--- END OF NEWS --->
                                    </div>
                                </div>
                            </div>   

                        </div>
                    </div>
					#defaultFooter().output#
				</cfoutput>
            <cfelse>
           		<cfoutput>
					#arguments.data.main.output#
				</cfoutput>
            </cfif>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="message" returntype="struct" access="public" hint="Layout for messages">
		<cfargument name="data" type="struct" required="true">

		<cfset var local = structNew()>

		<cfset local.result = getFactory().getResult()>
		
		<cfsavecontent variable="local.result.output">
			<cfoutput>
					<!DOCTYPE html>
                    <html lang="en">
						<head>
                            <meta charset="utf-8">
                            <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
							#defaultStyleHeader().output#
							<title></title>                            
						</head>
						<body>
							<div id="central">
								#arguments.data.main.output#
							</div>
						</body>
					</html>
				</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>

	<!--- template elements --->
	<cffunction name="defaultStyleHeader" returntype="struct" access="public" hint="Default stylesheets and js for templates">
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

		<cfsavecontent variable="local.result.output">
			<cfoutput>				
                <link rel="stylesheet" href="/res/css/common.css" type="text/css"></link>
                <link rel="stylesheet" href="/res/css/#getFactory().get("session").model.get("siteTemplate")#.css" type="text/css"></link>

                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="defaultLoginStyleHeader" returntype="struct" access="public" hint="styling header for login page">
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

		<cfsavecontent variable="local.result.output">
			<cfoutput>
                <link rel="stylesheet" href="/res/css/login.css" type="text/css"></link>
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn local.result>
	</cffunction>
    
	<cffunction name="defaultHeader" returntype="struct" access="private" hint="Default header for templates">
		<cfargument name="data" type="struct" required="false" default="#structNew()#">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

		<cfparam name="arguments.data.main" default="#structNew()#">
		<cfparam name="arguments.data.main.title" default="Welsh Rugby">


		<cfif Len(arguments.data.main.title)>
			<cfset local.title = arguments.data.main.title>
		<cfelseif StructKeyExists(arguments.data.main, "breadcrumb") AND ListLen(arguments.data.main.breadcrumb) gt 1>
			<cfset local.title = ListGetAt(ListGetAt(arguments.data.main.breadcrumb, ListLen(arguments.data.main.breadcrumb)), 1, "|")>
		<cfelse>
			<cfset local.title = "Welsh Rugby">
		</cfif>
		<cfset local.title = getFactory().get("htmlUtil").util.stripHTML(input=local.title, stripAll=true)>

		<cfset local.keywords = "">

		<cfif Len(arguments.data.main.breadcrumb)>
			<cfloop list="#arguments.data.main.breadcrumb#" index="local.part">
				<cfif ListLen(local.part, "|") gt 1>
					<cfset local.word = ReReplace(Trim(ListGetAt(local.part, 1, "|")), "[\&]", "", "ALL")>
					<cfset local.words = "">
					<cfloop list="#local.word#" index="local.single">
						<cfif Len(trim(local.single))>
							<cfset local.words = ListAppend(local.words, local.single)>
						</cfif>
					</cfloop>
					<cfset local.keywords = ListPrepend(local.keywords, local.words)>
				</cfif>
			</cfloop>
		<cfelse>
			<cfset local.body = getFactory().get("htmlUtil").util.stripHTML(input=arguments.data.main.output, stripAll=true)>
			<cfset local.body = replace(local.body, " ", ",", "ALL")>
			<cfloop from="1" to="#Min(30,ListLen(local.body))#" index="local.i">
				<cfset local.keywords = ListAppend(local.keywords, ListGetAt(local.body, local.i))>
			</cfloop>
		</cfif>

		<cfsavecontent variable="local.result.output">
			<cfoutput>
				<!DOCTYPE html>
                <html lang="en">
					<head>
						<cfheader name="Cache-Control" value="no-cache">
						<cfheader name="Expires" value="0">
						<cfheader name="Pragma" value="no-cache">
						<cfheader name="Last-Modified" value="#getHttpTimeString(now())#">
						
                        <meta charset="utf-8">
						<meta name="description" content="#local.title#">
						<meta name="cache-control" content="no-cache">
						<meta name="expires" content="0">
						<meta name="Last-Modified" content="#getHttpTimeString(now())#">
						<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

						#defaultStyleHeader(data=arguments.data.main).output#
                        
						<title>#local.title#</title>
                        
                        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.0/jquery.min.js"></script>
					</head>

					<body>
						
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>

    <cffunction name="leagueDivHeader" returntype="struct" access="public" hint="for use in divs loading other pages">
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

		<cfsavecontent variable="local.result.output">
			<cfoutput>
            <!DOCTYPE html>
            <html lang="en">
                <head>
                    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.0/jquery.min.js"></script>
                 </head>
                 <body>
            
			</cfoutput>
		</cfsavecontent>
		
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="defaultLoginHeader" returntype="struct" access="private" hint="For use in the login page">
		<cfargument name="data" type="struct" required="false" default="#structNew()#">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

		<cfparam name="arguments.data.main" default="#structNew()#">
		<cfparam name="arguments.data.main.title" default="Welsh Rugby">

		<cfif Len(arguments.data.main.title)>
			<cfset local.title = arguments.data.main.title>
		<cfelseif StructKeyExists(arguments.data.main, "breadcrumb") AND ListLen(arguments.data.main.breadcrumb) gt 1>
			<cfset local.title = ListGetAt(ListGetAt(arguments.data.main.breadcrumb, ListLen(arguments.data.main.breadcrumb)), 1, "|")>
		<cfelse>
			<cfset local.title = "Welsh Rugby">
		</cfif>
		<cfset local.title = getFactory().get("htmlUtil").util.stripHTML(input=local.title, stripAll=true)>

		<cfset local.keywords = "">

		<cfif Len(arguments.data.main.breadcrumb)>
			<cfloop list="#arguments.data.main.breadcrumb#" index="local.part">
				<cfif ListLen(local.part, "|") gt 1>
					<cfset local.word = ReReplace(Trim(ListGetAt(local.part, 1, "|")), "[\&]", "", "ALL")>
					<cfset local.words = "">
					<cfloop list="#local.word#" index="local.single">
						<cfif Len(trim(local.single))>
							<cfset local.words = ListAppend(local.words, local.single)>
						</cfif>
					</cfloop>
					<cfset local.keywords = ListPrepend(local.keywords, local.words)>
				</cfif>
			</cfloop>
		<cfelse>
			<cfset local.body = getFactory().get("htmlUtil").util.stripHTML(input=arguments.data.main.output, stripAll=true)>
			<cfset local.body = replace(local.body, " ", ",", "ALL")>
			<cfloop from="1" to="#Min(30,ListLen(local.body))#" index="local.i">
				<cfset local.keywords = ListAppend(local.keywords, ListGetAt(local.body, local.i))>
			</cfloop>
		</cfif>

		<cfsavecontent variable="local.result.output">
			<cfoutput>
				<!DOCTYPE html>
                <html lang="en">
					<head>
						<cfheader name="Cache-Control" value="no-cache">
						<cfheader name="Expires" value="0">
						<cfheader name="Pragma" value="no-cache">
						<cfheader name="Last-Modified" value="#getHttpTimeString(now())#">
						
                        <meta charset="utf-8">
						<meta name="description" content="#local.title#">
						<meta name="cache-control" content="no-cache">
						<meta name="expires" content="0">
						<meta name="Last-Modified" content="#getHttpTimeString(now())#">
						<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

						#defaultLoginStyleHeader(data=arguments.data.main).output#
						<title>#local.title#</title>
                        
                        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.0/jquery.min.js"></script>
					</head>

					<body>
						
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="defaultFooter" returntype="struct" access="public" hint="General footer">
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

		<cfsavecontent variable="local.result.output">
			<cfoutput>
                
					</body>
				</html>
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>

	<cffunction name="bcrumb" access="public" returntype="struct" hint="For use in the breadcrumb navigation">
		<cfargument name="encoded" type="string" required="false" default="">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

		<cfset local.trail = ArrayNew(1)>
		<cfset local.step = structNew()>
		<cfset local.step.link = "/">
        <cfset local.step.label = "Home">
		<cfset ArrayAppend(local.trail, local.step)>
        
		<cfset local.lastLink = local.step.link>
		<cfloop list="#arguments.encoded#" index="local.pair">
			<cfset local.step = structNew()>
				<cfset local.step.label = ListGetAt(local.pair, 1, "|")>
				<cfif ListLen(local.pair, "|") gt 1>
					<cfset local.tmpLink = listGetAt(local.pair, 2, "|")>
				<cfelse>
					<cfset local.tmpLink = "">
				</cfif>
				<cfif Left(local.tmpLink, 1) eq "/">
					<cfset local.step.link = local.tmpLink>
				<cfelse>
					<cfset local.step.link = ListAppend(local.lastLink, local.tmpLink, "/")>
					<cfset local.step.link = Replace(local.step.link, "//", "/")>
				</cfif>
			<cfset ArrayAppend(local.trail, local.step)>
			<cfset local.lastLink = local.step.link>
		</cfloop>
		
		<cfsavecontent variable="local.result.output">
			<cfoutput>
            	<div id="breadcrumb">
                    <nav aria-label="breadcrumb">
                        <ol class="breadcrumb">
                            <cfloop from="1" to="#ArrayLen(local.trail)#" index="local.i">
                                <cfif local.i lt ArrayLen(local.trail)>
                                    <li class="breadcrumb-item"><a href="#local.trail[local.i].link#">#local.trail[local.i].label#</a></li>
                                <cfelse>
                                    <li class="breadcrumb-item active" aria-current="page">#local.trail[local.i].label#</li>
                                </cfif>                            
                            </cfloop>
                        </ol>
                    </nav>
            	</div>
			</cfoutput>
		</cfsavecontent>
		<cfreturn local.result>
	</cffunction>

	<cffunction name="resultMessage" access="public" returntype="struct" hint="Common display function for success,failure,warning messages">
    	<cfargument name="type" type="string" required="true">
		<cfargument name="label" type="string" required="true">
		<cfargument name="message" type="string" required="true">
		<cfargument name="width" type="string" required="true">
        <cfargument name="restrictOutput" type="boolean" required="false" default="false">
       
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

		<cfsavecontent variable="local.result.output">
			<cfoutput>
            	<cfif NOT arguments.restrictOutput>
                    <table class="#arguments.type#" width="#arguments.width#">
                        <tr>
                            <td class="#arguments.type#-detail">
                                <div class="label">#arguments.label#</div>
                                <div class="message">#arguments.message#</div>
                            </td>
                        </tr>
                    </table>
                <cfelse>
                	#getFactory().get("template").view.defaultIframeHeader().output#
                    <div align="left" style="padding-top:20px;">
                	<table class="#arguments.type#" width="#arguments.width#">
                        <tr>
                            <td class="#arguments.type#-detail">
                                <div class="label">#arguments.label#</div>
                                <div class="message">#arguments.message#</div>
                            </td>
                        </tr>
                    </table>
                    </div>
                    #getFactory().get("template").view.defaultFooter().output#
                </cfif>
			</cfoutput>
		</cfsavecontent>
		<cfreturn local.result>
	</cffunction>

	<cffunction name="failure" access="public" returntype="struct" hint="Formats a failure for display to the user">
		<cfargument name="label" type="string" required="false" default="">
		<cfargument name="message" type="string" required="false" default="">
		<cfargument name="width" type="string" required="false" default="100%">
        <cfargument name="restrictOutput" type="boolean" required="false" default="false">
        
        <cfreturn resultMessage("failure", arguments.label, arguments.message, arguments.width)>
	</cffunction>

	<cffunction name="warning" access="public" returntype="struct" hint="Formats a warning for display to the user">
		<cfargument name="label" type="string" required="false" default="">
		<cfargument name="message" type="string" required="false" default="">
		<cfargument name="width" type="string" required="false" default="100%">
        <cfargument name="restrictOutput" type="boolean" required="false" default="false">
        
        <cfreturn resultMessage("warning", arguments.label, arguments.message, arguments.width)>
	</cffunction>

	<cffunction name="success" access="public" returntype="struct" hint="Formats a success for display to the user">
		<cfargument name="label" type="string" required="false" default="">
		<cfargument name="message" type="string" required="false" default="">
		<cfargument name="width" type="string" required="false" default="100%">
        <cfargument name="restrictOutput" type="boolean" required="false" default="false">

		<cfreturn resultMessage("success", arguments.label, arguments.message, arguments.width, arguments.restrictOutput)>
	</cffunction>
	
	<cffunction name="errors" access="public" returntype="struct" hint="Displaying errors">
		<cfargument name="data" type="array" required="false">

		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>

		<cfsavecontent variable="local.result.output">
			<cfif ArrayLen(arguments.data)>
			<cfoutput>
				<div class="errors">
					<h3>The following errors have occurred:</h3>
                    <ul>
					<cfloop from="1" to="#ArrayLen(arguments.data)#" index="local.i">
						<li>#arguments.data[local.i]#</li>
					</cfloop>
                    </ul>
				</div>
			</cfoutput>
			</cfif>
		</cfsavecontent>
		<cfreturn local.result>
	</cffunction>

    <cffunction name="popup" returntype="struct" access="public">
		<cfargument name="data" type="struct" required="true">

		<cfset var local = structNew()>

		<cfset local.result = getFactory().getResult()>
		
		<cfsavecontent variable="local.result.output">
			<cfoutput>
            <div style="padding:10px;">
            #getFactory().get("template").view.defaultStyleHeader().output#
            #arguments.data.main.output#
            </div>
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>
    
</cfcomponent>
