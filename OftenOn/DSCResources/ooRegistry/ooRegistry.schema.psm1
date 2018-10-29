Configuration ooRegistry {
    # Stop Windows from caching "not found" DNS requests (defaults at 15 minutes) because it slows down DSC WaitForX
    Registry 'DisableNegativeCacheTtl' {
        Ensure = 'Present'
        Key = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters'
        ValueName = 'MaxNegativeCacheTtl'
        ValueData = '0'
        ValueType = 'DWord'
    }

    # Stop Windows from cycling machine passwors in a domain that prevent snapshots > 30 days old from booting
    Registry 'DisableMachineAccountPasswordChange' {
        Ensure = 'Present'
        Key = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters'
        ValueName = 'DisablePasswordChange'
        ValueData = '1'
        ValueType = 'DWord'
    }
}

