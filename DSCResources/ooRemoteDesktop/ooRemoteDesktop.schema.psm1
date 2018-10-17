Configuration ooRemoteDesktop {
    # Enable the service
    xRemoteDesktopAdmin 'EnableRemoteDesktopService' {
        Ensure             = 'Present'
        UserAuthentication = 'NonSecure'
    }

    # Enable firewall exceptions
    foreach ($firewallRule in @('FPS-ICMP4-ERQ-In', 'FPS-ICMP6-ERQ-In', 'RemoteDesktop-UserMode-In-TCP', 'RemoteDesktop-UserMode-In-UDP')) {
        # In current versions of DSC you can pass a built-in rule name and enable it without specifying all of the other details
        Firewall "Enable$($firewallRule.Replace('-', ''))" {
            Name    = $firewallRule
            Ensure  = 'Present'
            Enabled = 'True'
        }
    }

    # Bulk-enable firewall exceptions for File and Printer sharing (needed to RDP from your host)
    Script 'EnableFileAndPrinterSharing' {
        GetScript = {
            if (Get-NetFirewallRule -DisplayGroup 'File and Printer Sharing' | Where-Object { $_.Enabled -eq 'False' }) {
                @{ Result = "false"; }
            } else {
                @{ Result = "true"; }
            }
        }
        TestScript = {
            if (Get-NetFirewallRule -DisplayGroup 'File and Printer Sharing' | Where-Object { $_.Enabled -eq 'False' }) {
                $false
            } else {
                $true
            }
        }
        SetScript = {
            Get-NetFirewallRule -DisplayGroup 'File and Printer Sharing' | Where-Object { $_.Enabled -eq 'False' } | Set-NetFirewallRule -Enabled True
        }
    }
}

