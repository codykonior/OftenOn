Configuration ooManagementStudio {
    param (
        [Parameter(Mandatory)]
        [string] $Version,
        [Parameter(Mandatory)]
        [string] $Node
    )

    Script 'ooManagementStudio' {
        GetScript = {
            Set-StrictMode -Version Latest; $ErrorActionPreference = "Stop";

            $displayName = "Microsoft SQL Server Management Studio - *"
            $displayNames = Get-ChildItem HKLM:\SOFTWARE\WOW6432NODE\Microsoft\Windows\CurrentVersion\Uninstall | ForEach-Object {
                $property = $_ | Get-ItemProperty
                if ($property -and $property.psobject.Properties["DisplayName"] -and $property.DisplayName -like $displayName) {
                    $property.DisplayName.Replace("Microsoft ", "").Replace(" -", "")
                }
            }

            @{ Result = "$displayNames"; }
        }
        TestScript = {
            Set-StrictMode -Version Latest; $ErrorActionPreference = "Stop";

            $state = [scriptblock]::Create($GetScript).Invoke()
            if ($state.Result -like "*$($using:Version)*") {
                $true
            } else {
                $false
            }
        }
        SetScript = {
            Set-StrictMode -Version Latest; $ErrorActionPreference = "Stop";

            # If you don't use -NoNewWindow it will hang with an Open File - Security Warning
            $fileName = (Get-ChildItem "\\$($using:Node)\Resources\$($using:Version)\*.exe" -File -Recurse).FullName | Select-Object -First 1
            $result = Start-Process -FilePath $fileName -ArgumentList '/install /quiet' -PassThru -Wait -NoNewWindow
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
