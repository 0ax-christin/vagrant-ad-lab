<#
    This script installs Active Directory Certificate Services as per Step 7 needed for LDAPS
#>
try {
    Import-Module ActiveDirectory -ErrorAction Stop
} catch {
    throw "Module ActiveDirectory not Installed"
}

# Install certificate services
Install-WindowsFeature Adcs-Cert-Authority -IncludeManagementTools

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
Install-Module -Name PSPKI -Force | Out-Null
Import-Module PSPKI


$domainDn = (Get-ADDomain).DistinguishedName
$caCommonName = 'Standalone Root CA'

Import-Module ADCSDeployment

# Specify validity period to 99 as per Step 7
Install-AdcsCertificationAuthority `
    -CAType StandaloneRootCA `
    -CACommonName $caCommonName `
    -HashAlgorithmName SHA256 `
    -KeyLength 4096 `
    -ValidityPeriodUnits 99 `
    -ValidityPeriod Years `
    -Force
