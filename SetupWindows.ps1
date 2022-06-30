$FullName = "Collin Dewey"
$ComputerName = "BURGUNDY"
$WallpaperLocation = "https://terascripting.com/public/Wallpapers/1302565.png"
$LockscreenLocation = "https://terascripting.com/public/Wallpapers/1382987.png"
$AvatarLocation = "https://terascripting.com/public/Avatars/Magic1.png"
$TimeZoneID = "Eastern Standard Time"

$AppxPackagesToUninstall = @(
	("Microsoft.Microsoft3DViewer"),
	("Microsoft.WindowsFeedbackHub"),
	("Microsoft.GetHelp"),
	("Microsoft.ZuneMusic"),
	("Microsoft.WindowsMaps"),
	("Microsoft.MixedReality.Portal"),
	("Microsoft.ZuneVideo"),
	("Microsoft.SkypeApp"),
	("Microsoft.ScreenSketch"),
	("Microsoft.MicrosoftStickyNotes"),
	("Microsoft.XboxApp"),
	("Microsoft.XboxGamingOverlay"),
	("Microsoft.People"),
	("Microsoft.Office.OneNote"),
	("Microsoft.MicrosoftSolitaireCollection"),
	("Microsoft.MicrosoftOfficeHub"),
	("Microsoft.BingWeather"),
	("Microsoft.WindowsAlarms"),
	("Microsoft.MSPaint")
)

$WingetPackagesToUninstall = @(
	("Microsoft.Edge"),
	("Microsoft.OneDrive")
)

$WingetPackagesToInstall = @(
	#Browsers
	("Mozilla.Firefox"),
	("Google.Chrome"),
	#Utilities
	("Microsoft.WindowsTerminal"),
	("7zip.7zip"),
	("WinSCP.WinSCP"),
	("KeeWeb.KeeWeb"),
	("WireGuard.Wireguard"),
	("KDE.Krita"),
	("Discord.Discord"),
	("TeamViewer.TeamViewer"),
	("WinFsp.WinFsp"),
	("SSHFS-Win.SSHFS-Win"),
	("evsar3.sshfs-win-manager"),
	("Notepad++.Notepad++"),
	("Microsoft.VisualStudioCode"),
	("Flameshot.Flameshot"),
	("stax76.mpv.net"),
	("AppWork.JDownloader"),
	("WinDirStat.WinDirStat"),
	#Games
	("OBSProject.OBSStudio"),
	("Moonsworth.LunarClient"),
	("Valve.Steam"),
	("MoonlightGameStreamingProject.Moonlight"),
	("Mojang.MinecraftLauncher"),
	("EpicGames.EpicGamesLauncher"),
	("Nvidia.GeForceExperience")
)

# Elevate Script
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
	if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
		$CommandLine = "-ExecutionPolicy Bypass " + "-File `"" + $MyInvocation.MyCommand.Path + "`" " + $MyInvocation.UnboundArguments
		Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
		Exit
	}
}

# Enter temp folder
New-Item -ItemType "directory" -Path "$env:TEMP\SetupWindows" | Out-Null
Set-Location -Path "$env:TEMP\SetupWindows"

# Set DPI scaling to 100%
Write-Host "Setting DPI scaling to 100%"
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name LogPixels -Value 96
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name Win8DpiScaling -Value 1

# Set avatar - http://www.classicshell.net/forum/viewtopic.php?f=12&t=7921
$AvatarExtension = $AvatarLocation.split('.')[$AvatarLocation.split('.').Length - 1]
$AvatarPath = "$env:USERPROFILE\Pictures\Avatar.$AvatarExtension"
Write-Host "Downloading Avatar to $AvatarPath"
Invoke-WebRequest $AvatarLocation -OutFile "$AvatarPath"

Function ResizeImage() {
    param([String]$ImagePath, [Int]$Quality = 90, [Int]$targetSize, [String]$OutputLocation)

    Add-Type -AssemblyName "System.Drawing"

    $img = [System.Drawing.Image]::FromFile($ImagePath)

    $CanvasWidth = $targetSize
    $CanvasHeight = $targetSize

    #Encoder parameter for image quality
    $ImageEncoder = [System.Drawing.Imaging.Encoder]::Quality
    $encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter($ImageEncoder, $Quality)

    # get codec
    $Codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object {$_.MimeType -eq 'image/jpeg'}

    #compute the final ratio to use
    $ratioX = $CanvasWidth / $img.Width;
    $ratioY = $CanvasHeight / $img.Height;

    $ratio = $ratioY
    if ($ratioX -le $ratioY) {
    $ratio = $ratioX
    }

    $newWidth = [int] ($img.Width * $ratio)
    $newHeight = [int] ($img.Height * $ratio)

    $bmpResized = New-Object System.Drawing.Bitmap($newWidth, $newHeight)
    $graph = [System.Drawing.Graphics]::FromImage($bmpResized)
    $graph.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

    $graph.Clear([System.Drawing.Color]::White)
    $graph.DrawImage($img, 0, 0, $newWidth, $newHeight)

    #save to file
    $bmpResized.Save($OutputLocation, $Codec, $($encoderParams))
    $bmpResized.Dispose()
    $img.Dispose()
}

$SID = [System.Security.Principal.WindowsIdentity]::GetCurrent().User.Value

$image_sizes = @(32, 40, 48, 96, 192, 200, 240, 448)
$image_mask = "Image{0}.jpg"
$image_base = $env:public + "\AccountPictures"
$reg_base = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AccountPicture\Users\{0}"
$reg_key = [string]::format($reg_base, $SID)
$reg_value_mask = "Image{0}"
If ((Test-Path -Path $reg_key) -eq $false) { New-Item -Path $reg_key | Out-Null }
ForEach ($size in $image_sizes) {
    $dir = $image_base + "\" + $SID
    If ((Test-Path -Path $dir) -eq $false) { $(mkdir $dir).Attributes = "Hidden" }
    $file_name = ([string]::format($image_mask, $size))
    $path = $dir + "\" + $file_name
    ResizeImage $AvatarPath $size $size $path
    $name = [string]::format($reg_value_mask, $size)
    New-ItemProperty -Path $reg_key -Name $name -Value $path -Force | Out-Null
}

# Set full username
Write-Host "Setting Full Name to $FullName"
Set-LocalUser -Name $env:UserName -Fullname $FullName

# Hide "Meet now" system notification thing
Write-Host "Hiding meet-now notification"
New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name 'HideSCAMeetNow' -Value 1 -PropertyType DWORD -Force | Out-Null

# Turn off Windows Security Notification Icon
Write-Host "Hiding Windows Security Notification Icon"
Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name 'SecurityHealth'

# Rename computer
Write-Host "Renaming Computer to $ComputerName"
$WarningPreference = "SilentlyContinue"
Rename-Computer $ComputerName

# Download wallpaper
Write-Host "Downloading and Setting Wallpaper"
$WallpaperExtension = $WallpaperLocation.split('.')[$WallpaperLocation.split('.').Length - 1]
Invoke-WebRequest $WallpaperLocation -OutFile "$env:USERPROFILE\Pictures\Wallpaper.$WallpaperExtension"

# Download lockscreen wallpaper
Write-Host "Downloading Lock Screen Image"
$LockscreenExtension = $LockscreenLocation.split('.')[$LockscreenLocation.split('.').Length - 1]
Invoke-WebRequest $LockscreenLocation -OutFile "$env:USERPROFILE\Pictures\Lockscreen.$LockscreenExtension"

# Set Wallpaper and Lockscreen
Write-Host "Setting Wallpaper and Lockscreen"
[Windows.Storage.StorageFile,Windows.Storage,ContentType=WindowsRuntime] | Out-Null
[Windows.System.UserProfile.LockScreen,Windows.System.UserProfile,ContentType=WindowsRuntime] | Out-Null
Add-Type -AssemblyName System.Runtime.WindowsRuntime

$asTaskGeneric = ([System.WindowsRuntimeSystemExtensions].GetMethods() | ? { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 -and $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]
function Await($WinRtTask, $ResultType) {
	$asTask = $asTaskGeneric.MakeGenericMethod($ResultType)
	$netTask = $asTask.Invoke($null, @($WinRtTask))
	$netTask.Wait(-1) | Out-Null
	$netTask.Result
}

$LockscreenFile = Await ([Windows.Storage.StorageFile]::GetFileFromPathAsync("$env:USERPROFILE\Pictures\Lockscreen.$LockscreenExtension")) ([Windows.Storage.StorageFile])
[Windows.System.UserProfile.LockScreen]::SetImageFileAsync($LockscreenFile) | Out-Null
Set-ItemProperty -path 'HKCU:\Control Panel\Desktop\' -Name WallPaper -Value "$env:USERPROFILE\Pictures\Wallpaper.$WallpaperExtension"

# Set timezone
Write-Host "Setting Time Zone to $TimeZoneID"
Set-TimeZone -Id $TimeZoneID

# Set show hidden file extensions
Write-Host "Showing Hidden File Extensions"
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name HideFileExt 0

# Disable hibername
Write-Host "Disabling Hibernate"
powercfg -h off

# Set Power Settings
Write-Host "Changing Power options"
powercfg -setdcvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 7648efa3-dd9c-4e3e-b566-50f929386280 3
powercfg -setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 7648efa3-dd9c-4e3e-b566-50f929386280 3
powercfg -SetActive SCHEME_CURRENT
powercfg /X standby-timeout-ac 0
powercfg /X monitor-timeout-ac 0

# Disable Bing Search
Write-Host "Disabling Windows Bing Search"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Type DWORD -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Type DWORD -Value 0
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search")) {
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Type DWORD -Value 1

# Hide Task View icon
Write-Host "Hiding Task View Icon"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Type DWORD -Value 0

# Windows 11 Specifics 
if (([Environment]::OSVersion.Version).Build -ge 22000) {
	# Hide Search icon
	Write-Host "Hiding Search Icon"
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Type DWORD -Value 0

	# Hide Widgets Icon
	Write-Host "Hide Widgets Icon"
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Type DWORD -Value 0

	# Move Taskbar to the left
	Write-Host "Left aligning Task Bar"
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarDa" -Type DWORD -Value 0

	# Turn off recommended
	Write-Host "Turning off recommended"
	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackDocs" -Type DWORD -Value 0

}

# Hide Recently Added Apps and Most Used Apps
Write-Host "Hiding Recently used and most used apps"
If (!(Test-Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer")) {
	New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" | Out-Null
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "HideRecentlyAddedApps" -Type DWORD -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoStartMenuMFUprogramsList" -Type DWORD -Value 1

# Hide Weather Applet
Write-Host "Removing Weather and News"
New-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds" -Name "ShellFeedsTaskbarViewMode" -Value 2 -PropertyType DWORD -Force | Out-Null

# Unpin Start Menu Tiles
Write-Host "Unpinning Start Menu Tiles"
$key = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*start.tilegrid`$windows.data.curatedtilecollection.tilecollection\Current"
$data = $key.Data[0..25] + ([byte[]](202,50,0,226,44,1,1,0,0))
Set-ItemProperty -Path $key.PSPath -Name "Data" -Type Binary -Value $data
Stop-Process -Name "ShellExperienceHost" -Force -ErrorAction SilentlyContinue

# Unpin Microsoft Store and Mail from the taskbar
$appname = "Microsoft Store"
((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | Where-Object{$_.Name -eq $appname}).Verbs() | Where-Object{$_.Name.replace('&','') -match 'Unpin from taskbar'} | ForEach-Object{$_.DoIt();}
$appname = "Mail"
((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | Where-Object{$_.Name -eq $appname}).Verbs() | Where-Object{$_.Name.replace('&','') -match 'Unpin from taskbar'} | ForEach-Object{$_.DoIt();}

# Disable XBOX Game Bar
Write-Host "Disabling XBOX Game Bar"
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0

# Turn off app suggestions
Write-Host "Turning off app suggestions"
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Value 0

# Hide Cortana
Write-Host "Hiding Cortana Button"
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCortanaButton" -Value 0

# Download KDE Window Movement
Invoke-Webrequest "https://terascripting.com/public/Software/SetupOS/kde-style-window-move.exe"-OutFile "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\kde-style-window-move.exe"

# Install Armoury Crate
if ($ComputerName -eq "BURGUNDY") {
    Write-Host "Downloading and launching Armoury Crate installer"
    Invoke-WebRequest "https://dlcdnets.asus.com/pub/ASUS/mb/14Utilities/SetupROGLSLService.zip" -OutFile ArmouryCrate.zip
    Expand-Archive ArmouryCrate.zip
    Remove-Item ArmouryCrate.zip
    $ArmouryCrateProcess = Start-Process ArmouryCrate\ArmouryCrateInstaller.exe -PassThru
    $ArmouryCrateProcess.WaitForExit()
    Remove-Item ArmouryCrate -Recurse -Force
}

# Install winget
Write-Host "Installing Winget"
Invoke-WebRequest "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" -OutFile "VCLibs.appx"
$ErrorActionPreference = "SilentlyContinue"
Add-AppxPackage -Path "VCLibs.appx"
$ErrorActionPreference = "Continue"

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest ((Invoke-RestMethod -uri "https://api.github.com/repos/microsoft/winget-cli/releases/latest").assets | Where-Object { $_.browser_download_url.EndsWith("msixbundle") } | Select-Object -First 1).browser_download_url -OutFile "Winget.msixbundle"
Add-AppxPackage -Path "Winget.msixbundle"
# Remove AppxPackages
Write-Host "Uninstalling AppxPackages"
foreach ($Application in $AppxPackagesToUninstall) {
    Write-Host "Uninstalling $Application"
	Get-AppxPackage $Application | Remove-AppxPackage
}

# Winget uninstall software
Write-Host "Uninstalling software with winget"
foreach ($Application in $WingetPackagesToUninstall) {
    Write-Host "Uninstalling $Application"
	winget uninstall $Application
}

# Winget install packages
Write-Host "Installing packages with winget"
foreach ($Application in $WingetPackagesToInstall) {
    Write-Host "Installing $Application"
	winget install $Application
}

# Delete temp folder
Set-Location -Path "$env:TEMP"
Remove-Item -Path "$env:TEMP\SetupWindows" -Recurse -Force

# Wait for Reboot
Write-Host "`nPress any key to reboot..."
[Console]::ReadKey($true) | Out-Null
Restart-Computer
