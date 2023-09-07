<#
    This script reads the 'provision/variables/users.json' for entries to add to domain, each entry has a type which is read to specify the action performed
    E.g. for type 'ou', an OU with the specified parameters is created
    The same functionality exists for Users, Admin Accounts and Service Accounts. All accounts have password expiry disabled
    'provision/variables/forest-variables.json' is read for general domain information

    This script deals with:
    Step 10 -  Creating OU
    Step 12 - Admin Account creation - Created by adding any use whose value in admin is true to Membership of Administrators and Domain Admins group
    Step 13 and 17- Service Account creation - Creation of Managed Service Account
    Step 14 and 15 - Domain User creation
    This script uses the values in users.json to create the above account details
#>
param(
    [string]
    [Parameter(Mandatory = $true, Position=0)]
    $forestVariables = 'forest-variables.json',

    [string[]]
    [Parameter(Position=1, ValueFromRemainingArguments)]
    $files = 'users.json'
)

# Required for Win2016 which takes ages to load
#Sleep 300

$domain = Get-Content -Raw -Path "C:\vagrant\provision\variables\${forestVariables}" | ConvertFrom-Json

try {
    Import-Module ActiveDirectory -ErrorAction Stop
} catch {
    throw "Module ActiveDirectory not Installed"
}

foreach ($file in $files) {
    $objects = Get-Content -Raw -Path "C:\vagrant\provision\variables\${file}" | ConvertFrom-Json
    $passExp = $true
    foreach ($object in $objects.objects) {
        $path = $object.path + $domain.dn
        if ($object.type -eq "ou") {
            $name = $object.name
            $ou = Get-ADOrganizationalUnit -Filter { name -eq $name }
            if ($ou -and $ou.distinguishedname.EndsWith($name + "," + $path)) {
                echo "${name} already exists."
                continue
            }

            New-ADOrganizationalUnit -Name $object.name -Path $path
        } elseif ($object.type -eq "user") {
            $username = $object.username
            if ([bool] (Get-ADUser -Filter { samAccountName -eq $username })) {
                echo "${username} already exists."
                continue
            }
            $optional = @{}
            if ($object | Get-Member first) {
                $optional['GivenName'] = $object.first
                $optional['Surname'] = $object.last
                $optional['DisplayName'] = $object.first + " " + $object.last
            }

            if ($object | Get-Member department) {
                $optional['Department'] = $object.department
            }

            if ($object | Get-Member title) {
                $optional['Title'] = $object.title
            }            

            if ($object | Get-Member spn) {
                $spnFQDN = $object.spn + "." + $domain.fqdn
                $optional['ServicePrincipalNames'] = @($object.spn, $spnFQDN)
            }

            if ($object | Get-Member passwordExp) {
                if ($object.passwordExp -eq 'true') {
                    $passExp = $True
                } else {
                    $passExp = $False
                }
            }

            $password = ConvertTo-SecureString $object.password -AsPlaintext -Force

            New-ADUser `
                -Name $object.username `
                -SamAccountName $object.username `
                -Path $path `
                -Enabled $true `
                -AccountPassword $password `
                -PasswordNeverExpires ($passExp -as [bool])`
                @optional

            if ($object.admin -eq "true") {
                Add-ADGroupMember -Identity "Administrators" -Members $object.username
                Add-ADGroupMember -Identity "Schema Admins" -Members $object.username
                Add-ADGroupMember -Identity "Enterprise Admins" -Members $object.username
                Add-ADGroupMember -Identity "Domain Admins" -Members $object.username
                Add-ADGroupMember -Identity "Group Policy Creator Owners" -Members $object.username
            }
            
        } elseif ($object.type -eq "service") {
            
            $password = ConvertTo-SecureString $object.password -AsPlaintext -Force

            New-ADServiceAccount `
            -Name $object.name `
            -DisplayName $object.displayName `
            -AccountPassword $password `
            -Description $object.description `
            -ServicePrincipalNames $object.servicePrincipalName `
            -RestrictToSingleComputer

        } else {
            echo "Unknown object type."
        }
    }
}
