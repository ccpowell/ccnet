param($files)
Set-Location -Path $env:ccnetworkingdirectory

Get-ChildItem Env:* |Out-File env.txt
"$args" |Out-File args.txt

Get-ChildItem $files |Out-File items.txt