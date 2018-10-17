Configuration ooNetFramework {
    param(
        [Parameter(Mandatory)]
        [string] $ResourceLocation
    )
    Script 'NetFx472' {
        GetScript = {
            Set-StrictMode -Version Latest; $ErrorActionPreference = "Stop";

            $release = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' 'Release' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Release
            @{ Result = "$release"; }
        }
        TestScript = {
            Set-StrictMode -Version Latest; $ErrorActionPreference = "Stop";

            $release = Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' 'Release' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Release
            if ($release -and $release -ge 461814) {
                $true
            } else {
                $false
            }
        }
        SetScript = {
            Set-StrictMode -Version Latest; $ErrorActionPreference = "Stop";

            # If you don't use -NoNewWindow it will hang with an Open File - Security Warning
            $result = Start-Process -FilePath $using:ResourceLocation -ArgumentList '/quiet' -PassThru -Wait -NoNewWindow
            if ($result.ExitCode -in @(1641, 3010)) {
                $global:DSCMachineStatus = 1
            } elseif ($result.ExitCode -ne 0) {
                Write-Error "Installation failed with exit code $($result.ExitCode)"
            } else {
                Write-Verbose "Installation succeeded"
            }
        }
    }
}