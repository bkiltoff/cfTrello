


<!--- test the cards.setCard() function  --->
<cfset cards	= createObject("component" , "com.timothycunningham.cftrello.cards")>
<cfset cardInsert = cards.setCard(cardName=#Form.cName#, targetListID=#Form.l_id#,cardDesc=#Form.cDesc#)>


<P>Your card has been submitted.</P>

<CFHEADER NAME="Refresh" VALUE="5; URL=./">