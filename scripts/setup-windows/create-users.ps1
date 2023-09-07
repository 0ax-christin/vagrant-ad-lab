<#
    Step 8
    As per 'provision/variables/local-users.json', Local accounts are created in machines of a given hostname with specified password
    In our case, in Windows1Machine there will be an account MyWindows1 added
    and in Windows2Machine, MyWindows2 is added with specified password
#>
param(
    [string[]]
    [Parameter(Mandatory = $true, Position=0)]
    $file = 'local-users.json'
)

$machines = Get-Content -Raw -Path "C:\vagrant\provision\variables\${file}" | ConvertFrom-Json
$password = ConvertTo-SecureString $account.password -AsPlainText -Force
foreach ($machine in $machines.machines) {
    if ($env:COMPUTERNAME -eq $machine.name) {
        foreach ($account in $machine.accounts) {
            New-LocalUser -Name $account.name -Password $password -FullName $account.fullName -Description $account.description
        }
    }
}
