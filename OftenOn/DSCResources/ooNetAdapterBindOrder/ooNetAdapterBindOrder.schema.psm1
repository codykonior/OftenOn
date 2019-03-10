Configuration ooNetAdapterBindOrder {
    Script 'EnableBinding' {
        GetScript  = {
            function Get-NetAdapterBindOrder {
                [CmdletBinding()]
                param (
                )

                $binding = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Linkage").Bind
                foreach ($bind in $binding) {
                    $adapter = Get-CimInstance -ClassName Win32_NetworkAdapter | Where-Object { $_.GUID -eq $bind.Split("\")[2] }
                    [PSCustomObject] @{
                        Binding = $bind
                        Name    = if ($adapter) { $adapter.NetConnectionId }
                    }
                }
            }

            $oldBindOrder = Get-NetAdapterBindOrder
            $newBindOrder = Get-NetAdapterBindOrder | Sort-Object { $_.Name -eq $null }, { $_.Name -like "WAN" }, { $_.Name -like "*_HB" }, { $_.Name -ne "CHICAGO" }
            if (($oldBindOrder.Name -join ",") -eq ($newBindOrder.Name -join ",")) {
                $result = $true
            } else {
                $result = $false
            }

            @{
                Result       = $result
                OldBindOrder = $oldBindOrder.Name
                NewBindOrder = $newBindOrder.Name
            }
        }
        TestScript = {
            function Get-NetAdapterBindOrder {
                [CmdletBinding()]
                param (
                )

                $binding = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Linkage").Bind
                foreach ($bind in $binding) {
                    $adapter = Get-CimInstance -ClassName Win32_NetworkAdapter | Where-Object { $_.GUID -eq $bind.Split("\")[2] }
                    [PSCustomObject] @{
                        Binding = $bind
                        Name    = if ($adapter) { $adapter.NetConnectionId }
                    }
                }
            }

            $oldBindOrder = Get-NetAdapterBindOrder
            $newBindOrder = Get-NetAdapterBindOrder | Sort-Object { $_.Name -eq $null }, { $_.Name -like "WAN" }, { $_.Name -like "*_HB" }, { $_.Name -ne "CHICAGO" }
            if (($oldBindOrder.Name -join ",") -eq ($newBindOrder.Name -join ",")) {
                return $true
            } else {
                return $false
            }
        }
        SetScript  = {
            function Get-NetAdapterBindOrder {
                [CmdletBinding()]
                param (
                )

                $binding = (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Linkage").Bind
                foreach ($bind in $binding) {
                    $adapter = Get-CimInstance -ClassName Win32_NetworkAdapter | Where-Object { $_.GUID -eq $bind.Split("\")[2] }
                    [PSCustomObject] @{
                        Binding = $bind
                        Name    = if ($adapter) { $adapter.NetConnectionId }
                    }
                }
            }

            function Set-NetAdapterBindOrder {
                [CmdletBinding()]
                param (
                    [object[]] $Binding
                )
                Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Linkage" -Name Bind -Value $Binding.Binding
            }

            $newBindOrder = Get-NetAdapterBindOrder | Sort-Object { $_.Name -eq $null }, { $_.Name -like "WAN" }, { $_.Name -like "*_HB" }, { $_.Name -ne "CHICAGO" }
            Set-NetAdapterBindOrder $newBindOrder
        }
    }
}
