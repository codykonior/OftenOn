Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Get-ChildItem $PSScriptRoot *.ps1 -Exclude *.Tests.ps1 -Recurse | ForEach-Object {
    Write-Verbose "Loading $($PSItem.FullName)"
    . $PSItem.FullName
}
