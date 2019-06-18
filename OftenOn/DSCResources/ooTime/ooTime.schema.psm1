Configuration ooTime {
    Script 'SetTime' {
        GetScript  = {
            $output = &w32tm /query /source
            @{ Result = $output.Trim(); }
        }
        TestScript = {
            $output = &w32tm /query /source
            if ($output.Trim() -eq "time.windows.com") {
                return $true
            } else {
                return $false
            }
        }
        SetScript  = {
            &w32tm /config /manualpeerlist:time.windows.com /syncfromflags:manual /reliable:yes /update
            &w32tm /resync /rediscover
            Stop-Service w32time
            Start-Service w32time
        }
    }
}
