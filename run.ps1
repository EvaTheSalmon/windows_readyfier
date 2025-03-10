$uninstallListPath = "$PSScriptRoot\uninstall_list.txt"
$installListPath   = "$PSScriptRoot\install_list.txt"
$logPath           = "$PSScriptRoot\install.log"

function Write-Log {
    param ([string]$message)
    "$([System.DateTime]::Now) - $message" | Out-File -Append -FilePath $logPath
}

function Test-IsAdministrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdministrator)) {
    Write-Warning "Скрипт не запущен от имени администратора. Перезапустите его с правами администратора."
    exit 1
}

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force

Import-Module "$PSScriptRoot\modules\winget.psm1" -Force
Import-Module "$PSScriptRoot\modules\install.psm1" -Force
Import-Module "$PSScriptRoot\modules\uninstall.psm1" -Force

Write-Log "Проверка наличия winget..."
Install-Winget

Write-Log "Запуск удаления приложений..."
Uninstall-Apps -uninstallListPath $uninstallListPath

Write-Log "Запуск установки приложений..."
Install-Apps -installListPath $installListPath

Write-Log "Обновление установленных приложений..."
winget upgrade --all --silent --accept-package-agreements --accept-source-agreements | Out-File -Append -FilePath $logPath

Write-Log "Настройка параметров энергопотребления..."
Powercfg /Change monitor-timeout-ac 0   # LCD всегда включен
Powercfg /Change monitor-timeout-dc 0
Powercfg /Change standby-timeout-ac 0   # ПК не засыпает
Powercfg /Change standby-timeout-dc 0

Write-Log "Отключение гибернации..."
powercfg -h off

Write-Log "Переключение плана питания на 'Высокая производительность'..."
powercfg /SETACTIVE SCHEME_MIN

Write-Log "Отключение UAC..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0

Write-Log "Отключение телеметрии..."
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0

Write-Log "Отключение истории активности..."
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Value 0

Write-Log "Все операции завершены."
exit 0
