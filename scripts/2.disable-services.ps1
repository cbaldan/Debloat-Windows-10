#Requires -RunAsAdministrator

# Description
# ===========
# This script disables unwanted Windows services. If you do not want to disable
# certain services comment out the corresponding lines below.

Import-Module -DisableNameChecking $PSScriptRoot\..\lib\common-lib.psm1 -Force

Print-ScriptBanner($MyInvocation.MyCommand.Name)

#=============================================================================

$services = @(
    "diagnosticshub.standardcollector.service" # Microsoft (R) Diagnostics Hub Standard Collector Service
    "DiagTrack"                                # Diagnostics Tracking Service
    "dmwappushservice"                         # WAP Push Message Routing Service (see known issues)
    "lfsvc"                                    # Geolocation Service
    "MapsBroker"                               # Downloaded Maps Manager
    "NetTcpPortSharing"                        # Net.Tcp Port Sharing Service
    "RemoteAccess"                             # Routing and Remote Access
    "RemoteRegistry"                           # Remote Registry
    "SharedAccess"                             # Internet Connection Sharing (ICS)
    "TrkWks"                                   # Distributed Link Tracking Client
    "WMPNetworkSvc"                            # Windows Media Player Network Sharing Service
    "XblAuthManager"                           # Xbox Live Auth Manager
    "XblGameSave"                              # Xbox Live Game Save Service
    "XboxNetApiSvc"                            # Xbox Live Networking Service
    "ndu"                                      # Windows Network Data Usage Monitor
	"TabletInputService"                       # Touch Keyboard and Handwriting Panel Service
	"DusmSvc"                                  # Data Usage
	"iphlpsvc"                                 # IP Helper (IPv6 translation)
	"WpnService"                               # Windows Push Notifications System Service
	"VSS"                                      # Volume Shadow Copy
	"swprv"                                    # Microsoft Software Shadow Copy Provider
	"PcaSvc"                                   # Program Compatibility Assistant Service
	"wisvc"                                    # Windows Insider Service

	# Services which may be disabled
	#"WbioSrvc"                                # Windows Biometric Service: required for Fingerprint reader and facial detection

    # Services which *CANNOT* be disabled
	#"TokenBroker"                             # Web Account Manager: New users can't sign in for the first time
)

foreach ($service in $services) {
    Write-Output "Trying to disable $service"
    Get-Service -Name $service | Set-Service -StartupType Disabled
}

Write-Output "Disabling service via Registry: Delivery Optimization Service"
Set-ItemProperty "HKLM:\System\CurrentControlSet\Services\DoSvc" "Start" 4

# Note: both Passport services are needed to allow user account to setup an account PIN - "Start" 3
# Having an account PIN is a requirement for fingerprint reader, not sure but most likely for facial
# recognition as well.

Write-Output "Disabling service via Registry: Microsoft Passport"
Set-ItemProperty "HKLM:\System\CurrentControlSet\Services\NgcSvc" "Start" 4

Write-Output "Disabling service via Registry: Microsoft Passport Container"
Set-ItemProperty "HKLM:\System\CurrentControlSet\Services\NgcCtnrSvc" "Start" 4

Write-Output "Disabling service via Registry: WinHTTP Web Proxy Auto-Discovery Service"
Set-ItemProperty "HKLM:\System\CurrentControlSet\Services\WinHttpAutoProxySvc" "Start" 4