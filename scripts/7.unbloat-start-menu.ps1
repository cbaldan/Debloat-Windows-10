#Requires -RunAsAdministrator

# Description
# ===========
# Removes all titles of the start menu.

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\common-lib.psm1 -Force

Print-Script-Banner($MyInvocation.MyCommand.Name)

$username = Get-LoggedUsername
$userSid = Get-UserSid $username

#The PSDrive mapping has to be done in every PS1 file
New-PSDrive HKU Registry HKEY_USERS | Out-Null

#=============================================================================

#Delete layout file if it already exists
#if (Test-Path $layoutFile)
#{
#    Remove-Item $layoutFile
#}

$layoutFile="C:\Windows\StartMenuLayout.xml"
#Creates the blank layout file
echo "<LayoutModificationTemplate xmlns:defaultlayout=""http://schemas.microsoft.com/Start/2014/FullDefaultLayout"" xmlns:start=""http://schemas.microsoft.com/Start/2014/StartLayout"" Version=""1"" xmlns=""http://schemas.microsoft.com/Start/2014/LayoutModification"">" >> $layoutFile
echo "  <LayoutOptions StartTileGroupCellWidth=""6"" />" >> $layoutFile
echo "  <DefaultLayoutOverride>" >> $layoutFile
echo "    <StartLayoutCollection>" >> $layoutFile
echo "      <defaultlayout:StartLayout GroupCellWidth=""6"" />" >> $layoutFile
echo "    </StartLayoutCollection>" >> $layoutFile
echo "  </DefaultLayoutOverride>" >> $layoutFile
echo "</LayoutModificationTemplate>" >> $layoutFile

$regAliases = @("HKLM:", "HKU:\$userSid")

#Assign the start layout and force it to apply with "LockedStartLayout" at both the machine and user level
foreach ($regAlias in $regAliases){
    $basePath = $regAlias + "\SOFTWARE\Policies\Microsoft\Windows"
    $keyPath = $basePath + "\Explorer" 
    IF(!(Test-Path -Path $keyPath)) { 
        New-Item -Path $basePath -Name "Explorer" | Out-Null
    }
    Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 1
    Set-ItemProperty -Path $keyPath -Name "StartLayoutFile" -Value $layoutFile
}

#Restart Explorer, open the start menu (necessary to load the new layout), and give it a few seconds to process
Stop-Process -name explorer
Start-Sleep -s 3
$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys('^{ESCAPE}')

#Enable the ability to pin items again by disabling "LockedStartLayout"
foreach ($regAlias in $regAliases){
    $basePath = $regAlias + "\SOFTWARE\Policies\Microsoft\Windows"
    $keyPath = $basePath + "\Explorer" 
    Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 0
}

#Restart Explorer
Stop-Process -name explorer

# Make clean start menu default to all users
Import-StartLayout -LayoutPath $layoutFile -MountPath $env:SystemDrive\

# Delete layout file
Remove-Item $layoutFile