# Winget Modules

## Описание
Этот проект включает в себя модули для автоматической установки и удаления приложений с помощью **winget** в Windows.

## Структура
- `modules/winget.psm1` - Проверка наличия и установка winget.
- `modules/install.psm1` - Модуль для установки приложений.
- `modules/uninstall.psm1` - Модуль для удаления приложений.
- `install_list.txt` - Список приложений для установки.
- `uninstall_list.txt` - Список приложений для удаления.
- `run.ps1` - Главный исполняемый файл, запускающий установку и удаление.

## Использование
Просто запустите основной скрипт:
```powershell
./run.ps1
```

## Настройка
1. Добавьте приложения для установки в `install_list.txt`, каждое на новой строке.
2. Добавьте приложения для удаления в `uninstall_list.txt`, каждое на новой строке.

## Требования
- Windows 10 / 11
- Winget установлен (если отсутствует, модуль `winget.psm1` попытается его установить)
