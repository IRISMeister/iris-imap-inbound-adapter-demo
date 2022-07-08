Class dc.demo.imap.IMAPOutboundAdapter Extends EnsLib.EMail.OutboundAdapter
{

Property TokenEndPoint As %String(MAXLEN = 500);

Property AccessToken As %String(MAXLEN = 500);

Property RefreshToken As %String(MAXLEN = 500);

Property ClientId As %String(MAXLEN = 500);

Property ClientSecret As %String(MAXLEN = 500);

Property ExpiresIn As %Integer;

Property LastRefreshedTime As %PosixTime [ InitialExpression = 0 ];

Parameter SETTINGS As %String = "RefreshToken:Connection,ClientId:Connection,ClientSecret:Connection,TokenEndPoint:Connection";

Method OnInit() As %Status
{
	Set tSC=$$$OK
	Do ##super()
	
	Try {
		If (..RefreshToken'="") {
		    Set ..SMTP.authenticator.MechanismList="XOAUTH2"
		}
	}
	Catch(e) {
		Set tSC=e.AsStatus()
	}

	Quit tSC
}

Method SendMail(pMailMessage As %Net.MailMessage, Output pFailedRecipients As %ListOfDataTypes) As %Status
{
	Set tSC=$$$OK
	Try {
		// refresh token if expired.
		Set currenttime=$NORMALIZE(##CLASS(%Library.PosixTime).CurrentTimeStamp(0)/1000000,0)    //seconds in posix
		If (currenttime-..LastRefreshedTime+30)>..ExpiresIn {  // add 30 seconds for safety 
		    Set resp=..GetAccessToken()
		    Set ..AccessToken=resp."access_token"
		    Set ..ExpiresIn=resp."expires_in"
		    Set ..LastRefreshedTime=currenttime
		    Set ..SMTP.authenticator.AccessToken=..AccessToken
		}
	}
	Catch(e) {
		Set tSC=e.AsStatus()
		Return tSC
	}
		
	Quit ##super(pMailMessage ,.pFailedRecipients)
}

Method GetAccessToken()
{
    Try {
    	Set req = ##class(%Net.HttpRequest).%New()
	    Set req.SSLConfiguration="ISC.FeatureTracker.SSL.Config" 
	    Do req.SetParam("client_id",..ClientId)     
	    Do req.SetParam("client_secret",..ClientSecret)             
	    Do req.SetParam("refresh_token",..RefreshToken)
	    Do req.SetParam("grant_type","refresh_token")
	    Do req.Post("https://accounts.google.com/o/oauth2/token")  

	    Set resData = req.HttpResponse.Data
	    Set json=resData.Read(req.HttpResponse.Data.Size)  
    }
	Catch(e) {
		Set tSC=e.AsStatus()
		Return ""
	}
    
    Return {}.%FromJSON(json)
}

}
