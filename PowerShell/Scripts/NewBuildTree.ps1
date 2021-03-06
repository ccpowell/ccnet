function New-BuildConfiguration($product, $configuration)
{
    New-Item -ItemType directory -Path "C:\Build\Work\$product\$configuration"
    New-Item -ItemType directory -Path "C:\Build\Artifacts\$product\$configuration"
    New-Item -ItemType directory -Path "C:\Build\Products\$product\$configuration"
}
function New-BuildTree($product)
{
    New-BuildConfiguration $product Debug
    New-BuildConfiguration $product QA
    New-BuildConfiguration $product Release
}
