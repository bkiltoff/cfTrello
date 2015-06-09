<cfcomponent output="false" extends="rootProxy">
<cfset this.name="CFTrello">
<cfset this.sessionManagement = "yes">
<cffunction name="onApplicationStart" >
	<cfset application.apiURL					= "https://api.trello.com/1/">
	<cfset application.sConsumerKey 			= "821653d6e0f6fe0cbf6908f058b13596">
	<cfset application.sConsumerkeysecret 		= "6d78eee5baae66d007d30059c0d928978b27794779e0635b333d11771564617b">
	<cfset application.sTokenEndpoint			= "https://trello.com/1/OAuthGetRequestToken"> 		
	<cfset application.sAccessTokenEndpoint 	= "https://trello.com/1/OAuthGetAccessToken"> 	
	<cfset application.sAuthorizationEndpoint 	= "https://trello.com/1/OAuthAuthorizeToken"> 
	<cfset application.sCallbackURL 			= "#getHttpType()##cgi.server_name#/#listFirst(cgi.script_name, "/")#/callback.cfm"> 
	<cfreturn>	
</cffunction>

<cffunction name="onSessionStart">
	<cfset sessionInit()>	<!--- create a sessionInit structure --->
	<cfset session.login = createObject("component","com.timothycunningham.cftrello.login")>
</cffunction>

<cffunction name="onRequestStart">
	<cfif ISDefined("session") is false>
		<cfset onSessionStart()>
	</cfif>
	<cfif ISDefined("url.restart")>
    	
		<cfset onSessionStart()>
		<cfset onApplicationStart()>
	</cfif>
	<cfif ISDefined("url.clearMeCookies")>
		<cfset clearTokenStorage()>
	</cfif>
	<cfreturn>	
</cffunction>

<cffunction name="onRequest" >
	<cfargument name="targetPage" type="string" required="true" hint="The requested ColdFusion Template">
	<cfif arguments.targetPage NEQ replaceNoCase(application.sCallbackURL, "#getHttpType()##cgi.server_name#", "")>
		<cfset session.login.getTrelloLogin(targetPage=arguments.targetPage)>
	</cfif>
	<cfset var prc = getPRC()>
	<cfinclude template="#arguments.targetPage#">
</cffunction>


</cfcomponent>