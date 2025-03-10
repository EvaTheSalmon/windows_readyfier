function Install-Apps {
    param (
        [string]$installListPath
    )
    
    if (-Not (Test-Path -Path $installListPath)) {
        Write-Output "Файл $installListPath не найден. Пропуск установки."
        return
    }
    
    $apps = Get-Content -Path $installListPath
    foreach ($app in $apps) {
        Write-Output "Установка $app..."
        winget install --id $app --silent --accept-package-agreements --accept-source-agreements
    }
}

Export-ModuleMember -Function Install-Apps