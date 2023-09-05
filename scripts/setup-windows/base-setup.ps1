param(
    [string] $zone = "en-US"
)

if(!$zone) {
    $zone = "en-US"
}

#1. Set keyboard layout and timezone of default en-US
# set keyboard layout
Set-WinUserLanguageList $zone -Force 
# set the date format, number format, etc.
Set-Culture $zone
# set the welcome screen culture and keyboard layout.
New-PSDrive -PSProvider "Registry" -Name "HKU" -Root "HKEY_USERS" | Out-Null 'Control Panel\International','Keyboard Layout' |
ForEach-Object {
    Remove-Item -Path "HKU:.DEFAULT\$_" -Recurse -Force
    Copy-Item -Path "HKCU:$_" -Destination "HKU:.DEFAULT\$_" -Recurse -Force
}

# set the timezone.
# tzutil /l lists all available timezone ids
# (UTC+04:00) Abu Dhabi, Muscat
#Arabian Standard Time
& $env:windir\system32\tzutil /s "GMT Standard Time"

# We need to enable the Windows License Manager Service for the next step to work (licensing keys will fail otherwise)
if (Get-Service LicenseManager -ErrorAction SilentlyContinue) {
    Set-Service -Name LicenseManager -StartupType Automatic
    Stop-Service LicenseManager
    Start-Service LicenseManager
}

# In order to make licensing and auto-activation work on Hyper-V, we set the edition to ServerStandard
# and then we pick the right key from: 
# https://learn.microsoft.com/en-us/windows-server/get-started/automatic-vm-activation
if ((Get-WmiObject -class Win32_OperatingSystem).Caption.Contains('2022')) {
    dism /NoRestart /online /Set-Edition:ServerStandard /AcceptEULA /ProductKey:YDFWN-MJ9JR-3DYRK-FXXRW-78VHK
}

# Disable password expiry
net accounts /maxpwage:unlimited
