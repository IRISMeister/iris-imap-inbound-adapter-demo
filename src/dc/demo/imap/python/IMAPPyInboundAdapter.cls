/// Description
Class dc.demo.imap.python.IMAPPyInboundAdapter Extends EnsLib.EMail.InboundAdapter
{

/// Description
Property MailServer As dc.demo.imap.python.POP3ToIMAPPyAdapter;

/// Description
Property Mailbox As %String [ InitialExpression = "INBOX" ];

Property FilePath As %String(MAXLEN = 1000);

Property RefreshToken As %String(MAXLEN = 500);

Property ClientId As %String(MAXLEN = 500);

Property ClientSecret As %String(MAXLEN = 500);

Parameter SETTINGS = "POP3Server:Basic,POP3Port:Basic,Credentials:Basic:credentialsSelector,SSLConfig:Connection:sslConfigSelector,SSLCheckServerIdentity:Connection,MatchFrom,MatchTo,MatchSubject,Mailbox,FilePath,RefreshToken:Connection,ClientId:Connection,ClientSecret:Connection";

Method OnInit() As %Status
{
    $$$TOE(sc, ##super())
    Do ..MailServer.SetMailboxName(..Mailbox)
    Do ..MailServer.SetRefreshToken(..RefreshToken)
    Do ..MailServer.SetClientId(..ClientId)
    Do ..MailServer.SetClientSecret(..ClientSecret)
    Return $$$OK
}

}
