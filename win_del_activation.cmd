DEL "%windir%\system32\drivers\oem-drv64.sys"
DEL "%windir%\system32\xNtKrnl.exe"
DEL "%windir%\system32\xOsLoad.exe"
DEL "%windir%\System32\ru-RU\xOsLoad.exe.mui"
DEL "%windir%\System32\en-US\xOsLoad.exe.mui"
BCDEDIT /set {current} path \Windows\system32\winload.exe
BCDEDIT /deletevalue {current} kernel
BCDEDIT /deletevalue {current} nointegritychecks
BCDEDIT /deletevalue {current} custom:26000027
REG DELETE HKLM\SYSTEM\CurrentControlSet\services\oem-drv64 /va /f
pause
shutdown -r -t 0
