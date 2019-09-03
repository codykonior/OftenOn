Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Get-ChildItem $PSScriptRoot *.ps1 -Exclude NlaSvcFix.ps1, TriggerDsc.ps1, *.Tests.ps1 -Recurse | ForEach-Object {
    Write-Verbose "Loading $($PSItem.FullName)"
    . $PSItem.FullName
}
