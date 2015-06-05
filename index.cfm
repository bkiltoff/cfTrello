
<!---
https://api.trello.com/1/boards/P66f8VXz
apikey = 821653d6e0f6fe0cbf6908f058b13596
get a token for read/write for 1day = "https://trello.com/1/authorize?key=821653d6e0f6fe0cbf6908f058b13596&name=Test_App&expiration=1day&response_type=token&scope=read,write"
--->

<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>Test Trello Injector</title>
</head>

<body>
<p><a href="reset.cfm">Reset application</a></p>
    
<!--- set variables --->
<cfset trelloKey		=	"821653d6e0f6fe0cbf6908f058b13596"										/>
<cfset trelloToken		=	"62fd9c330ad78e440901595e3db4b3db23dfd85be2632edaf415c1206c5eb6cf" 		/>
<cfset trelloBoardID	=	"P66f8VXz"																/>
<cfset trelloAPInumber	=	1																		/>
<cfset trelloOrgName	=	"snoisleit"																/>

<!--- initialize trello object --->
<cfset trelloConnection = CreateObject("component","trelloAuth").init(#trelloKey#,#trelloToken#,#trelloAPInumber#,#trelloOrgName#) 	/>

<cfscript>
trelloConnection.setBoardID(boardID=#trelloBoardID#);
</cfscript>

<cfoutput>
#trelloConnection.TEST()#
</cfoutput>

