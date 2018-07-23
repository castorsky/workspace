# Здесь нужно указать кусок наименования сетевого адаптера

$adaptor = Get-WmiObject -Class Win32_NetworkAdapter | Where-Object {$_.Name -like "*realtek*"}

$adaptor.Disable()

$adaptor.Enable()