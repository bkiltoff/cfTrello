<cfcomponent>
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

	<cffunction name="sessionInit">
		<cfset session.oauth_token 			= "">
		<cfset session.sAccessToken 		= "">
		<cfset session.sAccessTokenSecret 	= "">
		<cfset session.oauth_verifier 		= "">
		<cfset session.boardID				= "">
		<cfreturn>
	</cffunction>
	
	<cffunction name="getHttpType">
		<cfif cgi.https is "off">
			<cfreturn "http://">
		<cfelse>
			<cfreturn "https://">
		</cfif>
		<cfreturn "http://">
	</cffunction>
	
	<cffunction name="setTargetPage">
		<cfargument name="targetPage" required="true" type="string" default="#getHttpType()##cgi.server_name#">
		<cfset session.targetPage = arguments.targetPage>
		<cfreturn session.targetPage>
	</cffunction>
	
	<cffunction name="getTargetPage">
		<cfreturn session.targetPage>
	</cffunction>
	
<!--- =========================================================================
==============================doApiCall========================================
=============================================================================== --->		
	<cffunction name="doApiCall" access="public" hint="generic caller to Trello API">
		<cfargument name="verb" 		type="string" 	required="true" 	default="get">
		<cfargument name="uriFilter" 	type="string" 	required="true" >
		
		<!--- Set up needed variables --->
		<cfif ISDefined("arguments.fields") IS False>
			<cfset arguments.fields = structNew()>
		</cfif>
		<cfif ISDefined("arguments.formatType") IS False>
			<cfset arguments.formatType = "Struct">
		</cfif>
        
	<!--- Test --->
    <cfoutput>
        <br>
            <cfdump var="serializeJson(arguments)=#serializeJson(arguments)#">
        <br>
    </cfoutput>
    <!--- End Test --->

		<cfset structAppend(variables,getPRC(),"true")>		
		<cfset variables.rawReturn = "">
		<cfset variables.arg = "">
		<cfset variables.apiCall = "">

		<cfset variables.apiCall = apiURL  & "#arguments.uriFilter#">

	<!--- test --->
    <cfoutput>
        <br>
            <cfdump var="ApiCall=#apiCall#">
        <br>
        	<cfset textfield= structNew()>
    </cfoutput>
    <!--- End Test --->
    
		<!--- Append the other arguments passed in as parameters to a cfhttp request--->
			<cfhttp url="#apiCall#" method="#arguments.verb#" result="variables.rawReturn">
                <cfhttpparam name="key" type="URL" value="#sConsumerKey#">
	<!--- Test --->
        <br>
            <cfset textfield.key = "#sConsumerKey#">
            <cfset textfield.verb= "#arguments.verb#">
        <br>
	<!--- End Test --->
                <cfif saccesstoken NEQ "">
                    <cfhttpparam name="token" type="URL" value="#sAccessToken#">
	<!--- Test --->
        <br>
            <cfset textfield.token = "#sAccessToken#">
        <br>
	<!--- End Test --->

                </cfif>

                <cfloop collection="#arguments#" item="arg">	
                    <cfif isSimpleValue(arguments[arg]) AND  arg NEQ "urifilter" AND arg NEQ "formatType" AND arg NEQ "Verb">	
                        <cfhttpparam name="#arg#" type="URL" value="#arguments[arg]#">

	<!--- Test --->
        <br>
            <cfset textfield[arg] = "#arguments[arg]#">
        <br>
	<!--- End Test --->
                        </cfif>
                </cfloop>	           		

			</cfhttp>		
	<!--- Test --->
	<cfoutput>
        <br>
            <cfdump var="#textfield#">
        <br>
    </cfoutput>
	<!--- End Test --->

		<cfset  return = getApiReturn(rawReturn, arguments.formatType)>
        
		<!--- 	--------------------------------------------------
                application seems to run fine without this block of code
        
        <!--- not sure what this block does (if anything) --->
                <cfset var return = structNew()>
                <cfset return.apiCall =  apiCall>
        <!---  end mystery block --->
                -------------------------------------------------- --->
 		<cfreturn return>
	</cffunction>

<!--- =========================================================================
==============================getApiReturn=====================================
=============================================================================== --->		
	
	<cffunction name="getAPIReturn" access="public" hint="Formats the return call from Trello">
		<cfargument name="rawReturn"  type="struct" required="true">
		<cfargument name="formatType" type="string" required="true" default="Struct" hint="JSON or Struct (Deserialized JSON)">
		<cfset var errorReturn = structNew()>

	<!---- test --->
            <cfset var fileContentToString = rawReturn.fileContent.toString()>
    <cfoutput>
            <br>
            <cfdump var="File content to string: #fileContentToString#">
            <br>
            <cfset boolStr = toString(isStruct(rawReturn))>
            <cfdump var="rawReturn is struct=#boolStr#">
    </cfoutput>
    <!---- end test --->

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

	<cffunction name="setTokenStorage">
		<cfargument name="accessToken" 					required="true" >
		<cfargument name="length"		type="numeric"	required="true"	default=30>
		
		<cfcookie name="sAccessToken" value="#arguments.accessToken#" expires="#arguments.length#">
		
		<cfreturn>
	</cffunction>
	
	<cffunction name="getTokenStorage">
		<cfif ISDefined("cookie.sAccessToken") AND cookie.sAccessToken NEQ "">
			<cfset session.sAccessToken = cookie.sAccessToken>
			<cfreturn cookie.sAccessToken>
		</cfif>
		<cfreturn "">
	</cffunction>
	
	<cffunction name="clearTokenStorage">
		<cfset cookie.sAccessToken = "">
		<cfreturn>
	</cffunction>

</cfcomponent>