@ECHO  OFF
SET FOLDER="D:\1C_BACKUP"
SET BASE="D:\1C_DATA\MM"
SET BASENAME="SmallBusiness"
SET USER="backup_user"
SET PWD="backupsystem"
SET DENY="ЗавершитьРаботуПользователей"
SET ALLOW="РазрешитьРаботуПользователей"
SET ALLOWCODE="КодРазрешения"
SET PROG="C:\Program Files (x86)\1cv8\common\1cestart.exe"
FOR /F "tokens=1-3 delims=/." %%A IN ("%DATE%") DO (
	SET DAY=%%A
	SET MONTH=%%B
	SET YEAR=%%C
)
FOR /F "tokens=1-2 delims=/:" %%D IN ("%TIME%") DO (
	SET HOUR=%%D
	SET MINUTE=%%E
)
rem Запретить пользователям работать в базе
%PROG% ENTERPRISE /F %BASE% /N %USER% /P %PWD% /C %DENY% /DisableStartupMessages
rem Спать 300 секунд
ping -n 120 127.0.0.1 >nul 2>&1
rem Собственно запуск выгрузки базы
CD %FOLDER%
%PROG% DESIGNER /IBName %BASENAME% /N %USER% /P %PWD% /DumpIB "%YEAR%%MONTH%%DAY%_%HOUR%%MINUTE%.dt" /UC %ALLOWCODE% /DisableStartupMessages
