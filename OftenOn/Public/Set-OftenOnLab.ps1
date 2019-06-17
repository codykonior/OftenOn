<#

.EXAMPLE
Set-OftenOnLab -Cluster1 @{ Windows = '2012'; SQL = '2012'; AvailabilityGroup = $true; }

Original configuration (SQL 2012 on Windows 2012)

.EXAMPLE
Set-OftenOnLab -Cluster2 @{ Windows = '2012'; SQL = '2012'; AvailabilityGroup = $false; }

SQL 2012 on Windows 2012 and a second cluster of SQL 2012 on Windows 2012 with no AG.

.EXAMPLE
Set-OftenOnLab -Cluster2 @{ Windows = '2016'; SQL = '2017'; AvailabilityGroup = $false; }

SQL 2012 on Windows 2012 and a second cluster of SQL 2017 on Windows 2016 with no AG.

#>

function Set-OftenOnLab {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param (
        [Parameter(ParameterSetName = 'Default', Position = 1)]
        [ValidateSet('Default', 'CrossClusterMigration', 'Upgrade', 'DAG')]
        [string] $ConfigurationName = 'Default',

        [Parameter(ParameterSetName = 'Detailed')]
        [hashtable] $Cluster1,
        [Parameter(ParameterSetName = 'Detailed')]
        [hashtable] $Cluster2
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

    $configurationData = Import-Metadata "$PSScriptRoot\..\Configuration\OftenOn_Template.psd1" -Ordered

    if ($Cluster1) {
        $windows = if ($Cluster1.Windows -eq '2012') {
            'Windows Server 2012 Standard Evaluation (Server with a GUI)'
        } elseif ($Cluster1.Windows -eq '2016') {
            'Windows Server 2016 Standard 64bit English Evaluation'
        } else {
            Write-Error "Unknown Windows version $($Cluster1.Windows)"
        }
        foreach ($node in $configurationData.AllNodes | Where-Object { $_.Role.Contains("Cluster") -and $_.Role.Cluster.Name -eq "C1" }) {
            $node.Lability_Media = $windows
        }

        $sql = if ($Cluster1.SQL -eq '2012') {
            '\\CHDC01\Resources\SQLServer2012'
        } elseif ($Cluster1.SQL -eq '2017') {
            '\\CHDC01\Resources\SQLServer2017'
        } else {
            Write-Error "Unknown SQL version $($Cluster1.SQL)"
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
        $windows = if ($Cluster2.Windows -eq '2012') {
            'Windows Server 2012 Standard Evaluation (Server with a GUI)'
        } elseif ($Cluster2.Windows -eq '2016') {
            'Windows Server 2016 Standard 64bit English Evaluation'
        } else {
            Write-Error "Unknown Windows version $($Cluster2.Windows)"
        }
        foreach ($node in $configurationData.AllNodes | Where-Object { $_.Role.Contains("Cluster") -and $_.Role.Cluster.Name -eq "C2" }) {
            $node.Lability_Media = $windows
        }

        $sql = if ($Cluster2.SQL -eq '2012') {
            '\\CHDC01\Resources\SQLServer2012'
        } elseif ($Cluster2.SQL -eq '2017') {
            '\\CHDC01\Resources\SQLServer2017'
        } else {
            Write-Error "Unknown SQL version $($Cluster1.SQL)"
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

    Export-Metadata "$PSScriptRoot\..\Configuration\OftenOn.psd1" -InputObject $configurationData
}
