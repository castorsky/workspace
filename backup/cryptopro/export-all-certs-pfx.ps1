param($password=123456)
$secret = ConvertTo-SecureString -String $password -Force -AsPlainText

$env:Path = $env:Path+";"+$env:ProgramFiles+"\Crypto Pro\CSP;"+${env:ProgramFiles(x86)}+"\Crypto Pro\CSP"
$documentPath = [Environment]::GetFolderPath("MyDocuments")
[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("cp866")
New-Item -Force -Path $documentPath -Name "CryptoProPFX" -ItemType "directory" 

# List of container names
$containerList = @()
$containers = csptest.exe -keyset -enum_cont -fqcn
foreach ($line in $containers) {
    $temp = Select-String -InputObject $line -Pattern ".*REG.*"
    If ((![string]::IsNullOrWhiteSpace($temp))) {
        $containerList += $temp
    }
}

# List of certificates stored at containers
$containerCerts = @{}
foreach ($container in $containerList) {
    $certInfo = ''
    # <--- Workaround container names with quotes inside
    $quotedContainer = $container -replace '"','\"'
    $cmdLine = "certmgr.exe -list -container "+'"'+"$quotedContainer"+'"'
    $certInfo = cmd.exe /C $cmdLine
    # ---/> Workaround
    foreach ($line in $certInfo) {
        $SHA1Found = $line -Match '.*SHA1.*\:\s*(?<fingerprint>[0-9a-fA-F]+)'
        if ($SHA1Found) {
            $containerCerts.Add($Matches.fingerprint, $quotedContainer)
            break
        }
    }
}

# List of certificates at Windows' user store
$windowsCerts = @()
$allWinCerts = Get-ChildItem cert:\CurrentUser\My
foreach ($cert in $allWinCerts) {
    if ($cert.HasPrivateKey) {
        $windowsCerts += $cert.Thumbprint
    }
}

# Determine certificates that will be installed to Windows store
$containerCertsOnly = $containerCerts.Keys | % ToString
$compared = Compare-Object -ReferenceObject $containerCertsOnly -DifferenceObject $windowsCerts
$missingInWindows = @()
foreach ($item in $compared) {
    if ($item.SideIndicator.Equals('<=')) {
        $missingInWindows += $item.InputObject
    }
}

# Install missed certs to Windows store
foreach ($certificate in $missingInWindows) {
    $cmdLine = "certmgr.exe -install -store uMy -container "+'"'+$containerCerts.$certificate+'"'
    $cmdResult = cmd.exe /C $cmdLine
    $windowsCerts += $certificate
}

foreach ($windowsCert in $windowsCerts) {
    $cert = Get-ChildItem cert:\CurrentUser\My\$windowsCert
    $cn = $cert.GetNameInfo('SimpleName', $false).Replace('"','')
    $startDate = $cert.NotBefore.ToString("yyyyMMdd")
    $endDate = $cert.NotAfter.ToString("yyyyMMdd")
    $certFile = $documentPath+'\CryptoProPFX\'+"$cn-$startDate-$endDate.cer"
    $pfxFile = $documentPath+'\CryptoProPFX\'+"$cn-$startDate-$endDate.pfx"
    Export-Certificate -NoClobber -Type CERT -Cert $cert -FilePath $certFile
    Export-PfxCertificate -NoClobber -Cert $cert -Password $secret -FilePath $pfxFile
}

Write-Host 'Export finished!'