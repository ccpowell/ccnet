$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2

# get the latest build directory and configuration
function Get-LatestBuild($product, $configuration) 
{   
    $dir = Get-ChildItem "\\buildsrv\build\Products\$product\$configuration" | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1
       
    @{ 
        PackageDir = $dir.FullName; 
        LocalPackageDir = $dir.FullName -replace '\\\\buildsrv\\build','X:'
        BuildConfiguration = $product; 
        BuildNumber = $dir; 
    }
}  

# get the latest TFS build directory and configuration
function Get-LatestTfsBuild($product, $configuration) 
{   
    $dir = Get-ChildItem "\\buildsrv\build\Products\$product\${product}_${configuration}" | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1
           
    # find package directory
    $subdir = $dir.FullName -replace '\\\\buildsrv\\build','X:'
    Set-Location $subdir
    $pdir = Get-ChildItem -Filter "_PublishedWebsites\*_Package" | Select-Object -First 1

    @{ 
        LocalPackageDir = $pdir.FullName;
    }
}  
    
# install latest build to CI server
function Install-Build($product, $configuration, $server, $confirm)
{
    $cfg = Get-LatestBuild $product $configuration
    Set-Location $cfg.LocalPackageDir
    $cmd = Get-ChildItem -Filter '*.deploy.cmd'| Select-Object -First 1
    $y = 'T';
    if ($confirm) { $y = 'Y'}
    C:\Windows\system32\cmd.exe /C $cmd /M:$server  /U:'' /$y
}   

# install latest build to CI server
function Install-TfsBuild($product, $configuration, $server, $confirm)
{
    $cfg = Get-LatestTfsBuild $product $configuration
    Set-Location $cfg.LocalPackageDir
    $cmd = Get-ChildItem -Filter '*.deploy.cmd'| Select-Object -First 1
    $y = 'T';
    if ($confirm) { $y = 'Y'}
    C:\Windows\system32\cmd.exe /C $cmd /M:$server  /U:'' /$y
}



function Install-SubMenus()
{       
    $name = 'CCNet Build and Install'

    foreach ($tab in $psISE.PowerShellTabs)
    {
        if ($tab.DisplayName -eq $name)
        {
            $psISE.PowerShellTabs.Remove($tab)
            break
        }
    }
    $tab = $psISE.PowerShellTabs.Add()
    $tab.DisplayName = $name
    
    # we need double _ in menu string
    $i = $tab.AddOnsMenu.Submenus.Add("Install On DEV Server", $null, $null)
    $i.Submenus.Add('Ombudsman (Debug)', {Install-TfsBuild Ombudsman Debug wwwdev $true}, $null)
    $i.Submenus.Add('Contacts (Debug)', {Install-Build ContactManagement Debug wwwdev $true}, $null)
    $i.Submenus.Add('Trips4 (Debug)', {Install-TfsBuild Trips4 Debug wwwdev $true}, $null)
    $i.Submenus.Add('TipCfp (Debug)', {Install-Build TipCfp Debug wwwdev $true}, $null)
    $i.Submenus.Add('TipCfpAdmin (Debug)', {Install-Build TipCfpAdmin Debug wwwdev $true}, $null)

    $i = $tab.AddOnsMenu.Submenus.Add("Install On QA Server", $null, $null)
    $i.Submenus.Add('Ombudsman', {Install-TfsBuild Ombudsman QA wwwqa $true}, $null)
    $i.Submenus.Add('Contacts', {Install-Build ContactManagement QA wwwqa $true}, $null)
    $i.Submenus.Add('Trips4', {Install-TfsBuild Trips4 QA wwwqa $true}, $null)
    $i.Submenus.Add('TipCfp', {Install-Build TipCfp QA wwwqa $true}, $null)
    $i.Submenus.Add('TipCfpAdmin', {Install-Build TipCfpAdmin QA wwwqa $true}, $null)

    $i = $tab.AddOnsMenu.Submenus.Add("Install On Production", $null, $null)
    $i.Submenus.Add('Ombudsman', {Install-TfsBuild Ombudsman Release www3 $true}, $null)
    $i.Submenus.Add('Contacts', {Install-Build ContactManagement Release www3 $true}, $null)
    $i.Submenus.Add('Trips4', {Install-TfsBuild Trips4 Release www3 $true}, $null)
    $i.Submenus.Add('TipCfp', {Install-Build TipCfp Release www3 $true}, $null)
    $i.Submenus.Add('TipCfpAdmin', {Install-Build TipCfpAdmin Release www3 $true}, $null)

}  

Export-ModuleMember -Function Get-*, Install-*

