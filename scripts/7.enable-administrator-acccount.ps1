# For increased security, I enable the built-in administrator
# account in Windows and demote the user account to Standard user

$adminUser = Get-LocalUser -Name "Admin*"
$pwd = ConvertTo-SecureString "*123" -AsPlainText -Force

# Thanks so some nefarious W10 bug, the password has to be set
# in a different statement, after the account has been enabled
Enable-LocalUser $adminUser
Set-LocalUser $adminUser -Password $pwd
