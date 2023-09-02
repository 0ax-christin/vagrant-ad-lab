param(
    [string] $forestVariables
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
#    see https://docs.microsoft.com/en-us/windows-server/identity/ad-ds/active-directory-functional-levels
Install-ADDSForest `
    -InstallDns `
    -CreateDnsDelegation:$false `
    -DomainName $forest.name `
    -SafeModeAdministratorPassword $safeModePassword `
    -NoRebootOnCompletion `
    -Force
    #-DomainNetbiosName $forest.netbiosName `

#some way to pause before next step

# Install certificate services
Install-WindowsFeature Adcs-Cert-Authority

Install-AdcsCertificationAuthority `
   -Force
#Disable vagrant account?
