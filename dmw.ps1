# Uninstall Microsoft Edge
$EdgeVersion = Get-AppxPackage -AllUsers | Where-Object { $_.Name -eq "Microsoft.MicrosoftEdge.Stable" } | Select-Object -ExpandProperty Version
if ($EdgeVersion) {
    Write-Host "Starting to Uninstall Microsoft Edge."
    try {
        Write-Host 'Uninstalling Microsoft Edge.'
        Start-Process -FilePath ${env:ProgramFiles(x86)}"\Microsoft\Edge\Application\"$EdgeVersion"\Installer\setup.exe" -Wait -ArgumentList "--uninstall", "--system-level", "--verbose-logging", "--force-uninstall"
        Write-Host 'Microsoft Edge Uninstalled Successfully!' -BackgroundColor DarkGreen
    }
    catch {
        Write-Host $_.Exception.Message -BackgroundColor DarkRed
    }
}
else {
    Write-Host 'Microsoft Edge installation not found.'
}

# Uninstall OneDrive
try {
    Write-Host "Starting to Uninstall OneDrive."
    Start-Process -FilePath ${env:SystemRoot}"\SysWOW64\OneDriveSetup.exe" -Wait -ArgumentList "/uninstall"
    Write-Host 'OneDrive Uninstalled Successfully!' -BackgroundColor DarkGreen
}
catch {
    Write-Host $_.Exception.Message -BackgroundColor DarkRed
}

$WhiteList = @(
    'Microsoft.Windows.Photos',
    'Microsoft.WindowsCalculator',
    'Microsoft.WindowsStore',
    'Microsoft.XboxGameOverlay',
    'Microsoft.XboxGamingOverlay',
    'Microsoft.XboxIdentityProvider',
    'Microsoft.XboxSpeechToTextOverlay',
    'Microsoft.UI.Xaml.2.0',
    'Microsoft.VCLibs.140.00',
    'Microsoft.NET.Native.Runtime.2.2',
    'Microsoft.NET.Native.Framework.2.2'
)

# AppxProvisionedPackage
$ProvisionedPackage = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -NotIn $WhiteList }

if ($ProvisionedPackage) {

    $ProvisionedPackage | Select-Object DisplayName, Version | Out-String

    if ($Host.UI.PromptForChoice('Confirm', 'Do you want to remove these packages?', ('&Yes', '&No'), 1) -eq 0) {
        $count = 0
        foreach ($currentItemName in $ProvisionedPackage) {
            $count = $count + 1
            $Completed = ($count / $ProvisionedPackage.Count) * 100
            Write-Progress -Status $currentItemName.DisplayName -PercentComplete $Completed
            Remove-AppxProvisionedPackage -Online -PackageName $currentItemName.PackageName | Out-Null
        }
    }
}

# AppxPackage
$AppxPackage = Get-AppxPackage -AllUsers | Where-Object { -not $_.NonRemovable -and $_.Dependencies -and $_.Name -NotIn $WhiteList }

if ($AppxPackage) {

    $AppxPackage | Select-Object Name, Version | Out-String

    if ($Host.UI.PromptForChoice('Confirm', 'Do you want to remove these packages?', ('&Yes', '&No'), 1) -eq 0) {
        foreach ($currentItemName in $AppxPackage) {
            Remove-AppPackage -Package $currentItemName.PackageFullName
        }
    }
}

# Removing installed dependencies...
$AppxPackageDependencies = Get-AppxPackage -AllUsers | Where-Object { -not $_.NonRemovable -and -not $_.Dependencies -and $_.Name -NotIn $WhiteList }

if ($AppxPackageDependencies) {

    $AppxPackageDependencies | Select-Object Name, Version | Out-String

    if ($Host.UI.PromptForChoice('Confirm', 'Do you want to remove these packages?', ('&Yes', '&No'), 1) -eq 0) {
        foreach ($currentItemName in $AppxPackageDependencies) {
            Remove-AppPackage -Package $currentItemName.PackageFullName
        }
    }
}
