function Uninstall-Apps {
    param (
        [string]$uninstallListPath
    )
    
    if (-Not (Test-Path -Path $uninstallListPath)) {
        Write-Output "Файл $uninstallListPath не найден. Пропуск удаления."
        return
    }
    
    $apps = Get-Content -Path $uninstallListPath
    foreach ($app in $apps) {
        Write-Output "Удаление $app..."
        winget uninstall --id $app --silent
    }
}

Export-ModuleMember -Function Uninstall-Apps