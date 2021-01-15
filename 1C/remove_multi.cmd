@echo off
setlocal enableextensions disabledelayedexpansion
 
for %%a in (vusbbus haspflt) do call :CheckDriver %%a
pause
goto :eof
 
:CheckDriver
sc query %1|find /i "KERNEL_DRIVER">nul
if errorlevel 1 goto :DelSYS
sc stop %1
sc delete %1
:DelSYS
del /f /q "%SystemRoot%\system32\drivers\%1.sys"
goto :eof
