Param(
   [string]$localSource,
   [string]$targetName,
   [int]$daysToExpire
)
$env:PATH +=";$env:LOCALAPPDATA\MEGAcmd"
$currentDate = Get-Date -UFormat "%Y_%m_%d"
$expireDate = Get-Date -Date $(Get-Date).AddDays(-$daysToExpire) -UFormat "%Y_%m_%d"

mega-login studio@ya.ru 4LUC3y67nc7S2kkephyI
mega-cd backup/$targetName
$backupList = mega-ls
Foreach ($date in $backupList) {
   If ($date -lt $expireDate) {
      mega-rm -rf $date
   }
}
mega-mkdir $currentDate
cd $localSource
$localFiles = Get-ChildItem -Name
Foreach ($item in $localFIles) {
   mega-put $item $currentDate
}

mega-logout
mega-exit
