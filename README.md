# Debloat Windows 10

This project is a fork from [https://github.com/W4RH4WK/Debloat-Windows-10](https://github.com/W4RH4WK/Debloat-Windows-10).

Why one more fork?

Because I wanted to have more control over the scripts, and have it doing just what I want.

To see the original README.md go the original project.

## Getting started

**First of all**, I advise to only run these scripts on a *fresh Windows 10 instllation*, right after the installation is complete.
Things might become a bit unstable if you run in a Windows that is not healthy.
It was thoroughly tested on Windows 10 1909, with 0 errors.
The scripts **should** work in any Windows language, I tested in the following:
* English (US)
* Português (Brasil)
* Français (France)
* Español (España)

## Known issues

People complained in the original project that they can't use the XBox controller or play XBox linked games in the PC after running these scripts.
* https://github.com/W4RH4WK/Debloat-Windows-10/issues/78
* https://github.com/W4RH4WK/Debloat-Windows-10/issues/231

I don't have an XBox, so I don't have how to test that, but it makes sense.

The scripts will strip Windows 10 completely of all XBox related services and apps. Perhaps if the scripts are customized to leave everything XBox related untouched, it will continue to work.

If someone can test it an make a PR with a conditional MsgBox to remove XBox related stuff, I'd greatly appreciate.

## Caveats

**OneDrive uninstall**

Since the scripts will uninstall **OneDrive**, it should be completely installed before it can be uninstalled.

I said *should* because I noticed during the testing that in fact, **OneDrive** installation is kicked off when new users do the first login, and then, it will automatically download an update and kick off without requesting user consent.

So the script tries to detect the *OneDriveSetup.exe* setup process, and if detected, will prompt the user to decide if:
* Continue, but do not uninstall it
* Abort script execution entirely

If you don't need/use **OneDrive**, I'd say just wait for its completion and then run the scripts.

**Background Apps**

Through testing, I discovered that it's not possible to disable the **Background apps** configuration for new users.

Seems that the key that controls this is only created after the user default profile is cloned, and creating the key in the default profile caused multiple messages about default program changed in the new users first login.

## Heads up

The script will allow execution only once in each Windows installation.

If you run more than once, it will just print on screen when the script was successfully executed.

Plus, the script only needs to be executed once.

For security reasons, the script will automatically disable PS script execution once it's complete.

I imagine experienced users who need this a lot will just unblock again for their needs, but home users will be safer having it off, just like the default behavior.

    Set-ExecutionPolicy Restricted -Scope CurrentUser

## Execution

All statements below have to be executed in an elevated prompt, and they won't run otherwise.
First, you must enable execution of PowerShell scripts:

    Set-ExecutionPolicy Unrestricted -Scope CurrentUser

Second, execute the following script:

    scripts\0.unblock-and-run-all.ps1

You will be prompted to allow the execution of this first script, and it will conveniently unblock all other scripts and launch them in sequence.

## Liability

**All scripts are provided as is and you use them at your own risk.**

## Final Words

These scripts will do a deep cleanse of Windows, and leave pretty much a very lean, clean core version of W10.

It will be snappier and run faster than a fresh W10 vanilla installation.

I used these scripts in a budget laptop that had some cheap Celeron CPU, 4 GB RAM, but I must admit an SSD - which wasn't making any miracle.

After I installed a clean W10 1909 and ran these scripts, boy, that thing got much better (it didn't become an i5 alright, but it got way better).

Anyhow, I'd suggest you to build a Virtual Machine, install W10 and run these scripts before you go and apply in your machine.

**I did not create a script to revert these changes and don't plan to do so.**

100% of the UI customizations can be undone for the current or all users, I'm just not so sure about every app removed by script 5 (mind the XBox stuff).

It was fun, sometimes enfuriating, learning how to customize Windows, PowerShell, hit it's bugs, find workarounds, etc.

I think I'm done with this, my next (planned?) update will probably after Windows 20H1, if any needed.

## Contribute

I would be happy to extend the collection of scripts. Just open an issue or send me a pull request.

I leave here my appreciation for all the people who put so much effort in researching all this and making it available to everyone before me so I could continue their work.

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
