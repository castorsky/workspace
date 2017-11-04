Param(
	[Parameter(Mandatory = $True)] [string]$localSource,
	[Parameter(Mandatory = $True)] [string]$remoteTarget,
	[int]$daysToExpire = 7
)
$currentDate = Get-Date -UFormat "%Y_%m_%d"
$expireDate = Get-Date -Date $(Get-Date).AddDays(-$daysToExpire) -UFormat "%Y_%m_%d"
$PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
$logFile = (Join-Path $PSScriptRoot "webdav.log")

function Get-TimeStamp {
	Get-Date -UFormat "%Y-%m-%d %H:%M:%S"
}

try {
	Add-Type -Path (Join-Path $PSScriptRoot "WinSCPnet.dll")
	
	# Установка параметров подключения к Яндекс.Диску
	$sessionOptions = New-Object WinSCP.SessionOptions -Property @{
		Protocol = [WinSCP.Protocol]::Webdav
		HostName = "webdav.yandex.ru"
		PortNumber = 443
		UserName = "arnistudio"
		Password = "p5&bH92cc"
		WebdavSecure = $True
	}
	
	$session = New-Object WinSCP.Session
	
	try {
		# Открыть сессию (подключиться)
		$session.Open($sessionOptions)
		(Get-TimeStamp) + " Session opened" >> $logFile
		$files = $session.EnumerateRemoteFiles($remoteTarget, $Null, 
			[WinSCP.EnumerationOptions]::MatchDirectories)
		
		# Найти и удалить старые архивы
		Foreach ($file in $files) {
			If ($file.Name -lt $expireDate) {
				Write-Host ("$($file.Name) will be deleted.")
				$removalResult = $session.RemoveFiles($remoteTarget+"/"+$file.Name)
				If (!$removalResult.IsSuccess) {
					"Error removing file or directory $remoteTarget/$($file.Name): "+
					"$($removalResult.Failures[0].Message)" >> $logFile
				}
			}
		}
		
		# Создать список файлов $localFiles для отправки
		If (Test-Path $localSource -PathType container) {
			$localFiles = @($localSource) + (Get-ChildItem $localSource -Recurse | Select-Object -ExpandProperty FullName)
		}
		else {
			$localFiles = $localFiles
		}
		
		# Поменять назначение на папку с текущей датой
		#  и создать ее на сервере
		$remoteTarget += "/"+$currentDate
        If (!($session.FileExists($remoteTarget))) {
			$session.CreateDirectory($remoteTarget)
            (Get-TimeStamp) + " Target directory created" >> $logFile
		} else {
            (Get-TimeStamp) + " Target directory exists. Cleaning" >> $logFile
            $removalResult = $session.RemoveFiles($remoteTarget)
			If (!$removalResult.IsSuccess) {
				(Get-TimeStamp) + " Error removing file or directory $remoteTarget/$($file.Name): "+
				"$($removalResult.Failures[0].Message)" >> $logFile
			}
            else {
                $session.CreateDirectory($remoteTarget)
                (Get-TimeStamp) + " Target directory recreated" >> $logFile
            }
        }
		
		# Начать процесс заливки на сервер
		$localParent = Split-Path -Parent (Resolve-Path $localSource)
        Foreach ($localFilePath in $localFiles) {
            $remoteFilePath = $session.TranslateLocalPathToRemote(
				$localFilePath, $localParent, $remoteTarget)
			
			# Если папка, то проверить существование на сервере
			# Если файл, то залить его на сервер
			If (Test-Path $localFilePath -PathType container) {
				# Если папки нет - создать
				If (!($session.FileExists($remoteFilePath))) {
					$session.CreateDirectory($remoteFilePath)
				}
			}
			else {
				$transferResult = $session.PutFiles($localFilePath, $remoteFilePath)
				If (!$transferResult) {
					(Get-TimeStamp) + " Error uploading file $localFilePath" +
						$($transferResult.Failures[0].Message) >> $logFile
				}
				else {
					(Get-TimeStamp) + " File $localFilePath successfully uploaded" >> $logFile
				}
			}
		}
	}
	finally {
		$session.Dispose()
		(Get-TimeStamp) + " Session closed$([Environment]::NewLine)" +
			"----------------------------------" >> $logFile
	}	
	exit 0
}
catch [Exception] {
	Write-Host "Error: $($_.Exception.Message)"
	exit 1
}