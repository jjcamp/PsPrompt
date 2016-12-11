PsPrompt
========

PsPrompt is a highly-customizable agnoster-like prompt theme for Powershell.  PsPrompt will work without UTF support or a powerline-enabled font, but both are recommended.

[Get Powerline Fonts](https://github.com/powerline/fonts)

PsPrompt also has an optional dependency on [posh-git](https://github.com/dahlbyk/posh-git) to display current git status.

Installation
------------
After cloning the repository, run the included install.ps1 file.

Alternatively, copy the cloned directory into your Powershell `Modules` folder, and inside your profile script add:
```
Import-Module -Name PsPrompt
Set-PsPrompt 
```

Help and Cusomization
---------------------
PsPrompt comes with build-in help files:
```
Get-Help about_PsPrompt
Get-Help about_PsPromptConfiguration
Get-Help Set-PsPrompt
```