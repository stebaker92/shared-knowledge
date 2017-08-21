# Publishing dotnet core through Visual Studio

- Download the [DotNet-Helper](https://raw.githubusercontent.com/stebaker92/profile/master/PowerShell/DotNet-Helper.psm1) module and add the following to your PowerShell profile: (you can access this with `notepad $PROFILE`) - `Import-Module DotNet-Helper`

- Tools > External Tools
Add a new item with the following settings: 

|Task|Value|
|----|----|
|Command|powershell.exe|
|Arguments|"E:\scripts\deploy.ps1"|
|Initial Directory|$(ItemDir)|


- To add a hot key for this, check the position of the newly added command and navigate to Tools > Options > Environment > Keyboard
- Find "Tools.ExternalCommand[x]" where [x] is the position / index of the added command
- Add your custom shortcut! (Ctrl + Shift + P works well for me)
