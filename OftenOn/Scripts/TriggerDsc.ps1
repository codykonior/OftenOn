Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Wait until DSC is idle
while ($true) {
    $dscStatus = Get-DscLocalConfigurationManager
    "$(Get-Date) TriggerDsc status is $($dscStatus.LCMState)"

    if ($dscStatus.LCMState -eq 'Idle') {
        break
    }

    Start-Sleep -Seconds 60
}

# Get last execution
$lastConfiguration = Get-DscConfigurationStatus -All | Sort-Object StateDate -Descending | Select-Object -First 1
"$(Get-Date) TriggerDsc last execution is $($lastConfiguration.Status)"

if ($lastConfiguration.Status -eq 'Success') {
    # Can't do this, it breaks DSC WaitFor on other servers
    # "$(Get-Date) TriggerDsc removing DSC documents so they don't trigger again"
    # Remove-DscConfigurationDocument -Stage Current, Pending, Previous
    "$(Get-Date) TriggerDsc removing scheduled task so this script doesn't trigger again"
    &schtasks.exe /delete /tn 'TriggerDsc' /f
} else {
    "$(Get-Date) TriggerDsc starting DSC"
    Start-DscConfiguration -UseExisting
}
