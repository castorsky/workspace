@ECHO  OFF
SET FOLDER="D:\1C_BACKUP"
SET BASE="D:\1C_DATA\MM"
SET USER="backup_user"
SET PWD="backupsystem"
SET ALLOW="РазрешитьРаботуПользователей"
SET ALLOWCODE="КодРазрешения"
SET PROG="C:\Program Files (x86)\1cv8\common\1cestart.exe"
rem Разрешить пользователям работу
%PROG% ENTERPRISE /F %BASE% /N %USER% /P %PWD% /C %ALLOW% /UC %ALLOWCODE% /DisableStartupMessages
