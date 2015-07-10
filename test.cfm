

<cfset myBoardID="hXBxy7Rp">

 <!--- <cfset session.boardID = myBoardID> --->
<!---
Application Variables
<cfdump var="#application#">
Session Variables
<cfdump var="#session#">
 --->
<!---
get a token for read/write for 1day = "https://trello.com/1/authorize?key=821653d6e0f6fe0cbf6908f058b13596&name=Test_App&expiration=1day&response_type=token&scope=read,write,account"
--->
<b>Tests</b><br>

<cfinclude template="cardForm.cfm">