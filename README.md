# Debloat Windows 10

This project is a fork from [https://github.com/W4RH4WK/Debloat-Windows-10](https://github.com/W4RH4WK/Debloat-Windows-10).

Why one more fork?

Because I wanted to have more control over the scripts, and have it doing just what I want.

To see the original README.md go the original project.

## Known issues

People complained in the original project that they can't use the XBox controller in the PC after running these scripts.
https://github.com/W4RH4WK/Debloat-Windows-10/issues/78
https://github.com/W4RH4WK/Debloat-Windows-10/issues/231

I don't have an XBox, so I don't have how to test that, but it makes sense.
The scripts will strip Windows 10 completely of all XBox related services and apps. Perhaps if the scripts are customized to leave everything XBox related untouched, it will continue to work.
If someone can test it an make a PR with a conditional MsgBox to remove XBox related stuff, I'd greatly appreciate.

## Caveats

Since the scripts will uninstall **OneDrive**, it should be completely installed before it can be uninstalled.
I said should because I noticed during the testing that in fact, **OneDrive** installation is kicked off when new users do the first login, and then, it will automatically download an update and kick off without requesting user consent.
So the script will tries to detect the *OneDriveSetup.exe* setup process, and prompts the user to decide if:
* Continue, but do not uninstall OneDrive
* Abort script execution completely

If you don't need/use OneDrive, I'd say just wait for it to finish and then run the scripts.

## Final words

For security reasons, the script will automatically disable script execution once it's complete.
I imagine experienced users who need this a lot will just unblock again for their needs, but home users will be safer having it off, just like the default behavior.

    Set-ExecutionPolicy Restricted -Scope CurrentUser

## Execution

**First of all**, I'd advise this script to be run only on a *clean Windows 10 instllation*, right after the installation is complete.
Things might become a bit unstable if you run in a Windows installation that is not healthy.
It was thoroughly tested on Windows 10 1909, with 0 errors.
The scripts do work in any Windows language, it was tested in the following W10 1909 languages:
* English (US)
* Português (Brasil)
* Français (France)
* Español (España)

All statements below have to be executed in an elevated prompt, and they won't run otherwise.
First, you must enable execution of PowerShell scripts:

    Set-ExecutionPolicy Unrestricted -Scope CurrentUser

Second, execute the following script:

    0.unblock-and-run-all.ps1

You will be prompted to allow the execution of this first script, and it will conveniently unblock all other scripts and launch in sequence.

## Liability

**All scripts are provided as is and you use them at your own risk.**

## Contribute

I would be happy to extend the collection of scripts. Just open an issue or send me a pull request.

### Thanks To

- [W4RH4WK](https://github.com/W4RH4WK)
- [10se1ucgo](https://github.com/10se1ucgo)
- [Plumebit](https://github.com/Plumebit)
- [aramboi](https://github.com/aramboi)
- [maci0](https://github.com/maci0)
- [narutards](https://github.com/narutards)
- [tumpio](https://github.com/tumpio)

## License

    "THE BEER-WARE LICENSE" (Revision 42):

    As long as you retain this notice you can do whatever you want with this
    stuff. If we meet some day, and you think this stuff is worth it, you can
    buy us a beer in return.

    This project is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
    FITNESS FOR A PARTICULAR PURPOSE.
