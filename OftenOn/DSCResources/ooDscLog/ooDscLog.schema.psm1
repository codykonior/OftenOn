Configuration ooDscLog {
    Import-DscResource -ModuleName xWinEventLog

    # 1 hour is about 1MB so this gives you two days worth
    # LogMode cannot be changed to Cicular on these unfortunately

    xWinEventLog "AlterDSCOperationalLog" {
        LogName = "Microsoft-Windows-DSC/Operational"
        MaximumSizeInBytes = 48MB
    }

    xWinEventLog "EnableDSCAnalyticLog" {
        LogName = "Microsoft-Windows-DSC/Analytic"
        MaximumSizeInBytes = 48MB
        IsEnabled = $true
    }

    xWinEventLog "EnableDSCDebugLog" {
        LogName = "Microsoft-Windows-DSC/Debug"
        MaximumSizeInBytes = 48MB
        IsEnabled = $true
    }
}
