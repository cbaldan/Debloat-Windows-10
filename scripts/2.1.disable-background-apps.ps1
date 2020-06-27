#Requires -RunAsAdministrator

# Description
# ===========
# Disables all background apps

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\common-lib.psm1 -Force

Print-ScriptBanner($MyInvocation.MyCommand.Name)

$username = Get-LoggedUsername
$userSid = Get-UserSid $username

#The PSDrive mapping has to be done in every PS1 file
New-PSDrive HKU Registry HKEY_USERS | Out-Null

#=============================================================================

## Disable Background apps

$apps = @(
    # default Windows 10 2004 Background apps
    "Microsoft.MicrosoftEdge"
    "Microsoft.SkypeApp"
    "Microsoft.WindowsCalculator"
    "Microsoft.Windows.Photos"
    "Microsoft.WindowsStore"
    "windows.immersivecontrolpanel" # Settings apps
)

$keys =@(
    "Disabled"
    "DisabledByUser"
)

# Current user
$basePath="HKU:\$userSid\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications\"

Write-Output "`nDisabling Background apps:"

foreach ($app in $apps) {
    Write-Debug "Trying to find $app"

    try {
        $backgroundKeys=Get-ChildItem -path $basePath

        foreach ($childKey in $backgroundKeys) {
            $appFound = $childKey.Name.Contains($app)

            if ($appFound) {
                Write-Output "> $app"
                $splitArr = $childKey.Name.Split("\")
                $appPath = $basePath + $splitArr[$splitArr.Length - 1]
                foreach ($key in $keys){
                    New-ItemProperty $appPath -Name $key -PropertyType DWORD -Value 1 | Out-Null
                }
            }
        }
    } catch {
        $exception = $_
        Write-Host "WARN: Could not uninstall $app" -BackgroundColor DarkYellow
        Write-Debug $exception
    }
}


# 2020.06.26 - Disabling Background apps globably breaks Start Menu search:
# New apps installed won't be indexed
#$key="GlobalUserDisabled"
#New-ItemProperty $path -Name $key -PropertyType DWORD -Value 1 | Out-Null

# Default profile
# 2020-02-09: BackgroundAccessApplications can't be disabled through the default profile. Bug?

# Disable Microsoft Edge pre-launch
#force-mkdir "HKLM:SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main"
#Set-ItemProperty "HKLM:SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" "AllowPrelaunch" 0
