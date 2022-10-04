# Create GPO
New-GPO -name "Wallpaper"
# Note down the Guid and past it into the following command

# Link GPO to OU
New-GPlink -Guid "92d4cf93-8f73-4019-9deb-98507d6568fd" -target "OU=Employees,OU=Users,OU=XYZ,DC=xyz,DC=local"

# Set desktop wallpaper
Set-GPRegistryValue -Name "Wallpaper" -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName 'WallpaperStyle' -Value 0 -Type Dword
Set-GPregistryValue -Name "Wallpaper" -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName 'Wallpaper' -Value '\\dc1.xyz.local\SYSVOL\BG\bg.jpg' -Type ExpandString

# Prevent users changing the desktop background
Set-GPRegistryValue -Name "Wallpaper" -Key 'HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop'   -ValueName 'NoChangingWallPaper' -Value 1   -Type Dword

# Set the permissions for the staff group
Set-GPPermission -Name "Wallpaper" -TargetName "Staff" -TargetType Group -PermissionLevel GpoRead