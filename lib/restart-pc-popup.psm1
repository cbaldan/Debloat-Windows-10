
function RestartComputerPopup() {
	$caption = "Reboot"
	$message = "Reboot computer now?"
	[int]$defaultChoice = 0
	$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes"
	$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No"
	$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
	$choiceRTN = $host.ui.PromptForChoice($caption,$message, $options, $defaultChoice)

	if ( $choiceRTN -ne 1 )
	{
	   Restart-Computer -Force
	}
}