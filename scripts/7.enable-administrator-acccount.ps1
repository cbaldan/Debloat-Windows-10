# For increased security, I enable the built-in administrator
# account in Windows and demote the user account to Standard user
Get-LocalUser -Name "Administrator" | Enable-LocalUser