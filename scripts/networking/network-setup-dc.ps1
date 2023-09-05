param(
 [string] $domain = "qwerty.local"
)
# Do this after ADDS install
$ip = (Get-NetAdapter | Get-NetIPAddress | ? addressfamily -eq 'IPv4').ipaddress.split(".")

Install-WindowsFeature -Name DNS

#Import our file with DNS entries for the DC
Import-CSV -Path C:\dns_entries.csv | ForEach-Object {
    Remove-DnsServerResourceRecord -ZoneName "$domain" -RRType "A" -Name $_.Hostname -force
    $hostfullIP = "$($ip[0]).$($ip[1]).$($ip[2])." + $_.IPEnd
    Add-DnsServerResourceRecordA -Name $_.Hostname -ZoneName "$domain" -IPv4Address $hostfullIP
}

#Add the DNS forwarder for outbound DNS
$forward = Get-DnsServerForwarder
Remove-DnsServerForwarder $forward.IPAddress -force
Add-DnsServerForwarder -IPAddress 8.8.8.8

$dnsip = "$($ip[0]).$($ip[1]).$($ip[2]).$($ip[3])"

Remove-DnsServerResourceRecord -ZoneName "$domain" -RRType "A" -Name "$domain" -force
Add-DNSServerResourceRecordA -Name "$domain" -ZoneName "$domain" -IPv4Address $dnsip

$index = Get-NetAdapter -Name 'Ethernet*' | Select-Object -ExpandProperty 'ifIndex'
Set-DnsClientServerAddress -InterfaceIndex $index -ServerAddresses $dnsip
