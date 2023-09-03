if ($env:COMPUTERNAME -eq 'Windows1Machine') {
    Add-LocalGroupMember -Group "Administrators" -Member "MyWindows1"
    Add-LocalGroupMember -Group "Administrators" -Member "GROUPNAME\MyWindows1"
    Add-LocalGroupMember -Group "Administrators" -Member "GROUPNAME\MyWindows2"   
} elseif ($env:COMPUTERNAME -eq 'Windows2Machine') {
    Add-LocalGroupMember -Group "Administrators" -Member "MyWindows2"
    Add-LocalGroupMember -Group "Administrators" -Member "GROUPNAME\MyWindows1"
    Add-LocalGroupMember -Group "Administrators" -Member "GROUPNAME\MyWindows2"   
}


#Enable Local Admin
Enable-LocalUser -Name Administrator
# Reset Password
$password = "Password1!"
$localAdminPassword = ConvertTo-SecureString $password -AsPlainText -Force
Set-LocalUser -Name Administrator -Password $localAdminPassword –PasswordNeverExpires $true
