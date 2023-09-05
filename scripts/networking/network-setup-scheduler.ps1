param(
 [string] $script = "network-setup-workstation.ps1",
 [string] $dnsentries = "dns-entries.csv"
 [string] $domain = "qwerty.local"
)

if (!$script) {
    $script = "network-setup-workstation.ps1"
}

if ($script -match "network-setup-workstation.ps1") {
    cp $script C:\$script
    schtasks /create /f /tn "Networking" /sc onstart /delay 0000:30 /rl highest /ru system /tr "powershell.exe 'C:\$script'"
} else {
    cp C:\vagrant\provision\variables\$dnsentries C:\$dnsentries
    cp $script C:\$script
    schtasks /create /f /tn "Networking" /sc onstart /delay 0000:30 /rl highest /ru system /tr "powershell.exe 'C:\$script' $domain"
}
