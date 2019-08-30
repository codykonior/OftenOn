Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

<#
Any modules we specify to be used with
#>
$configurationData = Import-PowerShellDataFile -Path "$PSScriptRoot\Configuration\OftenOn.psd1"
foreach ($dscResource in $configurationData.NonNodeData.Lability.DSCResource) {
    [array] $modules = Get-Module $dscResource.Name -ListAvailable | Sort-Object Version -Descending
    if (!($dscResource.ContainsKey("RequiredVersion"))) {
        Write-Warning ".\Configuration\OftenOn.psd1 requires $($dscResource.Name) but does not have a RequiredVersion"
    } elseif ($dscResource.RequiredVersion -ne $modules[0].Version) {
        Write-Warning ".\Configuration\OftenOn.psd1 requires $($dscResource.Name) $($dscResource.RequiredVersion) but $($modules[0].Version) is the newest"
    }
}

Get-ChildItem $PSScriptRoot -Recurse -File | ForEach-Object {
    $fileName = $PSItem
    $content = Get-Content $fileName.FullName

    foreach ($line in $content) {
        if ($line -match "\s+Import-DscResource\s+-ModuleName\s+(.*)\s+-ModuleVersion\s+(.*)" -or
            $line -match "\s+Import-DscResource\s+-ModuleName\s+(.*)") {
            [array] $modules = Get-Module -ListAvailable $Matches[1] | Sort-Object Version -Descending

            if ($Matches.Count -eq 3) {
                # ModuleName and ModuleVersion match
                if ([version] $Matches[2] -ne $modules[0].Version) {
                    # Finding a newer version on disk is not catastrophic but means we should update our references
                    Write-Warning "$fileName requires $($Matches[1]) $($Matches[2]) but $($modules[0].Version) is the newest"
                }
                if ($modules.Version -notcontains [version] $Matches[2]) {
                    # Not having the referenced version on disk is catastrophic
                    Write-Warning "$fileName requires $($Matches[1]) $($Matches[2]) but it does not exist"
                }
            } elseif ($Matches.Count -eq 2) {
                # ModuleName match only
                if (!$modules) {
                    Write-Warning "$fileName requires $($Matches[1]) but it does not have a ModuleVersion and none were found on disk"
                } else {
                    Write-Warning "$fileName requires $($Matches[1]) but it does not have a ModuleVersion and $($modules[0].Version) is the newest"

                    # Multiple versions on disk and nothing specified is catastrophic
                    if ($modules.Count -ne 1) {
                        Write-Warning "$fileName requires $($Matches[1]) but multiple versions exist and $($modules[0].Version) is the newest"
                    }
                }
            } else {
                Write-Warning "Unknown number of matches when searching for broken Import-DscResource references"
            }
        }
    }
}

Get-ChildItem $PSScriptRoot *.ps1 -Exclude NlaSvcFix.ps1, TriggerDsc.ps1, *.Tests.ps1 -Recurse | ForEach-Object {
    Write-Verbose "Loading $($PSItem.FullName)"
    . $PSItem.FullName
}
