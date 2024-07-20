Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Repeat until DSC completes, we could also add in a check to abort if there were too many failures
while ($true) {
    while ($true) {
        $dscStatus = Get-DscLocalConfigurationManager
        "$((Get-Date).ToUniversalTime().ToString("s"))Z LCM status is [$($dscStatus.LCMState)] / [$($dscStatus.LCMStateDetail)]"

        if ($dscStatus.LCMState -in 'Idle', 'PendingConfiguration') {
            break
        }

        Start-Sleep -Seconds 60
    }

    # Get last execution
    $lastConfiguration = Get-DscConfigurationStatus -All | Sort-Object StateDate -Descending | Select-Object -First 1
    "$((Get-Date).ToUniversalTime().ToString("s"))Z Last DSC execution on [$($lastConfiguration.StartDate.ToString("u"))] was [$($lastConfiguration.Status)]"

    if ($dscStatus -ne 'PendingConfiguration' -and $lastConfiguration.Status -eq 'Success') {
        # Can't do this, it breaks DSC WaitFor on other servers
        # "$((Get-Date).ToUniversalTime().ToString("s"))Z Removing DSC documents so they don't trigger again"
        # Remove-DscConfigurationDocument -Stage Current, Pending, Previous
        "$((Get-Date).ToUniversalTime().ToString("s"))Z Removing scheduled task so this script doesn't trigger again"
        &schtasks.exe /delete /tn 'TriggerDsc' /f
        break
    } else {
        "$((Get-Date).ToUniversalTime().ToString("s"))Z Starting DSC"
        Start-DscConfiguration -UseExisting
    }

    Start-Sleep -Seconds 60
}
