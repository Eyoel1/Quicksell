$filePath = 'lib\screens\home\home_screen.dart'
$content = Get-Content $filePath -Raw

# Fix the enum values
$content = $content.Replace('ProductCategory.Electronics', 'ProductCategory.electronics')
$content = $content.Replace('ProductCategory.Fashion', 'ProductCategory.clothing')
$content = $content.Replace('ProductCategory.Sports', 'ProductCategory.sports')
$content = $content.Replace('ProductCategory.Books', 'ProductCategory.books')
$content = $content.Replace('ProductCategory.Toys', 'ProductCategory.toys')
$content = $content.Replace('ProductCategory.Automotive', 'ProductCategory.furniture')
$content = $content.Replace('ProductCategory.Other', 'ProductCategory.other')
$content = $content.Replace('ProductCategory.Home', 'ProductCategory.home')

# Write back to file
[System.IO.File]::WriteAllText((Resolve-Path $filePath).Path, $content)

Write-Host "File updated successfully"
