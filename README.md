# Debloat Windows 10

This project is a fork from [https://github.com/W4RH4WK/Debloat-Windows-10](https://github.com/W4RH4WK/Debloat-Windows-10).

Why one more fork?

Because I want it to be simple to run the way I like it, and doing just what I want.
Plus, the original project looks abandoned for the past few years. Many PRs open, not a single comment on them by the author, you get the picture.

To see the original readme.md go the original project.

## Execution

**First of all**, I'd advise this script to be run only on a *clean Windows 10 instllation*, right after the installation is complete.
Things might become a bit unstable if you run in a Windows installation that is not healthy.
It was thoroughly tested on Windows 10 1909, with 0 errors.

All statements below have to be executed in an elevated prompt.
First, you must enable execution of PowerShell scripts:

    Set-ExecutionPolicy Unrestricted -Scope CurrentUser

Second, execute the following script:

    0.unblock-and-run-all.ps1

It will conveniently unblock all scripts and launch them all.
After you are done, it's advisable to disable script execution for security purposes:

    Set-ExecutionPolicy Restricted -Scope CurrentUser

## Liability

**All scripts are provided as is and you use them at your own risk.**

## Contribute

I would be happy to extend the collection of scripts. Just open an issue or
send me a pull request.

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
