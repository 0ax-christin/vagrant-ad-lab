param(
    [string]
    [Parameter(Mandatory = $true, Position=0)]
    $domainVariables,

    [string[]]
    [Parameter(Position=1, ValueFromRemainingArguments)]
    $files
)

# Required for Win2016 which takes ages to load
Sleep 300

$domain = Get-Content -Raw -Path "C:\vagrant\provision\variables\${domainVariables}" | ConvertFrom-Json

try {
    Import-Module ActiveDirectory -ErrorAction Stop
} catch {
    throw "Module ActiveDirectory not Installed"
}

foreach ($file in $files) {
    $objects = Get-Content -Raw -Path "C:\vagrant\provision\variables\${file}" | ConvertFrom-Json
    $passExp = $true
    foreach ($file in $files) {
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
                    $passExp = $true
                } else {
                    $passExp = $false
                }
            }

            $password = ConvertTo-SecureString $object.password -AsPlaintext -Force
		    echo $object
		    echo $object.username

            New-ADUser `
                -Name $object.username `
                -SamAccountName $object.username `
                -Path $path `
                -Enabled $true `
                -AccountPassword $password `
                -PasswordNeverExpires $passExp`
                @optional
        } else {
            echo "Unknown object type."
        }
    }
}
