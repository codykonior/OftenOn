Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ((Get-CimInstance -ClassName Win32_ComputerSystem).PartOfDomain) {
    while ($true) {
        "$((Get-Date).ToUniversalTime().ToString("s"))Z Checking profiles"
        $profiles = Get-NetConnectionProfile
        $profiles | Format-Table InterfaceAlias, NetworkCategory | Out-String

        if ($profiles | Where-Object { $_.NetworkCategory -eq 'DomainAuthenticated' }) {
            "$((Get-Date).ToUniversalTime().ToString("s"))Z At least one profile is Domain Authenticated, exiting"
            break
        }

        "$((Get-Date).ToUniversalTime().ToString("s"))Z No profiles are Domain Authenticated, restarting services"

        try {
            foreach ($service in "netprofm", "nlasvc") { 
                if (Get-Service $service | Where-Object { $_.Status -eq 'Running' }) {
                    "$((Get-Date).ToUniversalTime().ToString("s"))Z Stopping service [$service]"
                    Stop-Service $service -Force
                }
            }
            foreach ($service in "nlasvc", "netprofm") { 
                if (Get-Service $service | Where-Object { $_.Status -ne 'Running' }) {
                    "$((Get-Date).ToUniversalTime().ToString("s"))Z Starting service [$service]"
                    Start-Service $service
                }
            }
        } catch {
            "$((Get-Date).ToUniversalTime().ToString("s"))Z Error occurred during service restarts [$_]"
        }

        Start-Sleep -Seconds 60
    }
} else {
    "$((Get-Date).ToUniversalTime().ToString("s"))Z This computer is not domain joined, exiting"
}
