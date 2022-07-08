Class App.Installer
{

XData setup
{
<Manifest>
  <Default Name="Namespace" Value="IRISAPP"/>
  <Default Name="app" Value="irisapp" />
  <Var Name="ProductionName" Value="dc.demo.imap.python.IMAPPyProduction"/>

  <Namespace Name="${Namespace}" Code="${Namespace}" Data="${Namespace}" Create="yes" Ensemble="1">

    <Configuration>
      <Database Name="${Namespace}" Dir="/opt/${app}/data" Create="yes" Resource="%DB_${Namespace}"/>
    </Configuration>
    <CSPApplication Url="/csp/${app}" Directory="${cspdir}${app}"  ServeFiles="1" Recurse="1" MatchRoles=":%DB_${Namespace}" AuthenticationMethods="32"
       
    />

    <Invoke Class="%SYSTEM.OBJ" Method="ImportDir" CheckStatus="true">
      <Arg Value="${SRCDIR}" />
      <Arg Value="" />
      <Arg Value="ck" />
      <Arg Value=".e" />
      <Arg Value="1" />
    </Invoke>
	  <Production Name="${ProductionName}" AutoStart="1">
	  <Credential Name="mail-gmail" Username="test" Password="test" Overwrite="1"/>
    </Production>
  </Namespace>

</Manifest>
}

ClassMethod setup(ByRef pVars, pLogLevel As %Integer = 3, pInstaller As %Installer.Installer, pLogger As %Installer.AbstractLogger) As %Status [ CodeMode = objectgenerator, Internal ]
{
  #; Let XGL document generate code for this method. 
  Quit ##class(%Installer.Manifest).%Generate(%compiledclass, %code, "setup")
}

}
