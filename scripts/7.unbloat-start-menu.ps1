#Requires -RunAsAdministrator

# Description
# ===========
# Removes all titles of the start menu.

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\common-lib.psm1

Print-Script-Banner($MyInvocation.MyCommand.Name)

#=============================================================================

#Delete layout file if it already exists
If(Test-Path C:\Windows\StartLayout.xml)
{
    Remove-Item C:\Windows\StartLayout.xml
}

#Creates the blank layout file
echo "<LayoutModificationTemplate xmlns:defaultlayout=""http://schemas.microsoft.com/Start/2014/FullDefaultLayout"" xmlns:start=""http://schemas.microsoft.com/Start/2014/StartLayout"" Version=""1"" xmlns=""http://schemas.microsoft.com/Start/2014/LayoutModification"">" >> C:\Windows\StartLayout.xml
echo "  <LayoutOptions StartTileGroupCellWidth=""6"" />" >> C:\Windows\StartLayout.xml
echo "  <DefaultLayoutOverride>" >> C:\Windows\StartLayout.xml
echo "    <StartLayoutCollection>" >> C:\Windows\StartLayout.xml
echo "      <defaultlayout:StartLayout GroupCellWidth=""6"" />" >> C:\Windows\StartLayout.xml
echo "    </StartLayoutCollection>" >> C:\Windows\StartLayout.xml
echo "  </DefaultLayoutOverride>" >> C:\Windows\StartLayout.xml
echo "</LayoutModificationTemplate>" >> C:\Windows\StartLayout.xml

$regAliases = @("HKLM", "HKCU")

#Assign the start layout and force it to apply with "LockedStartLayout" at both the machine and user level
foreach ($regAlias in $regAliases){
    $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
    $keyPath = $basePath + "\Explorer" 
    IF(!(Test-Path -Path $keyPath)) { 
        New-Item -Path $basePath -Name "Explorer"
    }
    Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 1
    Set-ItemProperty -Path $keyPath -Name "StartLayoutFile" -Value "C:\Windows\StartLayout.xml"
}

#Restart Explorer, open the start menu (necessary to load the new layout), and give it a few seconds to process
Stop-Process -name explorer
Start-Sleep -s 3
$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys('^{ESCAPE}')

# To make the clean start menu default for current and all future users, remove all lines below here
# ==================================================================================================

#Enable the ability to pin items again by disabling "LockedStartLayout"
foreach ($regAlias in $regAliases){
    $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
    $keyPath = $basePath + "\Explorer" 
    Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 0
}

#Restart Explorer and delete the layout file
Stop-Process -name explorer
Remove-Item C:\Windows\StartLayout.xml