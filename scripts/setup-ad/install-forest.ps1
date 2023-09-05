<#
    This script performs the installation of ADDS and Certificate Services on the Windows Server to promote it to a DOmain controller
    It reads from 'provision/variables/forest-variables.json' to get the variable values such as Safe mode password, administrator password, domain name, etc

    Local Admin is given the same password as Domain Admin
    Domain name is specified as qwerty.local and password is also taken from forest-variables.json

    As per Lab1, this script performs step 1 to 7

#>

param(
    [string] $forestVariables = "forest-variables.json"
)

$forest = Get-Content -Raw -Path "C:\vagrant\provision\variables\${forestVariables}" | ConvertFrom-Json
echo 'Resetting the Administrator account password and settings...'
$localAdminPassword = ConvertTo-SecureString $forest.administratorPassword -AsPlainText -Force
Set-LocalUser `
    -Name Administrator `
    -AccountNeverExpires `
    -Password $localAdminPassword `
    -PasswordNeverExpires:$true `
    -UserMayChangePassword:$true

echo 'Installing the AD services and administration tools...'
Install-WindowsFeature AD-Domain-Services,RSAT-AD-AdminCenter,RSAT-ADDS-Tools

$safeModePassword = ConvertTo-SecureString $forest.safeModeAdministratorPassword -AsPlainText -Force

echo 'Installing the AD forest (be patient, this will take more than 30m to install)...'

Import-Module ADDSDeployment
# NB ForestMode and DomainMode are set to WinThreshold (Windows Server 2016).
#    as per https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/active-directory-functional-levels
Install-ADDSForest `
    -InstallDns `
    -CreateDnsDelegation:$false `
    -DomainName $forest.name `
    -DomainNetbiosName $($forest.name -split '\.')[0].ToUpperInvariant() `
    -DomainMode 'WinThreshold' `
    -ForestMode 'WinThreshold' `
    -SafeModeAdministratorPassword $safeModePassword `
    -NoRebootOnCompletion `
    -Force
