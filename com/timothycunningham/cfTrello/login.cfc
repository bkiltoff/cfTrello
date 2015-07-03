<!----------------------------------------------------------------------------->
<!---login.cfc--->
<!----------------------------------------------------------------------------->
<cfcomponent extends="root" >
	<cfset structAppend(variables,getPRC(),"true")>
    
<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
<!---isLoggedIn() returns true if oauth token and saccesstoken are not blank--->
<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
	<cffunction name="isLoggedIn">
		<!--- <cfset var accesstoken = getTokenStorage()>
		<cfdump var="#accesstoken#"> --->
		<cfif session.oauth_token IS "" AND session.saccesstoken IS "">
			<cfreturn false>
		</cfif>
		<cfreturn true>
	</cffunction>
    
<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
<!---getTrelloLogin() if not logged in, follows OAuth workflow to get access tokens
stored into cookies. Calls the Trello server for a request token and then redirects
to the Trello authentication site to have user authorize token. On callback,
invokes the setTokens() function --->
<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
	<cffunction name="getTrelloLogin">
		<cfargument name="targetPage" 	
        			required="true" 	
                    type="string" 	
        			default="#getHttpType()##cgi.server_name#">
        <cfargument name="sitename"
        		 	required="true"
					type="string"
					default="#cgi.script_name#"			
                    hint="name of website app">
		<cfargument name="scope"
        	 		required="true" 	
                    type="string"	
			        default="read,write" 	
                    hint="[read][write][account]">
        <cfargument name="expiration"
        			required="true"
                    type="string"
			        default="1day"			
                    hint="[1hour][1day][30days][never]">		
		
		<cfif isLoggedIn() IS true>
			<cfreturn true>
		</cfif>
        
		<cfset setTargetPage(arguments.targetPage)>
		<cfset var parameters 			=	structNew()>
		<cfset parameters["scope"] 		=	arguments.scope>
        <cfset parameters["name"]		=	arguments.sitename>
        <cfset parameters["expiration"]	=	arguments.expiration>
		<!--- sAuthURL will be the URL 	for redirecting 
		the browser to Trello to authorize a token --->
        <cfset var sAuthURL 			= ""> 
		
        
        <!--- oReqSigMethodSHA object will be used to create signature string --->
		<cfset var oReqSigMethodSHA		= CreateObject("component", 
									"com.oauth.oauthsignaturemethod_hmac_sha1")>
		<!--- oToken will be used to hold token/secret values received from server 
		and generate encoded strings from those token values--->
		<cfset var oToken				= CreateObject("component", 
									"com.oauth.oauthtoken").createEmptyToken()>
		<!--- oConsumer will be used to hold token/secret values to be sent to 
		the server. These values are hardcoded in application.cfc --->
		<cfset var oConsumer			= CreateObject("component", 
									"com.oauth.oauthconsumer").init(sKey = 
									sConsumerKey, sSecret = sConsumerkeysecret)>
		<!--- oReq is the object that generates the first request, sent to 
		sTokenEndpoint: "https://trello.com/1/OAuthGetRequestToken" 
		this request asks the Trello server for a request token --->
        <cfset var oReq 				= CreateObject("component", 
									"com.oauth.oauthrequest").fromConsumerAndToken(
										oConsumer = oConsumer,oToken = oToken,
										sHttpMethod = "get",
										sHttpURL = sTokenEndpoint)>

        
        <!--- sign the request --->
		<cfset oReq.signRequest(oSignatureMethod=oReqSigMethodSHA,
									oConsumer=oConsumer,oToken=oToken)>
		<!--- send the request --->
		<cfhttp url="#oREQ.getString()#" method="get" result="tokenResponse"/>

		<!--- get the token and secret from the trello server's response --->
		<cfif findNoCase("oauth_token",tokenresponse.filecontent)>
			<cfset var sRequestToken 		= listlast(listfirst(
											tokenResponse.filecontent,"&"),"=")>
			<cfset var sRequestTokenSecret 	= listlast(listgetat(
											tokenResponse.filecontent,2,"&"),"=")>
		<cfelse>
	 		<cfdump var="#tokenresponse.filecontent#" label="getTrelloLogin-2">
		</cfif>
		
        <!--- add the special sauce to sCallbackURL --->
		<cfset var sCallbackURL	= sCallbackURL & "?" &  "key=" & sConsumerKey & 
							"&" & "secret=" & sConsumerkeysecret & "&" & 
							"token=" & sRequestToken & "&" & "token_secret=" & 
							sRequestTokenSecret & "&" & "endpoint=" & 
							URLEncodedFormat(sAuthorizationEndpoint)>

		<!---  redirect the browser (resource owner) to Trello and pass the
		oauth_token and the sCallbackURL (above) so that the server can identify
		the request and redirect back to the client once the authorized.
		Also include the scope,expiration,name parameters--->
		<cfset var parameterString = "">
        <cfloop list="#structKeyList(parameters)#" index="i" >
            <cfset parameterString = parameterString & i & "=" & parameters[i] & "&" />
        </cfloop>            
 		<cfset var AuthURL	= sAuthorizationEndpoint & "?" & parameterString &
							"oauth_token=" & sRequestToken & "&" & 
							"oauth_callback=" & URLEncodedFormat(sCallbackURL)>
 
		<cflocation url="#sAuthUrl#" >	
		<cfreturn>
	</cffunction>


<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
<!---setTokens() - this method is called when callback.cfm is loaded
	the argument "returned" that callback.cfm passes is the URL scope 
	This function basically takes the authorization token received from the 
	Trello server and the resource owner and uses them to get access tokens
	that are saved as application-scoped variables --->
<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
	<cffunction name="setTokens">
		<cfargument name="returned" type="struct" required="true" default="structNew()">
		<cfset structAppend(session,returned,"true")>
        
        <!--- Handle case where user selected "Deny" --->
		<cfif StructKeyExists(url,"oauth_token") NEQ True>
			<cflocation url="accessDenied.cfm" addtoken="no" />
        </cfif>
        
		<cfset oReqSigMethodSHA 				= CreateObject("component", 
									"com.oauth.oauthsignaturemethod_hmac_sha1")>
		<cfset var oToken 						= CreateObject("component", 
									"com.oauth.oauthtoken").init(
									sKey= url.oauth_token,sSecret=url.token_secret)>
		<cfset var oConsumer 					= CreateObject("component", 
									"com.oauth.oauthconsumer").init(
									sKey = sConsumerKey, sSecret = sConsumerkeysecret)>
		<cfset var Parameters 					= structNew()>
		<cfset var parameters.oauth_verifier	= url.oauth_verifier>
		<cfset var oReq 						= CreateObject("component", 
									"com.oauth.oauthrequest").fromConsumerAndToken(
									oConsumer = oConsumer,
									oToken = oToken,
									sHttpMethod = "GET",
									sHttpURL = sAccessTokenEndpoint,
									stparameters= Parameters )>
		<cfset oReq.signRequest(oSignatureMethod = oReqSigMethodSHA,
								oConsumer = oConsumer,oToken = oToken)>		
		<cfhttp url="#oREQ.getString()#" method="get" result="tokenResponse"/>
		<cfif findNoCase("oauth_token",tokenresponse.filecontent)>
			<cfset sAccessToken = listlast(listfirst(
											tokenResponse.filecontent,"&"),"=")>
			<cfset sAccessTokenSecret = listlast(listgetAt(
											tokenResponse.filecontent,2,"&"),"=")>
		</cfif>
		<cfset session.sAccessToken 		= sAccessToken>
		<cfset session.sAccessTokenSecret 	= sAccessTokenSecret>
		<cfset setTokenStorage(sAccessToken)>
		<cfreturn true>
	</cffunction>

<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
<!---setTokenStorage()--->
<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
	<cffunction name="setTokenStorage">
		<cfargument name="accessToken" 					required="true" >
		<cfargument name="length"		type="numeric"	required="true"	default=30>
		
		<cfcookie name="sAccessToken" value="#arguments.accessToken#" 
        											expires="#arguments.length#">
		
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