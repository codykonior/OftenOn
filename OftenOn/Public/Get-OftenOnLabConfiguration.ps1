function Get-OftenOnLabConfiguration {
    [CmdletBinding()]
    param (
    )

    #region Always-run, manipulate configuration data encryption information
    $configurationData = Import-PowerShellDataFile -Path "$PSScriptRoot\..\Configuration\OftenOn.psd1"
    $configurationData.AllNodes | Where-Object { $_.NodeName -eq '*' } | ForEach-Object {
        $PSItem.CertificateFile = $PSItem.CertificateFile.Replace('$env:ALLUSERSPROFILE', $env:ALLUSERSPROFILE)
        $certificate = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2
        $certificate.Import($PSItem.CertificateFile)
        $PSItem.Thumbprint = $certificate.Thumbprint
    }
    #endregion

    #region Always-run, manipulate configuration data network information
    foreach ($node in $configurationData.AllNodes) {
        <#
            Lability creates one NIC for each entry in the Lability_SwitchName array. We put these into a Network
            array instead so that we have more fine-grained control.

            We use that to populate Lability_SwitchName and Lability_MACAddress which assigns a random MAC. This
            is used later to match up with the network AdapterName and rename the NIC.

            This must be done because most versions of Windows assign default NIC names in an uncontrolled manner.
        #>
        if ($node.ContainsKey('Network')) {
            $switchName = @()
            $macAddress = @()

            foreach ($network in $node.Network) {
                $switchName += $network.SwitchName
                # It's important to limit what MAC are used otherwise you will get confusing errors during VM creation
                $macAddress += ('00', '03', (0..3 | ForEach-Object { '{0:x}{1:x}' -f (Get-Random -Minimum 0 -Maximum 15), (Get-Random -Minimum 0 -Maximum 15) }) | ForEach-Object { $_ }) -join ':'
            }

            $node.Lability_SwitchName = $switchName
            $node.Lability_MACAddress = $macAddress
        }

        <#
            Different xFailoverCluster resources need different combinations of IP, CIDR, and Subnet. This splits
            out all of the different variations for easy use during configuration.
        #>
        if ($node.ContainsKey('Role') -and $node.Role.ContainsKey('Cluster')) {
            $node.Role.Cluster.StaticAddress = ConvertFrom-CIDR $node.Role.Cluster.StaticAddress
            $node.Role.Cluster.StaticAddress.Name = "Cluster Network " + ($node.Network | Where-Object { (ConvertFrom-CIDR $_.IPAddress).NetworkID -eq $node.Role.Cluster.StaticAddress.NetworkID }).NetAdapterName + " (Client)"
            $node.Role.Cluster.IgnoreNetwork = ConvertFrom-CIDR $node.Role.Cluster.IgnoreNetwork
            $node.Role.Cluster.IgnoreNetwork.Name = "Cluster Network " + ($node.Network | Where-Object { (ConvertFrom-CIDR $_.IPAddress).NetworkID -eq $node.Role.Cluster.IgnoreNetwork.NetworkID }).NetAdapterName + " (Heartbeat)"
        }
    }
    #endregion

    $configurationData | Add-Member -MemberType ScriptMethod -Name ToString -Value { Convert-HashtableToString $this } -Force -PassThru
}
