/// Description
Class dc.demo.imap.IMAPTestSendEmailOperation Extends Ens.BusinessOperation
{

/// 2 modes: Queue, InProc
Parameter INVOCATION = "Queue";

/// Name of the adapter class
Parameter ADAPTER = "dc.demo.imap.IMAPOutboundAdapter";

XData MessageMap
{
<MapItem MessageType="dc.demo.imap.IMAPTestReplyMsg">
<Method>EMailSendReply</Method>
</MapItem>
}

Method EMailSendReply(pRequest As dc.demo.imap.IMAPTestReplyMsg, Output pResponse As Ens.Response) As %Status
{
	
	;注意。少なくともYahooは認証情報とFromを一致させないと拒否する模様。
	Set pRequest.Sender=..Adapter.%CredentialsObj.Username
	Set pRequest.Destination=pRequest.Sender ; 自分に送り返す
	
	If pRequest.Destination = "" $$$TRACE("no email address.") Quit $$$OK
	$$$TRACE("send email to "_pRequest.Destination)
	Set tMailMessage = ##class(%Net.MailMessage).%New()
	Do tMailMessage.To.Insert(pRequest.Destination)
	Set tMailMessage.From = pRequest.Sender
	Set tMailMessage.Subject = "[IMAP test]"_pRequest.Text
	set tMailMessage.Charset = "UTF-8"
	Set tSC = tMailMessage.TextData.Write("Test.") 
    Quit:$$$ISERR(tSC) tSC
	Set tSC = ..Adapter.SendMail(tMailMessage)
	Quit tSC
}

}
