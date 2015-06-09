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
<cfset lists = createObject("component" , "com.timothycunningham.cftrello.lists")>
<cfset test= boards.getOpenLists(myBoardID)>

<br><em>Test3</em><br>
<cfdump var="#test#" label="getOpenLists">