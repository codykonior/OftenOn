Configuration ooRouter {
    Script 'EnableRouting' {
        GetScript  = {
            if ((Get-RemoteAccess).VpnStatus -ne 'Installed') {
                @{ Result = "false"; }
            }
            $nat = &netsh routing ip nat show global
            if ($nat -like 'No information found*') {
                @{ Result = "false"; }
            }

            $ExternalInterface = 'WAN'
            $wan = &netsh routing ip nat show interface $ExternalInterface
            if ($wan -like 'No information found*') {
                @{ Result = "false"; }
            }
            <#
            Get-NetAdapter | Where-Object { $_.Name -ne 'WAN' -and $_.Name -notlike '*_HB' } | ForEach-Object {
                $adapter = &netsh routing ip nat show interface $_.Name
                if ($adapter -like 'No information found*') {
                    @{ Result = "false"; }
                }
            }
            #>
            @{ Result = "true"; }
        }
        TestScript = {
            if ((Get-RemoteAccess).VpnStatus -ne 'Installed') {
                return $false
            }

            $nat = &netsh routing ip nat show global
            if ($nat -like 'No information found*') {
                return $false
            }

            $ExternalInterface = 'WAN'
            $wan = &netsh routing ip nat show interface $ExternalInterface
            if ($wan -like 'No information found*') {
                return $false
            }
            <#
            Get-NetAdapter | Where-Object { $_.Name -ne 'WAN' -and $_.Name -notlike '*_HB' } | ForEach-Object {
                $adapter = &netsh routing ip nat show interface $_.Name
                if ($adapter -like 'No information found*') {
                    return $false
                }
            }
            #>
            return $true
        }
        SetScript  = {
            if ((Get-RemoteAccess).VpnStatus -ne 'Installed') {
                Install-RemoteAccess -VpnType Vpn
            }
            &netsh routing ip nat install

            $ExternalInterface = 'WAN'
            $wan = &netsh routing ip nat show interface $ExternalInterface
            if ($wan -like 'No information found*') {
                &netsh routing ip nat add interface $ExternalInterface
            }
            &netsh routing ip nat set interface $ExternalInterface mode=full

            <#
            Get-NetAdapter | Where-Object { $_.Name -ne 'WAN' -and $_.Name -notlike '*_HB' } | ForEach-Object {
                $adapter = &netsh routing ip nat show interface $_.Name
                if ($adapter -like 'No information found*') {
                    &netsh routing ip nat add interface $_.Name
                }
            }
            #>
        }
    }
}
