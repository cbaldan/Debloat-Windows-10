#Requires -RunAsAdministrator

# Description
# ===========
# This script optimizes Windows updates by disabling automatic download and
# seeding updates to other computers.
#

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\common-lib.psm1 -Force

Print-ScriptBanner($MyInvocation.MyCommand.Name)

#=============================================================================

# Disable seeding of updates to other computers via Group Policies
force-mkdir "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" "DODownloadMode" 0