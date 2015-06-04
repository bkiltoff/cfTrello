<!---
a trelloAuth object represents a user who has access to a finite
set of boards, lists, etc. This object can make api calls to Trello.com
on behalf of the user whose API Key and token they are using, assuming
those artifacts are valid.
--->

<cfcomponent>
	<cfset Variables.apiKey 	= 	""		>
    <cfset Variables.token 		= 	""		>
    <cfset Variables.api		=	"1"		>
    <cfset Variables.apiURL		=	"https://api.trello.com/">
    <cfset Variables.orgName	=	""		>
	<cfset Variables.urls		=	[]		>
    
<!---
	init function
	initialize a trelloAuth object with an api key, a token, and api number
	establish URL for future api calls that will set the board dID
--->
  <cffunction name="init" access="public" returntype="Any" output="false">
  	<cfargument name="secretKey" 	type="string" required="yes">
    <cfargument name="privateToken" type="string" required="yes">
    <cfargument	name="apiNumber"	type="numeric" required="no" default="1">
    <cfargument	name="organization"	type="string" required="no" default="">
    	<cfset Variables.apiKey		=	#secretKey#>
        <cfset Variables.token 		= 	#privateToken#>
        <cfset Variables.orgName	=	#organization# & "/">
		<cfscript>
		/*	this script checks to see if the apiNumber argument was supplied
			if it was, set the api variable to the new value
		*/
			if(apiNumber != 1) 
			{
				Variables.api = ToString(apiNumber);
			}
        </cfscript>
        <!--flesh out the URL that will be used for future calls-->
        <cfset Variables.apiURL 				=	#Variables.apiURL# & #Variables.api# & "/"	>
        <cfset Variables.urls["boards"]			= 	#Variables.apiURL# & "boards/"				>
	    <cfset Variables.urls["cards"]			= 	#Variables.apiURL# & "cards/"				>
    	<cfset Variables.urls["lists"]			= 	#Variables.apiURL# & "lists/"				>
    	<cfset Variables.urls["members"] 		= 	#Variables.apiURL# & "members/"				>
    	<cfset Variables.urls["organizations"]	= 	#Variables.apiURL# & "organizations/"		>
    <cfreturn this>
  </cffunction>

<!---
	setBoardID
	set the BoardID so that the url for boards will go to a specific board
	not useful if the apiKey and token are not permitted access to this board
--->
  <cffunction name="setBoardID" access="private" returntype="void" output="false">
  	<cfargument name="boardID" type="string" required="yes">
    	<cfset Variables.urls["boards"]		=	Variables.urls["boards"] & #boardID#	>
  </cffunction>
  

<!---
	getBoardID
	get the id number of a board based on its name
	get a list of open boards that are in the organization
	search the list for a board with a name that matches the string
	if more than one board has the same name, throw an error
	otherwise return the resulting board's id
--->
	<cffunction name="getBoardID" access="private" returntype="string" output="false">
    	<cfargument name="boardName" type="string" required="yes">
			<cfscript>
				resultID = "";
				count = 0;
				accessibleBoards = getBoardList();
				for(i = 1; i <= ArrayLen(accessibleBoards); i++)
				{
					if(accessibleBoards[i].name == "#boardName#")
					{	
						try
						{
							count++;
							if(count == 1)
							{
								resultID = accessibleBoards[i].id;
							} else
							{
								Throw(type="InvalidData",message="More than one board in accessibleBoards[].");
							}
						}
						catch(InvalidData bc)
						{
							WriteOutput("<p>More than one open Trello Boards with the same name in this organization</p>");
							WriteOutput("<p>#bc.message#</p>");
						}
					}
					return resultID;						
				}
			</cfscript>
    </cffunction>
    
    
<!---
	getBoardLists
	return open, unarchived lists from a board (boardID)
	
	create empty array
	GET boards/BoardID/lists
	filter="not unarchived"
	set array = deserializedjson(cfhttp)
--->

<!---
	getListID
	find the id of a list from a small set of lists, based on its name
	
	set array=getBoardLists(boardID);
	set soughtID=""
	for each list in array
		if name = nameSought
			increment counter
				try
					if counter is greater than 1
						throw error
					else
						soughtID=list[i]id;
				catch(error)
					message	
			return soughtID	
--->
    

<!---
	get a list of boards belonging to the organization that are open\
--->
  <cffunction name="getBoardList" access="public" returntype="array" output="false">
	<cfset urlAddress = #Variables.apiURL# & "organizations/" & "#Variables.orgName#" &  "boards">
  	<cfhttp method="get"	
    		url="#urlAddress#"	>
            <cfhttpparam name="key"		type="URL"	value="#Variables.apiKey#"	>
            <cfhttpparam name="token"	type="URL"	value="#Variables.token#"	>
            <cfhttpparam name="filter"	type="URL"	value="open"				>
            <cfhttpparam name="fields"	type="URL"	value="name"				>
    </cfhttp>
    <cfset arrayOfBoards = DeserializeJSON(cfhttp.FileContent)>
    <cfreturn arrayOfBoards>
  </cffunction>

<!---
	add card to list
	https://trello.com/docs/api/card/index.html#post-1-cards
--->	
	<cffunction name="postCardToList" access="public" returntype="any" output="false">
    	<cfargument name="name" 		type="string" 	required="yes">
    	<cfargument name="idlist" 		type="string" 	required="yes">
    	<cfargument name="due" 			type="string" 	required="yes" 		default="null">
    	<cfargument name="urlsource"	type="string" 	required="yes" 		default="null">
    	<cfargument name="idmembers" 	type="string" 	required="no">
    	<cfargument name="desc" 		type="string" 	required="no">
    	<cfargument name="pos" 			type="string" 	required="no">
    	<cfargument name="labels" 		type="string" 	required="no">
        	<cfhttp method="post"
            		url="#Variables.cardsURL#">
				<!--security token-->
					<cfhttpparam name="key"			type="URL"	value="#Variables.apiKey#">
		            <cfhttpparam name="token"		type="URL"	value="#Variables.token#">
				<!--required parameters 556de83bb60f99800c2c2a79-->                    
					<cfhttpparam name="name"		type="URL" 	value="#arguments.name#">
                    <cfhttpparam name="idlist"		type="URL" 	value="#arguments.idlist#">
					<cfhttpparam name="due"			type="URL" 	value="#arguments.due#">
                    <cfhttpparam name="urlsource" 	type="URL" 	value="#arguments.urlsource#">
<!---				<!--optional parameters-->
                	<cfset argumentCount = #ArrayLen(Arguments)#>
					<cfif argumentCount gt 4>						
                       <cfhttpparam name="idmembers" 	type="URL" 	value="#arguments.idmembers#">
                        <cfhttpparam name="desc" 		type="URL" 	value="#arguments.desc#">
                        <cfhttpparam name="pos" 		type="URL" 	value="#arguments.pos#">
                        <cfhttpparam name="labels"		type="URL" 	value="#arguments.labels#">
					</cfif>
--->
            </cfhttp>
		<cfreturn cfhttp.FileContent>
    </cffunction>

<!---
	test function
--->
	<cffunction name="TEST" access="public" returntype="string">
    	<cfargument name="nameofarg" type="string" default="null">
    	<cfset boardIDs = getBoardList()>
        <cfset boardsList = "">
        <cfscript>
		/*This script creates a string of boardIDs from boardIDs*/
		for (i = 1; i <= ArrayLen(boardIDs); i++)
		{
			boardsList = boardsList & ", " & boardIDs[i].name;
		}
		</cfscript>
		<cfset myResult=	"key=" 			& 	Variables.apiKey 	& "<br>" &	
							"token="		&	Variables.token		& "<br>" &
							"org="			&	Variables.orgName	& "<br>" &
							"boardURL="		&	Variables.boardURL 	& "<br>" &
							"listsURL=" 	&	Variables.listsURL	& "<br>" &
							"cardsURL=" 	&	arguments.nameofarg	& "<br>" &
							"listOfBoards="	& 	boardsList 			& "<br>" 
		>
		<cfreturn myResult>
	</cffunction>
    
</cfcomponent>