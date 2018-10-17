Configuration ooDscLog {
    xWinEventLog "EnableDSCAnalyticLog" {
        LogName = "Microsoft-Windows-DSC/Analytic"
        IsEnabled = $true
    }

    xWinEventLog "EnableDSCDebugLog" {
        LogName = "Microsoft-Windows-DSC/Debug"
        IsEnabled = $true
    }
}
