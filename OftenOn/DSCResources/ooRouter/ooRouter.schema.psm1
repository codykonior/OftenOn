Configuration ooRouter {
    Script 'EnableRouting' {
        GetScript = {
            if (Get-NetIPInterface | Where-Object { $_.Forwarding -ne 'Enabled' }) {
                @{ Result = "false"; }
            } else {
                @{ Result = "true"; }
            }
        }
        TestScript = {
            if (Get-NetIPInterface | Where-Object { $_.Forwarding -ne 'Enabled' }) {
                $false
            } else {
                $true
            }
        }
        SetScript = {
            Get-NetIPInterface | Where-Object { $_.Forwarding -ne 'Enabled' } | Set-NetIPInterface -Forwarding Enabled
        }
    }
}

