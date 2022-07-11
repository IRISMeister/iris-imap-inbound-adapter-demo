Class dc.demo.imap.python.IMAPPyProduction Extends Ens.Production
{

ClassMethod OnStart(pTimeStarted As %String) As %Status
{
  Set tSC=$$$OK
  Try {

    #; Docker Secretを使用しているため、コンテナ環境でしか機能しない。
    #; fileに実際のファイル名(gmail_client_secret.json)を絶対パスで指定すれば非コンテナ環境でも使用可能。

#if 0
    #; 非oAuth2の場合。
    Set file="/run/secrets/yahoo_cred"
    if ##class(%File).Exists(file) {
      Set stream = ##class(%Stream.FileCharacter).%New()
      Set sc = stream.LinkToFile(file)
      Set json = {}.%FromJSON(stream)
      Set tSC=##class(Ens.Config.Credentials).SetCredential("mail-yahoo",json.UserName,json.Password,1)
    }
#endif

    #; Refresh Tokenを使ったoAuth2認証の例
    #; AccountName,ClientId,ClientSecret,RefreshToken,TokenEndPointを取得し、プロダクションに反映する
    Set file="/run/secrets/gmail_client_secret"
    if ##class(%File).Exists(file) {
      Set stream = ##class(%Stream.FileCharacter).%New()
      Set sc = stream.LinkToFile(file)
      Set json = {}.%FromJSON(stream)

      Set tSC=##class(Ens.Config.Credentials).SetCredential("mail-gmail",json.AccountName,"",1)

      k p Do ##class(Ens.Director).GetAdapterSettings("IMAP-GMAIL",.p)
      Set p("ClientId")=json."client_id"
      Set p("ClientSecret")=json."client_secret"
      Set p("RefreshToken")=json."refresh_token"
      Merge settings("IMAP-GMAIL","Adapter")=p
      
	    k p Do ##class(Ens.Director).GetAdapterSettings("SMTP-GMAIL",.p)
      Set p("ClientId")=json."client_id"
      Set p("ClientSecret")=json."client_secret"
      Set p("RefreshToken")=json."refresh_token"
      Set p("TokenEndPoint")=json."token_uri"
      Merge settings("SMTP-GMAIL","Adapter")=p
      Set tSC=##class(Ens.Production).ApplySettings("dc.demo.imap.python.IMAPPyProduction",.settings)
    }
	}
	Catch e {
		Set tSC=e.AsStatus()
	}
  //常に成功させる
	Return $$$OK
}

XData ProductionDefinition
{
<Production Name="dc.demo.imap.python.IMAPPyProduction" TestingEnabled="true" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="IMAP-GMAIL" Category="mail,custom" ClassName="dc.demo.imap.python.IMAPPyTestService" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="true" Schedule="">
    <Setting Target="Adapter" Name="POP3Port">993</Setting>
    <Setting Target="Adapter" Name="POP3Server">imap.gmail.com</Setting>
    <Setting Target="Adapter" Name="Credentials">mail-gmail</Setting>
    <Setting Target="Adapter" Name="SSLConfig">ISC.FeatureTracker.SSL.Config</Setting>
    <Setting Target="Adapter" Name="Mailbox">INBOX</Setting>
    <Setting Target="Adapter" Name="CallInterval">30</Setting>
    <Setting Target="Adapter" Name="MatchSubject">[IMAP test]</Setting>
    <Setting Target="Adapter" Name="FilePath">/var/tmp/</Setting>
    <Setting Target="Adapter" Name="MatchFrom"></Setting>
    <Setting Target="Adapter" Name="MatchTo"></Setting>
    <Setting Target="Adapter" Name="SSLCheckServerIdentity">0</Setting>
  </Item>
  <Item Name="SMTP-GMAIL" Category="" ClassName="dc.demo.imap.IMAPTestSendEmailOperation" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="Credentials">mail-gmail</Setting>
    <Setting Target="Adapter" Name="SMTPPort">587</Setting>
    <Setting Target="Adapter" Name="SMTPServer">smtp.gmail.com</Setting>
    <Setting Target="Adapter" Name="SSLConfig">ISC.FeatureTracker.SSL.Config*</Setting>
    <Setting Target="Adapter" Name="From"></Setting>
    <Setting Target="Adapter" Name="Recipient"></Setting>
    <Setting Target="Adapter" Name="Bcc"></Setting>
    <Setting Target="Adapter" Name="Cc"></Setting>
    <Setting Target="Adapter" Name="ContinueAfterBadSend">1</Setting>
    <Setting Target="Adapter" Name="SSLCheckServerIdentity">0</Setting>
  </Item>
</Production>
}

}
