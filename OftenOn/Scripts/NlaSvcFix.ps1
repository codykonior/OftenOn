Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ((Get-CimInstance -ClassName Win32_ComputerSystem).PartOfDomain) {
    while ($true) {
        if (Get-NetConnectionProfile | Where-Object { $_.NetworkCategory -eq 'DomainAuthenticated' }) {
            "$(Get-Date) NlaSvcFix not needed"
            break
        } else {
            try {
                if (Get-Service netprofm | Where-Object { $_.Status -eq 'Running' }) {
                    "$(Get-Date) NlaSvcFix stopping netprofm"
                    Stop-Service netprofm -Force
                }
                if (Get-Service nlasvc | Where-Object { $_.Status -eq 'Running' }) {
                    "$(Get-Date) NlaSvcFix stopping nlasvc"
                    Stop-Service nlasvc -Force
                }
                if (Get-Service nlasvc | Where-Object { $_.Status -ne 'Running' }) {
                    "$(Get-Date) NlaSvcFix starting nlasvc"
                    Start-Service nlasvc
                }
                if (Get-Service netprofm | Where-Object { $_.Status -ne 'Running' }) {
                    "$(Get-Date) NlaSvcFix starting netprofm"
                    Start-Service netprofm
                }
            } catch {
                "$(Get-Date) NlaSvcFix error occurred"
                $_
            }
        }
    }
} else {
    "$(Get-Date) NlaSvcFix skipped as this computer is not yet domain joined"
}
