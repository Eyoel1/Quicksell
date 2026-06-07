$content = Get-Content 'lib\screens\home\home_screen.dart' -Raw
$content = $content -replace 'ProductCategory\.Electronics', 'ProductCategory.electronics'
$content = $content -replace 'ProductCategory\.Fashion', 'ProductCategory.clothing'
$content = $content -replace 'ProductCategory\.Home:', 'ProductCategory.home:'
$content = $content -replace 'ProductCategory\.Sports', 'ProductCategory.sports'
$content = $content -replace 'ProductCategory\.Books', 'ProductCategory.books'
$content = $content -replace 'ProductCategory\.Toys', 'ProductCategory.toys'
$content = $content -replace 'ProductCategory\.Automotive', 'ProductCategory.furniture'
$content = $content -replace 'ProductCategory\.Other', 'ProductCategory.other'
Set-Content 'lib\screens\home\home_screen.dart' -Value $content -NoNewline
