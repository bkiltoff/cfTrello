<cfset myBoardID="hXBxy7Rp">
<!--- <cfset session.boardID = myBoardID> --->
<!---
Application Variables
<cfdump var="#application#">
Session Variables
<cfdump var="#session#">
 --->

<b>Testing Boards</b><br>



<cfset boards = createObject("component" , "com.timothycunningham.cftrello.boards")>
<!--- <cfset lists = createObject("component" , "com.timothycunningham.cftrello.lists")> --->
<cfset cards = createObject("component" , "com.timothycunningham.cftrello.cards")>

<cfset boards = boards.getOpenLists(myBoardID)>

<cfset listID = toString(boards[1].id)>
<!--- 
<cfset cardInsert = cards.setCard(name="apiTest",idList="#listID#",desc="A test card")>

<br><em>Test3</em><br>
<cfdump var="#cardInsert#" label="cardInsert">
 --->


<!---  RAY SUGGESTED LOOKING INTO URL ENCODING AS THE SOURCE OF THESE ERRORS - COLDFUSION CFHTTPARAM TAG OF TYPE URL AUTOMATICALLY ENCODES VALUES
SO MAYBE SEE IF THE ENCODING IS HURTING THE VALUES BEING PASSED... --->
<cfset variables.return="">
<!--- the manual post method below verifies that listID is getting the right list and that setCard is failing --->
	<cfhttp method="post" 
			url="https://api.trello.com/1/cards/"
	result="variables.return">
			<cfhttpparam name="KEY"			type="URL"	value="821653d6e0f6fe0cbf6908f058b13596">
			<cfhttpparam name="NAME"		type="URl"	value="apiTest">
			<cfhttpparam name="DESC"		type="URl"	value="a test card">
			<cfhttpparam name="TOKEN"		type="URL"	value="e868a54dfb5f7669771b6c19bbc454d92dd32e292c2a6d6bbf6f2a290adb95e5">   <!---expires at 4:30pm--->
            <cfhttpparam name="IDLIST"		type="URL"	value="#listID#">
            <cfhttpparam name="DUE"			type="URL"	value=null>
            <cfhttpparam name="URLSOURCE"	type="URL"	value=null>
	</cfhttp>
<cfoutput>
<div>Output Test.cfm</div>
    <cfdump var="#GetHTTPRequestData()#">
    <cfdump var="#variables.return#">
<div>End output</div>
</cfoutput>