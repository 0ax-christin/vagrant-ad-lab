#
# OU is the optional path prefix, e.g. OU=Servers
#
param(
    [string] $forestVariables,
    [string] $ou = "default"
)

#This script will join the machine to the domain, based on the domain variables and added to the instructed OU

$domain = Get-Content -Raw -Path "C:\vagrant\provision\variables\${forestVariables}" | ConvertFrom-Json
echo "Pointing DNS"
# Point DNS at domain controller
$adapters = Get-WmiObject Win32_NetworkAdapterConfiguration
if ($adapters) {
    $adapters | ForEach-Object {$_.SetDNSServerSearchOrder($domain.dcIPAddress)}
}
echo "Creating account"
$securePassword = ConvertTo-SecureString $domain.administratorPassword -AsPlainText -Force
#must join with groupName.local rather than netbios
$username = $domain.name + "\Administrator" 
$domainAdminCredentials = New-Object System.Management.Automation.PSCredential($username, $securePassword)

$params = @{}
if ($ou -ne "default") {
    $params["OUPath"] = $ou + "," + $domain.dn
}
echo "Joining computer"
Add-Computer -DomainName $domain.name -Credential $domainAdminCredentials @params
echo "Computer Joined"

exit 0
