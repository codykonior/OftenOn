<#


#>

function Set-OftenOnLab {
    [CmdletBinding(DefaultParameterSetName = "Default")]
    param (
        [Parameter(ParameterSetName = 'Default', Position = 1)]
        [ValidateSet('Default', 'CrossClusterMigration', 'Upgrade', 'DAG')]
        [string] $ConfigurationName = 'Default',

        # This can be used to pass a directory (like C:\Blah\Modules) and this
        # entire thing will be copied into C:\Program Files\WindowsPowerShell
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'Detailed')]
        [string] $ModulePath,

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
        $node = $configurationData.AllNodes | Where-Object { $_.NodeName -eq 'CHWK01' }
        if (!$node.psobject.Properties["Lability_Resource"]) {
            $node.Lability_Resource = ($configurationData.AllNodes | Where-Object { $_.NodeName -eq '*' }).Lability_Resource
        }
        $node.Lability_Resource += 'ModulePath'
    }

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

    Convert-HashtableToString $configurationData | Set-Content "$PSScriptRoot\..\Configuration\OftenOn.psd1"
}
