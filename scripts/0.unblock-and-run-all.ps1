#Requires -RunAsAdministrator

Write-Output ">> Unblocking Scripts"

cd $PSScriptRoot\..
ls -Recurse *.ps*1 | Unblock-File

# This is a workaround to what seem to be a PShell bug
# The unblocking is only effective when called by a different script
&($PSScriptRoot+"\1.invoke-all.ps1")