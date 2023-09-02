echo "Installing Chocolatey"

$ChocoInstallPath = "$env:SystemDrive\ProgramData\Chocolatey\bin"

if (!(Test-Path $ChocoInstallPath)) {
    iex ((new-object net.webclient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

echo "Installed Chocolatey"
