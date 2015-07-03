

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
<!--- Instantiate some objects --->
<cfset boards	= createObject("component" , "com.timothycunningham.cftrello.boards")> 
<cfset lists	= createObject("component" , "com.timothycunningham.cftrello.lists")>
<cfset cards	= createObject("component" , "com.timothycunningham.cftrello.cards")>
<!--- get the idList for the test list on my board --->
<cfset boards	= boards.getOpenLists(myBoardID)>
<!---  CFDUMP ---><cfdump var="#boards#" label="getOpenLists(#myBoardID#)"><!---  /CFDUMP --->
<cfset listID 	= boards[1].id>
<!--- test the cards.setCard() function  --->
<cfset cardInsert = cards.setCard(cardName="apiTest", targetListID=#listID#,cardDesc="A test card created using the insertCard function")>
<!---  CFDUMP ---><cfdump var="#cardInsert#" label="cardInsert"><!---  /CFDUMP --->
