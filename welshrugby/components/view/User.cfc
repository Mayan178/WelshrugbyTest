<cfcomponent name="user" extends="parent" hint="View for user">
	<cffunction name="init" returntype="user" access="public">
		<cfset var local = structNew()>

		<cfset super.init()>
		<cfreturn this/>
	</cffunction>

	<cffunction name="default" access="private" returntype="struct" hint="default view for this component">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
        <cfset local.result.output=#profile(arguments.data).output#>
		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="profile" access="private" returntype="struct" hint="Displays the current user's profile">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
		<cfsavecontent variable="local.result.output">
			<cfoutput>
                <div class="row">                      
                    <div class="col-sm-8 col-md-6 col-lg-6 col-xl-6 mx-20">
                        <div class="container-fluid">
                            <cfif StructKeyExists(arguments.data, "errors")>
                                #getFactory().get("template").view.errors(arguments.data.errors).output#
                            </cfif>
                            <form action="/user/profile" method="POST"  class="was-validated" id="user-update" enctype="multipart/form-data">
                                <input type="hidden" name="originalPassword" value="#arguments.data.userpassword#" />

                                #getFactory().get("formFactory").view.display(method="inputText", id="username", label="Username", value=arguments.data.username, editMode=false).output#

                                #getFactory().get("formFactory").view.display(method="inputText", id="password", label="Your Password", value=arguments.data.userpassword, required=true, password=true).output#

                                #getFactory().get("formFactory").view.display(method="accessKey", value=arguments.data.accessKey).output#
                                #getFactory().get("formFactory").view.display(method="teamID", value=arguments.data.teamID).output#
                                <div id="RedMaxLevelInvalid" style="display:none;color:red;">sdfasdf</div>
                                #getFactory().get("formFactory").view.display(method="RedMaxLevel", value=arguments.data.RedMaxLevel,required=true).output#
                                #getFactory().get("formFactory").view.display(method="GreenMaxLevel", value=arguments.data.GreenMaxLevel,required=true).output#                                
                                
                                <div class="row my-3">
                                    <div class="col">
                                        <a class="btn btn-dark my-2" href="/user/ShowUsers" role="button">Cancel</a>
                                    </div>
                                    <div class="col"><input type="submit" name="update" id="update" value="Update Details" class="btn btn-dark my-2"></div>
                                </div>
                            </form>

                            <script>
                            $(document).ready(function(){
                                $("##user-update").submit(function(){
                                    var RedMaxLevelValue = parseInt($("##RedMaxLevel").val());
                                    var GreenMaxLevelValue = parseInt($("##GreenMaxLevel").val());

                                    if (RedMaxLevelValue >= GreenMaxLevelValue)
                                    {
                                        $("##RedMaxLevelInvalid").show(); 
                                        $("##RedMaxLevelInvalid").text("The value for Red needs to be lower than the value for Green");
                                        $("##RedMaxLevel").focus();
                                        return false;
                                    }
                                    else
                                    {
                                        $("##RedMaxLevelInvalid").hide();
                                    }
                                });
                            });
                        </script>


                        </div>
                    </div>
                </div>
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="showUsers" access="private" returntype="struct" hint="Displays all users">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
		<cfsavecontent variable="local.result.output">
        	<cfoutput>
                <div class="container-fluid mb-4 p-3">
            	<div class="float-end"><a href="/user/addUser" class="btn btn-dark mt-2">Add a User</a></div>
                </div>
                <!--- highest level Admin --->
            	<cfif getFactory().get("login").model.getUser().user.securityLevelID eq 5>
                    <div class="container-fluid p-3">
                        <div class="table-responsive">
                        <table class="table  table-striped table-bordered">
                            <thead class="thead-dark">
                                <tr>
                                    <th>User</th>
                                    <th>Country</th>
                                    <th>Level</th>
                                    <th>Last Log In</th>
                                    <th>Players Added</th>
                                    <th>&nbsp;</th>
                                    <th>&nbsp;</th>
                                </tr>
                            </thead>
                            <tbody>
                                <cfloop query="arguments.data.allusers">
                                <!--- styling differently: own record will be bold vs others not --->
                                <cfif userID neq getFactory().get("login").model.getUser().user.userID>
                                    <cfset local.styling = "font-weight: normal;">
                                <cfelse>
                                    <cfset local.styling = "font-weight: bold;">
                                </cfif>

                                <tr>
                                    <td style="#local.styling#">#username#</td>
                                    <td style="#local.styling#">#country#</td>
                                    <td style="#local.styling#">#securityLevel#</td>
                                    <td style="#local.styling#">&nbsp;#dateformat(lastloggedin,"dd/mm/yy")#</td>
                                    <td style="#local.styling#">#playersAdded#</td>
                                    
                                    <!--- edit basic info and delete if not own record --->
                                    <cfif userID neq getFactory().get("login").model.getUser().user.userID>
                                        <td style="#local.styling#"><a href="/user/editUser/userID/#userID#" id="user-editlink-#userID#">Edit</a></td>
                                        <td style="#local.styling#"><a href="/user/deleteUser/userID/#userID#" id="user-deletelink-#userID#" onclick="return confirm('Are you sure you want to delete user #username#?')">Delete</a></td>
                                    <cfelse>
                                        <td style="#local.styling#"><a href="/user/profile/userID/#userID#" id="user-editlink-#userID#">Edit</a></td>
                                        <td>&nbsp;</td>
                                    </cfif>
                                </tr>
                                </cfloop>
                            </tbody>
                        </table>
                        </div>
                    </div>
                <!--- Admin access level 4 --->
                <cfelseif getFactory().get("login").model.getUser().user.securityLevelID eq 4>
                    <div class="container-fluid p-3">
                        <div class="table-responsive">
                        <table class="table  table-striped table-bordered">
                            <thead class="thead-dark">
                                <tr>
                                    <th class="first">User</th>
                                    <th class="first">Level</th>
                                    <th class="first">&nbsp;</th>
                                    <th>&nbsp;</th>
                                </tr>
                            </thead>
                            <tbody>
                                <cfloop query="arguments.data.allusers">
                                <!--- styling differently: own record will be bold vs others not --->
                                <cfif userID neq getFactory().get("login").model.getUser().user.userID>
                                    <cfset local.styling = "font-weight: normal;">
                                <cfelse>
                                    <cfset local.styling = "font-weight: bold;">
                                </cfif>

                                    <tr>
                                        <td style="#local.styling#">#username#</td>
                                        <td style="#local.styling#">#securityLevel#</td>
                                        <td style="#local.styling#"><a href="/user/editUser/userID/#userID#" id="user-editlink-#userID#">Edit</a></td>
                                        <!--- user can't delete own record --->
                                        <cfif userID neq getFactory().get("login").model.getUser().user.userID>
                                            <!--- can only delete lower level users --->
                                            <cfif SecurityLevelID lt 4>
                                                <td style="#local.styling#"><a href="/user/deleteUser/userID/#userID#" id="user-deletelink-#userID#" onclick="return confirm('Are you sure you want to delete this user?')">Delete</a></td>
                                            <cfelse>
                                                <td>&nbsp;</td>
                                            </cfif>
                                        <cfelse>
                                            <td>&nbsp;</td>
                                        </cfif>
                                    </tr>
                                </cfloop>
                            </tbody>
                        </table>
                        </div>
                    </div>
                </cfif>    
            </cfoutput>  
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="editUser" access="private" returntype="struct" hint="Displays a form to edit a user">
		<cfargument name="data" type="query" required="false">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
		<cfsavecontent variable="local.result.output">
			<cfoutput>
                <div class="row">                      
                    <div class="col-sm-8 col-md-6 col-lg-6 col-xl-6 mx-20">
                        <cfif StructKeyExists(arguments.data, "errors")>
                            #getFactory().get("template").view.errors(arguments.data.errors).output#
                        </cfif>

                        <div class="container-fluid">
                            <form action="/user/editUser" method="POST" class="was-validated" id="user-update">
                                <input type="hidden" name="userID" value="#arguments.data.userID#" />

                                #getFactory().get("formFactory").view.display(method="inputText", id="username", label="Username", value=arguments.data.username, required=true, editMode=false).output#

                                #getFactory().get("formFactory").view.display(method="inputText", id="password", label="Reset Password", value="", required=true, password=true).output#

                                <cfif getFactory().get("login").model.getUser().user.securityLevelID eq 5>
                                    <cfset local.securityLevels = getFactory().get("user").model.getAllSecurityLevelIDs()>
                                <cfelseif getFactory().get("login").model.getUser().user.securityLevelID eq 4>
                                    <cfset local.securityLevels = getFactory().get("user").model.getSecurityLevelIDs3andbelow()>
                                </cfif>
                                <!--- build array of structs dataset to use in inputSelect --->
                                <cfset local.datasl = ArrayNew(1)>
                                <cfloop query="local.securityLevels">
                                    <cfset local.str = {label="#securityLevel#", value="#securityLevelID#"}>
                                    <cfset ArrayAppend(local.datasl, local.str)>
                                </cfloop>
                                #getFactory().get("formFactory").view.display(method="inputSelect", selectid="SecurityLevelID", label="Level of Access",
                                required=true, data=local.datasl, value="#arguments.data.securityLevelID#", novalue="Please Select", novalueID="").output#

                                <!--- taken out as no dbs for all countries yet
                                <cfif getFactory().get("login").model.getUser().user.securityLevelID eq 5>
                                #getFactory().get("formFactory").view.display(method="countryID", value=arguments.data.countryID).output#
                                </cfif>
                                --->
                                <input type="hidden" name="countryID" value="1">

                                <div class="row">
                                    <div class="col">
                                        <a class="btn btn-dark my-2" href="/user/ShowUsers" role="button">Cancel</a>
                                    </div>
                                    <div class="col"><input type="submit" name="update" id="update" value="Update Details" class="btn btn-dark my-2"></div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>
    
    <cffunction name="addUser" access="private" returntype="struct" hint="Displays a form to add a user">
		<cfargument name="data" type="struct" required="false">
		
		<cfset var local = structNew()>
		<cfset local.result = getFactory().getResult()>
		
		<cfsavecontent variable="local.result.output">
			<cfoutput>
            	<cfif StructKeyExists(arguments.data, "errors")>
                    #getFactory().get("template").view.errors(arguments.data.errors).output#
                </cfif>

                <div class="container-fluid">
                     <div class="row">                      
                        <div class="col-sm-8 col-md-6 col-lg-6 col-xl-6 mx-20">

                            <form action="/user/addUser" method="POST" id="user-add"  class="was-validated">
                                <div id="userExists" style="display:none; color:red;"></div>

                                #getFactory().get("formFactory").view.display(method="inputText", id="username", label="Username", value="", required=true).output#
                                
                                #getFactory().get("formFactory").view.display(method="inputText", id="password", label="Password", value="", required=true, password=true).output#

                                <cfif getFactory().get("login").model.getUser().user.securityLevelID eq 5>
                                    <cfset local.securityLevels = getFactory().get("user").model.getAllSecurityLevelIDs()>
                                <cfelseif getFactory().get("login").model.getUser().user.securityLevelID eq 4>
                                    <cfset local.securityLevels = getFactory().get("user").model.getSecurityLevelIDs3andbelow()>
                                </cfif>
                                <!--- build array of structs dataset to use in inputSelect --->
                                <cfset local.datasl = ArrayNew(1)>
                                <cfloop query="local.securityLevels">
                                    <cfset local.str = {label="#securityLevel#", value="#securityLevelID#"}>
                                    <cfset ArrayAppend(local.datasl, local.str)>
                                </cfloop>
                                #getFactory().get("formFactory").view.display(method="inputSelect", selectid="SecurityLevelID", label="Level of Access",
                                required=true, data=local.datasl, value="", novalue="Please Select", novalueID="").output#

                                <input type="hidden" name="countryID" value="1">
                                
                                <div class="row">
                                    <div class="col">
                                        <a class="btn btn-dark my-2" href="/user/ShowUsers" role="button">Cancel</a>
                                    </div>
                                    <div class="col"><input type="submit" name="add" id="add" value="Insert Details" class="btn btn-dark my-2"></div>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
				
                <script>
                $(document).ready(function(){
                    $("##username").blur(function(){
                        var userName = document.getElementById("username").value;
                        $("##userExists").show(); 
                        $("##userExists").load("/user/checkUserExists/username/" + userName);

                        var existingContent = document.getElementById("userExists").innerHTML;
                    });
                    $("##user-add").submit(function(){
                        var existingContent = document.getElementById("userExists").innerHTML;

                        if (existingContent.indexOf('already') != -1)
                        {
                            return false;
                        }
                    });
                });
                </script>
			</cfoutput>
		</cfsavecontent>

		<cfreturn local.result>
	</cffunction>
    
</cfcomponent>