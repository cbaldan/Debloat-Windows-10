Import-Module -DisableNameChecking $PSScriptRoot\..\lib\restart-dialog.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\force-mkdir.psm1
Import-Module -DisableNameChecking $PSScriptRoot\..\lib\take-own.psm1

$lineSeparator="`n================================================="

function Print-Script-Banner($scriptName)
{
   Write-Host "`n>> Executing: $scriptName$lineSeparator"
}

function Print-Message-With-Banner($msg)
{
   Write-Host "`n>> $msg$lineSeparator"
}