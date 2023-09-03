$machinePass = "Password1!"
$password = ConvertTo-SecureString $machinePass -AsPlaintext -Force
if ($env:COMPUTERNAME -eq 'Windows1Machine') {
    New-LocalUser -Name "MyWindows1" -Password $password -FullName "My Windows 1" -Description "Local My Windows User"
} elseif ($env:COMPUTERNAME -eq 'Windows2Machine') {
    New-LocalUser -Name "MyWindows2" -Password $password -FullName "My Windows 2" -Description "Local My Windows User"
}
