<cfset myBoardID="hXBxy7Rp">
<!--- Instantiate some objects --->
<cfset boards	= createObject("component" , "com.timothycunningham.cftrello.boards")> 
<cfset lists	= createObject("component" , "com.timothycunningham.cftrello.lists")>

<!--- get the idList for the test list on my board --->
<cfset boards	= boards.getOpenLists(myBoardID)>
<cfset listID 	= boards[1].id>

<form action="submit.cfm" method="post" name="submitCard">
	<input type="hidden" name="l_id" value="#listID#"/>
    <label>List ID: <cfoutput>#listID#</cfoutput></label>
    <br>
    <label>List Name: <cfoutput>#lists.getField(listID,"name")["_value"]#</cfoutput></label>
    <br>
    <label>Card Name: <input name="cName" type="text" required="yes" size="20"></input></label>
    <br>
    <label>Card Desc: <textarea name="cDesc" required maxlength="500"></textarea></label>
	<input type="submit" value="Submit">
</form>
