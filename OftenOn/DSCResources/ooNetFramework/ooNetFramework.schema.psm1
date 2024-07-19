Configuration ooNetFramework {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    param (
        [Parameter(Mandatory)]
        [string] $Version,
        [Parameter(Mandatory)]
        [string] $Node
    )

    Script 'ooNetFramework' {
        GetScript = {
            Set-StrictMode -Version Latest; $ErrorActionPreference = "Stop";

            $data = @(
                [PSCustomObject] @{ Version = 533320; Name = 'NET Framework 4.8.1'; }
                [PSCustomObject] @{ Version = 528040; Name = 'NET Framework 4.8'; }
                [PSCustomObject] @{ Version = 461808; Name = 'NET Framework 4.7.2'; }
                [PSCustomObject] @{ Version = 461308; Name = 'NET Framework 4.7.1'; }
                [PSCustomObject] @{ Version = 460798; Name = 'NET Framework 4.7'; }
                [PSCustomObject] @{ Version = 394802; Name = 'NET Framework 4.6.2'; }
                [PSCustomObject] @{ Version = 394254; Name = 'NET Framework 4.6.1'; }
                [PSCustomObject] @{ Version = 393295; Name = 'NET Framework 4.6'; }
                [PSCustomObject] @{ Version = 379893; Name = 'NET Framework 4.5.2'; }
                [PSCustomObject] @{ Version = 378675; Name = 'NET Framework 4.5.1'; }
                [PSCustomObject] @{ Version = 378389; Name = 'NET Framework 4.5'; }
            )

            $release = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name 'Release' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Release
            $displayName = $data | Where-Object { $release -ge $_.Version } | Select-Object -First 1 -ExpandProperty Name
            @{ Result = "$displayName"; }
        }
        TestScript = {
            Set-StrictMode -Version Latest; $ErrorActionPreference = "Stop";

            $state = [scriptblock]::Create($GetScript).Invoke()
            if ($state.Result -ge $using:Version) {
                $true
            } else {
                $false
            }
        }
        SetScript = {
            Set-StrictMode -Version Latest; $ErrorActionPreference = "Stop";

            # If you don't use -NoNewWindow it will hang with an Open File - Security Warning
            # If you allow NetFx to do the restart, it will wipe out the DSC configuration.
            $fileName = (Get-ChildItem "\\$($using:Node)\Resources\$($using:Version)\*.exe" -File -Recurse).FullName | Select-Object -First 1
            $result = Start-Process -FilePath $fileName -ArgumentList '/quiet /norestart' -PassThru -Wait -NoNewWindow
            if ($result.ExitCode -in @(1641, 3010)) {
                Write-Verbose "Installation succeeded, restart required"
                $global:DSCMachineStatus = 1
            } elseif ($result.ExitCode -ne 0) {
                Write-Error "Installation failed with exit code $($result.ExitCode)"
            } else {
                Write-Verbose "Installation succeeded"
            }
        }
    }
}