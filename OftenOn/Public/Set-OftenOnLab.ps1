<#


#>

function Set-OftenOnLab {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param (
        [Parameter(ParameterSetName = 'Default', Position = 1)]
        [ValidateSet('Default', 'Default2017',  'Default2019', 'CrossClusterMigration', 'Upgrade', 'DAG')]
        [string] $ConfigurationName = 'Default',

        # This can be used to pass a directory (like C:\Blah\Modules) and this
        # entire thing will be copied into C:\Program Files\WindowsPowerShell
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Detailed')]
        [string] $ModulePath,

        [Parameter(ParameterSetName = 'Detailed')]
        [hashtable] $Cluster1,
        [Parameter(ParameterSetName = 'Detailed')]
        [hashtable] $Cluster2,

        [ValidateSet("10.0", "192.168", "172.16")]
        $Subnet = "10.0"
    )

    if ($PSCmdlet.ParameterSetName -eq 'Default') {
        Write-Verbose "Setting configuration to $ConfigurationName"
        switch ($ConfigurationName) {
            'Default' {
                $Cluster1 = @{
                    Windows           = '2012'
                    SQL               = '2012'
                    AvailabilityGroup = $true
                }
                $Cluster2 = $null
            }
            'Default2017' {
                $Cluster1 = @{
                    Windows           = '2016'
                    SQL               = '2017'
                    AvailabilityGroup = $true
                }
                $Cluster2 = $null
            }
            'Default2019' {
                $Cluster1 = @{
                    Windows           = '2016'
                    SQL               = '2019'
                    AvailabilityGroup = $true
                }
                $Cluster2 = $null
            }
            'CrossClusterMigration' {
                $Cluster1 = @{
                    Windows           = '2012'
                    SQL               = '2012'
                    AvailabilityGroup = $true
                }
                $Cluster2 = @{
                    Windows           = '2016'
                    SQL               = '2012'
                    AvailabilityGroup = $false
                }
            }
            'Upgrade' {
                $Cluster1 = @{
                    Windows           = '2012'
                    SQL               = '2012'
                    AvailabilityGroup = $true
                    Patch             = $true
                }
                $Cluster2 = @{
                    Windows           = '2016'
                    SQL               = '2017'
                    AvailabilityGroup = $false
                }
            }
            'DAG' {
                $Cluster1 = @{
                    Windows           = '2012'
                    SQL               = '2017'
                    AvailabilityGroup = $true
                    Patch             = $true
                }
                $Cluster2 = @{
                    Windows           = '2016'
                    SQL               = '2017'
                    AvailabilityGroup = $false
                }
            }
        }
    } else {
        Write-Verbose "Using custom Cluster1 and Cluster2 configurations"
    }

    $configurationData = Import-PowerShellDataFile "$PSScriptRoot\..\Configuration\OftenOn_Template.psd1"

    if ($ModulePath) {
        if (-not (Test-Path $ModulePath)) {
            Write-Error "$ModulePath does not exist"
        }
        $configurationData.NonNodeData.Lability.Resource += @{ Id = 'ModulePath'; IsLocal = $true; Filename = $ModulePath; DestinationPath = '\Program Files\WindowsPowerShell'; }
        $node = $configurationData.AllNodes | Where-Object { $_.NodeName -eq 'CHDBA01' }
        if (!$node.psobject.Properties["Lability_Resource"]) {
            $node.Lability_Resource = ($configurationData.AllNodes | Where-Object { $_.NodeName -eq '*' }).Lability_Resource
        }
        $node.Lability_Resource += 'ModulePath'
    }

    if ($Cluster1) {
        $windows = "Windows Server $($Cluster1.Windows)"
        $sql = "\\CHDC01\Resources\SQL Server $($Cluster1.SQL)"
        foreach ($node in $configurationData.AllNodes | Where-Object { $_.Role.Contains("Cluster") -and $_.Role.Cluster.Name -eq "C1" }) {
            $node.Lability_Media = $windows
        }
        foreach ($node in $configurationData.AllNodes | Where-Object { $_.Role.Contains("SqlServer") -and $_.Role.Cluster.Name -eq "C1" }) {
            $node.Role.SqlServer.SourcePath = $sql
        }

        if (!$Cluster1.AvailabilityGroup) {
            foreach ($node in $configurationData.AllNodes | Where-Object { $_.Role.Contains("AvailabilityGroup") -and $_.Role.Cluster.Name -eq "C1" }) {
                $node.Role.Remove("AvailabilityGroup")
            }
        }
    }

    if ($Cluster2) {
        $windows = "Windows Server $($Cluster2.Windows)"
        $sql = "\\CHDC01\Resources\SQL Server $($Cluster2.SQL)"
        foreach ($node in $configurationData.AllNodes | Where-Object { $_.Role.Contains("Cluster") -and $_.Role.Cluster.Name -eq "C2" }) {
            $node.Lability_Media = $windows
        }
        foreach ($node in $configurationData.AllNodes | Where-Object { $_.Role.Contains("SqlServer") -and $_.Role.Cluster.Name -eq "C2" }) {
            $node.Role.SqlServer.SourcePath = $sql
        }

        if (!$Cluster2.AvailabilityGroup) {
            foreach ($node in $configurationData.AllNodes | Where-Object { $_.Role.Contains("AvailabilityGroup") -and $_.Role.Cluster.Name -eq "C2" }) {
                $node.Role.Remove("AvailabilityGroup")
            }
        }
    } else {
        $configurationData.AllNodes = $configurationData.AllNodes | Where-Object { -not $_.Role.Contains("Cluster") -or $_.Role.Cluster.Name -ne "C2" }
    }

    # Strip out unnecessary SQL installation media;
    # this is because some may not be available right now.
    foreach ($node in $configurationData.AllNodes) {
        if ($node.ContainsKey("Lability_Resource")) {
            $node.Lability_Resource = $node.Lability_Resource | ForEach-Object {
                if ($_ -notlike "SQL Server *") {
                    $_
                } elseif ($Cluster1 -and $Cluster1.SQL -and $_ -eq "SQL Server $($Cluster1.SQL)") {
                    $_
                }  elseif ($Cluster2 -and $Cluster2.SQL -and $_ -eq "SQL Server $($Cluster2.SQL)") {
                    $_
                }       
            }
        }
    }

    $areas = @()
    $areas += ($configurationData.AllNodes | Where-Object { $_.ContainsKey("Network") }).Network
    $areas += (($configurationData.AllNodes | Where-Object { $_.ContainsKey("Role") }).Role | Where-Object { $_.ContainsKey("Cluster") }).Cluster
    $areas += (($configurationData.AllNodes | Where-Object { $_.ContainsKey("Role") }).Role | Where-Object { $_.ContainsKey("AvailabilityGroup") }).AvailabilityGroup
    foreach ($network in $areas) {
        # Necessary as it's a collection under the hood and we can't modify inside a loop
        $keyNames = $network.Keys | ForEach-Object {
            $_
        }

        foreach ($keyName in $keyNames) {
            $newValue = $network.$keyName -replace "^10.0", $subnet
            if ($network.$keyName -match "^10.0" -and $network.$keyName -ne $newValue) {
                "Updating $keyName from $($network.$keyName) to $newValue"
                $network.$keyName = $newValue
            }
        }
    }

    $global:OftenOnConfigurationData = $configurationData
    Convert-HashtableToString $configurationData | Set-Content "$PSScriptRoot\..\Configuration\OftenOn.psd1"
}
