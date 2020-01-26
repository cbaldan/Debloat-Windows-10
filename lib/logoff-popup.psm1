Add-Type -AssemblyName Microsoft.VisualBasic

function LogoffPopup() {

    $choice = [Microsoft.VisualBasic.Interaction]::MsgBox('Would you like to Sign Out now?', 'YesNo,SystemModal,Question', 'Sign Out')

	switch  ($choice) {
	'Yes' {
		[Microsoft.VisualBasic.Interaction]::MsgBox('You will be signed out now.`nLog back in and execute script #8,', 'OkOnly,SystemModal,Information', 'Sign Out')
        &cmd.exe /c shutdown -L
	}
    'No' {
        $msg = "It is highly advisable to logoff now.`nScript #8 can only be executed after logoff."
        [Microsoft.VisualBasic.Interaction]::MsgBox($msg, 'OkOnly,SystemModal,Information', 'Sign Out')
    }
  }

}