Configuration ooDscLog {
    # 1 hour is about 1MB so this gives you two days worth

    xWinEventLog "EnableDSCAnalyticLog" {
        LogName = "Microsoft-Windows-DSC/Analytic"
        MaximumSizeInBytes = 48MB
        LogMode = 'Circular'
        IsEnabled = $true
    }

    xWinEventLog "EnableDSCDebugLog" {
        LogName = "Microsoft-Windows-DSC/Debug"
        MaximumSizeInBytes = 48MB
        LogMode = 'Circular'
        IsEnabled = $true
    }
}
