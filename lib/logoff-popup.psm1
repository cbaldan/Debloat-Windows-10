Add-Type -AssemblyName Microsoft.VisualBasic

function LogoffPopup() {

    $choice = [Microsoft.VisualBasic.Interaction]::MsgBox('Would you like to Sign Out now?', 'YesNo,SystemModal,Question', 'Sign Out')

	switch  ($choice) {
	'Yes' {
        $msg = "You will be signed out now.`nLog back in and execute script #9,"
		[Microsoft.VisualBasic.Interaction]::MsgBox($msg, 'OkOnly,SystemModal,Information', 'Sign Out')
        &cmd.exe /c shutdown -L
	}
    'No' {
        $msg = "It is highly advisable to Sign Out now.`nScript #9 can only be executed after the current session is terminated."
        [Microsoft.VisualBasic.Interaction]::MsgBox($msg, 'OkOnly,SystemModal,Information', 'Sign Out')
    }
  }

}