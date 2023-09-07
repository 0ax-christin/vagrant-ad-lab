Add-ADGroupMember -Identity "Domain Admins" -Members "vagrant"
Add-ADGroupMember `
    -Identity 'Enterprise Admins' `
    -Members "CN=vagrant,$usersAdPath"
