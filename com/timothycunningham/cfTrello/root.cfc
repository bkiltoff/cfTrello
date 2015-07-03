<cfcomponent>

<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
<!---getPRC - Returns application-scoped variables defined on application start 
  with session variables, as listed in the "sessionInit" method, in a struct--->
<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
	<cffunction name="getPRC">
		<cfset var prc = structNew()>
		<cfset prc.apiURL					= application.apiURL>
		<cfset prc.sConsumerKey 			= application.sConsumerKey>
		<cfset prc.sConsumerkeysecret 		= application.sConsumerkeysecret>
		<cfset prc.sTokenEndpoint			= application.sTokenEndpoint> 		
		<cfset prc.sAccessTokenEndpoint 	= application.sAccessTokenEndpoint> 	
		<cfset prc.sAuthorizationEndpoint 	= application.sAuthorizationEndpoint> 
		<cfset prc.sCallbackURL 			= application.sCallbackURL>
		<cfset structAppend(prc,session, "true")>		
		<cfreturn prc>
	</cffunction>
	
<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
<!---sessionInit() - Defines session scope variables--->
<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
	<cffunction name="sessionInit">
		<cfset session.oauth_token 			= "">
		<cfset session.sAccessToken 		= "">
		<cfset session.sAccessTokenSecret 	= "">
		<cfset session.oauth_verifier 		= "">
		<cfset session.boardID				= "">
		<cfreturn>
	</cffunction>
    
<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
<!---getHttpType() - returns string for either http or https--->
<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
	<cffunction name="getHttpType">
		<cfif cgi.https is "off">
			<cfreturn "http://">
		<cfelse>
			<cfreturn "https://">
		</cfif>
		<cfreturn "http://">
	</cffunction>
	
<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
<!---setTargetPage() - define session-scoped variable: "targetPage"--->
<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
	<cffunction name="setTargetPage">
		<cfargument name="targetPage" required="true" type="string" default="#getHttpType()##cgi.server_name#:8500">
		<cfset session.targetPage = arguments.targetPage>
		<cfreturn session.targetPage>
	</cffunction>
	
    <!--- return sesssion-scoped variable: "targetPage"--->
	<cffunction name="getTargetPage">
		<cfreturn session.targetPage>
	</cffunction>
	

<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
<!---doApiCall - Generic function to generate a RESTful API call--->
<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
	<cffunction name="doApiCall" access="public" hint="generic caller to Trello API">
		<cfargument name="verb" 		type="string" 	required="true" 	default="get">
		<cfargument name="uriFilter" 	type="string" 	required="true" >
		
		<!--- Set up needed variables --->
 		<cfif ISDefined("arguments.formatType") IS False>
			<cfset arguments.formatType = "Struct">
		</cfif>
		<cfset structAppend(variables,getPRC(),"true")>		
		<cfset variables.rawReturn = "">
		<cfset variables.arg = "">
		<cfset variables.apiCall = "">
		<cfset variables.apiCall = apiURL  & "#arguments.uriFilter#">

		<!--- create the cfhttp request--->
			<cfhttp url=#apiCall# method=#arguments.verb# result=variables.rawReturn>
            	<!--- Add application key and token --->
                <cfhttpparam name="key" type="URL" value=#sConsumerKey#>
                <cfif #sAccessToken# NEQ "">
                	<cfhttpparam name="token" type="URL" value=#sAccessToken#>
                </cfif>
                <!--- append other arguments as cfhttpparam tags --->
                <cfloop collection=#arguments# item="arg">	
                    <cfif isSimpleValue(#arguments[arg]#) AND  #arg# NEQ "uriFilter" AND #arg# NEQ "formatType" AND #arg# NEQ "verb">	
                        <cfhttpparam name=#arg# type="URL" value=#arguments[arg]#>
                    </cfif>
                </cfloop>	           		
			</cfhttp>		
		<cfset  return = getApiReturn(rawReturn, arguments.formatType)>
 		<cfreturn return>
	</cffunction>


<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
<!---getAPIReturn()--->
<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
	<cffunction name="getAPIReturn" access="public" hint="Formats the return call from Trello">
		<cfargument name="rawReturn"  type="struct" required="true">
		<cfargument name="formatType" type="string" required="true" default="Struct" hint="JSON or Struct (Deserialized JSON)">
		<cfset var errorReturn = structNew()>
		<cfif isStruct(rawReturn) AND isJsON(rawReturn.fileContent.toString()) AND arguments.formatType IS "Struct">
			<cfreturn deserializeJson(rawReturn.fileContent.toString())>
		</cfif>
		<cfif isStruct(rawReturn) AND isJsON(rawReturn.fileContent.toString()) AND arguments.formatType IS "JSON">
			<cfreturn rawReturn.fileContent.toString()>
		</cfif>
		<!--- Error checking --->
		<cfif isStruct(rawReturn.fileContent) IS false >
			<cfset errorReturn.name			= "ErrorCode">
			<cfset errorReturn.error		= rawReturn.fileContent>
            <cfset errorReturn.msg			= "isStruct(rawReturn.fileContent) returns false.">
			<cfset errorReturn.statusCode 	= rawReturn.statusCode>
			<cfif arguments.formatType IS "JSON">
				<cfset errorReturn= serializeJSON(errorReturn)>
			</cfif>
		</cfif>
		<cfreturn errorReturn>
	</cffunction>


<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
<!---setTokenStorage()--->
<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
	<cffunction name="setTokenStorage">
		<cfargument name="accessToken" 					required="true" >
		<cfargument name="length"		type="numeric"	required="true"	default=30>
		
		<cfcookie name="sAccessToken" value="#arguments.accessToken#" expires="#arguments.length#">
		
		<cfreturn>
	</cffunction>
   
<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
<!---getTokenStorage()--->
<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
	<cffunction name="getTokenStorage">
		<cfif ISDefined("cookie.sAccessToken") AND cookie.sAccessToken NEQ "">
			<cfset session.sAccessToken = cookie.sAccessToken>
			<cfreturn cookie.sAccessToken>
		</cfif>
		<cfreturn "">
	</cffunction>

<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
<!---clearTokenStorage()--->
<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
	<cffunction name="clearTokenStorage">
		<cfset cookie.sAccessToken = "">
		<cfreturn>
	</cffunction>

</cfcomponent>