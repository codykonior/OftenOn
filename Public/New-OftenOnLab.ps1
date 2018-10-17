function New-OftenOnLab {
    [CmdletBinding()]
    param(
    )

    <#
        It's important the configuration data is only retrieved once here because it contains some
        random MAC addresses, and these must be the same between compiling the MOF and starting the
        lab configuration (as Lability will use those to create the VMs and can't read it from the
        MOF)
    #>
    $configurationData = Get-OftenOnLabConfiguration
    OftenOn -ConfigurationData $configurationData -OutputPath "$PSScriptRoot\..\MOF"

    $administrator = New-Object System.Management.Automation.PSCredential('Administrator', ('Admin2018!' | ConvertTo-SecureString -AsPlainText -Force))
    Start-LabConfiguration -ConfigurationData $configurationData -IgnorePendingReboot -Credential $administrator -NoSnapshot -Path "$PSScriptRoot\..\MOF"
}
