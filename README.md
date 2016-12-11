PsPrompt
========

PsPrompt is a highly-customizable agnoster-like prompt theme for Powershell.  PsPrompt will work without UTF support or a powerline-enabled font, but both are recommended.

[Get Powerline Fonts](https://github.com/powerline/fonts)

PsPrompt also has an optional dependency on [posh-git](https://github.com/dahlbyk/posh-git) to display current git status.

![PsPrompt in ConEmu with posh-git and hack font](https://gist.githubusercontent.com/jjcamp/0ed34bae79a524ef8bd7f9b252ab44b1/raw/c4e0b8bc16bb47a3b54f1c4bcf8f6e6c585fde8b/conemu-example.png)

*PsPrompt in ConEmu with posh-git and hack font*

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