#Requires -RunAsAdministrator

# Description
# ===========
# Runs only the script that optimize user UI for second users

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\common-lib.psm1 -Force

Print-Message-With-Banner("Starting User UI Cleanup")

&($PSScriptRoot+"\6.optimize-user-interface.ps1")
&($PSScriptRoot+"\6.1.cleanup-taskbar.ps1")
&($PSScriptRoot+"\7.unbloat-start-menu.ps1")
&($PSScriptRoot+"\8.fix-acccount-privileges")
