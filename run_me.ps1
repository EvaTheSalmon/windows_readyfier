# Paths to files with apps to uninstall and install
$uninstallListPath = "uninstall_list.txt"
$installListPath = "install_list.txt"

function Test-WingetInstalled {
    try {
        Get-Command winget -ErrorAction Stop
        Write-Output "Winget is already installed"
        return $true
    }
    catch {
        Write-Output "Winget is not installed"
        return $false
    }
}

function Install-Winget {
    Write-Output "Installing winget..."
    $appInstallerUrl = "https://aka.ms/getwinget"

    try {
        Start-Process ms-windows-store -ArgumentList "AppLink=$appInstallerUrl" -Wait
        if (Test-WingetInstalled) {
            Write-Output "Winget installation was successful"
        } else {
            Write-Output "Winget installation failed"
        }
    }
    catch {
        Write-Error "An error occurred while trying to install winget: $_"
    }
}

function Install-Apps {
    param (
        [string]$installListPath
    )
    
    if (Test-Path $installListPath) {
        $apps = Get-Content $installListPath
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
    
    if (Test-Path $uninstallListPath) {
        $appList = Get-Content $uninstallListPath
        foreach ($app in $appList) {
            Write-Output "Uninstalling $app..."
            try {
                winget uninstall $app
                Write-Output "$app uninstalled successfully"
            }
            catch {
                Write-Output "Failed to uninstall $($app): $_"
            }
        }
    } else {
        Write-Output "File $uninstallListPath not found"
        exit 1
    }
}

Write-Output "Checking for winget availability..."
if (-not (Test-WingetInstalled)) {
    Install-Winget
}

Install-Apps -installListPath $installListPath
Uninstall-Apps -uninstallListPath $uninstallListPath

# Workspace setup
powercfg -h off                         # Hibernation off
powercfg /change monitor-timeout-ac 0   # LCD always on 

Write-Host "Press any key to continue..."
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
exit 0
