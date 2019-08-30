Configuration ooDscLog {
    Import-DscResource -ModuleName ComputerManagementDsc -ModuleVersion 6.5.0.0

    # 1 hour is about 1MB so this gives you two days worth
    # LogMode cannot be changed to Cicular on these unfortunately

    WindowsEventLog "AlterDSCOperationalLog" {
        LogName            = "Microsoft-Windows-DSC/Operational"
        MaximumSizeInBytes = 48MB
    }

    WindowsEventLog "EnableDSCAnalyticLog" {
        LogName            = "Microsoft-Windows-DSC/Analytic"
        MaximumSizeInBytes = 48MB
        IsEnabled          = $true
    }

    WindowsEventLog "EnableDSCDebugLog" {
        LogName            = "Microsoft-Windows-DSC/Debug"
        MaximumSizeInBytes = 48MB
        IsEnabled          = $true
    }
}
