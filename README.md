# vagrant-ad-lab

|Machine|hostName|DC?|IP|
|----|-------|---|---|
|Windows Server 2022|groupName-DC|Y|192.168.20.20|
|Windows 10 Enterprise|Windows1Machine|N|192.168.20.21|
|Windows 10 Enterprise|Windows2Machine|N|192.168.20.22|


### Local Accounts
Windows1 

|Username|Password|Disabled?|Admin?|
|-------|--------|----------|------|
|Administrator|Password1|No|Yes|
|MyWindows1|Password1!|No|No

Windows2
|Username|Password|Disabled?|Admin?|
|-------|--------|----------|------|
|Administrator|Password1|No|Yes|
|MyWindows2|Password1!|No|No|

### Domain Accounts
 
|User:Pass|Admin?|ServiceAcc?|OU|PasswordExp|
|-------|---|---------|------|-----------|
|Admin:P@$$w0rd!|Y|N|||
|atest:12345!|Y|N|Groups|N|
|SQLService:MYpassword123#|Y|Y|Groups||
|MyWindows1:Password1|N|N|Groups|N||
|MyWindows2:Password1|N|N|Groups|N||


