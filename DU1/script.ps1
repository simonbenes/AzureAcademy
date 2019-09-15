<#
    .SYNOPSIS
        Skript domaci ulohy 1. Nastavi firewall, nainstaluje IIS
#>

Param (
    [string]$user,
    [string]$password
)

# Force use of TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Firewall
netsh advfirewall firewall add rule name="http" dir=in action=block protocol=TCP localport=80
netsh advfirewall firewall add rule name="https" dir=in action=allow protocol=TCP localport=443
netsh advfirewall firewall add rule name="rdp" dir=in action=allow protocol=TCP localport=3389
netsh advfirewall firewall add rule name="test" dir=in action=block protocol=TCP localport=1234

# Install iis
Install-WindowsFeature web-server -IncludeManagementTools

# Prepare certificate
$cert = New-SelfSignedCertificate -CertStoreLocation 'Cert:\LocalMachine\My' -DnsName 'demo.contoso.com'

# Configure iis
Remove-WebSite -Name "Default Web Site"
#Set-ItemProperty IIS:\AppPools\DefaultAppPool\ managedRuntimeVersion ""
New-Website -Name "Demo" -IPAddress * -Port 443 -Protocol https
$provider = 'IIS:\SSLBindings\0.0.0.0!443'
Get-Item $cert | New-Item $provider
& iisreset
