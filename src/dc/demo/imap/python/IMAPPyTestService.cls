Class dc.demo.imap.python.IMAPPyTestService Extends Ens.BusinessService
{

Parameter ADAPTER = "dc.demo.imap.python.IMAPPyInboundAdapter";

Method OnProcessInput(pMailMessage As %Net.MailMessage, pOutput As %RegisteredObject) As %Status
{
    Set tSC = $$$OK
    Try {
        $$$TRACE("received email from "_pMailMessage.From_". To "_pMailMessage.To.GetAt(1)_". Subject"_pMailMessage.Subject)
        $$$TRACE("ContentType: "_pMailMessage.ContentType)

        If pMailMessage.IsBinary
        {
            $$$TRACE("This message is binary; not expected")
            Quit
        }

        //Check if mail message has multiple parts
        If pMailMessage.IsMultiPart
        {
            $$$TRACE("This message has multiple parts.")

            Set parts=pMailMessage.Parts
            $$$TRACE("MultiPart Count:"_parts.Count())

            For i=1:1:parts.Count() {
                Set mp=parts.GetAt(i)
                $$$TRACE("mp.ContentType["_i_"]: "_mp.ContentType)

                if mp.IsMultiPart {
                    $$$TRACE("further multiple parts. Do nothing.")
                }
                Elseif mp.IsHTML {
                    $$$TRACE("HTML part. Do nithing.")
                }
                Elseif mp.IsBinary {
                    Set desc=mp.Headers.GetAt("Content-Description")  // expecting a attached filename.
                    Set disp=mp.Headers.GetAt("Content-Disposition")  
                    Set maildata=mp.BinaryData
                    Set data= maildata.Read(20) Do maildata.Rewind()
                    $$$TRACE("Binary part. : ContentType:"_mp.ContentType_" CharSet:"_mp.Charset_" Description:"_desc_" Disposition:"_disp_" Size:"_maildata.Size_" Data:"_$E(data,1,20))

                    Set file=..Adapter.FilePath_desc
                    $$$TRACE("Saving to "_file)
                    Set fs=##class(%Stream.FileBinary).%New()
                    Set fs.Filename=file
                    Set tSC=fs.CopyFrom(maildata) $$$ThrowOnError(tSC)
                    Set tSC=fs.%Save() $$$ThrowOnError(tSC)
                }
                Else {
                    Set desc=mp.Headers.GetAt("Content-Description")  // expecting a attached filename.
                    Set disp=mp.Headers.GetAt("Content-Disposition")  
                    Set maildata=mp.TextData // %Library.FileCharacterStream
                    Set data= maildata.Read(20) Do maildata.Rewind()
                    $$$TRACE("Other part. : ContentType:"_mp.ContentType_" CharSet:"_mp.Charset_" Description:"_desc_" Disposition:"_disp_" Size:"_maildata.Size_" Data:"_$E(data,1,20))

                    If desc'="" {  // text file attachment 
                        Set file=..Adapter.FilePath_desc
                        $$$TRACE("Saving to "_file)
                        Set fs=##class(%Stream.FileBinary).%New()  // Use FileBinary to save incoming steram data as is.
                        Do fs.LinkToFile(file)
                        Set tSC=fs.CopyFrom(maildata) $$$ThrowOnError(tSC)
                        Set tSC=fs.%Save() $$$ThrowOnError(tSC)                
                    }
                    Else {
	                    $$$TRACE("Plain message received. Do nothing.")
                    }
                }
            }
        }

        //Send it back to itself
        Set tSendReply = ##class(dc.demo.imap.IMAPTestReplyMsg).%New()
        Set tSendReply.Text = "[IMAP test] ("_$ZDATETIME($H)_")"  ; Subject
        Set tSendReply.Sender = pMailMessage.To.GetAt(1)
        Set tSendReply.Destination = tSendReply.Sender

        $$$TRACE("Sending Text:"_tSendReply.Text_" Destination:"_tSendReply.Destination_" Sender:"_tSendReply.Sender)
        Set tSC = ..SendRequestAsync("SMTP-GMAIL", tSendReply)
        $$$TRACE("SendRequestAsync to SMTP-GMAIL")
    } Catch(ex) {
        Set tSC = ex.AsStatus()
    }
    Quit tSC
}

}
