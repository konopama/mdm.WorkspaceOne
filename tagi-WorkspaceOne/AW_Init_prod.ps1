

$api =  'place_your_API_key_here' 
$URI = 'https://mdmconsole.danone.com/API/'

$Credentials = Get-Credential
$Base64Auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credentials.GetNetworkCredential().username + ":" + $Credentials.GetNetworkCredential().password ))
$BasicCredentials = "Basic " + $Base64Auth

#Create header
$ContentType = 'application/json; charset=utf-8'
$headers = @{"aw-tenant-code" = $api; "Authorization"= $BasicCredentials}

#authenticate your Powershell Proxy session
$webclient=New-Object System.Net.WebClient
$webclient.Proxy.Credentials=$Credentials