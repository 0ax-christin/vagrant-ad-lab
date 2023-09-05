param(
    [string] $disableOrDel = "disable"
)

if($disableOrDel -eq "disable") {
    Disable-LocalUser -Name "vagrant"
    if (Get-Module -ListAvailable -Name ActiveDirectory) {
        Disable-ADAccount -Identity vagrant
    }
} elseif ($disableOrDel -eq "delete") {
    Remove-LocalUser vagrant
    if (Get-Module -ListAvailable -Name ActiveDirectory) {
        Remove-ADUser -Identity vagrant
    }
}
