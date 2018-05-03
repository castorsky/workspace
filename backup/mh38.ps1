Mount-DiskImage -ImagePath \\midgard\backup\virtual-backup.vhdx
$letter = (Get-DiskImage -ImagePath \\midgard\backup\virtual-backup.vhdx | Get-Disk | Get-Partition).DriveLetter

$backupPolicy = New-WBPolicy
Set-WBVssBackupOption -Policy $backupPolicy -VssFullBackup
Add-WBBareMetalRecovery -Policy $backupPolicy
Add-WBSystemState -Policy $backupPolicy
Add-WBVolume -Policy $backupPolicy -Volume (Get-WBVolume -VolumePath ("C:"))
Add-WBFileSpec -Policy $backupPolicy -FileSpec (New-WBFileSpec -FileSpec "D:\PUBLIC")
$backupTarget = New-WBBackupTarget -Volume (Get-WBVolume -VolumePath ($letter+":"))
Add-WBBackupTarget -Policy $backupPolicy -Target $backupTarget
Start-WBBackup -Policy $backupPolicy

Dismount-DiskImage -ImagePath \\midgard\backup\virtual-backup.vhdx
