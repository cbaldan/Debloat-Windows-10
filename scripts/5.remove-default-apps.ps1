#Requires -RunAsAdministrator

# Description
# ===========
# This script removes unwanted Apps that come with Windows. If you  do not want
# to remove certain Apps comment out the corresponding lines below.

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\common-lib.psm1 -Force

Print-ScriptBanner($MyInvocation.MyCommand.Name)

$username = Get-LoggedUsername
$userSid = Get-UserSid $username

#The PSDrive mapping has to be done in every PS1 file
New-PSDrive HKU Registry HKEY_USERS | Out-Null

#=============================================================================

$apps = @(
    # default Windows 10 apps
    "Microsoft.BingWeather"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftStickyNotes"
    "Microsoft.Office.OneNote"
    "Microsoft.OneConnect"
    "Microsoft.People"
    "Microsoft.Print3D"
    #"Microsoft.SkypeApp"
    "Microsoft.Wallet"
    #"Microsoft.Windows.Photos"
    "Microsoft.WindowsAlarms"
    #"Microsoft.WindowsCalculator"
    "Microsoft.WindowsCamera"
    "Microsoft.windowscommunicationsapps"
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsSoundRecorder"
    #"Microsoft.WindowsStore"
    "Microsoft.Xbox.TCUI"
    "Microsoft.XboxApp"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxGamingOverlay"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
	"Microsoft.MicrosoftSolitaireCollection"

    # Threshold 2 apps
    "Microsoft.GetHelp"
    "Microsoft.Getstarted"
    "Microsoft.Messaging"
    "Microsoft.WindowsFeedbackHub"

    # Creators Update apps
    "Microsoft.Microsoft3DViewer"
    "Microsoft.MSPaint" # Paint 3D

    # Redstone 5 apps
    "Microsoft.MixedReality.Portal"
    "Microsoft.ScreenSketch"
    "Microsoft.YourPhone"
	"Microsoft.XboxIdentityProvider"

    # apps which cannot be removed using Remove-AppxPackage
    #'Microsoft.Windows.CloudExperienceHost'
    #'Microsoft.AAD.BrokerPlugin'
    #'Microsoft.Windows.StartMenuExperienceHost'
    #'Microsoft.Windows.ShellExperienceHost'
    #'windows.immersivecontrolpanel'
    #'Microsoft.MicrosoftEdge'
    #'Microsoft.Windows.Cortana'
    #'Microsoft.Windows.ContentDeliveryManager'
    #'1527c705-839a-4832-9118-54d4Bd6a0c89'
    #'c5e2524a-ea46-4f67-841f-6a9465d9d515'
    #'E2A4F912-2574-4A75-9BB0-0D023378592B'
    #'F46D4000-FD22-4DB4-AC8E-4E1DDDE828FE'
    #'Microsoft.AccountsControl'
    #'Microsoft.AsyncTextService'
    #'Microsoft.BioEnrollment'
    #'Microsoft.CredDialogHost'
    #'Microsoft.ECApp'
    #'Microsoft.LockApp'
    #'Microsoft.MicrosoftEdgeDevToolsClient'
    #'Microsoft.PPIProjection'
    #'Microsoft.Win32WebViewHost'
    #'Microsoft.Windows.Apprep.ChxApp'
    #'Microsoft.Windows.CallingShellApp'
    #'Microsoft.Windows.CapturePicker'
    #'Microsoft.Windows.NarratorQuickStart'
    #'Microsoft.Windows.OOBENetworkCaptivePortal'
    #'Microsoft.Windows.OOBENetworkConnectionFlow'
    #'Microsoft.Windows.ParentalControls'
    #'Microsoft.Windows.PeopleExperienceHost'
    #'Microsoft.Windows.PinningConfirmationDialog'
    #'Microsoft.Windows.SecHealthUI'
    #'Microsoft.Windows.XGpuEjectDialog'
	#'Microsoft.XboxIdentityProvider'  # Can be removed after restart
    #'Microsoft.XboxGameCallableUI'
    #'Windows.CBSPreview'
    #'Windows.PrintDialog'
    #'InputApp'

    # apps which other apps depend on
    "Microsoft.Advertising.Xaml"
)

foreach ($app in $apps) {
    Write-Output "Trying to remove $app"

    try {
        Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage -AllUsers

        Get-AppXProvisionedPackage -Online |
            Where-Object DisplayName -EQ $app |
            Remove-AppxProvisionedPackage -Online
    } catch {
        $exception = $_
        Write-Host "WARN: Could not uninstall $app" -BackgroundColor DarkYellow
        Write-Debug $exception
    }
}

# Prevents Apps from re-installing
$cdm = @(
    "ContentDeliveryAllowed"
    "FeatureManagementEnabled"
    "OemPreInstalledAppsEnabled"
    "PreInstalledAppsEnabled"
    "PreInstalledAppsEverEnabled"
    "SilentInstalledAppsEnabled"
    "SubscribedContent-314559Enabled"
    "SubscribedContent-338387Enabled"
    "SubscribedContent-338388Enabled"
    "SubscribedContent-338389Enabled"
    "SubscribedContent-338393Enabled"
    "SubscribedContentEnabled"
    "SystemPaneSuggestionsEnabled"
)

force-mkdir "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
foreach ($key in $cdm) {
    Set-ItemProperty "HKU:\$userSid\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" $key 0
}

force-mkdir "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore"
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\WindowsStore" "AutoDownload" 2

# Prevents "Suggested Applications" returning
force-mkdir "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
Set-ItemProperty "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" 1