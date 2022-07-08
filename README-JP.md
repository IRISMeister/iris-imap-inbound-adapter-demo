# iris-imap-inbound-adapter-demo

IMAP(Python版), SMTPにoAuth2認証を追加。

# 事前準備
[gmail_cred.template](gmail_cred.template)を参考に、gmail_cred.jsonを作成。  
この情報は、IMAP,SMTPサーバへのアクセス時に、ユーザ名として使用します。oAuth認証時はPasswordは不要です。

[gmail_client_secret.template](gmail_client_secret.template)を参考に、gmail_client_secret.jsonを作成。  
この情報は、IMAP,SMTPサーバへのoAuth2認証に使用します。

ClientID, ClientSecretには、GCPのコンソールで、デスクトップクライアント用に発行したoAuth2のクライアントIDを使用しました。  
Refresh Tokenの取得には、[oauth2.py](https://github.com/google/gmail-oauth2-tools/blob/master/python/oauth2.py)を使用しました。

```
$ python2 oauth2.py --user=xxxx@gmail.com \
    --client_id=xxxxxx.apps.googleusercontent.com \
    --client_secret=GOCSPX-yyyyyyy  \
    --generate_oauth2_token

Refresh Token: xxxxxxx
Access Token: yyyyyyyyyyyyyyyy
Access Token Expiration Seconds: 3599
```
# 実行
下記実行で、プロダクション起動、準備したjsonファイルの自動取り込み([IMAPPyProduction.cls](src/dc/demo/imap/python/IMAPPyProduction.cls)のOnStartを使用)を行います。

```
docker-compose up -d
```
安全策として、IMAP-GMAIL, SMTP-GMAILはいずれもdisableにしてあります。それぞれのパラメータ設定が適切に適用されていることを確認の上、有効化してください。

|host item|パラメータ名||
|:---|:---|:---|
|IMAP-GMAIL|RefreshToken||
|IMAP-GMAIL|ClientId||
|IMAP-GMAIL|ClientSecret||
|IMAP-GMAIL|認証情報||
|SMTP-GMAIL|RefreshToken||
|SMTP-GMAIL|ClientId||
|SMTP-GMAIL|ClientSecret||
|SMTP-GMAIL|TokenEndPoint||
|SMTP-GMAIL|認証情報||

最低でも、指定のアカウントに、件名に[IMAP test]を含む1通のメールが存在しないと、30秒毎にメールのチェックが走るだけで何も起こりません。下記で、そのようなメールを１通送信することが出来ます。

```
docker-compose exec iris iris session iris -U IRISAPP "Send"
```
以降、IMAP-GMAILサービスが30秒毎に件名に[IMAP test]を含むメールをチェックし、存在した場合、SMTP-GMAILオペレーションが自分自身に送信します。このループはプロダクションを停止するまで続行しますので、適当なタイミングで停止することをお勧めします(メールの送受信を延々と繰り返すことになります)。
