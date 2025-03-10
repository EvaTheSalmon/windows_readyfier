function Install-Winget {
    Write-Output "Проверка наличия winget..."
    if (Get-Command -Name winget -ErrorAction SilentlyContinue) {
        Write-Output "winget уже установлен."
        return
    }
    
    Write-Output "winget не найден. Попытка установки..."
    try {
        $scriptPath = "$PSScriptRoot/winget-install/winget-install.ps1"
        & $scriptPath
    }
    catch {
        Write-Error "Ошибка установки winget: $_"
        exit 1
    }
}

Export-ModuleMember -Function Install-Winget
