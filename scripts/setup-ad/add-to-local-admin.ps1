param(
    [string] $forestVariables = "forest-variables.json",
)
$forest = Get-Content -Raw -Path "C:\vagrant\provision\variables\${forestVariables}" | ConvertFrom-Json
# Add JSON creation or integrate and merge create-users and add-to-local-admin
if ($env:COMPUTERNAME -eq 'Windows1Machine') {
    Add-LocalGroupMember -Group "Administrators" -Member "MyWindows1"
    Add-LocalGroupMember -Group "Administrators" -Member "$($forest.capsName)\MyWindows1"
    Add-LocalGroupMember -Group "Administrators" -Member "$($forest.capsName)\MyWindows2"   
} elseif ($env:COMPUTERNAME -eq 'Windows2Machine') {
    Add-LocalGroupMember -Group "Administrators" -Member "MyWindows2"
    Add-LocalGroupMember -Group "Administrators" -Member "$($forest.capsName)\MyWindows1"
    Add-LocalGroupMember -Group "Administrators" -Member "$($forest.capsName)\MyWindows2"   
}


#Enable Local Admin
Enable-LocalUser -Name Administrator
# Reset Password
$password = "Password1!"
$localAdminPassword = ConvertTo-SecureString $password -AsPlainText -Force
Set-LocalUser -Name Administrator -Password $localAdminPassword -PasswordNeverExpires $true
