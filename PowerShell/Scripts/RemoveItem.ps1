param($files)
Set-Location -Path $env:ccnetworkingdirectory
Get-ChildItem $files | Remove-Item 