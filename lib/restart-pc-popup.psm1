Add-Type -AssemblyName System.Windows.Forms

function RestartComputerPopup() {

	$msgBoxInput =  [System.Windows.Forms.MessageBox]::Show('Would you like to reboot the PC now?','Reboot','YesNo','Question')

	switch  ($msgBoxInput) {

	'Yes' {
		Restart-Computer -Force
	}
  }

}