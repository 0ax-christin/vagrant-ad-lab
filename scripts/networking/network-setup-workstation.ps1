# Get the IP and store its octet digits in array
$ip = (Get-NetAdapter | Get-NetIPAddress | ? addressfamily -eq 'IPv4').ipaddress.split(".")

# Set DNS Server as the Active Directory Domain Controller
#$dnsip = "$($ip[0]).$($ip[1]).$($ip[2]).20"
$dnsip = "192.168.56.20"
$index = Get-NetAdapter -Name 'Ethernet*' | Select-Object -ExpandProperty 'ifIndex'
Set-DnsClientServerAddress -InterfaceIndex $index -ServerAddresses $dnsip
