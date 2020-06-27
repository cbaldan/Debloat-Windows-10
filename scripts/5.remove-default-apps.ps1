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
    # Original Windows 10 apps
    "Microsoft.BingWeather"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftStickyNotes"
    "Microsoft.Office.OneNote"
    "Microsoft.People"
    "Microsoft.Wallet"
    "Microsoft.WindowsAlarms"
    "Microsoft.WindowsCamera"
    "Microsoft.windowscommunicationsapps"
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsSoundRecorder"
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
    "Microsoft.WindowsFeedbackHub"

    # Creators Update apps
    "Microsoft.Microsoft3DViewer"
    "Microsoft.MSPaint" # Paint 3D

    # Redstone 5 apps
    "Microsoft.MixedReality.Portal"
    "Microsoft.ScreenSketch"
    "Microsoft.YourPhone"
    "Microsoft.XboxIdentityProvider"

    # 2004 Update
    "Microsoft.549981C3F5F10" # Cortana

    # Advertising.Xaml has to be removed last
    "Microsoft.Advertising.Xaml"

    # Kept apps
    #"Microsoft.Windows.Photos"
    #"Microsoft.WindowsStore"
    #"Microsoft.DesktopAppInstaller"
    #"Microsoft.SkypeApp"
    #"Microsoft.WindowsCalculator"
    #"Microsoft.WebpImageExtension"
    #"Microsoft.WebMediaExtensions"
    #"Microsoft.VP9VideoExtensions"
    #"Microsoft.StorePurchaseApp"
    #"Microsoft.HEIFImageExtension"
    #"Microsoft.VCLibs.140.00"

    # apps which cannot be removed using Remove-AppxPackage
    #"Microsoft.AAD.BrokerPlugin"
    #"Microsoft.BioEnrollment"
    #"Microsoft.Windows.CloudExperienceHost"
    #"Microsoft.Windows.OOBENetworkCaptivePortal"
    #"Microsoft.Windows.OOBENetworkConnectionFlow"
    #"MicrosoftWindows.UndockedDevKit"
    #"Microsoft.Windows.StartMenuExperienceHost"
    #"Microsoft.Windows.ShellExperienceHost"
    #"windows.immersivecontrolpanel"
    #"Microsoft.Windows.Search"
    #"Microsoft.VCLibs.140.00.UWPDesktop"
    #"Microsoft.NET.Native.Framework.2.2"
    #"Microsoft.NET.Native.Runtime.2.2"
    #"Microsoft.MicrosoftEdge"
    #"Microsoft.Windows.ContentDeliveryManager"
    #"MicrosoftWindows.Client.CBS"
    #"Microsoft.UI.Xaml.2.0"
    #"Microsoft.NET.Native.Framework.1.7"
    #"Microsoft.NET.Native.Runtime.1.7"
    #"Windows.PrintDialog"
    #"Windows.CBSPreview"
    #"NcsiUwpApp"
    #"Microsoft.Windows.XGpuEjectDialog"
    #"Microsoft.Win32WebViewHost"
    #"Microsoft.Windows.Apprep.ChxApp"
    #"Microsoft.Windows.CapturePicker"
    #"Microsoft.Windows.ParentalControls"
    #"Microsoft.Windows.PinningConfirmationDialog"
    #"Microsoft.Windows.SecHealthUI"
    #"Microsoft.Windows.PeopleExperienceHost"
    #"Microsoft.XboxGameCallableUI"
    #"Microsoft.Windows.CallingShellApp"
    #"1527c705-839a-4832-9118-54d4Bd6a0c89"
    #"Microsoft.MicrosoftEdgeDevToolsClient"
    #"Microsoft.LockApp"
    #"c5e2524a-ea46-4f67-841f-6a9465d9d515"
    #"E2A4F912-2574-4A75-9BB0-0D023378592B"
    #"F46D4000-FD22-4DB4-AC8E-4E1DDDE828FE"
    #"Microsoft.AccountsControl"
    #"Microsoft.AsyncTextService"
    #"Microsoft.Windows.NarratorQuickStart"
    #"Microsoft.ECApp"
    #"Microsoft.CredDialogHost"
    #"Microsoft.Services.Store.Engagement"
    #"Microsoft.Services.Store.Engagement" # it appears twice
)

foreach ($app in $apps) {
    Write-Output "Trying to remove $app"

    try {
        Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage

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

Write-Output "`nDisabling Optional Features"
Write-Output "IE11"
Disable-WindowsOptionalFeature -FeatureName Internet-Explorer-Optional-amd64 -Online -NoRestart | Out-Null
Write-Output "XPS Printer"
Disable-WindowsOptionalFeature -FeatureName Printing-XPSServices-Features -Online -NoRestart | Out-Null
