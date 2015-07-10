<cfcomponent output="false" extends="rootProxy">
<cfset this.name="CFTrello Test API Thing">
<cfset this.sessionManagement = "yes">

<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
<!---onApplicationStart()--->
<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
<cffunction name="onApplicationStart" >
	<cfset this.serialization.preservecaseforstructkey = true>
	<cfset application.apiURL					= "https://api.trello.com/1/">
	<cfset application.sConsumerKey 			= "821653d6e0f6fe0cbf6908f058b13596">
	<cfset application.sConsumerkeysecret 		= "6d78eee5baae66d007d30059c0d928978b27794779e0635b333d11771564617b">
	<cfset application.sTokenEndpoint			= "https://trello.com/1/OAuthGetRequestToken"> 		
	<cfset application.sAccessTokenEndpoint 	= "https://trello.com/1/OAuthGetAccessToken"> 	
	<cfset application.sAuthorizationEndpoint 	= "https://trello.com/1/OAuthAuthorizeToken"> 
	<cfset application.sCallbackURL 			= "#getHttpType()##cgi.server_name#:8500/#listFirst(cgi.script_name, "/")#/callback.cfm"> 
	<cfreturn>	
</cffunction>


<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
<!---onSessionStart()--->
<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
<cffunction name="onSessionStart">
	<!--- create a sessionInit structure --->
	<cfset sessionInit()>
	<!---  create session-scoped login object from login.cfc --->
	<cfset session.login = createObject("component","com.timothycunningham.cftrello.login")>
</cffunction>


<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
<!---onRequestStart()--->
<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
<cffunction name="onRequestStart">
	<!--- check if session is defined, if not call onSessionStart --->
	<cfif ISDefined("session") is false>
		<cfset onSessionStart()>
	</cfif>
    <!--- check if url restart parameter is passed; if so, 
	call onSessionStart, onApplicationStart methods --->
	<cfif ISDefined("url.restart")>  	
		<cfset onSessionStart()>
		<cfset onApplicationStart()>
	</cfif>
    <!--- check if url clearMeCookies paramter is passed; if so
	call clearTokenStorage method --->
	<cfif ISDefined("url.clearMeCookies")>
		<cfset clearTokenStorage()>
	</cfif>
	<cfreturn>	
</cffunction>


<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
<!---onRequest()--->
<!----------------------------------------------------------------------------->
<!----------------------------------------------------------------------------->
<cffunction name="onRequest" >
	<cfargument name="targetPage" type="string" required="true" hint="The requested ColdFusion Template">
	<!--- if requested page is not ""callback.cfm"--->

	<cfif arguments.targetPage NEQ replaceNoCase(application.sCallbackURL, "#getHttpType()##cgi.server_name#:8500", "")>
    	<!--- then call getTrelloLogin method --->
		<cfset session.login.getTrelloLogin(targetPage=arguments.targetPage)>
	</cfif>

	<cfset var prc = getPRC()>
    <!--- pull up targetPage --->
	<cfinclude template="#arguments.targetPage#">
</cffunction>


</cfcomponent>