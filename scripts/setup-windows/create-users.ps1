if ($env:COMPUTERNAME -eq 'Windows1Machine') {
    New-LocalUser -Name "LazyUser" -Password $password -FullName "Lazy User" -Description "Test user"
} else {

}
