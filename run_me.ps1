# Paths to files with apps to uninstall and install
$uninstallListPath = "uninstall_list.txt"
$installListPath = "install_list.txt"

function Install-Winget {
    Write-Output "Installing winget..."
    
    try {
        $scriptPath = "$PSScriptRoot/winget-install/winget-install.ps1"
        & $scriptPath
    }
    catch {
        Write-Error "An error occurred while trying to install winget: $_"
        Write-Host "Press any key to exit..."
        $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit 0
    }
}

function Install-Apps {
    param (
        [string]$installListPath
    )
    
    if (Test-Path -Path $installListPath) {
        $apps = Get-Content -Path $installListPath
        foreach ($app in $apps) {
            Write-Output "Installing $app..."
            winget install --id $app --silent --accept-package-agreements --accept-source-agreements
        }
    } else {
        Write-Output "The file $installListPath does not exist."
    }
}

function Uninstall-Apps {
    param (
        [string]$uninstallListPath
    )
    
    if (Test-Path -Path $uninstallListPath) {
        $apps = Get-Content -Path $uninstallListPath
        foreach ($app in $apps) {
            Write-Output "Uninstalling $app..."
            winget remove $app --silent
        }
    } else {
        Write-Output "The file $uninstallListPath does not exist."
        exit 1
    }
}

function Test-IsAdministrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdministrator)) {
    Write-Warning "This script is not running as Administrator. Restart it as Administrator"
    Write-Host "Press any key to exit..."
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 0
}

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force

Install-Winget

Install-Apps -installListPath $installListPath
Uninstall-Apps -uninstallListPath $uninstallListPath

powercfg -h off                         # Hibernation off
powercfg /change monitor-timeout-ac 0   # LCD always on

Write-Host "Press any key to exit..."
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
exit 0
