Configuration ooRegistry {
    # Stop Windows from caching "not found" DNS requests (defaults at 15 minutes) because it slows down DSC WaitForX
    Registry 'DisableNegativeCacheTtl' {
        Ensure    = 'Present'
        Key       = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters'
        ValueName = 'MaxNegativeCacheTtl'
        ValueData = '0'
        ValueType = 'DWord'
    }

    # Stop Windows from cycling machine passwors in a domain that prevent snapshots > 30 days old from booting
    Registry 'DisableMachineAccountPasswordChange' {
        Ensure    = 'Present'
        Key       = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\Netlogon\Parameters'
        ValueName = 'DisablePasswordChange'
        ValueData = '1'
        ValueType = 'DWord'
    }

    # This makes it so Internet Explorer is usable
    Registry 'DisableInternetExplorerEnhancedSecurityConfigurationAdmin' {
        Ensure    = 'Present'
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}'
        ValueName = 'IsInstalled'
        ValueData = '0'
        ValueType = 'DWord'
    }

    Registry 'DisableInternetExplorerEnhancedSecurityConfigurationUser' {
        Ensure    = 'Present'
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}'
        ValueName = 'IsInstalled'
        ValueData = '0'
        ValueType = 'DWord'
    }

    Registry 'DisableInternetExplorerFirstRun' {
        Ensure    = 'Present'
        Key       = 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Internet Explorer\Main'
        ValueName = 'DisableFirstRunCustomize'
        ValueData = '1'
        ValueType = 'DWord'
    }

    # When the network location awareness service starts up before the domain starts (especially on Windows 2016),
    # the network adapters get changed to public instead of domain, and then everything fails
    Registry 'EnableNetworkLocationAwarenessServiceDelayedStart' {
        Ensure    = 'Present'
        Key       = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\nlasvc'
        ValueName = 'DelayedAutoStart'
        ValueData = '1'
        ValueType = 'DWord'
    }
}
