Add-Type -AssemblyName Microsoft.VisualBasic

function Restart-Dialog() {

    $choice = [Microsoft.VisualBasic.Interaction]::MsgBox('Would you like to restart the PC now?', 'YesNo,SystemModal,Question', 'Restart')

	switch  ($choice) {
	'Yes' {
        Restart-Computer
	    }
    'No' {
        Write-Host "`nIt's highly recommended to restart the PC after these updates." -BackgroundColor Yellow -ForegroundColor Black
        }
    }
}